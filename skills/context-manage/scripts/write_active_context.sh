#!/usr/bin/env bash
# shellcheck shell=bash
# Writes bootstrap/ACTIVE_CONTEXT.md from stdin. Corpus cwd on gateway is MEMORY_CLONE_PATH.
# Also backs up the previous version with ISO 8601 timestamp before overwriting.
# When BODHI_DISCORD_POST_CHANNEL_ID is set: writes resume-clear marker + first Bodhi post (nonce).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# scripts -> context-manage -> skills -> repo root
ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
TARGET="${ROOT}/bootstrap/ACTIVE_CONTEXT.md"
MAX_BYTES="${BODHI_ACTIVE_CONTEXT_MAX_BYTES:-500000}"

TMP="$(mktemp)"
POST_BODY="$(mktemp)"
HTTP_OUT="$(mktemp)"
trap 'rm -f "${TMP}" "${POST_BODY}" "${HTTP_OUT}"' EXIT
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

CH="${BODHI_DISCORD_POST_CHANNEL_ID:-}"
CH="${CH//[[:space:]]/}"
if [[ -z "${CH}" ]]; then
  exit 0
fi

NONCE="$(python3 -c "import secrets; print(secrets.token_hex(12))")"
NOW_MS="$(python3 -c "import time; print(int(time.time() * 1000))")"
MARKER="${ROOT}/bootstrap/.bodhi_resume_clear.${CH}.json"

export CH NONCE NOW_MS BYTES MARKER
python3 - <<'PY'
import json
import os

ch = os.environ["CH"]
payload = {
    "v": 1,
    "action": "clear_discord_resume",
    "surfaceId": ch,
    "writtenAtUnixMs": int(os.environ["NOW_MS"]),
    "nonce": os.environ["NONCE"],
    "activeContextBytes": int(os.environ["BYTES"]),
}
path = os.environ["MARKER"]
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w", encoding="utf-8") as f:
    json.dump(payload, f, indent=2)
    f.write("\n")
PY

PORT_VAL="${PORT:-3000}"
BASE_URL="${BODHI_GATEWAY_INTERNAL_URL:-http://127.0.0.1:${PORT_VAL}}"
ENDPOINT="${BASE_URL}/v1/discord/post-message"
CONTENT="**Bodhi:** ACTIVE_CONTEXT saved — resume-clear requested (nonce \`${NONCE}\`)."

export CONTENT CH
python3 - <<'PY' >"${POST_BODY}"
import json
import os

print(json.dumps({"channelId": os.environ["CH"], "content": os.environ["CONTENT"]}))
PY

CURL_AUTH=()
if [[ -n "${INTERNAL_QUERY_TOKEN:-}" ]]; then
  CURL_AUTH+=(-H "Authorization: Bearer ${INTERNAL_QUERY_TOKEN}")
fi

code="$(
  curl -sS -o "${HTTP_OUT}" -w "%{http_code}" \
    -X POST \
    "${CURL_AUTH[@]}" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d "@${POST_BODY}" \
    "${ENDPOINT}" || true
)"
[[ -n "${code}" ]] || code="000"

if [[ "${code}" != "200" ]]; then
  echo "write_active_context: POST ${ENDPOINT} failed HTTP ${code}" >&2
  cat "${HTTP_OUT}" >&2 || true
  exit 1
fi
echo "write_active_context: resume-clear marker ${MARKER} + Discord post (nonce ${NONCE})" >&2
