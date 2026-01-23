#!/usr/bin/env bash
# repo-register.sh
# Add a symlink for a local repo into the registry (default: ~/repos/git/adathelove/<name>).
# Usage: repo-register.sh [PATH_TO_REPO]

set -euo pipefail

target="${1:-$PWD}"
target="$(cd "$target" && pwd)"

if [[ ! -d "$target/.git" ]]; then
  echo "[Fail] $target is not a git repo (missing .git)" >&2
  exit 1
fi

name="$(basename "$target")"
registry_base="${REPO_REGISTRY:-$HOME/repos/git/adathelove}"
mkdir -p "$registry_base"
reg_link="$registry_base/$name"

if [[ -e "$reg_link" && ! -L "$reg_link" ]]; then
  echo "[Fail] Registry entry exists and is not a symlink: $reg_link" >&2
  exit 1
fi

ln -snf "$target" "$reg_link"
echo "[Done] Registered $name -> $target at $reg_link"
