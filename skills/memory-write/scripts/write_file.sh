#!/usr/bin/env bash
# Usage: write_file.sh <filepath> <commit_message> < content-on-stdin
# Prints commit SHA to stdout.

set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../memory-read/scripts/_github_memory_env.sh
. "${_script_dir}/../../memory-read/scripts/_github_memory_env.sh"

FILEPATH="${1:?Usage: write_file.sh <filepath> <commit_message> <stdin>}"
COMMIT_MSG="${2:?Usage: write_file.sh <filepath> <commit_message>}"
REPO="${GITHUB_MEMORY_REPO:?GITHUB_MEMORY_REPO not set}"
TOKEN="${GITHUB_TOKEN:?GITHUB_TOKEN not set}"

TMP="/tmp/wf_content_$$.txt"
trap 'rm -f "$TMP"' EXIT
cat >"$TMP"

export _GH_REPO="$REPO" _GH_TOKEN="$TOKEN" _GH_PATH="$FILEPATH" _GH_MSG="$COMMIT_MSG" _GH_TMP="$TMP"
python3 <<'PY'
import base64, json, os, sys, urllib.error, urllib.request

repo = os.environ["_GH_REPO"]
token = os.environ["_GH_TOKEN"]
path = os.environ["_GH_PATH"]
msg = os.environ["_GH_MSG"]
with open(os.environ["_GH_TMP"], "r", encoding="utf-8") as f:
    content = f.read()
b64 = base64.b64encode(content.encode("utf-8")).decode("ascii")


def req(method, url, body=None):
    r = urllib.request.Request(
        url,
        data=body.encode("utf-8") if body else None,
        method=method,
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "bodhi-memory-write",
        },
    )
    with urllib.request.urlopen(r, timeout=120) as resp:
        return resp.status, resp.read().decode("utf-8")


url = f"https://api.github.com/repos/{repo}/contents/{path}"
sha = None
status, body = None, ""
try:
    status, body = req("GET", url)
except urllib.error.HTTPError as e:
    status = e.code
    body = e.read().decode("utf-8", errors="replace")

if status == 200:
    sha = json.loads(body).get("sha")
elif status != 404:
    print(f"ERROR: GET {path} HTTP {status} {body[:500]}", file=sys.stderr)
    sys.exit(1)

payload = {"message": msg, "content": b64}
if sha:
    payload["sha"] = sha

st, out = req("PUT", url, json.dumps(payload))
if st not in (200, 201):
    print(f"ERROR: PUT {path} HTTP {st} {out[:800]}", file=sys.stderr)
    sys.exit(1)
print(json.loads(out)["commit"]["sha"])
PY
