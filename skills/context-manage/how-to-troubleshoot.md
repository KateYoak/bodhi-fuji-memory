# Context-manage — troubleshoot

You are working in the **memory repo root** (`MEMORY_CLONE_PATH`). Use **Read**, **Glob**, and **Bash** on `skills/context-manage/scripts/…` only.

---

## How to tell what's in the bundle

The bundle is the fixed bootstrap files the gateway may prepend. It is **not** the whole conversation.

1. **Read** `bootstrap/bundle-config` if it exists — one line: `complete`, `basic`, or `minimal`.
2. If missing, treat the preset as **`complete`** unless Anandaka or ops said otherwise.
3. **Read** the files for that preset:

| Preset | Read |
|--------|------|
| `complete` | `bootstrap/SOUL.md`, `USER.md`, `AGENTS.md`, `MEMORY_INDEX.md` |
| `basic` | `SOUL.md`, `USER.md`, `AGENTS.md` |
| `minimal` | `AGENTS.md` |

That is the full bundle **on disk**.

To change the preset (does **not** clear thread session):

```bash
bash skills/context-manage/scripts/write_bundle_config.sh basic
```

**Read** `bootstrap/bundle-config` again to confirm.

---

## How to tell what's in context

Two layers — do not confuse them.

### A. On disk (you can always check with Read / Glob)

| File | Meaning |
|------|---------|
| Bundle files (above) | What **can** be prepended on a **new** thread session |
| `bootstrap/ACTIVE_CONTEXT.md` | Curated summary saved for the next fresh load |
| `bootstrap/.ACTIVE_CONTEXT_backups/*.md` | Older copies; filename has UTC time of the overwrite |

Disk files can be **newer or older** than what the gateway actually sent you this turn.

### B. In **this turn** (what the gateway actually gave you)

Look at the **user message** for this turn (the block that starts with `New message arrives:`).

- **Bundle was prepended** — you see SOUL / USER / AGENTS / MEMORY_INDEX (per preset) **above** `New message arrives:`. The gateway started (or restarted) a session and injected bootstrap for this thread.
- **Bundle was not prepended** — you go straight to `New message arrives:` and the user text. The gateway is **resuming** this thread’s stored session. Live context is that session’s history plus this message — **not** re-listed in the repo. It is **larger** than the bundle and grows every turn.

You **cannot** Read the full resumed session from a file. You only have what is already in this conversation plus the disk files above.

**Session compaction** is not a script you run. Anandaka (or ops) sends **`!fu compact`** (or **`/compact`**) **in Discord** as a normal channel message. The gateway then runs a compaction-only turn on this thread’s session. That does not update `ACTIVE_CONTEXT.md` and does not load a fresh bundle. If the session feels too large and you cannot reset yet, ask her to send that command.

---

## How to tell if context got reset (or how long ago)

**Reset** = this Discord thread’s stored session was cleared. The **next** user message should show the bundle prepended again (section B).

### Did reset finish after you ran `write_active_context.sh`?

Run the writer **in the Discord turn** that is handling you (gateway sets the post channel for your shell).

1. Bash must **exit 0**. Read stderr for:  
   `resume-clear marker … + Discord post (nonce …)`  
   Note the **nonce**.
2. **Glob** `bootstrap/.bodhi_resume_clear.*.json`  
   - File **present** right after the script: request is on disk; gateway clears it when the turn ends.  
   - File **gone** on a later turn: gateway consumed it (reset path ran).
3. When **you** get the next user message on this thread: check section B — bundle prepended again means a fresh session load.

If the script exits non-zero, reset did **not** start. Fix in **How to fix**.

You do **not** need to search old channel messages. The script posts a Bodhi line when Discord env is set; the gateway posts a matching ack when the turn completes. If you are unsure, use steps 1–3 (stderr, marker Glob, next-turn bootstrap).

### When was `ACTIVE_CONTEXT.md` last replaced?

Not the same as session reset, but the repo timestamp you **can** read:

1. **Glob** `bootstrap/.ACTIVE_CONTEXT_backups/ACTIVE_CONTEXT.*.md`
2. Newest filename suffix is UTC time of the last overwrite (e.g. `…2026-05-15T12:34:56Z.md`).
3. **Read** `bootstrap/ACTIVE_CONTEXT.md` for the current text.

---

## How to fix things that go wrong

### Bundle wrong for next fresh load

1. **Read** bundle files and `bootstrap/bundle-config`.
2. Run `write_bundle_config.sh` with the right preset; **Read** `bundle-config` again.
3. Session may still be resumed until you clear it (below).

### `ACTIVE_CONTEXT.md` wrong on disk

1. **Read** current file and backups if you need the old text.
2. Recompose per `SKILL.md` Phase 2.
3. Run:

```bash
bash skills/context-manage/scripts/write_active_context.sh <<'EOF'
(full body)
EOF
```

Use a **Discord** turn if you need session reset; use a non-Discord run if you only want the file updated (no marker, no resume clear).

### Thread still “remembers” old conversation (need reset)

1. Complete Phase 1–2 in `SKILL.md` when this is end-of-session.
2. In the **same Discord turn**, run `write_active_context.sh` (heredoc above).
3. Confirm exit 0, stderr nonce, then marker consumed (Glob gone on next turn) and bundle prepended on the next user message.
4. If Anandaka used **`!fu skill run context-manage`**, you are already in that forced turn — still run `write_active_context.sh` before the turn ends; gateway errors if the marker never completes.

### Symptom → fix

| Symptom | Fix |
|---------|-----|
| Script fails or no nonce in stderr | Not a Discord turn, or `post-message` failed. Read stderr; re-run in a Discord-handled turn. |
| Marker file still there after several turns | Turn did not finish or clear failed. Re-run writer on a new Discord message; ops may check gateway logs. |
| Forced skill error about marker | Run `write_active_context.sh` again **before** that forced turn ends. |
| Disk bundle correct but no bootstrap in your user message | Resumed session. Run reset flow above, or ask Anandaka to send **`!fu compact`** if she only wants the current session shrunk. |
| User says context feels huge | Ask her to send **`!fu compact`** to shrink the resumed session, **or** run `write_active_context.sh` on a Discord turn for a fresh load with curated disk context. |
