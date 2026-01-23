#!/usr/bin/env bash
# gh-clone-select.sh
# Interactively pick one of your GitHub repos and clone it.
# Default destination: ~/repos/git/<owner>/<repo>
# Options:
#   --owner NAME    Override owner (default: gh auth user)
#   --here          Clone into current directory (./<repo>)
#   --proto ssh|https  Choose clone protocol (default: https; respects GH_CLONE_PROTO)

set -euo pipefail

proto="${GH_CLONE_PROTO:-https}"
owner=""
here=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) owner="${2:-}"; shift 2 ;;
    --owner=*) owner="${1#--owner=}"; shift ;;
    --here) here=1; shift ;;
    --proto=*) proto="${1#--proto=}"; shift ;;
    --proto) proto="${2:-}"; shift 2 ;;
    -h|--help)
      cat <<EOF
Usage: gh-clone-select.sh [--owner NAME] [--here] [--proto ssh|https]
Default destination: ~/repos/git/<owner>/<repo>
EOF
      exit 0 ;;
    *) shift ;;
  esac
done

if [[ -z "$owner" ]]; then
  # Special case: deduce owner from repos/git/<owner>/ path structure
  if [[ "$PWD" =~ /repos/git/([^/]+) ]]; then
    owner="${BASH_REMATCH[1]}"
  fi
fi
if [[ -z "$owner" ]]; then
  owner="$(gh auth status 2>/dev/null | awk '/github.com as/{print $NF; exit}')"
fi
if [[ -z "$owner" ]]; then
  owner="$(git config --global github.user 2>/dev/null || true)"
fi
if [[ -z "$owner" ]]; then
  echo "[Fail] Could not determine owner; use --owner." >&2
  exit 1
fi

# Fetch list
if command -v jq >/dev/null 2>&1; then
  repos_json="$(gh repo list "$owner" --limit 200 --json name,sshUrl,url)"
  if command -v fzf >/dev/null 2>&1; then
    selection="$(echo "$repos_json" | jq -r '.[] | "\(.name)\t\(.url)"' | fzf --with-nth=1 --delimiter='\t' --ansi)"
  else
    # simple numbered menu
    mapfile -t lines < <(echo "$repos_json" | jq -r '.[] | "\(.name)\t\(.url)"')
    if [[ ${#lines[@]} -eq 0 ]]; then echo "[Fail] no repos found"; exit 1; fi
    i=1; for l in "${lines[@]}"; do echo "$i) ${l%%$'\t'*}"; ((i++)); done
    read -rp "Select repo number: " idx
    selection="${lines[$((idx-1))]}"
  fi
  repo_name="${selection%%$'\t'*}"
else
  # fallback: gh repo list text
  list="$(gh repo list "$owner" --limit 200)"
  if command -v fzf >/dev/null 2>&1; then
    selection="$(echo "$list" | fzf)"
  else
    echo "$list"
    read -rp "Type repo name to clone: " repo_name
    selection="$repo_name"
  fi
  repo_name="$(echo "$selection" | awk '{print $1}' | awk -F/ '{print $NF}')"
fi

if [[ -z "${repo_name:-}" ]]; then
  echo "[Fail] No repo selected." >&2
  exit 1
fi

# Determine clone URL
clone_url=""
if [[ "$proto" == "ssh" ]]; then
  if command -v jq >/dev/null 2>&1; then
    clone_url="$(echo "$repos_json" | jq -r ".[] | select(.name==\"$repo_name\") | .sshUrl")"
  fi
  [[ -z "$clone_url" ]] && clone_url="git@github.com:$owner/$repo_name.git"
else
  clone_url="https://github.com/$owner/$repo_name.git"
fi

# Destination
if [[ $here -eq 1 ]]; then
  dest="$PWD/$repo_name"
else
  base="${CLONE_BASE:-$HOME/repos/git/$owner}"
  mkdir -p "$base"
  dest="$base/$repo_name"
fi

if [[ -e "$dest" ]]; then
  echo "[Fail] Destination already exists: $dest" >&2
  exit 1
fi

echo "[Info] Cloning $clone_url -> $dest"
git clone "$clone_url" "$dest"
echo "[Done] Clone complete."
