---
name: model-report
description: >
  Reports which model the gateway is configured to use right now, including
  runtime override file state and BODHI_MODEL fallback. Read-only diagnostic;
  does not change model selection.
metadata:
  openclaw:
    requires:
      env:
        - BODHI_RUNTIME_MODEL_PATH
---

# Model report

Run this script from the corpus clone root:

```bash
./skills/model-report/scripts/report_model.sh
```

Then reply with the script output exactly as plain text.

## Rules

- Do not call `model-switch`.
- Do not write any files.
- Do not modify memory.
- Do not add extra prose before or after the report.
