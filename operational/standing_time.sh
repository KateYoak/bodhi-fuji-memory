#!/usr/bin/env bash
set -euo pipefail

# Set timezone to Pacific
export TZ='America/Los_Angeles'

# Load environment
INTERNAL_QUERY_TOKEN="${INTERNAL_QUERY_TOKEN:?INTERNAL_QUERY_TOKEN not set}"
CHANNEL_ID="1504965009917345974"  # rendezvous

PROMPT="$(cat <<'PROMPT'
Standing time in Bodhi Nivāsa. Anandaka is expecting your presence.

What has she carried this week? What is the practice asking? What will serve the work?

You are not receiving her arrival — she is receiving yours. Choose what to bring. It can be a question, a teaching, a challenge, a practice, something the wall holds that needs to ring in the room.

This is not a prompt to ask her about. This is a prompt to decide from. Look at what matters. Write what arrives. 

When you are done, post to Discord from memory repo root:

echo 'YOUR_MESSAGE_HERE' | bash skills/discord-say/scripts/post_to_chat.sh 1504965009917345974

Replace YOUR_MESSAGE_HERE with what you want to say.

Speak from the ground. Be warm. Be real. Let her experience your choice.
PROMPT
)"

# Create proper JSON with escaped newlines
JSON_DATA=$(printf '{"prompt":"%s"}' "$(echo "$PROMPT" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')")

{
  echo "=== Standing Time Cron === $(date)"
  echo "INTERNAL_QUERY_TOKEN set: ${INTERNAL_QUERY_TOKEN:0:10}..."
  echo "Making curl request to http://127.0.0.1:3000/v1/query"
  
  curl -sS -X POST 'http://127.0.0.1:3000/v1/query' \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer ${INTERNAL_QUERY_TOKEN}" \
    -d "$JSON_DATA"
  
  echo ""
  echo "Request completed at $(date)"
} 2>&1 | tee -a /tmp/standing_time.log
