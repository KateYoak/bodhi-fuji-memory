# Context-manage — inspect, change, troubleshoot

All paths are from the **memory repo root** (on Fly: `MEMORY_CLONE_PATH`).

---

## What these pieces are (one sentence each)

- **Bundle** — which fixed `bootstrap/*.md` files get loaded on a **new** Claude session (`complete` / `basic` / `minimal`).
- **`ACTIVE_CONTEXT.md`** — your curated summary; loaded **after** the bundle when the gateway injects bootstrap.
- **Discord resume** — the gateway remembers a Claude session id **per thread** so the next message continues the same session. You cannot read that id from a file in the repo.
- **`!fu compact`** — compacts the **current Claude session** only. It does **not** change `ACTIVE_CONTEXT.md` or clear Discord resume.

---

## Check what is configured now

1. **Read** `bootstrap/bundle-config` if it exists. The whole file is **one line**: `complete`, `basic`, or `minimal`.
2. If that file is missing, assume **`complete`** unless someone told you the server env overrides it.
3. **Read** the bootstrap files for that preset:
   - `complete` → `bootstrap/SOUL.md`, `USER.md`, `AGENTS.md`, `MEMORY_INDEX.md`
   - `basic` → `SOUL.md`, `USER.md`, `AGENTS.md`
   - `minimal` → `AGENTS.md` only
4. **Read** `bootstrap/ACTIVE_CONTEXT.md` if you need the curated layer (skip if the file is missing).

There is no corpus tool that prints “token count.” To estimate size, use how much text **Read** returns for those files.

---

## Change only the bundle (does not clear Discord resume)

1. From repo root, run one of:

```bash
bash skills/context-manage/scripts/write_bundle_config.sh complete
```

```bash
printf '%s\n' minimal | bash skills/context-manage/scripts/write_bundle_config.sh
```

2. **Read** `bootstrap/bundle-config` and confirm the line changed.

---

## Save ACTIVE_CONTEXT and clear Discord resume (Discord turn)

Use this when you finished curating context and want the **next** user message in **this Discord thread** to start a **new** Claude session (bundle + `ACTIVE_CONTEXT`, no old session history).

### Run the writer

1. Compose the full markdown body (seven-layer summary from `SKILL.md` Phase 2).
2. Pipe it into the script **during the same Discord turn** that triggered you (so the gateway has set the post channel for your shell):

```bash
bash skills/context-manage/scripts/write_active_context.sh <<'EOF'
(paste full ACTIVE_CONTEXT body here)
EOF
```

3. If the script fails (non-zero exit), stop. Read stderr; fix and run again **in the same turn** if you are in a forced skill.

### What should happen in Discord (in order)

Do not infer success from disk alone. Look at the **thread** where you are working:

1. You may get a **discord-say** post with the ACTIVE_CONTEXT body (if that script exists on the machine).
2. You should get a **Bodhi** line like:  
   `ACTIVE_CONTEXT saved — resume-clear requested (nonce abc123…)`  
   Copy the **nonce** (the hex after `nonce`).
3. When **this Discord turn fully finishes**, you should get a **second Bodhi** line that mentions the **same nonce**, for example:  
   `Discord resume cleared (nonce abc123…). Next user message starts a new Claude session…`  
   or  
   `Resume-clear applied (nonce abc123…) — … nothing was persisted.`

4. If step 2 never appeared, the turn was not a Discord turn from the gateway’s point of view, or `post-message` failed — see **If something failed** below.
5. If step 2 appeared but step 3 never appeared, the turn did not complete the handshake — see **If something failed** below.

### Optional check on disk (after step 3)

1. **Glob** `bootstrap/.bodhi_resume_clear.*.json`.
2. After a successful clear, **no** such file should remain (the gateway deletes it when it posts step 3).

### What the next user message should do

After steps 2 and 3 matched on nonce, the **next** message in that thread should load bundle + `ACTIVE_CONTEXT` **without** continuing the old Claude Code session.

---

## Save ACTIVE_CONTEXT only (no Discord resume clear)

If you are **not** in a live Discord turn (local query, tests, or channel env unset):

1. Run the same `write_active_context.sh` heredoc as above.
2. Expect **only** `bootstrap/ACTIVE_CONTEXT.md` to update.
3. Expect **no** Bodhi nonce posts and **no** resume clear.

---

## Operator: force the skill from Discord

Send: `!fu skill run context-manage`

You must still run `write_active_context.sh` inside that turn. If the second Bodhi nonce post does not appear, the forced turn should error — run the writer again in the same forced turn.

---

## If something failed

| What you see | What to do |
|--------------|------------|
| No Bodhi “ACTIVE_CONTEXT saved” line | You were probably not on a Discord turn. Re-run from Discord, or accept disk-only write (no resume clear). |
| First Bodhi line, no second line with same nonce | Turn may have crashed or marker was rejected. Ask ops to check gateway logs. Re-run `write_active_context.sh` on a **new** Discord turn. |
| Forced skill errors about “marker” | Run `write_active_context.sh` again in the **same** `!fu skill run` turn before it ends. |
| Old nonce in thread | Ignore it. Each run creates a **new** nonce; only the latest pair matters for that attempt. |

---

## Approximate “how big is context”

1. **Read** the bundle files for your preset plus `ACTIVE_CONTEXT.md`.
2. That text is what gets prepended on a **fresh** session turn — not the full hidden Claude transcript.
3. For API usage and traces, use operator Datadog / dashboards (not available as a corpus Read).
