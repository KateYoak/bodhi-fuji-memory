---
name: context-manage
description: >
  Curate bootstrap for upcoming turns: you choose the corpus bundle preset (complete / basic /
  minimal), write ACTIVE_CONTEXT.md via script, so the gateway loads bundle + active layer without
  pasting walls of text into Discord. After a successful run, the gateway clears this thread's
  Claude resume when ACTIVE_CONTEXT was refreshed on disk.
metadata:
  openclaw:
    requires: {}
---

# Context management (bundle + `ACTIVE_CONTEXT`)

You persist **on-disk** state under the memory repo root (`MEMORY_CLONE_PATH`). The gateway **never** runs these scripts at session start; it only **reads** the files you write.

**What loads into the prompt on the next turn (in order):**

1. **Bundle** — corpus files from preset **`complete`**, **`basic`**, or **`minimal`**. Resolved from **`bootstrap/bundle-config`** (first line) if that file exists, else env **`BODHI_BOOTSTRAP_BUNDLE`**, else **`complete`**.
2. **`bootstrap/ACTIVE_CONTEXT.md`** — curated layer **after** the bundle (only if the file exists).

**After you succeed:** When this skill finishes with **`ACTIVE_CONTEXT.md`** updated (script write, mtime advanced), the **Discord gateway clears this channel/thread's resume** so the next user message reinjects bundle + active context — same rule as **`!fu skill run context-manage`**. If you do not run **`write_active_context.sh`**, resume is **kept**.

Your **Discord reply must stay short** (one or two sentences). Put long markdown **only** into the scripts’ stdin — **do not** paste full replacement context into the channel.

---

## Which bundle? (you decide)

| Preset | When to use | Files loaded |
|--------|----------------|--------------|
| **`complete`** | **Full conversation with Anandaka** — relationship, teaching, memory index, the whole stance | `SOUL.md`, `USER.md`, `AGENTS.md`, `MEMORY_INDEX.md` |
| **`basic`** | Middle weight: identity + agents, less index bulk | `SOUL`, `USER`, `AGENTS` — **no** `MEMORY_INDEX` |
| **`minimal`** | **Pure engineering work** — tickets, code, infra; keep token load low | `AGENTS.md` only |

**To set or change the preset**, run from the memory repo root (Bash tool cwd = that root):

```bash
bash skills/context-manage/scripts/write_bundle_config.sh <<'EOF'
complete
EOF
```

Or pass the id as the only argument: `bash skills/context-manage/scripts/write_bundle_config.sh minimal`

**Skip changing the bundle** if Anandaka did not ask for a different mode and the current preset should stay (omit **`bundle-config`** change or leave the file as-is).

---

## ACTIVE_CONTEXT (required for resume reset)

1. **Compose** the curated markdown: facts, goals, constraints that should ride on top of the bundle for the next turns.

2. **Pipe it into the writer** (same cwd — memory repo root):

   ```bash
   bash skills/context-manage/scripts/write_active_context.sh <<'EOF'
   <your summary markdown body>
   EOF
   ```

   Or use an unquoted here-doc only if the body avoids fragile shell characters.

3. **Reply briefly** in Discord, e.g. “Set bundle to `minimal`; active context written.” Do **not** include the full file body in the reply.

---

## Script behavior

- **`write_bundle_config.sh`** — validates **`complete` \| `basic` \| `minimal`**, writes **`bootstrap/bundle-config`** (single line).
- **`write_active_context.sh`** — reads stdin, applies **`BODHI_ACTIVE_CONTEXT_MAX_BYTES`** (default 500000), writes **`bootstrap/ACTIVE_CONTEXT.md`** with a short generated header and your body.

---

## Related (not this skill’s job)

- **Native compaction:** `!fu compact` / `/compact` — Claude Code session compaction; separate from bootstrap files.
- **Guidance:** You may explain compact vs new thread vs corpus memory. The gateway only clears resume when **`ACTIVE_CONTEXT.md`** was refreshed this turn (validated mtime / creation).
