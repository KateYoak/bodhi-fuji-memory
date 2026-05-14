#!/usr/bin/env bash
# shellcheck shell=bash
# Writes bootstrap/ACTIVE_CONTEXT.md from stdin. Corpus cwd on gateway is MEMORY_CLONE_PATH.
# Also backs up the previous version with ISO 8601 timestamp before overwriting.
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

# Back up the previous version with ISO 8601 timestamp
if [[ -f "${TARGET}" ]]; then
  TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  BACKUP="${ROOT}/bootstrap/.ACTIVE_CONTEXT_backups/ACTIVE_CONTEXT.${TIMESTAMP}.md"
  mkdir -p "$(dirname "${BACKUP}")"
  cp "${TARGET}" "${BACKUP}"
  echo "write_active_context: backed up previous version to ${BACKUP}" >&2
fi

cat "${TMP}" >"${TARGET}"

echo "write_active_context: wrote ${TARGET} (${BYTES} bytes)" >&2

# Display active context to screen via discord-say
DISCORD_SAY="${ROOT}/.claude/skills/discord-say/scripts/post_to_chat.sh"
if [[ -x "${DISCORD_SAY}" ]]; then
  "${DISCORD_SAY}" <"${TMP}" || echo "write_active_context: discord-say post failed (non-fatal)" >&2
else
  echo "write_active_context: discord-say script not found at ${DISCORD_SAY}" >&2
fi
