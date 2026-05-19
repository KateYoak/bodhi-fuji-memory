#!/usr/bin/env bash
# Usage: ./memory_write.sh "<detailed commit message>"
# Commits + pushes all tracked memory changes, then posts Discord notification.

set -euo pipefail

COMMIT_MSG="${1:-}"
if [ -z "${COMMIT_MSG}" ]; then
  echo "Usage: ./skills/memory-write/scripts/memory_write.sh \"<detailed commit message>\"" >&2
  exit 1
fi

if [ "${#COMMIT_MSG}" -lt 20 ]; then
  echo "Commit message must be detailed (at least 20 chars)." >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Must run from inside the memory git repository." >&2
  exit 1
fi

if ! git diff --quiet -- . ':!*.lock'; then
  :
fi

# Tracked changes only (modified/deleted tracked files).
git add .

if git diff --cached --quiet; then
  echo "No tracked changes to commit." >&2
  exit 1
fi

git commit -m "$COMMIT_MSG"
git push

SHA="$(git rev-parse HEAD)"
REPO="${GITHUB_MEMORY_REPO:?GITHUB_MEMORY_REPO not set}"
TOKEN="${DISCORD_BOT_TOKEN:?DISCORD_BOT_TOKEN not set}"
CHANNEL_ID="${DISCORD_MEMORY_UPDATES_CHANNEL_ID:?DISCORD_MEMORY_UPDATES_CHANNEL_ID not set}"
URL="https://github.com/${REPO}/commit/${SHA}"
FILES="$(git show --name-only --pretty="" "${SHA}" | sed '/^$/d')"

if [ -z "${FILES}" ]; then
  FILES="(none)"
fi

export _MW_COMMIT_MSG="${COMMIT_MSG}"
export _MW_FILES="${FILES}"
export _MW_URL="${URL}"
BODY="$(python3 - <<'PY'
import json, os
msg = os.environ["_MW_COMMIT_MSG"]
files = os.environ["_MW_FILES"]
url = os.environ["_MW_URL"]
content = (
    "memory-write\n"
    f"commit message:\n{msg}\n\n"
    f"files changed:\n{files}\n\n"
    f"github: {url}"
)
# Discord message cap is 2000 chars; long file lists (e.g. accidental marker commits) break notify.
max_len = 1900
if len(content) > max_len:
    lines = files.splitlines()
    shown = []
    n = 0
    for line in lines:
        if line.startswith("bootstrap/.bodhi_resume_clear."):
            continue
        shown.append(line)
        n += 1
    omitted = len(lines) - n
    files = "\n".join(shown)
    if omitted:
        files += f"\n… ({omitted} resume-clear marker file(s) omitted from list)"
    content = (
        "memory-write\n"
        f"commit message:\n{msg}\n\n"
        f"files changed:\n{files}\n\n"
        f"github: {url}"
    )
    if len(content) > max_len:
        content = content[: max_len - 20] + "\n…[truncated]"
print(json.dumps({"content": content}))
PY
)"

_DC_JSON="/tmp/memory_write_dc_$$.json"
code="$(curl -sS -o "${_DC_JSON}" -w "%{http_code}" \
  -X POST \
  -H "Authorization: Bot ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "${BODY}" \
  "https://discord.com/api/v10/channels/${CHANNEL_ID}/messages")"

if [ "$code" != "200" ]; then
  echo "ERROR: Discord notify failed HTTP ${code}" >&2
  cat "${_DC_JSON}" >&2 || true
  rm -f "${_DC_JSON}"
  exit 1
fi

rm -f "${_DC_JSON}"
echo "${SHA}"
