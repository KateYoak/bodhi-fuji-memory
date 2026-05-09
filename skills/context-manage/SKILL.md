---
name: context-manage
description: >
  Curate and persist the next thread bootstrap: summarize what must stay in play, write it
  via the corpus script so the gateway picks up ACTIVE_CONTEXT without spamming Discord.
metadata:
  openclaw:
    requires: {}
---

# Context management (`ACTIVE_CONTEXT`)

When **`!fu skill run context-manage`** is used, the gateway expects **`bootstrap/ACTIVE_CONTEXT.md`** to be updated by **your** run of the script below. Your **Discord reply must stay short** (one or two sentences). Put the full curated context **only** into stdin of the script — **do not** paste the full replacement context into the channel.

---

## Required action (forced invocation)

1. **Compose** the replacement bootstrap body in Markdown: what matters for the next turns (facts, goals, constraints). This replaces the default SOUL/USER/AGENTS bundle while `ACTIVE_CONTEXT.md` exists.

2. **Pipe it into the writer script** (run from the memory repo root — `MEMORY_CLONE_PATH`; Bash tool cwd is that root):

   ```bash
   bash skills/context-manage/scripts/write_active_context.sh <<'EOF'
   <your summary markdown body — no need for outer quotes>
   EOF
   ```

   Or use a here-doc without quotes only if you avoid fragile shell characters.

3. **Reply briefly** in Discord only, e.g. “Active context written; next turn loads from `ACTIVE_CONTEXT.md`.” Do **not** include the full file body in the reply.

---

## Script behavior

- **`skills/context-manage/scripts/write_active_context.sh`** reads **stdin**, applies a **max size** check (`BODHI_ACTIVE_CONTEXT_MAX_BYTES`, default 500000), writes **`bootstrap/ACTIVE_CONTEXT.md`** with a short generated header and your body.

---

## Related (not this skill’s job)

- **Native compaction:** `!fu compact` / `/compact` — Claude Code session compaction; different from replacing bootstrap text.
- **Guidance:** You may still explain when to compact vs start a new thread vs persist facts to corpus memory — but the **forced path** must complete the script write when Anandaka invoked this skill for a reset.
