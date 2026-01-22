# gh-env.sh — add gh-auto scripts to PATH and completions (source from bash/zsh profile)
GH_AUTO_ROOT="${GH_AUTO_ROOT:-$HOME/repos/git/adathelove/gh-auto}"
GH_AUTO_BIN="$GH_AUTO_ROOT"
if [[ -d "$GH_AUTO_BIN" ]] && [[ ":$PATH:" != *":$GH_AUTO_BIN:"* ]]; then
  export PATH="$GH_AUTO_BIN:$PATH"
fi

# Completion: basic file-name completion for gh-* scripts
if [ -n "$BASH_VERSION" ]; then
  for _gh_cmd in gh-bootstrap gh-list gh-ada-init; do
    complete -F _command_offset 0 $_gh_cmd 2>/dev/null || true
  done
fi
if [ -n "$ZSH_VERSION" ]; then
  autoload -U compinit && compinit -u
fi
