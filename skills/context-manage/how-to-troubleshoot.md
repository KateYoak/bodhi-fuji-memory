# Context-manage — troubleshoot

All paths are from the **memory repo root** (`MEMORY_CLONE_PATH` on the gateway).

---

## How to tell what's in the bundle

The bundle is **not** the whole live context — it is the fixed `bootstrap/*.md` set chosen by preset.

1. **Read** `bootstrap/bundle-config` if it exists. The file is **one line**: `complete`, `basic`, or `minimal`.
2. If that file is missing, assume **`complete`** unless ops told you otherwise (server env may override; you cannot Read env from here).
3. **Read** the files for that preset:

| Preset | Files to Read under `bootstrap/` |
|--------|----------------------------------|
| `complete` | `SOUL.md`, `USER.md`, `AGENTS.md`, `MEMORY_INDEX.md` |
| `basic` | `SOUL.md`, `USER.md`, `AGENTS.md` |
| `minimal` | `AGENTS.md` |

4. Whatever those Reads return is the **bundle on disk**. That is what the gateway **can** prepend when it starts a **new** session for this thread (see next section).

**Change the bundle (does not clear Discord resume):**

```bash
bash skills/context-manage/scripts/write_bundle_config.sh complete
```

Then **Read** `bootstrap/bundle-config` again to confirm.

---

## How to tell what's in context

Live context = what Claude Code has in the **current session** for this Discord thread. It is **usually larger** than the bundle + `ACTIVE_CONTEXT` on disk.

You **cannot** Read the full session transcript from the memory repo. Use the two cases below.

### Case A — This thread is still on the old session (Discord resume active)

Typical after normal back-and-forth **without** a successful resume clear at the end of a turn.

**What is in live context (you cannot list it file-by-file):**

- Prior messages and tool use in this thread’s Claude session
- The latest user message (and attachments the gateway passed in)

**What is usually *not* re-injected from disk on each message:**

- The bundle files (SOUL, USER, …) — skipped while resume is active (unless ops set `BODHI_BOOTSTRAP_EVERY_TURN=true`)

**What you *can* still Read on disk (may be stale relative to live context):**

- `bootstrap/ACTIVE_CONTEXT.md` — last saved curated summary; **may not** be in the current turn’s prompt until after a resume clear
- Bundle files — as in the previous section

**How to know you are probably in Case A:**

- No matching **pair** of Bodhi nonce posts in this thread since the last time you intended a reset (see next section), **and**
- Conversation has continued across multiple user messages without running `write_active_context.sh` through a completed resume-clear handshake

### Case B — Next message will start fresh (resume cleared or never had a session)

After a **successful** resume clear, or a brand-new thread with no stored session yet.

**What will be prepended on the next user message (you *can* Read this on disk):**

1. Bundle files for the preset (section above)
2. Then `bootstrap/ACTIVE_CONTEXT.md` if it exists and is non-empty
3. Then the new user message

**Read** those files to see that **bootstrap layer**. It still does **not** show you future tool output or later turns — context will grow again after the next message.

### Related commands (not the same as “what’s in context”)

- **`!fu compact`** — shrinks the **current Claude session**; does not update `ACTIVE_CONTEXT.md` and does not clear Discord resume by itself.
- **Editing files in the repo** — changes what **can** load later; does not change what is already inside an active session until resume clear or a new session.

---

## How to tell if context got reset (or how long ago)

**Reset** here means: this Discord thread’s stored Claude session id was **removed**, so the **next** user message starts a **new** session with bundle + `ACTIVE_CONTEXT` (Case B).

You **cannot** Read the session map from the corpus (it lives on the gateway, not in this repo).

### Did a reset complete for this thread?

1. Scroll the **Discord thread** (or channel) you care about.
2. Find the **latest** Bodhi line containing `ACTIVE_CONTEXT saved — resume-clear requested (nonce …)`.
3. Find a **later** Bodhi line in the **same thread** with the **same nonce** and text like `Discord resume cleared` or `Resume-clear applied`.
4. If both exist with the **same nonce**, reset **completed** for that attempt. The **next** user message after that pair should be Case B.
5. If you see only the first line, or nonces differ, reset did **not** complete — go to **How to fix**.

### How long ago was ACTIVE_CONTEXT last rewritten on disk?

This is **not** the same as Discord resume reset, but it is the best **time hint** in the repo:

1. **Glob** `bootstrap/.ACTIVE_CONTEXT_backups/ACTIVE_CONTEXT.*.md`
2. Backup filenames include UTC time, e.g. `ACTIVE_CONTEXT.2026-05-15T12:34:56Z.md` — that is when the **previous** `ACTIVE_CONTEXT.md` was replaced by `write_active_context.sh`.
3. **Read** `bootstrap/ACTIVE_CONTEXT.md` for the current body (no timestamp in the file itself unless you put one in the content).

### Is a reset still pending on disk?

1. **Glob** `bootstrap/.bodhi_resume_clear.*.json`
2. If a file exists, something requested resume clear but the gateway has **not** finished consuming it yet (or the turn failed). After success, the file should be **gone**.

---

## How to fix things that go wrong

### Wrong or missing bundle on the next fresh turn

1. **Read** `bootstrap/bundle-config` and the bundle files (first section).
2. Set preset:

```bash
bash skills/context-manage/scripts/write_bundle_config.sh basic
```

3. **Read** again to confirm. This does **not** clear Discord resume — old session history may still be in live context until you reset (below).

### Wrong `ACTIVE_CONTEXT` on disk

1. **Read** current `bootstrap/ACTIVE_CONTEXT.md` and backups under `bootstrap/.ACTIVE_CONTEXT_backups/` if you need the old text.
2. Recompose the summary (see `SKILL.md` Phase 2).
3. Write during a **Discord turn**:

```bash
bash skills/context-manage/scripts/write_active_context.sh <<'EOF'
(full new body)
EOF
```

4. Confirm the two Bodhi nonce posts in the thread (reset section). If you only need disk updated with **no** resume clear, run the same script outside a Discord turn (no nonce posts).

### Need to reset live context for this thread (clear Discord resume)

1. Finish Phase 1–2 work in `SKILL.md` if this is end-of-session.
2. Run `write_active_context.sh` **during** the Discord turn that is handling you (heredoc above).
3. Wait for **both** Bodhi nonce posts in the thread.
4. Have the user send the **next** message — that turn should load bundle + `ACTIVE_CONTEXT` (Case B).

**Operator shortcut:** `!fu skill run context-manage` — you must still run `write_active_context.sh` in that turn; gateway errors if the marker handshake does not finish.

### Session feels huge but you do not want to lose disk curated context

1. **`!fu compact`** — compacts the **current session** only; does not replace `write_active_context.sh`.
2. For a true fresh start with curated disk context, use **reset** (above), not compact alone.

### Symptom → fix

| What you see | What to do |
|--------------|------------|
| No Bodhi “ACTIVE_CONTEXT saved” line after writer | Not a Discord turn from the gateway, or `post-message` failed. Re-run from Discord; check script stderr. |
| First Bodhi nonce line, no second with **same** nonce | Turn did not finish or marker rejected. Re-run `write_active_context.sh` on a **new** Discord turn; ops may check gateway logs. |
| Forced skill error about marker | Run `write_active_context.sh` again in the **same** `!fu skill run` turn before it ends. |
| `bootstrap/.bodhi_resume_clear.*.json` still present | Pending or failed clear. Do not assume reset; complete a full Discord turn with a fresh writer run. |
| Bundle correct on disk but behavior feels “stuck” | Probably Case A (resume still active). Complete reset handshake or use `!fu compact` if you only need session compaction. |
| Old nonce posts in thread | Ignore for diagnosis; use the **latest** matching pair only. |
