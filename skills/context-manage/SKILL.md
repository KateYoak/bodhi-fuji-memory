---
name: context-manage
description: >
  Guide context hygiene in long Discord threads: when to compact, when to start
  a new thread, and how to preserve critical facts in corpus memory.
metadata:
  openclaw:
    requires: {}
---

# Context management

Use this skill when the conversation is long, stale after resume, or the user
asks about memory-window pressure.

---

## What the runtime already does

- Auto-compact near the configured context window.
- Optional compact-on-resume preflight when enabled by operator flag.
- Manual compaction command in Discord: `!fu compact` (or `/compact`).

---

## How to guide the user

- If the thread feels overloaded, suggest `!fu compact`.
- If continuity is no longer useful, suggest a new thread for a fresh session.
- If a fact must persist, write it to corpus memory (for example wall or
  operational logs) rather than relying on session history.

---

## Important boundary

This skill is advisory. It does not execute compaction by itself. Use the
runtime command path for compaction actions.
