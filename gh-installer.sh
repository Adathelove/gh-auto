#!/usr/bin/env bash
# gh-installer.sh — ensure gh-auto lives at the standard path, is on PATH, and env/completions are sourced.
set -euo pipefail

TARGET_PROFILE="${TARGET_PROFILE:-$HOME/.bash_profile}"
if [[ -n "${ZSH_VERSION:-}" ]]; then
  TARGET_PROFILE="$HOME/.zshrc"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_ROOT="$SCRIPT_DIR"
DESIRED_ROOT="$HOME/repos/git/adathelove/gh-auto"
GH_AUTO_ROOT="${GH_AUTO_ROOT:-$DESIRED_ROOT}"
GH_AUTO_BIN="$GH_AUTO_ROOT"
ENV_LINE="source $GH_AUTO_ROOT/gh-env.sh"

# Move current clone into the standard location if needed
if [[ "$CURRENT_ROOT" != "$DESIRED_ROOT" ]]; then
  echo "[Warn] gh-auto currently at $CURRENT_ROOT but desired path is $DESIRED_ROOT"
  read -rp "Move gh-auto to $DESIRED_ROOT? [y/N]: " mv_ans
  if [[ "$mv_ans" =~ ^[Yy]$ ]]; then
    mkdir -p "$(dirname "$DESIRED_ROOT")"
    mv -v "$CURRENT_ROOT" "$DESIRED_ROOT"
    GH_AUTO_ROOT="$DESIRED_ROOT"
    GH_AUTO_BIN="$GH_AUTO_ROOT"
    ENV_LINE="source $GH_AUTO_ROOT/gh-env.sh"
    echo "[Info] Moved gh-auto to $DESIRED_ROOT"
  else
    echo "[Warn] Leaving gh-auto at $CURRENT_ROOT; GH_AUTO_ROOT will point there."
    GH_AUTO_ROOT="$CURRENT_ROOT"
    GH_AUTO_BIN="$GH_AUTO_ROOT"
    ENV_LINE="source $GH_AUTO_ROOT/gh-env.sh"
  fi
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

# Check for fzf (required by gh-list)
if ! command -v fzf >/dev/null 2>&1; then
  OS="$(uname -s)"
  case "$OS" in
    Darwin)
      echo "[Info] fzf not found. Installing via Homebrew..."
      if command -v brew >/dev/null 2>&1; then
        brew install fzf
        echo "[Info] fzf installed successfully."
      else
        echo "[Warn] Homebrew not found. Please install fzf manually for gh-list to work." >&2
      fi
      ;;
    Linux)
      echo "[Warn] fzf not found. Please install fzf for gh-list to work:" >&2
      echo "       - Debian/Ubuntu: sudo apt install fzf" >&2
      echo "       - Fedora/RHEL: sudo dnf install fzf" >&2
      echo "       - Arch: sudo pacman -S fzf" >&2
      ;;
    *)
      echo "[Warn] fzf not found. Please install fzf manually for gh-list to work." >&2
      ;;
  esac
else
  echo "[Info] fzf already installed."
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
for f in gh-bootstrap.sh gh-list.sh gh-ada-init.sh gh-gh-boot.sh gh-installer.sh gh-env.sh; do
  src="$GH_AUTO_ROOT/$f"
  dest="$HOME/bin/${f%.sh}"
  ln -snf "$src" "$dest"
  echo "[Info] Symlinked $dest -> $src"
done

# Reload instructions
echo "[Done] Install complete. Restart your shell or run: source $TARGET_PROFILE"
