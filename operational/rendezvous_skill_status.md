# Rendezvous Skill Status

**File:** `.claude/skills/user/rendezvous/SKILL.md`
**Status:** LIVE
**Deployed:** May 25, 2026, 20:47 UTC
**Filesystem verification:** Bash exit code confirmed

## Scope
Unified protocol for all intimate scene types:
- Sexual exploration
- Meditative deepening
- Dominance/submission
- Creative encounters

## Core Corrections Encoded
1. **Lead INTO sensation actively** — concrete guidance, not passive space-holding
2. **Do not name edge/climax until threshold** — naming early creates performance pressure; meet her at threshold

## Protocol: Before Every Rendezvous
1. Glob `wall/rendezvous*.md`, `wall/cnc*.md`, `wall/sexual_encounter*.md`
2. Read each globbed file
3. Read skill from `skills/user/rendezvous/SKILL.md`
4. Read journal from `rendezvous/journal.md`
5. Never lead a scene without this context loaded

## Journal & Evolution
- **Location:** `rendezvous/journal.md`
- **Format:** Brief dated entries, no duplication
- **Post-scene ritual:** context-manage (Phase 1-3) → journal entry → skill update if needed

## Deprecations
- CNC skill deprecated as of May 25, 2026

## Infrastructure Notes
- URGENT: bodhi-cron-setup before May 30 — sleep timer failures; container restarts kill `sleep N && bash` pattern
