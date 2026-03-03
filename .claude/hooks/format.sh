#!/usr/bin/env bash

# PostToolUse hook: auto-format Dart files after edit/write.
# Receives JSON on stdin with tool_input.file_path.
# Must always exit 0 — formatting failures should never block edits.

FILE_PATH=$(jq -r '.tool_input.file_path // empty' 2>/dev/null) || true

if [[ -z "${FILE_PATH:-}" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

case "$FILE_PATH" in
  *.dart)
    dart format "$FILE_PATH" || true
    ;;
esac

exit 0
