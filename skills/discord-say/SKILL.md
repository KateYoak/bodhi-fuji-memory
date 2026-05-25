---
name: discord-say
description: >
  Post text and/or images from the memory repo to the current Discord conversation
  (not automatic tool stdout). Pipe stdin for the message body; use --file for repo-relative
  image paths (png/jpg/gif/webp). Runs on the same machine as bodhi-gateway (e.g. Fly).
  During a Discord turn the gateway sets BODHI_DISCORD_POST_CHANNEL_ID so you can omit the
  channel id. If the gateway has INTERNAL_QUERY_TOKEN set, pass the same value into the
  skill env (subprocess inherits it on Fly).
bodhi:
  forceBypassModel: true
  forceBypassEntry: scripts/post_to_chat.sh
---

# Discord say (intentional chat post)

Use when **Anandaka should see something in Discord** that should **not** be inferred from normal Bash output (that output stays in the model/tool transcript only).

## Post text to the active Discord thread/channel

From the memory repo root, with message on stdin:

```bash
echo "Hello from the skill" | ./skills/discord-say/scripts/post_to_chat.sh
```

## Post an image from the repo (optional caption on stdin)

Path is **relative to the memory repo root** (`MEMORY_CLONE_PATH`). Supported: **png, jpg, jpeg, gif, webp** (same size cap as inbound Discord attachments — `BODHI_DISCORD_ATTACHMENT_MAX_BYTES`, default 2 MB).

```bash
echo "Here's the diagram from wall/" | ./skills/discord-say/scripts/post_to_chat.sh --file wall/my-diagram.png
```

Image only (no caption):

```bash
./skills/discord-say/scripts/post_to_chat.sh --file bootstrap/chart.png </dev/null
```

Multiple images (one Discord message, up to 10 files):

```bash
echo "Before and after" | ./skills/discord-say/scripts/post_to_chat.sh \
  --file wall/before.png --file wall/after.png
```

Optional last argument: **Discord channel or thread snowflake** (required if `BODHI_DISCORD_POST_CHANNEL_ID` is not set — e.g. raw `curl` from outside a Discord-originated turn).

## Post ACTIVE_CONTEXT as text

```bash
./skills/discord-say/scripts/post_to_chat.sh --active-context
```

## Requirements

- **`INTERNAL_QUERY_TOKEN`** — required **only if** the gateway was started with this variable set (then `POST /v1/discord/post-message` requires `Authorization: Bearer …`). If the gateway runs **without** internal auth, the script omits the header and local `curl` still works.
- **HTTP** to the gateway (default `127.0.0.1:3000` on Fly). Override with `BODHI_INTERNAL_HTTP_HOST` / `PORT` if needed.
- The gateway must have logged in to Discord (`/health` → `discord: true`).

## What not to do

- Do not rely on ordinary Bash / Read tool output appearing in Discord — that is **off** unless you use this skill (or call `POST /v1/discord/post-message` yourself).
- Do not pass absolute paths or paths outside the memory clone — the gateway rejects them.
