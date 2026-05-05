#!/usr/bin/env bash
# Writes a gateway allowlisted model id for the next Agent SDK turns.
# Usage: set_model.sh haiku|sonnet|opus|reset

set -euo pipefail

PATH_FILE="${BODHI_RUNTIME_MODEL_PATH:?BODHI_RUNTIME_MODEL_PATH not set}"
alias="${1:?usage: set_model.sh haiku|sonnet|opus|reset}"

case "$alias" in
  haiku) model="claude-haiku-4-5" ;;
  sonnet) model="claude-sonnet-4-6" ;;
  opus) model="claude-opus-4-7" ;;
  reset)
    rm -f "$PATH_FILE"
    echo "Runtime model override cleared — using BODHI_MODEL or SDK default from here on."
    exit 0
    ;;
  *)
    echo "Unknown alias: $alias (use haiku, sonnet, opus, reset)" >&2
    exit 1
    ;;
esac

_tmp="${PATH_FILE}.tmp.$$"
printf '%s' "$model" > "$_tmp"
mv -f "$_tmp" "$PATH_FILE"
echo "Runtime model set to ${model} (next assistant turn)."
