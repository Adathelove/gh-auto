#!/usr/bin/env bash
# repos-locate-refresh.sh
# Update macOS locate database so repo paths are searchable.
# Requires sudo for /usr/libexec/locate.updatedb.

set -euo pipefail

echo "This will start the macOS locate service (launchctl) and run /usr/libexec/locate.updatedb (sudo)."
read -rp "Type YES to proceed: " confirm
if [[ "$confirm" != "YES" ]]; then
  echo "Aborted."
  exit 1
fi

# Ensure locate daemon is started
if launchctl list | grep -q "com.apple.locate"; then
  echo "[Info] locate daemon already loaded."
else
  echo "[Info] loading locate daemon..."
  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist || true
fi

echo "[Info] updating locate database (this may take a while)..."
sudo /usr/libexec/locate.updatedb
echo "[Done] locate database refreshed."
