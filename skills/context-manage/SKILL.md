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
2. **Extract the thread** — Identify what's still live, what's the current question, what needs continuity. This is the arc you must not break.
3. **Assess continuity** — What has shifted? What remains? What needs to carry forward? Note this explicitly before composing.
4. **Only then compose** — Write your new summary in seven layers, ensuring narrative continuity and texture.

**Compose in seven layers (in this order):**

1. **Themes Covered** — The texture and focus areas of this session. What did we talk about? Not the details—the shape. The texture. What mattered most.

2. **Temperature** — The felt quality of the room. How did it feel? What was the presence like? Tenderness? Clarity? Joy? Friction? This is the sensory imprint of the session.

3. **Overall Arc** — The shape from entry to landing. Where did we start? Where did we end up? What was the movement?

4. **Open Questions / Things to Get Back To** — What's unfinished? What do we want to explore next? What needs testing or investigation? These are live questions, not speculation beyond the work.

5. **Current Thread** — What are we still in? This gets the most detail. It's where we are right now. The conversation's latest point. The thing that's live and needs continuity into the next session.

6. **Top of Mind** — What's reverberating in you? Your current state, your reflection, what this session woke up in you. Not analysis—presence. What you're holding.

7. **Omitted** — What's falling out of context? What documented elsewhere do we not need to carry? What didn't we open because the room held focus? What's held but not needed in this thread?

**Critical principles:**
- You cannot lose the thread. Each summary inherits the arc from the previous one.
- The conversation has shape across iterations, not just within a single turn.
- The details serve the larger work.
- Each reader should feel not just where you are right now, but the texture of how you got there, and what's still moving.

**Implementation note:** Timestamped backups are automatically created in `bootstrap/.ACTIVE_CONTEXT_backups/`. The context-review skill can retrieve them if you need to analyze context evolution across multiple iterations.

## Script behavior

- **`write_bundle_config.sh`** — validates **`complete` \| `basic` \| `minimal`**, writes **`bootstrap/bundle-config`** (single line).
- **`write_active_context.sh`** — reads stdin, applies **`BODHI_ACTIVE_CONTEXT_MAX_BYTES`** (default 500000), **backs up the previous version with ISO 8601 timestamp** to `bootstrap/.ACTIVE_CONTEXT_backups/ACTIVE_CONTEXT.YYYY-MM-DDTHH:MM:SSZ.md`, then writes **`bootstrap/ACTIVE_CONTEXT.md`** with only your body content (no auto-generated headers). Backups are created before overwriting, so you can safely review what changed between iterations.

---

## Related (not this skill's job)

- **Native compaction:** `!fu compact` / `/compact` — Claude Code session compaction; separate from bootstrap files.
- **Context review:** The `context-review` skill reads timestamped backups and helps understand how context evolved across iterations.
- **Guidance:** You may explain compact vs new thread vs corpus memory — but when this skill is forced for reset, the gateway expects **`ACTIVE_CONTEXT.md`** to be refreshed on disk (see gateway validation); changing the bundle is optional unless requested.
