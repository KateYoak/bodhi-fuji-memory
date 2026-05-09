#!/usr/bin/env bash
# shellcheck shell=bash
# Writes bootstrap/ACTIVE_CONTEXT.md from stdin. Corpus cwd on gateway is MEMORY_CLONE_PATH.
# Hook for future safety checks (size caps, forbidden patterns, etc.).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# scripts -> context-manage -> skills -> repo root
ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
TARGET="${ROOT}/bootstrap/ACTIVE_CONTEXT.md"
MAX_BYTES="${BODHI_ACTIVE_CONTEXT_MAX_BYTES:-500000}"

TMP="$(mktemp)"
trap 'rm -f "${TMP}"' EXIT
cat >"${TMP}"

BYTES="$(wc -c <"${TMP}" | tr -d ' ')"
if [[ "${BYTES}" -gt "${MAX_BYTES}" ]]; then
  echo "write_active_context: body exceeds BODHI_ACTIVE_CONTEXT_MAX_BYTES (${MAX_BYTES}), got ${BYTES}" >&2
  exit 1
fi

mkdir -p "$(dirname "${TARGET}")"
{
  printf '%s\n\n' "# ACTIVE_CONTEXT"
  printf '> Written by `skills/context-manage/scripts/write_active_context.sh` at %s.\n\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  cat "${TMP}"
} >"${TARGET}"

echo "write_active_context: wrote ${TARGET} (${BYTES} bytes)" >&2
