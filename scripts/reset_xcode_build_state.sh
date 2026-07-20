#!/bin/bash
# Resets stuck Xcode PIF / dependency graph state for PrapoDe iOS project.
# Error fixed: "unable to initiate PIF transfer session (operation in progress?)"
set -euo pipefail

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_NAME="Learning_prepositions_is_easy"
WORKSPACE="$PROJECT_ROOT/${PROJECT_NAME}.xcworkspace"
SCHEME="$PROJECT_NAME"

echo "==> Stopping Xcode build services..."
killall Xcode SWBBuildService XCBBuildService xcodebuild SourceKitService 2>/dev/null || true
sleep 2

echo "==> Clearing DerivedData for ${PROJECT_NAME}..."
rm -rf "${HOME}/Library/Developer/Xcode/DerivedData/${PROJECT_NAME}-"*
rm -rf "${PROJECT_ROOT}/.derivedData"

echo "==> Clearing stale workspace build state..."
find "${PROJECT_ROOT}" -name "IDEWorkspaceChecks.plist" -path "*/xcuserdata/*" -delete 2>/dev/null || true

cd "${PROJECT_ROOT}"

if command -v pod >/dev/null 2>&1; then
  echo "==> Running pod install..."
  if ! pod install; then
    echo "WARNING: pod install failed. Continue if Pods/ is already up to date."
  fi
else
  echo "==> Skipping pod install (CocoaPods not in PATH)"
fi

if [[ "${SKIP_BUILD_VERIFY:-0}" != "1" ]]; then
  echo "==> Verifying command-line build (set SKIP_BUILD_VERIFY=1 to skip)..."
  xcodebuild \
    -workspace "${WORKSPACE}" \
    -scheme "${SCHEME}" \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "${PROJECT_ROOT}/.derivedData" \
    build \
    | tail -5
fi

echo ""
echo "Done. Open ${WORKSPACE} (not .xcodeproj) and build again."
