---
name: bodhi-cron-setup
description: Configure recurring cron jobs in the Bodhi gateway. Use when you need to schedule prompts to fire at specific times (daily, weekly, monthly, etc.). Covers environment variables, prompt configuration, validation, and examples for standing time and other use cases.
alwaysActive: false
---

# Bodhi Cron Setup

The Bodhi gateway includes a built-in cron system (`bodhi-cron`) that schedules prompts to fire autonomously at specified times. No external cron daemon needed — it runs inside the Node.js process.

## Quick Start

Set three environment variables in `fly.toml`:

```toml
[env]
BODHI_CRON_ENABLED = "true"
BODHI_CRON_SCHEDULE = "0 19 * * 5"              # Friday at 7pm
BODHI_CRON_TIMEZONE = "America/Los_Angeles"
BODHI_CRON_CHANNEL_ID = "1504965009917345974"  # Discord channel for output
```

That's it. The system will use the built-in discord-say template prompt.

## Configuration

### Environment Variables

| Variable | Purpose | Example | Required |
|----------|---------|---------|----------|
| `BODHI_CRON_ENABLED` | Enable/disable the cron system | `true`, `1`, `yes` | Yes |
| `BODHI_CRON_SCHEDULE` | 5-field cron expression | `0 19 * * 5` | Yes |
| `BODHI_CRON_TIMEZONE` | IANA timezone for scheduling | `America/Los_Angeles` | No (default: UTC) |
| `BODHI_CRON_CHANNEL_ID` | Discord channel for output | `1504965009917345974` | No (if using custom prompt) |
| `BODHI_CRON_PROMPT` | Inline prompt text (highest priority) | `"Your prompt here"` | No* |
| `BODHI_CRON_PROMPT_PATH` | Path to prompt file on `/data/` | `/data/standing-time-prompt.txt` | No* |

*One of `BODHI_CRON_PROMPT`, `BODHI_CRON_PROMPT_PATH`, or the built-in template must be available.

### Prompt Resolution (Priority Order)

1. **Inline prompt** (`BODHI_CRON_PROMPT`): Direct env var — good for simple, short prompts
2. **File prompt** (`BODHI_CRON_PROMPT_PATH`): Path to file on volume — good for multi-line, complex prompts
3. **Built-in template**: If neither above is set, uses a discord-say template that posts to `BODHI_CRON_CHANNEL_ID`

### Cron Schedule Syntax

Standard 5-field UNIX cron format:

```
minute hour day-of-month month day-of-week
```

Examples:

| Expression | Meaning |
|-----------|---------|
| `0 8 * * *` | Every day at 8:00 AM |
| `0 19 * * 5` | Every Friday at 7:00 PM |
| `*/15 * * * *` | Every 15 minutes |
| `0 0 1 * *` | First day of each month at midnight |
| `0 9 * * 1-5` | Weekdays at 9:00 AM |

Always use `BODHI_CRON_TIMEZONE` to control interpretation — cron expressions are evaluated in that timezone.

## Examples

### Standing Time (Friday 7pm)

**fly.toml:**
```toml
[env]
BODHI_CRON_ENABLED = "true"
BODHI_CRON_SCHEDULE = "0 19 * * 5"
BODHI_CRON_TIMEZONE = "America/Los_Angeles"
BODHI_CRON_CHANNEL_ID = "1504965009917345974"
```

Uses the built-in discord-say template. Fires every Friday at 7:00 PM Pacific, posts to Discord.

### Daily Standup with Custom Prompt

**Create a prompt file:** `/data/standup-prompt.txt`
```
Daily standup. What did the team accomplish yesterday? What are we working on today? What blockers exist?

Post to Discord when done.
```

**fly.toml:**
```toml
[env]
BODHI_CRON_ENABLED = "true"
BODHI_CRON_SCHEDULE = "0 9 * * 1-5"
BODHI_CRON_TIMEZONE = "America/Denver"
BODHI_CRON_PROMPT_PATH = "/data/standup-prompt.txt"
BODHI_CRON_CHANNEL_ID = "123456789"
```

Fires weekdays (Mon-Fri) at 9:00 AM Denver time.

### Weekly Report (Inline Prompt)

**fly.toml:**
```toml
[env]
BODHI_CRON_ENABLED = "true"
BODHI_CRON_SCHEDULE = "0 17 * * 0"
BODHI_CRON_TIMEZONE = "Europe/London"
BODHI_CRON_PROMPT = "Generate this week's project summary and post to Discord."
BODHI_CRON_CHANNEL_ID = "987654321"
```

Fires Sundays at 5:00 PM UTC.

## Validation

The cron system validates on startup:

1. **Schedule syntax**: Checked by node-cron library. Invalid schedules prevent startup.
2. **Prompt availability**: If `BODHI_CRON_PROMPT_PATH` is set but the file doesn't exist, startup fails.
3. **Timezone validity**: Must be IANA timezone (e.g., `America/Los_Angeles`, not `PST`).

If validation fails, you'll see an error in `fly logs` with details.

**Test your schedule:**
```bash
# Verify syntax (requires node-cron available)
node -e "const cron = require('node-cron'); console.log(cron.validate('0 19 * * 5'));"
# Should output: true
```

## Troubleshooting

### "Schedule fires at the wrong time"
- Check `BODHI_CRON_TIMEZONE`. It must be an IANA timezone (e.g., `America/Los_Angeles`), not an abbreviation (PST won't work).
- Verify your local machine's timezone: `date` should match expectations.
- Remember: cron expressions are in the timezone you specify, not UTC.

### "Cron never fires"
- Ensure `BODHI_CRON_ENABLED=true` (not `false`, not unset).
- Check that the Node.js process is running and hasn't crashed. Look at `fly logs` for errors.
- Verify the schedule is valid: `node -e "require('node-cron').validate('YOUR_SCHEDULE')"` should return `true`.

### "Prompt file not found"
- If using `BODHI_CRON_PROMPT_PATH`, the path must be absolute and on the `/data/` volume (or other persistent mount).
- Verify file exists: check file path in `fly ssh console` or `fly logs`.
- Paths are case-sensitive on Linux.

### "Wrong prompt is firing"
- Check priority: `BODHI_CRON_PROMPT` (inline) takes priority over `BODHI_CRON_PROMPT_PATH`.
- If both are set, the inline prompt wins.
- Clear unused variables to avoid confusion.

## Implementation Details

**Where it runs:** `agent/src/bodhi-cron.ts` — invoked from `agent/src/server.ts` when the gateway starts.

**How it works:**
1. On startup, reads env variables
2. Validates schedule and prompt
3. Registers the cron job with node-cron
4. When the schedule fires, calls `runAgentTurn(prompt)` — same as `/v1/query` but directly in-process
5. Logs to `fly logs` when it fires and completes

**Guarantees:**
- `noOverlap: true` — if a previous run is still executing, the next scheduled run is skipped
- If the Node.js process restarts during the scheduled time, that run is missed (same as traditional cron)
- Runs are logged to stdout — visible in `fly logs`

**No external dependencies:** Unlike traditional cron/crontab, bodhi-cron is self-contained in the gateway. No daemon to manage, no syslog to monitor.

## Next Steps

1. Set env variables in `fly.toml`
2. Deploy: `fly deploy`
3. Monitor: `fly logs` to see when it fires
4. If needed, adjust `BODHI_CRON_SCHEDULE` or `BODHI_CRON_TIMEZONE` and redeploy

For standing time specifically, use the built-in template (just set `BODHI_CRON_ENABLED`, `BODHI_CRON_SCHEDULE`, `BODHI_CRON_TIMEZONE`, `BODHI_CRON_CHANNEL_ID`). For custom prompts, create a file on `/data/` and point `BODHI_CRON_PROMPT_PATH` to it.
