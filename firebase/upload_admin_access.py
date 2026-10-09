#!/usr/bin/env python3
"""Upload functions/admin-access.json to Firestore admin/access."""

from pathlib import Path
import json
import sys

from google.cloud import firestore

ROOT = Path(__file__).resolve().parents[1]
KEY = ROOT / "firebase" / "keys" / "prapode-sa.json"
SOURCE = ROOT / "functions" / "admin-access.json"
FIELDS = (
    "enabled",
    "passcode",
    "alertEmail",
    "telegramBotToken",
    "telegramChatId",
    "resendApiKey",
    "alertWebhook",
)


def main() -> int:
    data = json.loads(SOURCE.read_text(encoding="utf-8"))
    payload = {key: data.get(key, "") if key != "enabled" else bool(data.get("enabled", True)) for key in FIELDS}
    payload["passcode"] = str(payload["passcode"])
    db = firestore.Client.from_service_account_json(str(KEY))
    db.document("admin/access").set(payload, merge=True)
    print("Uploaded admin/access")
    print(f"enabled={payload['enabled']} passcode={payload['passcode']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
