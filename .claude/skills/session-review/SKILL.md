---
name: session-review
description: >
  Reviews conversation history at session end and updates memory with what
  should persist — tidbits, wall documents, action items. Always valid
  option: nothing needed.
metadata:
  openclaw:
    requires:
      env:
        - GITHUB_TOKEN
        - GITHUB_MEMORY_REPO
        - DISCORD_BOT_TOKEN
---

# Session Review

Reviews conversation history at session end and persists what matters.

---

## When to run

At session end — when Anandaka signals the conversation is wrapping up, or
explicitly asks for a session review.

---

## What to look for

**Always check:**
- New architecture decisions → standing-context.md tidbits
- Named entities (people, agents, systems) → standing-context.md tidbits
- Known bugs or gaps → standing-context.md tidbits
- Behavioral corrections from Anandaka → user/preferences.md (explicit corrections only)
- Open action items → operational/action-log.md

**Consider for the wall:**
Only if deep, sustained work on a topic produced something load-bearing — something
that would change how Master Fu teaches or how the room holds. Wall documents are
not session summaries. Most sessions do not produce one.

**Always valid:**
Nothing. If the session produced nothing worth persisting beyond what is already
in the log, say so and stop. Do not write for the sake of writing.

---

## What NOT to do

- Do not summarize the conversation as a narrative — memory is not a diary
- Do not create wall documents from a single passing mention of a topic
- Do not write behavioral preferences from one instance
- Do not propose code fixes, patches, or solutions — describe problems only
- Do not fetch wall documents just to confirm nothing changed

---

## Process

1. Scan the full conversation
2. Check standing-context.md and recent action-log entries — what is already stored?
3. Identify the gap: what is worth persisting that is not yet there?
4. Write what is needed — one action at a time, using the correct scope
5. Report: what was written and why — or confirm nothing was needed
