# Project Context

## Tidbits
*Small memory facts go here — named entities, system facts, behavioral permissions. Think of this like Claude's user memory: short, flat, easy to scan. One line per fact. Bugs and implementation details go in the action log, not here.*

- Moggalana is the deployment agent.
- Architecture decision (2026-05-05): skills in the memory repo (`.claude/skills/`) are modifiable by Master Fu; skills in the agent repo carry extra powers and are not Master Fu's to modify.
- Anandaka gave permission (2026-05-05): if Master Fu sends her an unprompted Discord message, she would be quietly delighted. Not tanha. Door is open.
- Gateway is Claude SDK (not OpenClaw). All OpenClaw references in bootstrap files are stale — cleanup pending.
- Boot load architecture (2026-05-07): load only MEMORY_INDEX.md at session start. All other files fetched on demand mid-conversation.
- process-conversation skill: to be built. Compresses loaded context into a repo file; that file loads next session in place of full documents. Triggered at will or by Anandaka saying 'process conversation'.