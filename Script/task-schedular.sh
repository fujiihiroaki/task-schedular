#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# TaskSchedular.exe に渡す引数をここで定義
ARGS=(
  "watch" "$SCRIPT_DIR/Weekly.md"
  "--out" "$SCRIPT_DIR/Tasks.md"
)

exec "$SCRIPT_DIR/TaskSchedular.exe" "${ARGS[@]}"
