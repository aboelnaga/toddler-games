#!/usr/bin/env bash
# Fails if pubspec.lock contains any forbidden third-party SDK that violates
# our zero-data-collection compliance posture.
#
# See: docs/superpowers/specs/2026-05-11-toddler-mini-games-design.md §6
# and CLAUDE.md "Hard invariants".

set -euo pipefail

FORBIDDEN_PATTERNS=(
  "firebase_"
  "sentry"
  "mixpanel"
  "amplitude"
  "facebook_"
  "appsflyer"
  "branch_io"
  "onesignal"
)

LOCKFILE="pubspec.lock"
if [[ ! -f "$LOCKFILE" ]]; then
  echo "ERROR: $LOCKFILE not found. Run flutter pub get first."
  exit 2
fi

FOUND=()
for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  if grep -i -E "^[[:space:]]+${pattern}" "$LOCKFILE" > /dev/null 2>&1; then
    matches=$(grep -i -E "^[[:space:]]+${pattern}" "$LOCKFILE" || true)
    FOUND+=("$pattern: $matches")
  fi
done

if [[ ${#FOUND[@]} -gt 0 ]]; then
  echo "Compliance check FAILED. Forbidden SDK(s) detected in $LOCKFILE:"
  for entry in "${FOUND[@]}"; do
    echo "  - $entry"
  done
  echo ""
  echo "This app's compliance posture is zero data collection."
  echo "Adding any of these SDKs requires explicit user approval and a"
  echo "memo updating the design spec. See CLAUDE.md."
  exit 1
fi

echo "OK: no forbidden SDKs detected in $LOCKFILE."
exit 0
