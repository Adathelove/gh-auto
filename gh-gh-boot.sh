#!/usr/bin/env bash
# gh-gh-boot.sh — bootstrap GitHub CLI (gh) on macOS/Homebrew and run initial auth.
# Usage: gh-gh-boot.sh
# - Installs gh via Homebrew if missing.
# - Runs `gh auth login` if not already authenticated.
# - Reminds about SSH vs HTTPS and scopes.
set -euo pipefail

install_gh() {
  if command -v gh >/dev/null 2>&1; then
    echo "[Info] gh already installed: $(command -v gh)"
    return 0
  fi
  if ! command -v brew >/dev/null 2>&1; then
    echo "[Fail] Homebrew not found; install Homebrew first (https://brew.sh)." >&2
    return 1
  fi
  echo "[Info] Installing gh via Homebrew..."
  brew install gh
}

auth_gh() {
  if gh auth status >/dev/null 2>&1; then
    echo "[Info] gh already authenticated."
    gh auth status
    return 0
  fi
  echo "[Info] gh not authenticated. Starting gh auth login."
  echo "[Hint] You'll be prompted for protocol (HTTPS vs SSH) and scopes; default HTTPS is fine."
  gh auth login
  gh auth status || true
}

main() {
  install_gh
  auth_gh
  echo "[Done] gh bootstrap complete. You can now run gh-list / gh-bootstrap."
}

main "$@"
