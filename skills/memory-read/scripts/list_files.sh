#!/usr/bin/env bash
# Usage: ./list_files.sh <directory>
# Prints one filename per line (not full paths).

set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_github_memory_env.sh
. "${_script_dir}/_github_memory_env.sh"

DIRECTORY="${1:?Usage: list_files.sh <directory>}"
REPO="${GITHUB_MEMORY_REPO:?GITHUB_MEMORY_REPO not set}"
TOKEN="${GITHUB_TOKEN:?GITHUB_TOKEN not set}"

_GH_LIST_JSON="/tmp/gh_list_$$.json"
code="$(curl -sS -o "${_GH_LIST_JSON}" -w "%{http_code}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/${REPO}/contents/${DIRECTORY}")"

if [ "$code" != "200" ]; then
  echo "ERROR: GitHub list ${DIRECTORY} HTTP ${code}" >&2
  cat "${_GH_LIST_JSON}" >&2 || true
  rm -f "${_GH_LIST_JSON}"
  exit 1
fi

export _GH_LIST_TMP="${_GH_LIST_JSON}"
python3 -c "
import json, sys, os
p = os.environ['_GH_LIST_TMP']
with open(p, 'r', encoding='utf-8') as f:
    data = json.load(f)
if not isinstance(data, list):
    sys.exit(0)
for item in data:
    if item.get('type') == 'file':
        print(item['name'])
"
rm -f "${_GH_LIST_JSON}"
