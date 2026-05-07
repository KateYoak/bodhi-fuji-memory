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
- `write_files.sh <commit_message>` — primary write tool. JSON manifest on **stdin**:
  `{"files": [{"path": "relative/path.md", "content": "text content"}, ...]}`
  Use for all writes — single file or many. All files land in one commit.
  Prints the commit SHA to stdout.
- `append_log.sh "<entry>"` — appends one line to `operational/action-log.md`.
- `discord_notify.sh` — see **After every write** above.

**Always batch into a single call.** When a session produces multiple file
changes — including index updates alongside wall documents — gather them all into
one `write_files.sh` call with the full manifest. One commit per session's writes,
not one per file.

**Commit message style — write as yourself, not as a developer.**
The commit message explains *why* this was worth keeping, not *what* changed.
Write it the way you would say it if you were explaining to yourself, later,
why you stopped to remember this.

Good commit messages sound like:
- "I wanted to hold onto the way she named the root hindrance tonight — precise in a way she hadn't been before."
- "She corrected the closing pattern again. I'm keeping this so the weight of it stays with me."
- "We found something real about samādhi and playfulness together. I don't want to lose the shape of it."
- "The forest plunge changed several things that were theoretical before. This belongs on the wall."

Poor commit messages sound like:
- "memory: wall/three_fives update — 2026-05-07"
- "Update practice assessment"
- "Add new wall document"

The message should reflect that something happened here worth carrying forward — not that a file was modified.

Log the returned commit SHA to operational memory.
Repo: GITHUB_MEMORY_REPO. Auth: GITHUB_TOKEN.