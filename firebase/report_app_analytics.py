#!/usr/bin/env python3
"""Pull GA4 overview + last N new users from Firestore with activity stats."""

from __future__ import annotations

import argparse
import json
import os
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

import requests
from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    DateRange,
    Dimension,
    Filter,
    FilterExpression,
    Metric,
    RunReportRequest,
)
from google.auth.transport.requests import Request
from google.oauth2 import service_account

DEFAULT_PROPERTY_ID = "525311318"
DEFAULT_CREDENTIALS = Path(__file__).resolve().parent / "keys" / "prapode-sa.json"
FIRESTORE_URL = (
    "https://firestore.googleapis.com/v1/projects/prapode-bf274/databases/(default)/documents/users"
)
SCOPES = [
    "https://www.googleapis.com/auth/analytics.readonly",
    "https://www.googleapis.com/auth/datastore",
]


def load_credentials():
    key_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS", str(DEFAULT_CREDENTIALS))
    if not os.path.isfile(key_path):
        sys.exit(f"Missing credentials: {key_path}")
    creds = service_account.Credentials.from_service_account_file(key_path, scopes=SCOPES)
    creds.refresh(Request())
    return creds


def run_simple_report(client, property_id: str, days: int, dimensions: list[str], metrics: list[str], event_name: str | None = None, limit: int = 100):
    dim_objs = [Dimension(name=d) for d in dimensions]
    metric_objs = [Metric(name=m) for m in metrics]
    req = RunReportRequest(
        property=f"properties/{property_id}",
        date_ranges=[DateRange(start_date=f"{days}daysAgo", end_date="today")],
        dimensions=dim_objs,
        metrics=metric_objs,
        limit=limit,
    )
    if event_name:
        req.dimension_filter = FilterExpression(
            filter=Filter(
                field_name="eventName",
                string_filter=Filter.StringFilter(value=event_name),
            )
        )
    return client.run_report(req)


def metric_total(response, index: int = 0) -> int:
    if not response.rows:
        return 0
    return int(response.rows[0].metric_values[index].value)


def fetch_firestore_users(credentials, limit: int = 10) -> list[dict]:
    headers = {"Authorization": f"Bearer {credentials.token}"}
    users: list[dict] = []
    page_token = None

    while True:
        params = {"pageSize": 300}
        if page_token:
            params["pageToken"] = page_token
        resp = requests.get(FIRESTORE_URL, headers=headers, params=params, timeout=60)
        if resp.status_code != 200:
            raise RuntimeError(f"Firestore error {resp.status_code}: {resp.text[:500]}")
        data = resp.json()
        for doc in data.get("documents", []):
            fields = doc.get("fields", {})
            uid = doc["name"].split("/")[-1]
            created_raw = fields.get("createdAt", {})
            if "timestampValue" in created_raw:
                created_at = datetime.fromisoformat(created_raw["timestampValue"].replace("Z", "+00:00"))
            elif "integerValue" in created_raw:
                created_at = datetime.fromtimestamp(int(created_raw["integerValue"]) / 1000, tz=timezone.utc)
            else:
                created_at = datetime.min.replace(tzinfo=timezone.utc)
            users.append(
                {
                    "uid": uid,
                    "name": fields.get("name", {}).get("stringValue", "—"),
                    "country": fields.get("country", {}).get("stringValue", "—"),
                    "totalGamesPlayed": int(fields.get("totalGamesPlayed", {}).get("integerValue", "0")),
                    "bestSprintScore": int(fields.get("bestSprintScore", {}).get("integerValue", "0")),
                    "createdAt": created_at,
                }
            )
        page_token = data.get("nextPageToken")
        if not page_token:
            break

    users.sort(key=lambda u: u["createdAt"], reverse=True)
    return users[:limit]


def fetch_user_activity(client, property_id: str, days: int, user_ids: list[str]) -> dict[str, dict]:
    if not user_ids:
        return {}

    activity: dict[str, dict] = defaultdict(lambda: {
        "sessions": 0,
        "quiz_started": 0,
        "quiz_finished": 0,
        "sprint_started": 0,
        "sprint_finished": 0,
        "training_started": 0,
        "training_finished": 0,
        "writing_started": 0,
        "writing_finished": 0,
        "prepositions_guide": 0,
        "last_seen": "—",
    })

    event_names = [
        "quiz_started", "quiz_finished",
        "sprint_started", "sprint_finished",
        "training_started", "training_finished",
        "writing_started", "writing_finished",
        "prepositions_guide_viewed",
    ]

    for event in event_names:
        req = RunReportRequest(
            property=f"properties/{property_id}",
            date_ranges=[DateRange(start_date=f"{days}daysAgo", end_date="today")],
            dimensions=[Dimension(name="customUser:user_id"), Dimension(name="date")],
            metrics=[Metric(name="eventCount")],
            dimension_filter=FilterExpression(
                filter=Filter(
                    field_name="eventName",
                    string_filter=Filter.StringFilter(value=event),
                )
            ),
            limit=10000,
        )
        try:
            resp = client.run_report(req)
        except Exception:
            continue
        for row in resp.rows:
            uid = row.dimension_values[0].value
            if uid not in user_ids:
                continue
            count = int(row.metric_values[0].value)
            date = row.dimension_values[1].value
            key = event.replace("_viewed", "_guide") if event == "prepositions_guide_viewed" else event
            if key.endswith("_started") or key.endswith("_finished"):
                activity[uid][key] += count
            elif event == "prepositions_guide_viewed":
                activity[uid]["prepositions_guide"] += count
            if date > activity[uid]["last_seen"]:
                activity[uid]["last_seen"] = date

    # sessions by user
    req = RunReportRequest(
        property=f"properties/{property_id}",
        date_ranges=[DateRange(start_date=f"{days}daysAgo", end_date="today")],
        dimensions=[Dimension(name="customUser:user_id")],
        metrics=[Metric(name="sessions")],
        limit=10000,
    )
    try:
        resp = client.run_report(req)
        for row in resp.rows:
            uid = row.dimension_values[0].value
            if uid in user_ids:
                activity[uid]["sessions"] = int(row.metric_values[0].value)
    except Exception:
        pass

    return dict(activity)


def print_overview(client, property_id: str, days: int):
    print(f"\n{'='*60}")
    print(f"  PrapoDe — GA4 overview (last {days} days)")
    print(f"{'='*60}\n")

    overview = run_simple_report(
        client, property_id, days,
        dimensions=[],
        metrics=["activeUsers", "newUsers", "sessions", "eventCount", "averageSessionDuration"],
    )
    if overview.rows:
        m = overview.rows[0].metric_values
        print(f"  Active users:     {m[0].value}")
        print(f"  New users:        {m[1].value}")
        print(f"  Sessions:         {m[2].value}")
        print(f"  Total events:     {m[3].value}")
        avg_sec = float(m[4].value)
        print(f"  Avg session:      {avg_sec/60:.1f} min")

    print("\n  By platform:")
    platform = run_simple_report(
        client, property_id, days,
        dimensions=["platform"],
        metrics=["activeUsers", "sessions"],
        limit=10,
    )
    for row in platform.rows:
        print(f"    {row.dimension_values[0].value:8}  users={row.metric_values[0].value:>4}  sessions={row.metric_values[1].value}")

    print("\n  Activity modes (started / finished):")
    for mode in ("quiz", "sprint", "training", "writing"):
        started = run_simple_report(client, property_id, days, [], ["eventCount"], event_name=f"{mode}_started")
        finished = run_simple_report(client, property_id, days, [], ["eventCount"], event_name=f"{mode}_finished")
        s = metric_total(started)
        f = metric_total(finished)
        rate = f"{100*f/s:.0f}%" if s else "—"
        print(f"    {mode:10}  started={s:>4}  finished={f:>4}  completion={rate}")

    print("\n  Prepositions guide:")
    guide = run_simple_report(client, property_id, days, [], ["eventCount", "activeUsers"], event_name="prepositions_guide_viewed")
    article = run_simple_report(client, property_id, days, [], ["eventCount"], event_name="preposition_article_viewed")
    print(f"    guide opens:    {metric_total(guide)}")
    print(f"    guide users:    {metric_total(guide, 1)}")
    print(f"    article views:  {metric_total(article)}")

    print("\n  Top wrong words (quiz):")
    wrong = run_simple_report(
        client, property_id, days,
        dimensions=["customEvent:wordWithPrap"],
        metrics=["eventCount"],
        event_name="quiz_error",
        limit=8,
    )
    for row in wrong.rows:
        print(f"    {row.dimension_values[0].value:30}  {row.metric_values[0].value}x")

    print("\n  Onboarding:")
    setup_started = run_simple_report(client, property_id, days, [], ["eventCount"], event_name="profile_setup_started")
    setup_done = run_simple_report(client, property_id, days, [], ["eventCount"], event_name="profile_setup_completed")
    print(f"    profile started:   {metric_total(setup_started)}")
    print(f"    profile completed: {metric_total(setup_done)}")

    countries = run_simple_report(
        client, property_id, days,
        dimensions=["customEvent:country_code"],
        metrics=["eventCount"],
        event_name="profile_setup_completed",
        limit=10,
    )
    if countries.rows:
        print("    countries (onboarding):")
        for row in countries.rows:
            code = row.dimension_values[0].value or "(not set)"
            print(f"      {code:6}  {row.metric_values[0].value}")


def print_new_users(client, property_id: str, credentials, days: int, limit: int):
    print(f"\n{'='*60}")
    print(f"  Last {limit} new users (Firestore profiles)")
    print(f"{'='*60}\n")

    users = fetch_firestore_users(credentials, limit=limit)
    uids = [u["uid"] for u in users]
    activity = fetch_user_activity(client, property_id, days, uids)

    for i, u in enumerate(users, 1):
        act = activity.get(u["uid"], {})
        created = u["createdAt"].strftime("%Y-%m-%d %H:%M UTC")
        games_fs = u["totalGamesPlayed"]
        quiz_f = act.get("quiz_finished", 0)
        sprint_f = act.get("sprint_finished", 0)
        train_f = act.get("training_finished", 0)
        writing_f = act.get("writing_finished", 0)
        total_finished = quiz_f + sprint_f + train_f + writing_f
        sessions = act.get("sessions", 0)

        print(f"  {i}. {u['name']}  ({u['country']})")
        print(f"     UID: {u['uid'][:12]}…")
        print(f"     Registered: {created}")
        print(f"     Firestore totalGamesPlayed: {games_fs}")
        print(f"     GA4 sessions ({days}d): {sessions}")
        print(f"     Finished — quiz: {quiz_f}, sprint: {sprint_f}, training: {train_f}, writing: {writing_f}  (total: {total_finished})")
        if act.get("prepositions_guide"):
            print(f"     Prepositions guide opens: {act['prepositions_guide']}")
        last_seen = act.get("last_seen")
        if last_seen and last_seen != "—":
            print(f"     Last activity: {last_seen}")
        print()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--days", type=int, default=7)
    parser.add_argument("--new-users", type=int, default=10)
    args = parser.parse_args()

    property_id = os.environ.get("GA4_PROPERTY_ID", DEFAULT_PROPERTY_ID).removeprefix("properties/")
    credentials = load_credentials()
    os.environ.setdefault("GOOGLE_APPLICATION_CREDENTIALS", str(DEFAULT_CREDENTIALS))
    client = BetaAnalyticsDataClient()

    print_overview(client, property_id, args.days)
    print_new_users(client, property_id, credentials, args.days, args.new_users)


if __name__ == "__main__":
    main()
