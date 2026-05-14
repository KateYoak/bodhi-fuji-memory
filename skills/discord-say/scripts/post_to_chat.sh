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

# Gateway only requires this header when INTERNAL_QUERY_TOKEN is set on the Node process
# (`server.ts`). If unset, omit header so local `curl` matches optional auth.
AUTH_ARGS=()
if [[ -n "$TOKEN" ]]; then
  AUTH_ARGS=(-H "Authorization: Bearer ${TOKEN}")
else
  echo "post_to_chat: INTERNAL_QUERY_TOKEN unset — calling without Authorization (ok only if gateway auth is off)." >&2
fi

curl -sS -X POST "http://${HOST}:${PORT}/v1/discord/post-message" \
  "${AUTH_ARGS[@]}" \
  -H "Content-Type: application/json" \
  -d "$JSON"
echo
