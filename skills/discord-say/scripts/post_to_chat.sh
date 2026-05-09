#!/usr/bin/env bash
# Post stdin to Discord via bodhi-gateway (intentional — not automatic tool stdout).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# scripts -> discord-say -> skills -> repo root
ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
cd "$ROOT" || exit 1

PORT="${PORT:-3000}"
HOST="${BODHI_INTERNAL_HTTP_HOST:-127.0.0.1}"
TOKEN="${INTERNAL_QUERY_TOKEN:-}"
if [[ -z "$TOKEN" ]]; then
  echo "INTERNAL_QUERY_TOKEN is not set (same secret as POST /v1/query)." >&2
  exit 1
fi

CH_OVERRIDE="${1:-}"
CONTENT="$(cat)"

export CH_OVERRIDE CONTENT
JSON="$(
  python3 -c 'import json, os
ch = (os.environ.get("CH_OVERRIDE") or os.environ.get("BODHI_DISCORD_POST_CHANNEL_ID") or "").strip()
body = os.environ["CONTENT"]
o = {"content": body}
if ch:
    o["channelId"] = ch
print(json.dumps(o))'
)"

curl -sS -X POST "http://${HOST}:${PORT}/v1/discord/post-message" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$JSON"
echo
