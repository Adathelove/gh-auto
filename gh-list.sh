#!/usr/bin/env bash
# gh-list.sh — list GitHub repos for an owner and clone/pull via fzf.
# Usage: gh-list.sh [--owner OWNER]
# Owner defaults to "Adathelove" but can be overridden with --owner
set -euo pipefail

owner="Adathelove"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) owner="${2:-}"; shift 2;;
    *) echo "[Warn] Unknown arg $1" >&2; shift;;
  esac
done

echo "[Info] Using owner: $owner"

# Fetch list
if ! command -v fzf >/dev/null 2>&1; then
  echo "[Fail] fzf is required." >&2; exit 1
fi
list=$(gh repo list "$owner" --limit 200 --json name,visibility,url,description --jq '.[] | "\(.name)\t\(.visibility)\t\(.url)\t\(.description // "")"')
if [[ -z "$list" ]]; then
  echo "[Warn] No repos returned for $owner"; exit 0
fi
choice=$(printf '%s
' "$list" | fzf --with-nth=1 --prompt="repo> " --header="Select repo to clone/pull") || exit 0
repo=$(printf '%s' "$choice" | awk -F'\t' '{print $1}')
url=$(printf '%s' "$choice" | awk -F'\t' '{print $3}')

dest_root="$HOME/repos/git/$owner"
mkdir -p "$dest_root"
dest="$dest_root/$repo"
if [[ -d "$dest/.git" ]]; then
  echo "[Info] Repo exists; pulling latest..."
  git -C "$dest" pull --ff-only
else
  echo "[Info] Cloning $owner/$repo -> $dest"
  gh repo clone "$owner/$repo" "$dest"
fi

echo "[Done] $repo at $dest"
