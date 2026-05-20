#!/usr/bin/env bash
# Runs the Flutter macOS app with automatic hot reload on lib/ changes.
# Usage: bash scripts/dev_run.sh

FIFO=/tmp/flutter_hot_reload_$$
SENTINEL=/tmp/flutter_sentinel_$$
FLUTTER_PID=""
WATCHER_PID=""

cleanup() {
  exec 3>&- 2>/dev/null || true
  rm -f "$FIFO" "$SENTINEL"
  [ -n "$FLUTTER_PID" ] && kill "$FLUTTER_PID" 2>/dev/null || true
  [ -n "$WATCHER_PID" ] && kill "$WATCHER_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

touch "$SENTINEL"
mkfifo "$FIFO"

echo "[dev_run] Starting flutter run on macOS..."
flutter run -d macos --flavor development -t lib/main_development.dart < "$FIFO" &
FLUTTER_PID=$!

# Open write end so flutter's stdin never gets EOF
exec 3>"$FIFO"

# Let flutter start before we begin watching
sleep 5

echo "[dev_run] Watching lib/ for changes (polls every 1s)..."

(
  while kill -0 "$FLUTTER_PID" 2>/dev/null; do
    changed=$(find lib/ -name "*.dart" -newer "$SENTINEL" 2>/dev/null)
    if [ -n "$changed" ]; then
      touch "$SENTINEL"
      echo "[dev_run] Change detected — hot reload"
      printf "r" >&3
    fi
    sleep 1
  done
) &
WATCHER_PID=$!

wait "$FLUTTER_PID"
echo "[dev_run] Flutter exited."
