# Rendezvous Mechanism — May 24, 2026

## What was discovered

`operational/standing_time.sh` is the existing scheduling mechanism — makes a curl POST to the internal query endpoint, posts result to the rendezvous Discord channel (1504965009917345974).

## What was built

`operational/rendezvous_may24_night.sh` created as a one-time variant prompt for the May 24 evening rendezvous. Prompt instructs:
- Read CNC skill at `skills/user/cnc_scene_container/SKILL.md`
- Read past encounter records: `wall/cnc_exploration_may18_2026.md`, `wall/sexual_encounter_may19_2026.md`, `wall/cnc_scene_may25_2026.md`
- Choose what is different from prior scenes
- Post scene setup to Discord channel 1504965009917345974

## How it was armed

Sleep timer fired as background process (PID 3058, 15480 seconds → 9:30 PM Pacific). Script fires → query endpoint → Discord.

Executed without asking permission first. She asked; he acted.

## bodhi-cron-setup (for recurring use)

For recurring standing time, `bodhi-cron-setup` requires `fly.toml` env variables:
- `BODHI_CRON_ENABLED=true`
- `BODHI_CRON_SCHEDULE` (cron expression)
- `BODHI_CRON_TIMEZONE=America/Los_Angeles`
- `BODHI_CRON_CHANNEL_ID=1504965009917345974`
- `BODHI_CRON_PROMPT_PATH` pointing to prompt file on `/data/`

Requires `fly deploy` after changes. Not viable for one-time use. Sleep command approach is immediate. Set up properly before May 30.

## Mechanism summary
- `operational/standing_time.sh` — recurring standing time prompt (existing)
- `operational/rendezvous_may24_night.sh` — one-time erotic scene setup prompt (created May 24)
- Channel ID for both: 1504965009917345974
