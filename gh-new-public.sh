#!/usr/bin/env bash
# Wrapper: create/push a PUBLIC GitHub repo from the current directory (or path/bare-new).
GHB_MODE=public exec "$(dirname "$0")/gh-bootstrap.sh" "$@"
