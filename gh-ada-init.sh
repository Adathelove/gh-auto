#!/usr/bin/env bash
# gh-ada-init.sh — ensure ~/repos/git/adathelove/gh-auto exists and matches current clone.
# If target missing, clone from GitHub; if already present, report status.
set -euo pipefail

OWNER="Adathelove"
TARGET_ROOT="$HOME/repos/git/$OWNER"
TARGET_REPO="$TARGET_ROOT/gh-auto"
REPO_URL="https://github.com/$OWNER/gh-auto.git"

mkdir -p "$TARGET_ROOT"

current_root=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  current_root="$(git rev-parse --show-toplevel)"
fi

if [[ -d "$TARGET_REPO/.git" ]]; then
  echo "[Info] Target exists: $TARGET_REPO"
  echo "[Info] Remote: $(git -C "$TARGET_REPO" remote get-url origin)"
  git -C "$TARGET_REPO" status --short
  if [[ -n "$current_root" && "$current_root" != "$TARGET_REPO" ]]; then
    echo "[Warn] You are running from $current_root; target already exists."
  fi
  exit 0
fi

echo "[Info] Target missing: $TARGET_REPO"
if [[ -n "$current_root" ]]; then
  echo "Current repo: $current_root"
  echo "Remote: $(git -C "$current_root" remote get-url origin 2>/dev/null || echo 'none')"
fi
read -rp "Clone fresh to $TARGET_REPO? [y/N]: " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  git clone "$REPO_URL" "$TARGET_REPO"
  echo "[Info] Cloned $REPO_URL -> $TARGET_REPO"
else
  if [[ -n "$current_root" ]]; then
    read -rp "Move current repo contents into target? [y/N]: " move_ans
    if [[ "$move_ans" =~ ^[Yy]$ ]]; then
      mkdir -p "$TARGET_REPO"
      rsync -a --delete "$current_root"/ "$TARGET_REPO"/
      echo "[Info] Copied working tree into $TARGET_REPO (original left in place)"
    else
      echo "[Warn] Nothing done."
    fi
  else
    echo "[Warn] Nothing done."
  fi
fi
