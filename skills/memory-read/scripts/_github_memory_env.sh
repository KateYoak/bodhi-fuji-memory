# shellcheck shell=bash
# Sourced by memory-read/write scripts. OpenClaw exec (especially sandboxed runs)
# may not inherit GITHUB_* from the gateway; entrypoint writes these files at boot.
_oc_private="${OPENCLAW_STATE_DIR:-/app/.openclaw}/private"
if [ -z "${GITHUB_TOKEN:-}" ] && [ -r "${_oc_private}/github_token" ]; then
  GITHUB_TOKEN="$(cat "${_oc_private}/github_token")"
  export GITHUB_TOKEN
fi
if [ -z "${GITHUB_MEMORY_REPO:-}" ] && [ -r "${_oc_private}/github_memory_repo" ]; then
  GITHUB_MEMORY_REPO="$(tr -d '\n\r' < "${_oc_private}/github_memory_repo")"
  export GITHUB_MEMORY_REPO
fi
