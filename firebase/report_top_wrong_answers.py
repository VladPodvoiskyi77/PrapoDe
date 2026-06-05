#!/usr/bin/env python3
"""
Top wrong-answer words from GA4 (*_error events) for PrapoDe.

Requires:
  - Analytics Data API enabled on project prapode-bf274
  - Service account with Editor on GA4 property

Usage:
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/firebase/keys/prapode-sa.json"
  export GA4_PROPERTY_ID="525311318"
  python3 firebase/report_top_wrong_answers.py
  python3 firebase/report_top_wrong_answers.py --days 5 --limit 20
"""

from __future__ import annotations

import argparse
import os
import sys
from collections import defaultdict

import requests
from google.auth.transport.requests import Request
from google.oauth2 import service_account

API_URL = "https://analyticsdata.googleapis.com/v1beta/properties/{property_id}:runReport"
SCOPES = ["https://www.googleapis.com/auth/analytics.readonly"]
ERROR_EVENTS = ("quiz_error", "sprint_error", "writing_error")
ENABLE_API_URL = (
    "https://console.cloud.google.com/apis/library/analyticsdata.googleapis.com"
    "?project=prapode-bf274"
)


def load_credentials():
    key_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not key_path or not os.path.isfile(key_path):
        sys.exit("Set GOOGLE_APPLICATION_CREDENTIALS to firebase/keys/prapode-sa.json")
    credentials = service_account.Credentials.from_service_account_file(key_path, scopes=SCOPES)
    credentials.refresh(Request())
    return credentials


def run_report(property_id: str, days: int, limit: int, credentials) -> dict:
    body = {
        "dateRanges": [{"startDate": f"{days}daysAgo", "endDate": "today"}],
        "dimensions": [
            {"name": "customEvent:wordWithPrap"},
            {"name": "eventName"},
        ],
        "metrics": [{"name": "eventCount"}],
        "dimensionFilter": {
            "orGroup": {
                "expressions": [
                    {
                        "filter": {
                            "fieldName": "eventName",
                            "stringFilter": {"matchType": "EXACT", "value": name},
                        }
                    }
                    for name in ERROR_EVENTS
                ]
            }
        },
        "orderBys": [{"metric": {"metricName": "eventCount"}, "desc": True}],
        "limit": 500,
    }

    url = API_URL.format(property_id=property_id)
    response = requests.post(
        url,
        headers={
            "Authorization": f"Bearer {credentials.token}",
            "Content-Type": "application/json",
        },
        json=body,
        timeout=60,
    )

    if response.status_code == 403 and "SERVICE_DISABLED" in response.text:
        sys.exit(
            f"Analytics Data API is not enabled.\n"
            f"Enable it here (one click), wait 1–2 min, retry:\n  {ENABLE_API_URL}"
        )

    if response.status_code != 200:
        sys.exit(f"Report failed ({response.status_code}):\n{response.text}")

    return response.json()


def aggregate_rows(payload: dict, limit: int) -> list[tuple[str, int, dict[str, int]]]:
    totals: dict[str, int] = defaultdict(int)
    by_mode: dict[str, dict[str, int]] = defaultdict(lambda: defaultdict(int))

    for row in payload.get("rows", []):
        dims = row.get("dimensionValues", [])
        metric = int(row.get("metricValues", [{}])[0].get("value", "0"))
        word = dims[0].get("value", "(not set)")
        event = dims[1].get("value", "?")
        if word in ("(not set)", ""):
            continue
        totals[word] += metric
        by_mode[word][event] += metric

    ranked = sorted(totals.items(), key=lambda item: item[1], reverse=True)[:limit]
    return [(word, count, dict(by_mode[word])) for word, count in ranked]


def print_report(days: int, ranked: list[tuple[str, int, dict[str, int]]]) -> None:
    if not ranked:
        print(f"No *_error events with wordWithPrap in the last {days} days.")
        print("Check DebugView after playing Quiz / Sprint / Writing.")
        return

    print(f"Top wrong answers — last {days} days (quiz + sprint + writing)\n")
    print(f"{'#':>3}  {'Word':<40}  {'Errors':>7}  Breakdown")
    print("-" * 72)
    for index, (word, count, modes) in enumerate(ranked, start=1):
        breakdown = ", ".join(f"{k.replace('_error', '')}:{v}" for k, v in sorted(modes.items()))
        print(f"{index:>3}  {word:<40}  {count:>7}  {breakdown}")
    print("-" * 72)
    print(f"Total listed errors: {sum(c for _, c, _ in ranked)}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Top wrong-answer words from GA4")
    parser.add_argument("--days", type=int, default=5, help="Lookback window (default: 5)")
    parser.add_argument("--limit", type=int, default=20, help="Top N words (default: 20)")
    parser.add_argument("--property-id", default=os.environ.get("GA4_PROPERTY_ID", "525311318"))
    args = parser.parse_args()

    credentials = load_credentials()
    payload = run_report(args.property_id, args.days, args.limit, credentials)
    ranked = aggregate_rows(payload, args.limit)
    print_report(args.days, ranked)


if __name__ == "__main__":
    main()
