#!/usr/bin/env bash
# gh-bootstrap.sh — initialize a directory as a git repo and (optionally) create/push a GitHub repo.
# Usage: gh-bootstrap.sh [PATH] [--owner OWNER] [--name NAME] [--persona PERSONA] [--symlink]
# - PATH: target directory (default: current directory)
# - OWNER: GitHub owner (default: gh auth user or inferred from origin)
# - NAME: repo name (default: basename of PATH)
# - PERSONA: persona to symlink under <persona>/repos/ (optional)
# - --symlink: create the symlink if persona provided
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR/.." rev-parse --show-toplevel)"

if ! command -v gh >/dev/null 2>&1; then
  echo "[Fail] GitHub CLI (gh) is required." >&2
  exit 1
fi

TARGET="${1:-$PWD}"
OWNER=""
NAME=""
PERSONA=""
DO_SYMLINK=0

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="${2:-}"; shift 2 ;;
    --name) NAME="${2:-}"; shift 2 ;;
    --persona) PERSONA="${2:-}"; shift 2 ;;
    --symlink) DO_SYMLINK=1; shift ;;
    *) echo "[Warn] Unknown arg $1" >&2; shift ;;
  esac
done

TARGET="$(cd "$TARGET" && pwd)"
[[ -n "$NAME" ]] || NAME="$(basename "$TARGET")"

# Detect owner
if [[ -z "$OWNER" ]]; then
  OWNER="$(gh auth status 2>/dev/null | awk '/github.com as/{print $NF; exit}')"
fi
if [[ -z "$OWNER" ]]; then
  origin_url="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)"
  if [[ "$origin_url" =~ github.com[:/]+([^/]+)/[^/]+(.git)?$ ]]; then
    OWNER="${BASH_REMATCH[1]}"
  fi
fi
if [[ -z "$OWNER" ]]; then
  echo "[Fail] Could not determine GitHub owner; use --owner" >&2
  exit 1
fi

echo "[Info] Target: $TARGET"
echo "[Info] Repo name: $NAME"
echo "[Info] GitHub owner: $OWNER"

mkdir -p "$TARGET"

# Ensure git repo
if git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[Info] Already a git repo."
else
  echo "[Info] Initializing git repo."
  git -C "$TARGET" init -q
fi

# Check remote
remote_url=$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)
if [[ -z "$remote_url" ]]; then
  read -rp "Create GitHub repo $OWNER/$NAME and push? [y/N]: " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    gh repo create "$OWNER/$NAME" --public --source "$TARGET" --remote origin --push
    echo "[Info] Created and pushed to https://github.com/$OWNER/$NAME"
  else
    echo "[Warn] Skipped remote creation."
  fi
else
  echo "[Info] Remote origin already set to $remote_url"
fi

# Symlink into persona if requested
if [[ -n "$PERSONA" && $DO_SYMLINK -eq 1 ]]; then
  link_dir="$REPO_ROOT/$PERSONA/repos"
  mkdir -p "$link_dir"
  ln -snf "$TARGET" "$link_dir/$NAME"
  echo "[Info] Symlinked $TARGET -> $link_dir/$NAME"
fi

echo "[Done] gh-bootstrap complete."
