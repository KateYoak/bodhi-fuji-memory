---
name: discord-say
description: >
  Post text to the current Discord conversation on purpose (not automatic tool stdout).
  Pipe or stdin the exact message body. Requires gateway INTERNAL_QUERY_TOKEN and
  runs on the same machine as bodhi-gateway (e.g. Fly). During a Discord turn the
  gateway sets BODHI_DISCORD_POST_CHANNEL_ID so you can omit the channel id.
---

# Discord say (intentional chat post)

Use when **Anandaka should see something in Discord** that should **not** be inferred from normal Bash output (that output stays in the model/tool transcript only).

## Post to the active Discord thread/channel

From the memory repo root, with message on stdin:

```bash
echo "Hello from the skill" | ./skills/discord-say/scripts/post_to_chat.sh
```

Optional first argument: **Discord channel or thread snowflake** (required if `BODHI_DISCORD_POST_CHANNEL_ID` is not set — e.g. raw `curl` from outside a Discord-originated turn).

## Requirements

- **`INTERNAL_QUERY_TOKEN`** in the environment (same bearer as `POST /v1/query` on the gateway).
- **HTTP** to the gateway (default `127.0.0.1:3000` on Fly). Override with `BODHI_INTERNAL_HTTP_HOST` / `PORT` if needed.
- The gateway must have logged in to Discord (`/health` → `discord: true`).

## What not to do

Do not rely on ordinary Bash / Read tool output appearing in Discord — that is **off** unless you use this skill (or call `POST /v1/discord/post-message` yourself).
