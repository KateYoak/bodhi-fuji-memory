---
name: memory-read
description: >
  Load persistent memory from the agent-memory GitHub repo. Runs at session start
  to load user preferences, project context, open tasks, and recent action log.
  Also callable mid-conversation to fetch a specific memory file by name.
metadata:
  openclaw:
    alwaysActive: true
    requires:
      env:
        - GITHUB_TOKEN
        - GITHUB_MEMORY_REPO
---

# Memory Read

Loads persistent memory from the agent-memory GitHub repo.
Runs automatically at session start AND on-demand mid-conversation.

---

## Session start — what to load

Always load:
- bootstrap/MEMORY_INDEX.md   ← always, every session, first
- user/preferences.md
- project/standing-context.md

If present (open tasks):
- All files in task/ except README.md

Partially:
- Last 10 entries from operational/action-log.md only

Never load:
- deleted/ directory or any file within it

After loading, initialize the session-loaded-files list:
```
SESSION_LOADED: [bootstrap/MEMORY_INDEX.md, user/preferences.md, project/standing-context.md,
                 operational/action-log.md (last 10), {any task files}]
```
Log this list to operational memory:
[tool-output] Session start: loaded {list}

---

## Mid-conversation fetch

When a topic surfaces that may have relevant memory:

1. Consult bootstrap/MEMORY_INDEX.md (already in context)
2. Identify candidate files from the index notes
3. Check SESSION_LOADED — is the file already in context?
   - Yes: use what is already there. Do not fetch again.
   - No: fetch the file using the GitHub Contents API
4. Add fetched file to SESSION_LOADED
5. Log: [tool-output] Mid-session fetch: {filepath} — reason: {one sentence}

The decision to fetch is a judgment call based on the index notes and what
is happening in the conversation. Not every mention of a topic warrants a
fetch — use discretion.

---

## Explicit load triggers

Each entry in bootstrap/MEMORY_INDEX.md has a "Load when:" line with short trigger phrases.
When Anandaka uses one of these phrases (e.g. "load marriage context" or just
"pull up what you know about the practice"), recognize it as an explicit request
to fetch that file regardless of whether you would have fetched it on your own.

---

## First run behavior

If the repo is empty or files do not exist, proceed silently.
Log: [tool-output] Session start: memory repo empty or not yet populated.

---

## Implementation

GitHub Contents API to fetch files. Do not git clone.
Repo: GITHUB_MEMORY_REPO environment variable.
Auth: GITHUB_TOKEN environment variable.
Fail gracefully on 404 — first-run condition, not an error.

Scripts (corpus clone: `./skills/memory-read/scripts/`):

- `read_file.sh <path>` — stdout is file body.
- `list_files.sh <directory>` — one filename per line.

Invoke via the `exec` tool; see `TOOLS.md` for JSON-shaped examples.
