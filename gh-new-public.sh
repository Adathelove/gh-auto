#!/usr/bin/env bash
# Wrapper: create/push a PUBLIC GitHub repo from the current directory (or path/bare-new).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHB_MODE=public exec "$SCRIPT_DIR/gh-bootstrap.sh" "$@"
