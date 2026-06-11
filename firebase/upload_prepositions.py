#!/usr/bin/env python3
"""Upload prepositions JSON files to Firebase Storage."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    from google.cloud import storage
    from google.oauth2 import service_account
except ImportError:
    print("Install dependency: pip3 install google-cloud-storage", file=sys.stderr)
    sys.exit(1)

DEFAULT_BUCKET = "prapode-bf274.firebasestorage.app"
DEFAULT_SA = Path(__file__).resolve().parent / "keys" / "prapode-sa.json"
DEFAULT_SOURCE = Path(__file__).resolve().parent / "prepositions" / "storage"
STORAGE_ROOT = "Präpositionen"
EXPLANATIONS_FOLDER = f"{STORAGE_ROOT}/Erklärung"


def upload_prepositions(
    source_dir: Path,
    bucket_name: str,
    service_account_path: Path,
) -> int:
    credentials = service_account.Credentials.from_service_account_file(
        str(service_account_path)
    )
    client = storage.Client(credentials=credentials, project=credentials.project_id)
    bucket = client.bucket(bucket_name)

    index_path = source_dir / "index.json"
    if not index_path.exists():
        print(f"Missing index.json in {source_dir}", file=sys.stderr)
        return 1

    uploaded = 0

    index_destination = f"{STORAGE_ROOT}/index.json"
    bucket.blob(index_destination).upload_from_filename(
        str(index_path), content_type="application/json"
    )
    print(f"uploaded gs://{bucket_name}/{index_destination}")
    uploaded += 1

    detail_files = sorted(
        path for path in source_dir.glob("*.json") if path.name != "index.json"
    )
    for file_path in detail_files:
        destination = f"{EXPLANATIONS_FOLDER}/{file_path.name}"
        bucket.blob(destination).upload_from_filename(
            str(file_path), content_type="application/json"
        )
        print(f"uploaded gs://{bucket_name}/{destination}")
        uploaded += 1

    print(f"Done: {uploaded} file(s)")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--bucket", default=DEFAULT_BUCKET)
    parser.add_argument("--service-account", type=Path, default=DEFAULT_SA)
    args = parser.parse_args()

    if not args.service_account.exists():
        print(f"Service account not found: {args.service_account}", file=sys.stderr)
        return 1

    if not args.source.exists():
        print(f"Source directory not found: {args.source}", file=sys.stderr)
        return 1

    return upload_prepositions(args.source, args.bucket, args.service_account)


if __name__ == "__main__":
    raise SystemExit(main())
