#!/usr/bin/env bash
# Wrapper: create/push a PRIVATE GitHub repo from the current directory (or path/bare-new).
GHB_MODE=private exec "$(dirname "$0")/gh-bootstrap.sh" "$@"
