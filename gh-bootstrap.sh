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
# Allow override; otherwise try git root of this script; fallback to script dir.
REPO_ROOT="${REPO_ROOT:-$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR")}"

if ! command -v gh >/dev/null 2>&1; then
  echo "[Fail] GitHub CLI (gh) is required." >&2
  exit 1
fi

TARGET="${1:-$PWD}"
OWNER=""
NAME=""
PERSONA=""
DO_SYMLINK=0
DRY_RUN=0

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="${2:-}"; shift 2 ;;
    --name) NAME="${2:-}"; shift 2 ;;
    --persona) PERSONA="${2:-}"; shift 2 ;;
    --symlink) DO_SYMLINK=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) echo "[Warn] Unknown arg $1" >&2; shift ;;
  esac
done

TARGET="$(cd "$TARGET" && pwd)"
[[ -n "$NAME" ]] || NAME="$(basename "$TARGET")"

# Detect owner (gh auth -> target origin -> repo root origin -> git configs)
if [[ -z "$OWNER" ]]; then
  OWNER="$(gh auth status 2>/dev/null | awk '/github.com as/{print $NF; exit}')"
fi
if [[ -z "$OWNER" ]]; then
  origin_url="$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)"
  if [[ "$origin_url" =~ github.com[:/]+([^/]+)/[^/]+(.git)?$ ]]; then
    OWNER="${BASH_REMATCH[1]}"
  fi
fi
if [[ -z "$OWNER" ]]; then
  origin_url="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)"
  if [[ "$origin_url" =~ github.com[:/]+([^/]+)/[^/]+(.git)?$ ]]; then
    OWNER="${BASH_REMATCH[1]}"
  fi
fi
if [[ -z "$OWNER" ]]; then
  OWNER="$(git config --global github.user 2>/dev/null || true)"
fi
if [[ -z "$OWNER" ]]; then
  OWNER="$(git config --global user.email 2>/dev/null | awk -F'[@+]' 'NF>=2{print $(NF-1)}')"
fi
if [[ -z "$OWNER" ]]; then
  OWNER="$(git config --global user.name 2>/dev/null | awk '{print $1}')"
fi
if [[ -z "$OWNER" ]]; then
  echo "[Fail] Could not determine GitHub owner; use --owner" >&2
  exit 1
fi

echo "[Info] Target: $TARGET"
echo "[Info] Repo name: $NAME"
echo "[Info] GitHub owner: $OWNER"
[[ $DRY_RUN -eq 1 ]] && echo "[Info] DRY RUN: no changes will be made."

# Helpers
maybe_do() {
  local msg="$1"; shift
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[DRY-RUN] $msg"
  else
    "$@"
  fi
}

if [[ $DRY_RUN -eq 0 ]]; then
  mkdir -p "$TARGET"
elif [[ ! -d "$TARGET" ]]; then
  echo "[DRY-RUN] Would create directory: $TARGET"
fi

# Ensure git repo
if git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[Info] Already a git repo."
else
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[DRY-RUN] Would git init in $TARGET"
  else
    echo "[Info] Initializing git repo."
    git -C "$TARGET" init -q
  fi
fi

# Check remote / upstream status
remote_url=$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)
repo_exists=0
repo_visibility=""
repo_url=""
origin_access=0
refs_present=0
if [[ -n "$remote_url" ]]; then
  # Does the GitHub repo exist (for this owner/name)?
  repo_url="$(gh repo view "$OWNER/$NAME" --json url,visibility --jq '.url + "|" + .visibility' 2>/dev/null || true)"
  if [[ -n "$repo_url" ]]; then
    repo_exists=1
    repo_visibility="${repo_url#*|}"
    repo_url="${repo_url%%|*}"
  fi
  # Is origin reachable?
  if git -C "$TARGET" ls-remote origin >/dev/null 2>&1; then
    origin_access=1
  fi
  # Are there refs on origin?
  if git -C "$TARGET" ls-remote --heads origin >/dev/null 2>&1; then
    heads="$(git -C "$TARGET" ls-remote --heads origin)"
    [[ -n "$heads" ]] && refs_present=1
  fi
fi

if [[ -z "$remote_url" ]]; then
  read -rp "Create GitHub repo $OWNER/$NAME and push? [y/N]: " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "[DRY-RUN] Would run: gh repo create $OWNER/$NAME --public --source $TARGET --remote origin --push"
    else
      gh repo create "$OWNER/$NAME" --public --source "$TARGET" --remote=origin --push
      echo "[Info] Created and pushed to https://github.com/$OWNER/$NAME"
    fi
  else
    echo "[Warn] Skipped remote creation."
  fi
else
  echo "[Info] Remote origin already set to $remote_url"
  if (( repo_exists )); then
    echo "[Info] GitHub repo exists: ${repo_url:-$OWNER/$NAME} (visibility: ${repo_visibility:-unknown})"
    if (( origin_access )); then
      echo "[Info] Origin reachable (ls-remote ok)."
    else
      echo "[Warn] Origin not reachable (ls-remote failed). Check auth/network."
    fi
    if (( refs_present )); then
      echo "[Info] Upstream present: refs found on origin for $OWNER/$NAME"
    else
      echo "[Warn] GitHub repo exists but no refs pushed to origin."
      read -rp "Push current branch to origin? [y/N]: " push_ans
      if [[ "$push_ans" =~ ^[Yy]$ ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
          echo "[DRY-RUN] Would run: git -C \"$TARGET\" push origin HEAD"
        else
          git -C "$TARGET" push origin HEAD
        fi
      fi
    fi
  else
    echo "[Warn] Origin is set, but GitHub repo $OWNER/$NAME not found."
    read -rp "Create it now and push? [y/N]: " create_ans
    if [[ "$create_ans" =~ ^[Yy]$ ]]; then
      if [[ $DRY_RUN -eq 1 ]]; then
        echo "[DRY-RUN] Would run: gh repo create $OWNER/$NAME --public --source $TARGET --remote origin --push"
      else
        gh repo create "$OWNER/$NAME" --public --source "$TARGET" --remote=origin --push
        echo "[Info] Created and pushed to https://github.com/$OWNER/$NAME"
      fi
    fi
  fi
fi

# Symlink into persona if requested
if [[ -n "$PERSONA" && $DO_SYMLINK -eq 1 ]]; then
  link_dir="$REPO_ROOT/$PERSONA/repos"
  if [[ ! -d "$REPO_ROOT/$PERSONA" ]]; then
    echo "[Warn] Persona path not found at $REPO_ROOT/$PERSONA; skipping symlink."
  else
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "[DRY-RUN] Would ensure dir: $link_dir"
      echo "[DRY-RUN] Would symlink $TARGET -> $link_dir/$NAME"
    else
      mkdir -p "$link_dir"
      ln -snf "$TARGET" "$link_dir/$NAME"
      echo "[Info] Symlinked $TARGET -> $link_dir/$NAME"
    fi
  fi
fi

[[ $DRY_RUN -eq 1 ]] && echo "[Done] gh-bootstrap dry run (no changes made)." || echo "[Done] gh-bootstrap complete."
