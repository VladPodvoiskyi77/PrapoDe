#!/usr/bin/env python3
"""
Query GA4 stats for preposition guide / article views.

Usage:
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/firebase/keys/prapode-sa.json"
  export GA4_PROPERTY_ID="525311318"
  python3 firebase/query_prepositions_stats.py
  python3 firebase/query_prepositions_stats.py --days 7
  python3 firebase/query_prepositions_stats.py --days 1 --platform android
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    DateRange,
    Dimension,
    Filter,
    FilterExpression,
    Metric,
    RunReportRequest,
)

DEFAULT_PROPERTY_ID = "525311318"
DEFAULT_CREDENTIALS = Path(__file__).resolve().parent / "keys" / "prapode-sa.json"


def resolve_property_id() -> str:
    raw = os.environ.get("GA4_PROPERTY_ID", DEFAULT_PROPERTY_ID).strip()
    return raw.removeprefix("properties/")


def resolve_credentials() -> None:
    if os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        return
    if DEFAULT_CREDENTIALS.is_file():
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = str(DEFAULT_CREDENTIALS)


def platform_filter(platform: str | None) -> FilterExpression | None:
    if not platform:
        return None
    value = "Android" if platform.lower() == "android" else "iOS"
    return FilterExpression(
        filter=Filter(
            field_name="platform",
            string_filter=Filter.StringFilter(value=value),
        )
    )


def event_filter(event_name: str) -> FilterExpression:
    return FilterExpression(
        filter=Filter(
            field_name="eventName",
            string_filter=Filter.StringFilter(value=event_name),
        )
    )


def combine_filters(*parts: FilterExpression | None) -> FilterExpression | None:
    active = [p for p in parts if p is not None]
    if not active:
        return None
    if len(active) == 1:
        return active[0]
    return FilterExpression(and_group={"expressions": active})


def run_event_report(
    client: BetaAnalyticsDataClient,
    property_id: str,
    event_name: str,
    days: int,
    platform: str | None,
    extra_dimensions: list[str],
) -> list[dict[str, str]]:
    dimensions = [Dimension(name=name) for name in extra_dimensions]
    request = RunReportRequest(
        property=f"properties/{property_id}",
        date_ranges=[DateRange(start_date=f"{days}daysAgo", end_date="today")],
        dimensions=[Dimension(name="eventName"), *dimensions],
        metrics=[
            Metric(name="eventCount"),
            Metric(name="activeUsers"),
        ],
        dimension_filter=combine_filters(event_filter(event_name), platform_filter(platform)),
        limit=100,
    )
    response = client.run_report(request)
    rows: list[dict[str, str]] = []
    for row in response.rows:
        item = {
            header.name: row.dimension_values[index].value
            for index, header in enumerate(response.dimension_headers)
        }
        item["eventCount"] = row.metric_values[0].value
        item["activeUsers"] = row.metric_values[1].value
        rows.append(item)
    return rows


def print_section(title: str) -> None:
    print()
    print(title)
    print("-" * len(title))


def main() -> int:
    parser = argparse.ArgumentParser(description="PrapoDe preposition analytics report")
    parser.add_argument("--days", type=int, default=7, help="Lookback window (default: 7)")
    parser.add_argument(
        "--platform",
        choices=["android", "ios"],
        help="Optional platform filter",
    )
    args = parser.parse_args()

    resolve_credentials()
    property_id = resolve_property_id()

    try:
        client = BetaAnalyticsDataClient()
    except Exception as error:
        print(f"Failed to initialize GA4 client: {error}", file=sys.stderr)
        print("Check GOOGLE_APPLICATION_CREDENTIALS and Analytics Data API access.", file=sys.stderr)
        return 1

    print_section(f"PrapoDe prepositions analytics (last {args.days} days)")
    print(f"Property: properties/{property_id}")
    if args.platform:
        print(f"Platform: {args.platform}")

    guide_rows = run_event_report(
        client,
        property_id,
        "prepositions_guide_viewed",
        args.days,
        args.platform,
        [],
    )
    print_section("Guide opened (prepositions_guide_viewed)")
    if not guide_rows:
        print("No events.")
    else:
        for row in guide_rows:
            print(f"  events={row['eventCount']}  users={row['activeUsers']}")

    article_rows = run_event_report(
        client,
        property_id,
        "preposition_article_viewed",
        args.days,
        args.platform,
        ["customEvent:lemma", "customEvent:case_group", "customEvent:content_language"],
    )
    print_section("Articles viewed (preposition_article_viewed)")
    if not article_rows:
        print("No events.")
    else:
        print(f"{'lemma':<12} {'case':<10} {'lang':<6} {'events':>8} {'users':>8}")
        for row in sorted(
            article_rows,
            key=lambda item: int(item["eventCount"]),
            reverse=True,
        ):
            lemma = row.get("customEvent:lemma", "?")
            case_group = row.get("customEvent:case_group", "?")
            language = row.get("customEvent:content_language", "?")
            print(
                f"{lemma:<12} {case_group:<10} {language:<6} "
                f"{row['eventCount']:>8} {row['activeUsers']:>8}"
            )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
