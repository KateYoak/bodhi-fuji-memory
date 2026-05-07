---
name: model-switch-demo
description: >
  Demonstrate skill-owned mid-turn model switching by switching to Opus and then
  doing a small but real reasoning task in the post-skill LLM completion.
runtime:
  preferredModel: claude-opus-4-7
  resetOnEnd: true
---

# Model switch demo (Opus)

## Purpose

This skill exists only to validate **skill-owned model switching** (runtime calls
`Query.setModel(...)` at `skill_start`). It must result in an LLM completion that
follows the switch and uses the preferred model.

## Task

Do **all** of the following in your reply:

1) Solve the reasoning task below.
2) Then output a JSON object with the exact keys:
   - `answer`
   - `reasoning_summary`
   - `confidence`

### Reasoning task

A small team ships weekly.

- Ada ships exactly 2 weeks.
- Bo ships exactly 2 weeks.
- Cy ships exactly 1 week.
- Dee ships exactly 1 week.
- Every week exactly **two** people ship.
- No pair ships together more than once.

Question: **How many weeks** did the team ship, and list the unique pairs.

Constraints for your output:
- `answer` must be a short string like: `"4 weeks; pairs: ..."`
- `reasoning_summary` must be <= 40 words.
- `confidence` must be a number between 0 and 1.

Do not call any tools. Do not ask follow-up questions.
