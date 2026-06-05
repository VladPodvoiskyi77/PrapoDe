#!/usr/bin/env python3
"""
Grant GA4 property access to the PrapoDe service account using YOUR Google account.

Use this when GA4 UI rejects the service account email.

One-time setup:
  gcloud auth application-default login \\
    --scopes=https://www.googleapis.com/auth/analytics.manage.users,https://www.googleapis.com/auth/cloud-platform

Then:
  python3 firebase/grant_sa_access.py --property-id 525311318
"""

from __future__ import annotations

import argparse
import json
import os
import sys

import requests
import google.auth
from google.auth.transport.requests import Request

API_BASE = "https://analyticsadmin.googleapis.com/v1alpha"
SCOPES = ["https://www.googleapis.com/auth/analytics.manage.users"]
DEFAULT_SA_EMAIL = "prapode-analytics-setup@prapode-bf274.iam.gserviceaccount.com"
DEFAULT_ROLE = "predefinedRoles/editor"


def load_user_credentials():
    try:
        credentials, _ = google.auth.default(scopes=SCOPES)
        credentials.refresh(Request())
        return credentials
    except google.auth.exceptions.DefaultCredentialsError:
        sys.exit(
            "No user credentials found.\n\n"
            "Run once (pick the Google account that is GA4 Administrator):\n\n"
            "  gcloud auth application-default login \\\n"
            "    --scopes=https://www.googleapis.com/auth/analytics.manage.users,"
            "https://www.googleapis.com/auth/cloud-platform\n\n"
            "Install gcloud if needed: https://cloud.google.com/sdk/docs/install"
        )


def normalize_property_id(raw: str) -> str:
    raw = raw.strip()
    if raw.startswith("properties/"):
        return raw.split("/", 1)[1]
    return raw


def grant_access(
    credentials,
    property_id: str,
    service_account_email: str,
    role: str,
    dry_run: bool,
) -> None:
    parent = f"properties/{property_id}"
    body = {
        "user": service_account_email,
        "roles": [role],
    }

    print(f"Property: {parent}")
    print(f"Service account: {service_account_email}")
    print(f"Role: {role}\n")

    if dry_run:
        print("[dry-run] would POST accessBindings:")
        print(json.dumps(body, indent=2))
        return

    url = f"{API_BASE}/{parent}/accessBindings"
    response = requests.post(
        url,
        headers={
            "Authorization": f"Bearer {credentials.token}",
            "Content-Type": "application/json",
        },
        json=body,
        timeout=30,
    )

    if response.status_code == 200:
        print("Success. Service account now has access to this GA4 property.")
        print(response.text)
        return

    if response.status_code == 409 or "ALREADY_EXISTS" in response.text:
        print("Service account already has access (or binding exists).")
        print(response.text)
        return

    sys.exit(f"Failed ({response.status_code}):\n{response.text}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Grant GA4 property access to the PrapoDe service account"
    )
    parser.add_argument(
        "--property-id",
        default=os.environ.get("GA4_PROPERTY_ID", "525311318"),
        help="Numeric GA4 property ID",
    )
    parser.add_argument(
        "--service-account",
        default=os.environ.get("GA4_SERVICE_ACCOUNT_EMAIL", DEFAULT_SA_EMAIL),
        help="Service account email to grant access",
    )
    parser.add_argument(
        "--role",
        default=DEFAULT_ROLE,
        help="GA4 predefined role (default: predefinedRoles/editor)",
    )
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    credentials = load_user_credentials()
    grant_access(
        credentials,
        normalize_property_id(args.property_id),
        args.service_account.strip(),
        args.role.strip(),
        args.dry_run,
    )


if __name__ == "__main__":
    main()
