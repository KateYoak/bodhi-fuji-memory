#!/usr/bin/env bash
# Post stdin (and optional repo images) to Discord via bodhi-gateway.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# scripts -> discord-say -> skills -> .claude -> repo root
ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
cd "$ROOT" || exit 1

PORT="${PORT:-3000}"
HOST="${BODHI_INTERNAL_HTTP_HOST:-127.0.0.1}"
TOKEN="${INTERNAL_QUERY_TOKEN:-}"

CH_OVERRIDE=""
CONTENT=""
USE_ACTIVE_CONTEXT=0
FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      if [[ $# -lt 2 ]]; then
        echo "post_to_chat: --file requires a repo-relative path" >&2
        exit 1
      fi
      FILES+=("$2")
      shift 2
      ;;
    --active-context)
      USE_ACTIVE_CONTEXT=1
      shift
      ;;
    *)
      if [[ -z "$CH_OVERRIDE" ]]; then
        CH_OVERRIDE="$1"
      else
        echo "post_to_chat: unexpected argument: $1" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ "$USE_ACTIVE_CONTEXT" -eq 1 ]]; then
  CONTENT="$(cat "${ROOT}/bootstrap/ACTIVE_CONTEXT.md")"
else
  CONTENT="$(cat)"
fi

export CH_OVERRIDE CONTENT
FILES_JSON=""
if [[ ${#FILES[@]} -gt 0 ]]; then
  FILES_JSON="$(printf '%s\n' "${FILES[@]}" | python3 -c 'import json, sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))')"
fi
export FILES_JSON

JSON="$(
  python3 -c 'import json, os
ch = (os.environ.get("CH_OVERRIDE") or os.environ.get("BODHI_DISCORD_POST_CHANNEL_ID") or "").strip()
body = os.environ.get("CONTENT", "")
o = {"content": body}
if ch:
    o["channelId"] = ch
files_raw = os.environ.get("FILES_JSON", "").strip()
if files_raw:
    o["files"] = json.loads(files_raw)
print(json.dumps(o))'
)"

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
