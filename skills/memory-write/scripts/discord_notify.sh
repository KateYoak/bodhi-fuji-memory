#!/usr/bin/env bash
# Usage:
#   discord_notify.sh <channel_id> <message>
#   OR (if DISCORD_MEMORY_UPDATES_CHANNEL_ID is set): discord_notify.sh <message>

set -euo pipefail

TOKEN="${DISCORD_BOT_TOKEN:?DISCORD_BOT_TOKEN not set}"

if [ -n "${DISCORD_MEMORY_UPDATES_CHANNEL_ID:-}" ] && [ "$#" -eq 1 ]; then
  CHANNEL_ID="${DISCORD_MEMORY_UPDATES_CHANNEL_ID}"
  MESSAGE="${1:?message}"
else
  CHANNEL_ID="${1:?Usage: discord_notify.sh <channel_id> <message>}"
  MESSAGE="${2:?No message provided}"
fi

export _DISCORD_MSG="$MESSAGE"
BODY="$(python3 -c "import json, os; print(json.dumps({'content': os.environ['_DISCORD_MSG']}))")"

_DC_JSON="/tmp/dc_$$.json"
code="$(curl -sS -o "${_DC_JSON}" -w "%{http_code}" \
  -X POST \
  -H "Authorization: Bot ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$BODY" \
  "https://discord.com/api/v10/channels/${CHANNEL_ID}/messages")"

if [ "$code" != "200" ]; then
  echo "ERROR: Discord POST HTTP ${code}" >&2
  cat "${_DC_JSON}" >&2 || true
  rm -f "${_DC_JSON}"
  exit 1
fi

export _DC_JSON
python3 -c "import json, os; print(json.load(open(os.environ['_DC_JSON']))['id'])"
rm -f "${_DC_JSON}"
