#!/usr/bin/env bash
# gh-repo-owner.sh — report which persona repos contain a given repo name.
# Uses gh-list --no-fzf to list repos (owner default Adathelove) and scans mythos personas' repos symlinks.
set -euo pipefail

owner="Adathelove"
repo_name=""
mythos_root="${MYTHOS_ROOT:-$HOME/repos/git/mythos}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) owner="${2:-}"; shift 2;;
    --repo) repo_name="${2:-}"; shift 2;;
    --mythos-root) mythos_root="${2:-}"; shift 2;;
    *) echo "[Warn] Unknown arg $1" >&2; shift;;
  esac
done

if [[ -z "$repo_name" ]]; then
  # Try to infer from cwd
  if [[ "$PWD" =~ /([^/]+)$ ]]; then
    repo_name="${BASH_REMATCH[1]}"
  fi
fi
[[ -z "$repo_name" ]] && { echo "[Fail] Provide --repo" >&2; exit 1; }

if [[ ! -d "$mythos_root/Chaos" ]]; then
  echo "[Warn] mythos root not found at $mythos_root" >&2
fi

# Persona list from Phyle
personas=()
if [[ -f "$mythos_root/Chaos/Phyle.txt" ]]; then
  mapfile -t personas < <(awk 'NF && $1 !~ /^#/ {for(i=1;i<=NF;i++) if($i ~ /^[A-Z][A-Za-z0-9._-]*$/){print $i; break}}' "$mythos_root/Chaos/Phyle.txt")
fi

owners=()
for p in "${personas[@]}"; do
  for base in repos shared; do
    path="$mythos_root/$p/$base/$repo_name"
    if [[ -e "$path" ]]; then
      owners+=("$p ($base)")
    fi
  done
done

if [[ ${#owners[@]} -eq 0 ]]; then
  echo "[Warn] No persona repos found containing $repo_name"
else
  echo "[Info] Persona matches for $repo_name: ${owners[*]}"
fi

# Confirm repo exists under owner on GitHub
if gh repo view "$owner/$repo_name" >/dev/null 2>/dev/null; then
  echo "[Info] GitHub repo exists: $owner/$repo_name"
else
  echo "[Warn] GitHub repo $owner/$repo_name not found via gh repo view"
fi

# Optionally show clones available via gh-list
if gh_list_out=$(./gh-list.sh --owner "$owner" --no-fzf 2>/dev/null); then
  if printf '%s\n' "$gh_list_out" | awk -F'\t' -v r="$repo_name" 'tolower($1)==tolower(r){exit 0} END{exit 1}'; then
    echo "[Info] Repo $repo_name is listed for owner $owner"
  else
    echo "[Warn] Repo $repo_name not in gh-list for owner $owner"
  fi
else
  echo "[Warn] Could not run gh-list.sh --no-fzf"
fi
