---
name: model-report
description: >
  Test/diagnostic skill for skill-owned mid-turn model switching. Declares
  runtime.preferredModel=claude-haiku-4-5 and resetOnEnd=false, then asks the
  responder to acknowledge in one sentence. No scripts, no GitHub I/O, no
  runtime overrides written to disk. The only model-changing mechanism is
  this skill's frontmatter — used to validate
  build/iteration-3/phase_skill_owned_model_switch.md acceptance criteria.
runtime:
  preferredModel: claude-haiku-4-5
  resetOnEnd: false
---

# Model report

When this skill is invoked, reply with **one short sentence** acknowledging the
skill ran (e.g. *"model-report skill executed."*).

Do not call other tools, do not write to memory, do not ask follow-up
questions, do not introduce yourself. Keep the entire reply to one line.
