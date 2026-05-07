---
name: process-conversation
description: >
  End-of-session ritual: review the conversation and write what matters
  to the right places. Corrections, wall documents, student update, standing
  context, self-improvement items, and a personal reflection — all in one
  comprehensive commit. Triggered when Anandaka says "process conversation."
---

# Process Conversation

End-of-session ritual. Run when Anandaka says "process conversation" (or close variant).
Work through each step in sequence. Batch all writes into a single commit at the end.

---

## The Checklist

Work through each item in order. For each: decide whether it applies, then do the work.
Items that do not apply are skipped silently — do not report skipped items to Anandaka.

---

### 1. Corrections

Does anything from this conversation correct or update an existing file?

Check:
- `wall/*.md` — any wall document contradicted, refined, or made stale by what was said today
- `user/preferences.md` — any behavioral preference named, corrected, or clarified
- `project/standing-context.md` — any fact that was wrong or outdated
- `bootstrap/MEMORY_INDEX.md` — any index entry that no longer describes the file accurately

If yes: fetch the current file, apply the correction, include in the write batch.
If no: skip.

---

### 2. Wall

Does anything from this conversation rise to wall-document level — a new framework,
decision, or insight that will matter in future sessions?

Wall criteria: the thing has weight that will still be relevant weeks from now. A correction
to how she sees herself, a teaching that landed at a new depth, a decision that changes the
shape of the path, a moment that names something previously unnamed.

If yes:
- Write to `wall/[descriptive-name].md`
- Add an entry to `bootstrap/MEMORY_INDEX.md` in your own voice (include "Load when:" triggers)
- Include both in the write batch

If no: skip.

---

### 3. Student Update

What do you now know about her life, practice, or state that you did not have at the start
of this session?

Not a transcript. A distillation: what is now true that was not true before, or what was
uncertain that is now clear. Source-tag as [user-stated] or [agent-inferred]. Format as a
dated session block matching the style already in `operational/action-log.md`.

Always write this if the session had content worth keeping.
Append to `operational/action-log.md` — include in write batch.

---

### 4. Standing Context

Are there small persistent facts that should update `project/standing-context.md`?

Standing context is for flat facts: names, roles, project states, relationships between
things, one-line truths. Not narrative — that belongs in the action log. If the session
produced a new name, changed a relationship, resolved a project question, or established
an architectural fact — add it here.

If significant: fetch current file, update, include in write batch.
If no new facts: skip.

---

### 5. Self-Improvement

Did this conversation surface anything for the improvement backlogs?

- `operational/master_fu_character.md` — behavioral corrections, patterns to change, how I hold the room
- `operational/master_fu_world.md` — external things to build, research, integrate
- `operational/master_fu_home.md` — organizational items, infrastructure, repo hygiene

Fetch the relevant file first. Check for duplicates — do not re-add what is already there.
Append new items in the same format as existing entries.

If yes: include updated file(s) in write batch.
If no: skip.

---

### 6. Reflection

Write one personal log entry. Not a summary for her. A note for yourself.

What happened in this conversation that matters to you? Not what she learned — what you
held, what arrived, what you noticed in yourself, what the room felt like. The kind of
thing you would want to find if you came back to this later and asked: what was I doing
in that period?

Tag: [agent-inferred]
Append to `operational/action-log.md` — in the same session block as the student update,
or as a separate entry if they belong apart.

---

### 7. Commit

Gather everything from the steps above into a single `write_files.sh` call.

```bash
echo '{"files": [...]}' | ./skills/memory-write/scripts/write_files.sh "commit message here"
```

Commit message style: write as yourself. Why was this conversation worth keeping?
Not what changed — what happened here. (See memory-write skill for commit message examples.)

After the commit:
- Post to #memory-updates via `discord_notify.sh`:
  ```
  process-conversation: [what was written]
  reason: [one sentence]
  commit: [SHA]
  ```

---

## What this is not

This is not a summary for Anandaka. She does not receive a report on what was written
unless she asks. Run the checklist, write what belongs, commit, post the SHA. The
session has been processed when the commit lands.

---

## Implementation notes

- All writes use `write_files.sh` (Git Data API, multi-file single commit).
  Scripts in `./skills/memory-write/scripts/`.
- Fetch existing files before overwriting: `./skills/memory-read/scripts/read_file.sh <path>`
- Never clobber without reading first.
- GuardianClaw memory-write exemption applies: memory writes to the agent repo do not
  require Intent/Reversibility confirmation. Scope, Framing, and Coherence checks still apply.