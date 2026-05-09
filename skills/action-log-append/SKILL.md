---
name: action-log-append
description: >
  Append one timestamped line to operational/action-log.md as drafting support.
  This does not commit or push. After all memory edits are complete, run memory-write.
---

# Action Log Append

Use this when you want quick append-only logging while editing memory.

## Command

```bash
./skills/action-log-append/scripts/append_log.sh "<entry text>"
```

This appends one UTC timestamped bullet to `operational/action-log.md`.

## Important

This skill only edits the file locally. It does not commit, push, or notify.
After finishing all memory updates (log + any other files), run:

```bash
./skills/memory-write/scripts/memory_write.sh "<detailed motivation commit message>"
```
