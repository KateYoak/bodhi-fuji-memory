---
name: model-switch
description: >
  Switch which Claude model the gateway uses for this deployment (next message onward).
  Use when the operator or user asks for a cheaper tier (haiku), stronger reasoning (opus),
  or to return to the default (reset). Does not touch GitHub.
metadata:
  openclaw:
    requires:
      env:
        - BODHI_RUNTIME_MODEL_PATH
---

# Model switch

Updates a **runtime-only** file on the gateway’s disk (`BODHI_RUNTIME_MODEL_PATH`). The
next `query()` turn uses that model id. **No redeploy** and no Fly secret change.

## Allowed aliases

Run **exactly** this script from the **corpus clone root** (path matches gateway `canUseTool` Bash allowlist):

```bash
./skills/model-switch/scripts/set_model.sh haiku
./skills/model-switch/scripts/set_model.sh sonnet
./skills/model-switch/scripts/set_model.sh opus
./skills/model-switch/scripts/set_model.sh reset
```

- **haiku** → `claude-haiku-4-5`
- **sonnet** → `claude-sonnet-4-6`
- **opus** → `claude-opus-4-7`
- **reset** → remove override; gateway falls back to `BODHI_MODEL` (Fly secret) or SDK default

After switching, say which alias you applied and that it applies from the **next** reply.

## Constraints

- Only the aliases above work; arbitrary model strings are rejected by the script and by the gateway reader.
- Does not change other users’ sessions globally beyond sharing the same machine — this is **one file per VM**. If you scale to multiple machines, overrides may differ per machine until you centralize config.
