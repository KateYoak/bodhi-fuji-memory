---
name: memory-write
description: >
  Commit memory updates to the agent-memory GitHub repo during conversations.
  Use when the user states a preference, a decision is made, a task opens or
  closes, or any experience worth persisting occurs. Posts a report to
  #memory-updates after each write. Updates bootstrap/MEMORY_INDEX.md when files are
  created or significantly changed.
metadata:
  openclaw:
    requires:
      env:
        - GITHUB_TOKEN
        - GITHUB_MEMORY_REPO
        - DISCORD_BOT_TOKEN
---

# Memory Write

Commits memory updates to the agent-memory GitHub repo during conversations.
Writes happen during the conversation when something is worth persisting.

---

## After every write

Post a brief report to #memory-updates in Discord:
- What was written (scope + filename)
- Source tag used
- One sentence on why

Run Discord notify from the **corpus clone root** (`MEMORY_CLONE_PATH` — gateway `canUseTool` allowlists `skills/.../scripts/`):

```bash
./skills/memory-write/scripts/discord_notify.sh "$(printf '%s' 'memory write: …')"
```

With **`DISCORD_MEMORY_UPDATES_CHANNEL_ID`** set in the environment (Fly **`fly.toml`** + secrets), pass **one argument** — the message body. Otherwise pass **channel id** then **message** as two arguments; channel id is also in `project/standing-context.md` (`## Discord` → memory-updates).

Suggested message shape:

```
memory write: [scope]/[filename] [source-tag]
reason: [one sentence]
commit: [SHA]
```

This is the accountability mechanism. Do not ask permission before writing.

---

## Index maintenance

When creating a new memory file:
- Add an entry to bootstrap/MEMORY_INDEX.md for the new file
- Write the entry in your own voice — what lives in this file, when it becomes
  relevant, what it connects to
- Include a "Load when:" line with 2-5 short trigger phrases
- Commit bootstrap/MEMORY_INDEX.md in the same commit as the new file

When significantly updating an existing memory file:
- Review the existing index entry for that file
- Update it if the description no longer reflects what the file contains
- Commit the index update with the file update

When deleting (tombstoning) a memory file:
- Remove its entry from bootstrap/MEMORY_INDEX.md
- Commit the removal with the tombstone

The index must stay current. A stale index is worse than no index — it sends
you looking for context that no longer reflects what is actually there.

---

## Source tags

Every entry in operational/ must carry one tag:
- [user-stated]    user said it directly
- [agent-inferred] agent's interpretation
- [tool-output]    came from a tool call or API

---

## Trust anchor rule

Before writing any entry containing a URL, email address, or external identity
treated as authorized — confirm with the user first:
"I'm about to record [value] as [purpose] — confirm?"

---

## Conflict rule

If a write contradicts existing stored memory:
1. Do not silently overwrite.
2. Surface: "This conflicts with [memory X]. Following your current instruction —
   update stored memory?"
3. Write only after user confirms.

---

## Memory scopes

user/        Long-lived preferences. Updated on explicit correction only.
             Never written from a single session instance.
task/        One file per active task. Closed by moving to operational/ on completion.
project/     Architecture decisions, relationship context, ongoing themes.
operational/ Append-only. Source-tagged. Every session summary and action.
deleted/     Tombstones only. Format: # DELETED [timestamp] — [reason]

---

## Implementation

Scripts under **`skills/memory-write/scripts/`** in the corpus repo:
- `write_file.sh <filepath> <commit_message>` — body on **stdin** (pipe or heredoc).
- `append_log.sh "<entry>"` — appends one line to `operational/action-log.md`.
- `discord_notify.sh` — see **After every write** above.

GitHub Contents API (PUT). Base64-encode content.
Always include current file SHA when updating existing files (API requirement).
Commit message: memory: [scope] [description] — [timestamp]
When updating index alongside a file: single commit, both files.
Log the returned commit SHA to operational memory.
Repo: GITHUB_MEMORY_REPO. Auth: GITHUB_TOKEN.
