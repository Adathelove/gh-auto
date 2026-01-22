#!/usr/bin/env bash
# gh-installer.sh — ensure gh-auto scripts are on PATH and gh-env.sh is sourced from shell profile.
set -euo pipefail

TARGET_PROFILE="${TARGET_PROFILE:-$HOME/.bash_profile}"
if [[ -n "${ZSH_VERSION:-}" ]]; then
  TARGET_PROFILE="$HOME/.zshrc"
fi

GH_AUTO_ROOT="${GH_AUTO_ROOT:-$HOME/repos/git/adathelove/gh-auto}"
GH_AUTO_BIN="$GH_AUTO_ROOT"
ENV_LINE="source $GH_AUTO_ROOT/gh-env.sh"

if [[ ! -d "$GH_AUTO_ROOT" ]]; then
  echo "[Fail] gh-auto root not found at $GH_AUTO_ROOT" >&2
  exit 1
fi

# Ensure env file exists
if [[ ! -f "$GH_AUTO_ROOT/gh-env.sh" ]]; then
  echo "[Fail] Missing gh-env.sh in $GH_AUTO_ROOT" >&2
  exit 1
fi

# Add PATH now for current shell
if [[ ":$PATH:" != *":$GH_AUTO_BIN:"* ]]; then
  export PATH="$GH_AUTO_BIN:$PATH"
  echo "[Info] Added $GH_AUTO_BIN to PATH for current session."
fi

# Ensure profile sources gh-env.sh
if ! grep -F "$ENV_LINE" "$TARGET_PROFILE" >/dev/null 2>&1; then
  echo "" >> "$TARGET_PROFILE"
  echo "# gh-auto" >> "$TARGET_PROFILE"
  echo "$ENV_LINE" >> "$TARGET_PROFILE"
  echo "[Info] Appended gh-env sourcing to $TARGET_PROFILE"
else
  echo "[Info] $TARGET_PROFILE already sources gh-env.sh"
fi

# Symlink helpers into ~/bin for convenience
mkdir -p "$HOME/bin"
for f in gh-bootstrap.sh gh-list.sh gh-ada-init.sh; do
  src="$GH_AUTO_ROOT/$f"
  dest="$HOME/bin/${f%.sh}"
  ln -snf "$src" "$dest"
  echo "[Info] Symlinked $dest -> $src"
done

# Reload instructions
echo "[Done] Install complete. Restart your shell or run: source $TARGET_PROFILE"
