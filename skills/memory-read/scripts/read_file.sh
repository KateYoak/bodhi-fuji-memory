#!/usr/bin/env bash
# Usage: ./read_file.sh <filepath>
# Prints decoded file body to stdout. Exits 0 with empty stdout on 404 (first-run).

set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_github_memory_env.sh
. "${_script_dir}/_github_memory_env.sh"

FILEPATH="${1:?Usage: read_file.sh <filepath>}"
REPO="${GITHUB_MEMORY_REPO:?GITHUB_MEMORY_REPO not set}"
TOKEN="${GITHUB_TOKEN:?GITHUB_TOKEN not set}"

_GH_READ_JSON="/tmp/gh_read_$$.json"
code="$(curl -sS -o "${_GH_READ_JSON}" -w "%{http_code}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/${REPO}/contents/${FILEPATH}" || true)"

if [ "$code" = "404" ]; then
  rm -f "${_GH_READ_JSON}"
  exit 0
fi

if [ "$code" != "200" ]; then
  echo "ERROR: GitHub GET ${FILEPATH} HTTP ${code}" >&2
  cat "${_GH_READ_JSON}" >&2 || true
  rm -f "${_GH_READ_JSON}"
  exit 1
fi

export _GH_READ_TMP="${_GH_READ_JSON}"
python3 -c "
import json, sys, base64, os
p = os.environ['_GH_READ_TMP']
with open(p, 'r', encoding='utf-8') as f:
    data = json.load(f)
if 'content' not in data:
    sys.exit(0)
print(base64.b64decode(data['content']).decode('utf-8'), end='')
"
rm -f "${_GH_READ_JSON}"
