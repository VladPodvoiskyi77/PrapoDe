#!/usr/bin/env python3
"""
Register GA4 custom dimensions for PrapoDe via Google Analytics Admin API.

Usage:
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/firebase/keys/prapode-sa.json"
  export GA4_PROPERTY_ID="123456789"   # numeric ID from --discover
  python3 firebase/setup_custom_dimensions.py

  python3 firebase/setup_custom_dimensions.py --discover
  python3 firebase/setup_custom_dimensions.py --dry-run
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import dataclass
from typing import Literal, Optional, Set

import requests
from google.auth.transport.requests import Request
from google.oauth2 import service_account

API_BASE = "https://analyticsadmin.googleapis.com/v1beta"
SCOPES = ["https://www.googleapis.com/auth/analytics.edit"]
FIREBASE_PROJECT_ID = "prapode-bf274"

Scope = Literal["EVENT", "USER"]


@dataclass(frozen=True)
class DimensionDef:
    parameter_name: str
    display_name: str
    scope: Scope
    description: str = ""


DIMENSIONS = [
    DimensionDef("category", "Study category", "EVENT", "Word category (Verben, Adjektive, Nomen)"),
    DimensionDef("level", "Study level", "EVENT", "CEFR level A1–C1"),
    DimensionDef("accuracy", "Session accuracy", "EVENT", "score / total_questions"),
    DimensionDef("score", "Session score", "EVENT", "Correct answers in session"),
    DimensionDef("total_questions", "Total questions", "EVENT", "Questions in session"),
    DimensionDef("questions_answered", "Questions answered", "EVENT", "Answered before abandon"),
    DimensionDef("wordWithPrap", "Word with preposition", "EVENT", "German word for error analytics"),
    DimensionDef("user_answer", "User answer", "EVENT", "What the user selected or typed"),
    DimensionDef("country_code", "Country code", "EVENT", "Onboarding country"),
    DimensionDef("status", "Toggle status", "EVENT", "Widget word enabled/disabled"),
    DimensionDef("enabled_count", "Widget enabled words", "EVENT", "Words shown in widget"),
    DimensionDef("total_count", "Widget total words", "EVENT", "Words available for widget"),
    DimensionDef("widget_count", "Installed widgets", "EVENT", "Home screen widget instances"),
    DimensionDef("family", "Widget size family", "EVENT", "small / medium / large"),
    DimensionDef("refresh_count", "Widget refresh count", "EVENT", "Batched timeline refreshes"),
    DimensionDef("entry_count", "Widget entry count", "EVENT", "Timeline entries generated"),
    DimensionDef("previous_count", "Previous widget count", "EVENT", "Count before widget removal"),
    DimensionDef("preposition_id", "Preposition ID", "EVENT", "Article id (fur, in, …)"),
    DimensionDef("lemma", "Preposition lemma", "EVENT", "German preposition (für, in, …)"),
    DimensionDef("case_group", "Preposition case group", "EVENT", "dativ / akkusativ / genitiv / wechsel"),
    DimensionDef("content_language", "Content language", "EVENT", "Article UI language ru / ua / en"),
    DimensionDef("source", "Article source", "EVENT", "menu / quiz / review / training"),
    DimensionDef("preposition_count", "Preposition count", "EVENT", "Items in prepositions guide"),
    DimensionDef("nickname", "Nickname", "USER", "Display name from profile"),
    DimensionDef("current_study_level", "Current study level", "USER", "Selected CEFR level"),
    DimensionDef("has_widget_installed", "Widget installed", "USER", "true / false"),
    DimensionDef("widget_enabled_words", "Widget enabled words", "USER", "Count of words enabled for widget"),
]


def load_credentials() -> service_account.Credentials:
    key_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not key_path:
        sys.exit(
            "Missing GOOGLE_APPLICATION_CREDENTIALS.\n"
            "Example:\n"
            '  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/firebase/keys/prapode-sa.json"'
        )
    if not os.path.isfile(key_path):
        sys.exit(f"Credentials file not found: {key_path}")

    credentials = service_account.Credentials.from_service_account_file(key_path, scopes=SCOPES)
    credentials.refresh(Request())
    return credentials


def auth_headers(credentials: service_account.Credentials) -> dict[str, str]:
    return {
        "Authorization": f"Bearer {credentials.token}",
        "Content-Type": "application/json",
    }


def discover_properties(credentials: service_account.Credentials) -> None:
    url = f"{API_BASE}/accountSummaries"
    response = requests.get(url, headers=auth_headers(credentials), timeout=30)
    if response.status_code != 200:
        sys.exit(f"Failed to list properties ({response.status_code}):\n{response.text}")

    data = response.json()
    summaries = data.get("accountSummaries", [])
    if not summaries:
        print("No GA4 properties found for this service account.")
        print("Add the service account email to GA4 → Admin → Property access management.")
        return

    print(f"Firebase / GCP project hint: {FIREBASE_PROJECT_ID}\n")
    print("Available GA4 properties:\n")
    for account in summaries:
        account_name = account.get("displayName", account.get("account", "?"))
        print(f"Account: {account_name}")
        for prop in account.get("propertySummaries", []):
            raw_id = prop.get("property", "")
            numeric_id = raw_id.replace("properties/", "")
            print(f"  - {prop.get('displayName', numeric_id)}")
            print(f"    GA4_PROPERTY_ID={numeric_id}")
            print(f"    resource: {raw_id}")
        print()


def normalize_property_id(raw: str) -> str:
    raw = raw.strip()
    if raw.startswith("properties/"):
        return raw.split("/", 1)[1]
    return raw


def validate_property_id(raw: str) -> str:
    property_id = normalize_property_id(raw)
    placeholders = {"YOUR_NUMERIC_ID", "123456789", "YOUR_ID", "REPLACE_ME"}
    if property_id in placeholders:
        sys.exit(
            f"Invalid GA4_PROPERTY_ID={raw!r} — this is a placeholder, not a real property ID.\n"
            "Run discovery first:\n"
            "  python3 firebase/setup_custom_dimensions.py --discover\n"
            "Then export the numeric ID, e.g.:\n"
            '  export GA4_PROPERTY_ID="525311318"'
        )
    if not property_id.isdigit():
        sys.exit(
            f"Invalid GA4_PROPERTY_ID={raw!r} — expected a numeric ID like 525311318.\n"
            "Run: python3 firebase/setup_custom_dimensions.py --discover"
        )
    return property_id


def list_existing_dimensions(credentials: service_account.Credentials, property_id: str) -> Set[str]:
    url = f"{API_BASE}/properties/{property_id}/customDimensions"
    existing: Set[str] = set()
    page_token: Optional[str] = None

    while True:
        params = {"pageSize": 200}
        if page_token:
            params["pageToken"] = page_token

        response = requests.get(url, headers=auth_headers(credentials), params=params, timeout=30)
        if response.status_code != 200:
            sys.exit(f"Failed to list custom dimensions ({response.status_code}):\n{response.text}")

        payload = response.json()
        for item in payload.get("customDimensions", []):
            key = f"{item.get('scope')}:{item.get('parameterName')}"
            existing.add(key)
        page_token = payload.get("nextPageToken")
        if not page_token:
            break

    return existing


def create_dimension(
    credentials: service_account.Credentials,
    property_id: str,
    definition: DimensionDef,
    dry_run: bool,
) -> str:
    body = {
        "parameterName": definition.parameter_name,
        "displayName": definition.display_name,
        "scope": definition.scope,
        "description": definition.description,
    }

    if dry_run:
        return f"[dry-run] would create {definition.scope}:{definition.parameter_name}"

    url = f"{API_BASE}/properties/{property_id}/customDimensions"
    response = requests.post(url, headers=auth_headers(credentials), json=body, timeout=30)

    if response.status_code == 200:
        return f"created {definition.scope}:{definition.parameter_name}"

    if response.status_code == 409 or "ALREADY_EXISTS" in response.text:
        return f"exists  {definition.scope}:{definition.parameter_name}"

    return (
        f"FAILED  {definition.scope}:{definition.parameter_name} "
        f"({response.status_code}): {response.text}"
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Register GA4 custom dimensions for PrapoDe")
    parser.add_argument("--discover", action="store_true", help="List GA4 property IDs")
    parser.add_argument("--dry-run", action="store_true", help="Print actions without API writes")
    parser.add_argument("--property-id", default=os.environ.get("GA4_PROPERTY_ID"), help="Numeric GA4 property ID")
    args = parser.parse_args()

    credentials = load_credentials()

    if args.discover:
        discover_properties(credentials)
        return

    if not args.property_id:
        sys.exit(
            "Missing GA4 property ID.\n"
            "Run discovery first:\n"
            "  python3 firebase/setup_custom_dimensions.py --discover\n"
            "Then:\n"
            '  export GA4_PROPERTY_ID="525311318"'
        )

    property_id = validate_property_id(args.property_id)
    existing = list_existing_dimensions(credentials, property_id)

    print(f"Property: properties/{property_id}")
    print(f"Existing custom dimensions loaded: {len(existing)}\n")

    for definition in DIMENSIONS:
        key = f"{definition.scope}:{definition.parameter_name}"
        if key in existing:
            print(f"skip    {definition.scope}:{definition.parameter_name} (already registered)")
            continue
        result = create_dimension(credentials, property_id, definition, args.dry_run)
        print(result)

    print("\nDone. New data in GA4 reports may take 24–48 hours to appear.")


if __name__ == "__main__":
    main()
