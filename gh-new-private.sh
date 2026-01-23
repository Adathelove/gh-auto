#!/usr/bin/env bash
# Wrapper: create/push a PRIVATE GitHub repo from the current directory (or path/bare-new).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHB_MODE=private exec "$SCRIPT_DIR/gh-bootstrap.sh" "$@"
