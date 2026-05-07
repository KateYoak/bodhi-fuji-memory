#!/usr/bin/env bash
# Appends an entry to operational/action-log.md without loading the log into LLM context.
# The read/append/write cycle happens entirely inside this script.
#
# Usage:
#   ./append_log.sh "<single-line entry>"
#   ./append_log.sh "<single-line entry>" "<commit message>"
#   echo "multi-line entry" | ./append_log.sh
#   ./append_log.sh - "<commit message>" <<'EOF'
#   multi-line
#   entry
#   EOF
#
# If first arg is absent or "-", content is read from stdin.
# commit_message is optional; defaults to a plain timestamped note.

set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../memory-read/scripts/_github_memory_env.sh
. "${_script_dir}/../../memory-read/scripts/_github_memory_env.sh"

FILEPATH="operational/action-log.md"
REPO="${GITHUB_MEMORY_REPO:?GITHUB_MEMORY_REPO not set}"
TOKEN="${GITHUB_TOKEN:?GITHUB_TOKEN not set}"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%MZ")"

# Determine entry source
FIRST_ARG="${1:-}"
if [ -z "$FIRST_ARG" ] || [ "$FIRST_ARG" = "-" ]; then
  ENTRY="$(cat)"
  COMMIT_MSG="${2:-}"
else
  ENTRY="$FIRST_ARG"
  COMMIT_MSG="${2:-}"
fi

if [ -z "$ENTRY" ]; then
  echo "ERROR: no entry content provided" >&2
  exit 1
fi

# Default commit message if not supplied
if [ -z "$COMMIT_MSG" ]; then
  COMMIT_MSG="Logged what happened — ${TIMESTAMP}"
fi

_GH_AL_JSON="/tmp/gh_al_$$.json"
trap 'rm -f "${_GH_AL_JSON}"' EXIT

code="$(curl -sS -o "${_GH_AL_JSON}" -w "%{http_code}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/${REPO}/contents/${FILEPATH}")"

if [ "$code" != "200" ]; then
  echo "ERROR: cannot read ${FILEPATH} HTTP ${code}" >&2
  cat "${_GH_AL_JSON}" >&2 || true
  exit 1
fi

export _GH_REPO="$REPO" _GH_TOKEN="$TOKEN" _GH_PATH="$FILEPATH" \
       _GH_ENTRY="$ENTRY" _GH_TS="$TIMESTAMP" _GH_TMP="${_GH_AL_JSON}" \
       _GH_MSG="$COMMIT_MSG"

python3 <<'PY'
import base64, json, os, sys, urllib.request, urllib.error

repo  = os.environ["_GH_REPO"]
token = os.environ["_GH_TOKEN"]
path  = os.environ["_GH_PATH"]
entry = os.environ["_GH_ENTRY"]
ts    = os.environ["_GH_TS"]
tmp   = os.environ["_GH_TMP"]
msg   = os.environ["_GH_MSG"]

with open(tmp, "r", encoding="utf-8") as f:
    data = json.load(f)
sha     = data["sha"]
current = base64.b64decode(data["content"]).decode("utf-8")

if not current.endswith("\n"):
    current += "\n"

# Multi-line entries: indent continuation lines, prefix first line with timestamp
lines = entry.strip().splitlines()
if len(lines) == 1:
    new_content = current + f"- {ts} {lines[0]}\n"
else:
    first = f"- {ts} {lines[0]}\n"
    rest  = "".join(f"  {ln}\n" for ln in lines[1:])
    new_content = current + first + rest

b64 = base64.b64encode(new_content.encode("utf-8")).decode("ascii")
payload = json.dumps({"message": msg, "content": b64, "sha": sha})

url = f"https://api.github.com/repos/{repo}/contents/{path}"
req = urllib.request.Request(
    url,
    data=payload.encode("utf-8"),
    method="PUT",
    headers={
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "Content-Type": "application/json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "bodhi-memory-write",
    },
)
try:
    with urllib.request.urlopen(req, timeout=120) as resp:
        out = json.loads(resp.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    print(e.read().decode("utf-8", errors="replace"), file=sys.stderr)
    sys.exit(1)
print(out["commit"]["sha"])
PY
