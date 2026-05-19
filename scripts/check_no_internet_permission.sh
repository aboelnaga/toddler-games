#!/usr/bin/env bash
# Fails if any production-flavor Android manifest declares
# android.permission.INTERNET *without* tools:node="remove".
#
# Allowed: <uses-permission android:name="android.permission.INTERNET" tools:node="remove"/>
# Forbidden: <uses-permission android:name="android.permission.INTERNET"/>

set -euo pipefail

# Check all production-flavor manifests (and main if no production override exists).
MANIFESTS=()
if [[ -f android/app/src/production/AndroidManifest.xml ]]; then
  MANIFESTS+=("android/app/src/production/AndroidManifest.xml")
fi
MANIFESTS+=("android/app/src/main/AndroidManifest.xml")

VIOLATIONS=()
for m in "${MANIFESTS[@]}"; do
  if [[ ! -f "$m" ]]; then
    continue
  fi
  # Look for the INTERNET permission line that does NOT contain tools:node="remove"
  if grep -E 'android.permission.INTERNET' "$m" | grep -v 'tools:node="remove"' > /dev/null 2>&1; then
    VIOLATIONS+=("$m")
  fi
done

if [[ ${#VIOLATIONS[@]} -gt 0 ]]; then
  echo "Compliance check FAILED. INTERNET permission detected in production manifest(s):"
  for v in "${VIOLATIONS[@]}"; do
    echo "  - $v"
  done
  echo ""
  echo "The release flavor must not declare INTERNET. The app is offline."
  echo "If you need INTERNET in debug for hot reload, declare it only in"
  echo "android/app/src/debug/AndroidManifest.xml."
  exit 1
fi

echo "OK: no INTERNET permission detected in production manifests."
exit 0
