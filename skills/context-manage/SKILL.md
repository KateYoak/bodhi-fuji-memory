---
name: context-manage
description: >
  Curate bootstrap for upcoming turns: optionally set the corpus bundle preset (complete / basic /
  minimal), write ACTIVE_CONTEXT.md via script, so the gateway loads bundle + active layer without
  pasting walls of text into Discord.
metadata:
  openclaw:
    requires: {}
---

# Context management (bundle + `ACTIVE_CONTEXT`)

When **`!fu skill run context-manage`** is used, you persist **on-disk** state under the memory repo root (`MEMORY_CLONE_PATH`). The gateway **never** runs these scripts at session start; it only **reads** the files you write.

**What loads into the prompt (in order):**

1. **Bundle** — fixed corpus files from preset **`complete`**, **`basic`**, or **`minimal`** (see below). Resolved from **`bootstrap/bundle-config`** (first line) if that file exists, else env **`BODHI_BOOTSTRAP_BUNDLE`**, else **`complete`**.
2. **`bootstrap/ACTIVE_CONTEXT.md`** — optional curated layer **after** the bundle (only if the file exists).

Your **Discord reply must stay short** (one or two sentences). Put long markdown **only** into the scripts' stdin — **do not** paste full replacement context into the channel.

---

## Bundle presets (optional change each run)

| Preset | Files loaded |
|--------|----------------|
| **`complete`** (default) | `SOUL.md`, `USER.md`, `AGENTS.md`, `MEMORY_INDEX.md` |
| **`basic`** | `SOUL`, `USER`, `AGENTS` — **no** `MEMORY_INDEX` |
| **`minimal`** | `AGENTS.md` only |

**To set or change the preset**, run from the memory repo root (Bash tool cwd = that root):

```bash
bash skills/context-manage/scripts/write_bundle_config.sh <<'EOF'
basic
EOF
```

**To write `ACTIVE_CONTEXT.md`**, compose your summary as markdown. Use single quotes in the heredoc to protect shell interpretation:

```bash
bash skills/context-manage/scripts/write_active_context.sh <<'EOF'
   <your summary markdown body>
   EOF
```

Or use an unquoted here-doc only if the body avoids fragile shell characters.

---

## Summarization Instructions

**BEFORE YOU COMPOSE — Required first steps:**

1. **Read the previous ACTIVE_CONTEXT.md** — Fetch `/data/memory/bodhi-fuji-memory/bootstrap/ACTIVE_CONTEXT.md` and read it fully.
2. **Extract the arc** — Identify what Big Picture and Next Horizon were there. This is the thread you must not break.
3. **Assess continuity** — Does that arc still hold? Has it shifted? Is it complete? Note this explicitly before composing.
4. **Only then compose** — Write your new summary in three layers, ensuring the new Big Picture preserves and extends (or deliberately shifts) what was there.

**Compose in three layers:**

1. **Big picture** — Why does this work matter? What are you building toward? (Preserve this from the previous context if it still holds; note explicitly if it has shifted.)
2. **Current turn** — What did you discover? What changed? What advanced the work? What specific task was completed?
3. **Next horizon** — What question does this raise? What needs testing next? What's on the edge?

**Critical principle:** You cannot lose the thread. Each summary inherits the arc from the previous one. The conversation has shape across iterations, not just within a single turn. The details serve the larger work. Each reader should see not just where you are right now, but where you're heading.

**Implementation note:** Timestamped backups are automatically created in `bootstrap/.ACTIVE_CONTEXT_backups/`. The context-review skill can retrieve them if you need to analyze context evolution across multiple iterations.

---

## Script behavior

- **`write_bundle_config.sh`** — validates **`complete` \| `basic` \| `minimal`**, writes **`bootstrap/bundle-config`** (single line).
- **`write_active_context.sh`** — reads stdin, applies **`BODHI_ACTIVE_CONTEXT_MAX_BYTES`** (default 500000), **backs up the previous version with ISO 8601 timestamp** to `bootstrap/.ACTIVE_CONTEXT_backups/ACTIVE_CONTEXT.YYYY-MM-DDTHH:MM:SSZ.md`, then writes **`bootstrap/ACTIVE_CONTEXT.md`** with only your body content (no auto-generated headers). Backups are created before overwriting, so you can safely review what changed between iterations.

---

## Related (not this skill's job)

- **Native compaction:** `!fu compact` / `/compact` — Claude Code session compaction; separate from bootstrap files.
- **Context review:** The `context-review` skill reads timestamped backups and helps understand how context evolved across iterations.
- **Guidance:** You may explain compact vs new thread vs corpus memory — but when this skill is forced for reset, the gateway expects **`ACTIVE_CONTEXT.md`** to be refreshed on disk (see gateway validation); changing the bundle is optional unless requested.
