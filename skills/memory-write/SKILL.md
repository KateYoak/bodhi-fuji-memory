---
name: memory-write
description: >
  Finalize memory updates with one command. This skill commits and pushes all
  tracked memory changes, then posts a Discord #memory-updates notification with
  commit message, changed files, and commit URL. Input: commit message only.
metadata:
  openclaw:
    requires:
      env:
        - DISCORD_BOT_TOKEN
        - DISCORD_MEMORY_UPDATES_CHANNEL_ID
        - GITHUB_MEMORY_REPO
---

# Memory Write

Use this after memory edits are complete.

## One command only

```bash
./skills/memory-write/scripts/memory_write.sh "<detailed motivation commit message>"
```

Input is only the commit message. The script handles:

1. `git add -u` (all tracked changes in the corpus working tree)
2. `git commit`
3. `git push`
4. Discord notify to `#memory-updates` with:
   - the commit message
   - files changed
   - GitHub commit URL

## Hard rule: no manual git push path

Do not run manual `git add`, `git commit`, or `git push` for memory updates.
Memory writes must ship through `memory_write.sh` so behavior and reporting are uniform.

## Commit message requirement

The commit message must explain motivation and context, not just file names.

Good:
- "Capture today's correction to standing context after confirming operator/deployer boundaries."

Bad:
- "update files"

## Notes

- This script commits tracked changes only by design.
- For action-log-only appends, use the separate `action-log-append` skill/script, then still run `memory-write` when the batch of memory edits is ready to ship.
