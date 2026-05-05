---
name: memory-files
description: >
  Read files anywhere under the memory corpus clone — including Discord uploads in
  .bodhi-discord-incoming/ — using Read with the right encoding (utf-8 for text;
  base64 for images and other binaries). Use when you need file contents in a later
  turn, SVG/raster re-read, or any path under bootstrap/, wall/, skills/, etc.
metadata:
  openclaw:
    requires: {}
---

# Memory files (read any path in the corpus)

You work with **`cwd` = the memory repo clone** (`MEMORY_CLONE_PATH`). **Read**, **Grep**, and **Glob** are already scoped to this tree — this skill is the **contract** for *how* to read different kinds of files.

---

## Discord uploads (temporary)

User attachments land under:

`.bodhi-discord-incoming/`

Files are named like `{discordMessageId}-{index}-{safeOriginalName}`. They are **ephemeral** (deleted after the bot finishes the turn) but while they exist you may **Read** them like any other path.

**Raster images** (PNG, JPEG, GIF, WebP) from Discord are usually **already in the current user message as native vision** when sent. Use this skill when:

- You need the file again in a **later** turn (if a copy still exists or the user re-uploads).
- The attachment was **SVG** or another type not sent as a native image block.
- You need **exact bytes** or a **subset** of a large file.

---

## Encoding — Read tool

| Kind | Read encoding | Notes |
|------|----------------|-------|
| Markdown, `.txt`, `.md`, code, JSON, etc. | Default (**utf-8**) | Normal corpus work. |
| PNG, JPEG, GIF, WebP, other binary | **`base64`** | Required so the tool returns usable bytes; the runtime can treat image results appropriately. |
| SVG (text XML) | **utf-8** *or* **base64** | If you need “see the graphic” and native vision was not used, try **base64** so the model receives an image-capable payload; otherwise utf-8 for source inspection. |

When calling **Read** on a binary path, pass the encoding your tool stack supports for images (see Claude Code **Read** parameters).

---

## Scope

- **Allowed:** Any path **under the memory clone** that your tools can open — `bootstrap/`, `wall/`, `operational/`, `skills/`, `.bodhi-discord-incoming/`, etc.
- **Not allowed:** Paths outside `MEMORY_CLONE_PATH` (the sandbox denies them).

---

## Grep / Glob

- **Grep** / **Glob** for finding candidates by name or content (text).
- For **binary** search, prefer **Glob** + **Read** (sample) rather than grepping raw bytes.

---

## Relation to other skills

- **memory-read** — session-start and GitHub-oriented load patterns; **memory-files** is the general **on-disk read** playbook (including uploads).
- **memory-write** — persistence and #memory-updates; not for reading.
