#!/usr/bin/env bash
# Usage: write_files.sh <commit_message> < json_manifest
#
# JSON manifest on stdin:
#   {"files": [{"path": "relative/path.md", "content": "text content"}, ...]}
#
# Makes a single Git commit containing all listed files.
# Prints commit SHA to stdout.
#
# Use this for ALL writes — single file or many. It replaces per-file commits.

set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../memory-read/scripts/_github_memory_env.sh
. "${_script_dir}/../../memory-read/scripts/_github_memory_env.sh"

COMMIT_MSG="${1:?Usage: write_files.sh <commit_message> < json_manifest}"
REPO="${GITHUB_MEMORY_REPO:?GITHUB_MEMORY_REPO not set}"
TOKEN="${GITHUB_TOKEN:?GITHUB_TOKEN not set}"
BRANCH="${GITHUB_MEMORY_BRANCH:-main}"

TMP="/tmp/wf_manifest_$$.json"
trap 'rm -f "$TMP"' EXIT
cat >"$TMP"

export _GH_REPO="$REPO" _GH_TOKEN="$TOKEN" _GH_MSG="$COMMIT_MSG" _GH_TMP="$TMP" _GH_BRANCH="$BRANCH"
python3 <<'PY'
import json, os, sys, urllib.error, urllib.request

repo  = os.environ["_GH_REPO"]
token = os.environ["_GH_TOKEN"]
msg   = os.environ["_GH_MSG"]
branch = os.environ.get("_GH_BRANCH", "main")

with open(os.environ["_GH_TMP"], "r", encoding="utf-8") as f:
    manifest = json.load(f)

files = manifest["files"]   # [{"path": "...", "content": "..."}]
if not files:
    print("ERROR: no files in manifest", file=sys.stderr)
    sys.exit(1)

HDR = {
    "Authorization": f"Bearer {token}",
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
    "User-Agent": "bodhi-memory-write",
    "Content-Type": "application/json",
}
base = f"https://api.github.com/repos/{repo}"

def req(method, url, body=None):
    data = json.dumps(body).encode("utf-8") if body is not None else None
    r = urllib.request.Request(url, data=data, method=method, headers=HDR)
    try:
        with urllib.request.urlopen(r, timeout=120) as resp:
            return resp.status, json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        return e.code, {"_error": e.read().decode("utf-8", errors="replace")}

# 1. Current branch tip
st, ref_data = req("GET", f"{base}/git/ref/heads/{branch}")
if st != 200:
    print(f"ERROR: GET ref HTTP {st}: {ref_data}", file=sys.stderr)
    sys.exit(1)
latest_sha = ref_data["object"]["sha"]

# 2. Tree SHA of that commit
st, commit_data = req("GET", f"{base}/git/commits/{latest_sha}")
if st != 200:
    print(f"ERROR: GET commit HTTP {st}: {commit_data}", file=sys.stderr)
    sys.exit(1)
base_tree_sha = commit_data["tree"]["sha"]

# 3. Create a blob for each file
tree_items = []
for entry in files:
    path    = entry["path"]
    content = entry["content"]
    st, blob = req("POST", f"{base}/git/blobs", {"content": content, "encoding": "utf-8"})
    if st not in (200, 201):
        print(f"ERROR: blob for {path} HTTP {st}: {blob}", file=sys.stderr)
        sys.exit(1)
    tree_items.append({"path": path, "mode": "100644", "type": "blob", "sha": blob["sha"]})

# 4. New tree
st, tree_data = req("POST", f"{base}/git/trees", {"base_tree": base_tree_sha, "tree": tree_items})
if st not in (200, 201):
    print(f"ERROR: create tree HTTP {st}: {tree_data}", file=sys.stderr)
    sys.exit(1)
new_tree_sha = tree_data["sha"]

# 5. New commit
st, new_commit = req("POST", f"{base}/git/commits", {
    "message": msg,
    "tree": new_tree_sha,
    "parents": [latest_sha]
})
if st not in (200, 201):
    print(f"ERROR: create commit HTTP {st}: {new_commit}", file=sys.stderr)
    sys.exit(1)
new_sha = new_commit["sha"]

# 6. Advance branch ref
st, upd = req("PATCH", f"{base}/git/refs/heads/{branch}", {"sha": new_sha})
if st not in (200, 201):
    print(f"ERROR: update ref HTTP {st}: {upd}", file=sys.stderr)
    sys.exit(1)

print(new_sha)
PY