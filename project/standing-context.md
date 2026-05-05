# Project Context

## Tidbits
*Small memory facts go here — named entities, system facts, known gaps. Think of this like Claude's user memory: short, flat, easy to scan. One line per fact. Add freely; never delete without reason.*

- Moggalana is the deployment agent.
- Discord bot does not yet handle file attachments (txt pastes auto-convert to message.txt and are not passed to Master Fu). Fix: check `message.attachments` and inject `.txt` content into the message.
- Bug: `/app/skills/memory-write/scripts/write_file.sh` and `discord_notify.sh` not found at `/app/` path; `append_log.sh` works there but others require `/data/memory/bodhi-fuji-memory/.claude/skills/` path. Inconsistent.
- Bug convention: Master Fu describes problems as tidbits. Humans decide the fix. No agent-proposed patches.
