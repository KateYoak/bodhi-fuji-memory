#!/usr/bin/env bash
# Usage: ./append_log.sh "<entry>"
# Appends a timestamped line to operational/action-log.md (local edit only).

set -euo pipefail

ENTRY="${1:-}"
if [ -z "${ENTRY}" ]; then
  echo "Usage: ./skills/action-log-append/scripts/append_log.sh \"<entry>\"" >&2
  exit 1
fi

OUT="operational/action-log.md"
TS="$(date -u +"%Y-%m-%dT%H:%MZ")"
mkdir -p "$(dirname "${OUT}")"
if [ ! -f "${OUT}" ]; then
  printf "# Action Log\n\n" > "${OUT}"
fi

printf -- "- %s %s\n" "${TS}" "${ENTRY}" >> "${OUT}"
echo "${OUT}"
