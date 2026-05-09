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

Your **Discord reply must stay short** (one or two sentences). Put long markdown **only** into the scripts’ stdin — **do not** paste full replacement context into the channel.

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

Or pass the id as the only argument: `bash skills/context-manage/scripts/write_bundle_config.sh basic`

**Skip this** if Anandaka did not ask to change the bundle and the current preset should stay as-is (omit **`bundle-config`** or leave it unchanged; gateway keeps using it once written, or falls back to env / `complete`).

---

## ACTIVE_CONTEXT (required for forced reset path)

1. **Compose** the curated markdown: facts, goals, constraints that should ride on top of the bundle for the next turns.

2. **Pipe it into the writer** (same cwd — memory repo root):

   ```bash
   bash skills/context-manage/scripts/write_active_context.sh <<'EOF'
   <your summary markdown body>
   EOF
   ```

   Or use an unquoted here-doc only if the body avoids fragile shell characters.

3. **Reply briefly** in Discord, e.g. “Bundle left at `basic`; active context written.” Do **not** include the full file body in the reply.

---

## Script behavior

- **`write_bundle_config.sh`** — validates **`complete` \| `basic` \| `minimal`**, writes **`bootstrap/bundle-config`** (single line).
- **`write_active_context.sh`** — reads stdin, applies **`BODHI_ACTIVE_CONTEXT_MAX_BYTES`** (default 500000), writes **`bootstrap/ACTIVE_CONTEXT.md`** with a short generated header and your body.

---

## Related (not this skill’s job)

- **Native compaction:** `!fu compact` / `/compact` — Claude Code session compaction; separate from bootstrap files.
- **Guidance:** You may explain compact vs new thread vs corpus memory — but when this skill is forced for reset, the gateway expects **`ACTIVE_CONTEXT.md`** to be refreshed on disk (see gateway validation); changing the bundle is optional unless requested.
