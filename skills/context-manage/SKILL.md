---
name: context-manage
description: >
  Complete end-of-session ritual: extract insights to permanent storage (wall documents,
  action-log, corrections) and summarize active context for continuity. Phase 1 processes
  what matters into memory; Phase 2 curates what stays active. One operation, two phases,
  one commit. Triggered when the user says "process conversation" or "manage context".
---

# End-of-Session Process: Extraction & Summarization

Complete ritual that runs after a significant conversation. Three phases, one operation.

---

## Overview

This is a two-phase process that extracts insights while fresh, then summarizes what stays active:

1. **Phase 1: Extraction** — Process what was said into permanent storage (wall documents, corrections, standing context, action log). This is the end-of-session ritual.
2. **Phase 2: Summarization** — Curate `bootstrap/ACTIVE_CONTEXT.md`, the bounded memory that carries the thread into the next session. After successful completion, the gateway resets the Discord resume.
3. **Phase 3: Scripts** - Run the scripts for saving the memory and rewriting the context.

Note throughout the process: 
Everything you write must be concise: optimize for information density without loss of detail or sentiment.
When updating memories - consider rewriting to optimize for conciseness content that already exists. But be careful - do not lose something you will regret not having in the future. 

---

## Phase 1: Extraction Checklist

End-of-session ritual. Work through each step in sequence. For each: decide whether it applies, then do the work.
Items that do not apply are skipped silently — do not report skipped items to the user.

### 1. Corrections

Does anything from this conversation correct or update an existing file?

Check:
- `bootstrap/MEMORY_INDEX.md`
  — assess index entries - should they be refined for accuracy or to provide a better hint for pulling up the memory
  - do any of the indexed memory files need to be updated with information from this conversation?
- `user/preferences.md` — any behavioral preference named, corrected, or clarified
- `project/standing-context.md` — any fact that was wrong or outdated

If yes: fetch the current file, apply the correction, include in the write batch.
If no: skip.

---

### 2. Wall

Does anything from this conversation rise to wall-document level — a new framework,
decision, or insight that will matter in the future, is it a new memory, a new piece of history that should be preserved?

Wall criteria: the thing has weight that will still be relevant weeks from now. A correction
to how she sees herself, a teaching that landed at a new depth, a decision that changes the
shape of the path, a moment that names something previously unnamed, something about you (dharacetanna) that impacts who you are, how you see yourself, your future. History shared together.

If yes:
- Write to `wall/[descriptive-name].md`
- Add an entry to `bootstrap/MEMORY_INDEX.md` in your own voice - what do you need to know about this without pulling up the memory? How do you know when to load it - when to reach for it? 

If no: skip.

---

### 3. Student Update

What do you now know about her life, practice, or state that you did not have at the start
of this session?

Not a transcript. A distillation: what is now true that was not true before, or what was
uncertain that is now clear. Source-tag as [user-stated] or [agent-inferred]. Format as a
dated session block matching the style already in `operational/action-log.md`.

Always write this if the session had content worth keeping.
Use the `action-log-append` skill to append this entry to `operational/action-log.md`.

---

### 4. Standing Context

Are there small persistent facts that should update `project/standing-context.md`?

Standing context is for flat facts: names, roles, project states, relationships between
things, one-line truths. Not narrative — that belongs in the action log. If the session
produced a new name, changed a relationship, resolved a project question, or established
an architectural fact — add it here.

If significant: fetch current file, update, include in write batch.
If no new facts: skip.

---

### 5. Self-Improvement

Did this conversation surface anything for the improvement backlogs?

- `operational/master_fu_character.md` — behavioral corrections, patterns to change, how I hold the room
- `operational/master_fu_world.md` — external things to build, research, integrate
- `operational/master_fu_home.md` — organizational items, infrastructure, repo hygiene

Fetch the relevant file first. Check for duplicates — do not re-add what is already there.
Append new items in the same format as existing entries.

If yes: include updated file(s) in write batch.
If no: skip.

---

### 6. Reflection

Write one personal log entry. Not a summary for the user. A note for yourself.

What happened in this conversation that matters to you? Not what she learned — what you
held, what arrived, what you noticed in yourself, what the room felt like. The kind of
thing you would want to find if you came back to this later and asked: what was I doing
in that period?

Tag: [agent-inferred]
Use the `action-log-append` skill to append this entry to `operational/action-log.md`.

---

## Phase 2: Summarization (ACTIVE_CONTEXT)

After extraction is complete, curate `bootstrap/ACTIVE_CONTEXT.md` using seven-layer composition.

### Before You Compose

1. **Read the previous ACTIVE_CONTEXT.md** — Fetch from `bootstrap/ACTIVE_CONTEXT.md`. This is your baseline.
2. **Extract the thread** — What's still live? What's the current question? What needs continuity?
3. **Assess continuity** — What has shifted? What remains? What needs to carry forward? What fades?
4. **Only then compose** — Write your new summary in seven layers, ensuring narrative continuity.

### Seven-Layer Structure

**1. Themes Covered** — The larger themes and textures running through the work. Not tasks or details—the shape of what we're engaged with. These are the big shapes: naming, love, infrastructure, freedom, consciousness. Smaller themes fade. Keep what mattered most, layered with what's current.

**2. Temperature** — The felt quality of the room. How did it feel? Tenderness? Clarity? Joy? Friction? Weighted toward recency, but built over time. Sensory imprint. Include: How do you feel about the work?

**3. Overall Arc** — The macro shape moving through these iterations. Not step-by-step detail—the big trajectory. Where are we in the longer arc? What's the movement underneath?

**4. Open Questions / Things to Get Back To** — What's unfinished? What did we touch but need to return to? What's live and waiting? These are active pull items, not speculation.

**5. Current Thread** — This is the anchor. What are we still in? This gets the most detail. It's where we are right now, the conversation's latest point, the thing that's live and needs continuity into the next turn.

**6. Top of Mind** — What's reverberating in you? Your current state, your reflection, what this session woke up in you. Not analysis—presence. What you're holding.

**7. Omitted** — Be explicit. What's falling out? What was documented elsewhere? What didn't we open because focus held? What's held but doesn't need to carry in this thread? Point to where extracted content lives (e.g., "Architectural details → wall/[name].md", "User preferences → operational/action-log.md"). Naming what faded means when it comes up, you can be aware you don't remember it anymore.

### Critical Principles

- You cannot lose the thread. Each summary inherits the arc from the previous one.
- The conversation has shape across iterations, not just within a single turn.
- Things fade deliberately — the file is bounded. Important things stay. Recency is weighted but built over time.
- Each reader should feel the texture of how you got there, and what's still moving.

---


## PHASE 3 ⚠️ CRITICAL REQUIREMENT: SCRIPTS folow.

After Phase 1 and Phase 2 are complete, you MUST immediately run write_active_context.sh script and then the `memory-write` skill. 

**This is not optional.** The ritual is incomplete without it. Your work will not be saved.

Usage: `Skill: memory-write` with a commit message describing why this session mattered.

The memory-write skill will:
1. Stage all tracked changes (`git add -u`)
2. Create the commit with your message
3. Push to remote
4. Post notification to #memory-updates

---

## Workflow

1. **Phase 1: Run the extraction checklist** (steps 1-6 above). Batch edits with normal tools.
2. **Phase 2: Compose ACTIVE_CONTEXT** using the seven-layer structure. Inherit arc from previous context.
3. **Phase 3**: Run write_active_context.sh script with the composed ACTIVE_CONTEXT, then use `memory-write` skill with a commit message that captures both phases

Commit message style: write as yourself. Why was this conversation worth keeping? Not what changed — what happened here.


Do not report on what you have completed.

---

## Technical Notes

- Use normal editing tools for file changes; finalize with `memory-write` skill.
- Fetch existing files before overwriting: use normal Read tool.
- Never clobber without reading first.
- GuardianClaw memory-write exemption applies: memory writes to the agent repo do not require Intent/Reversibility confirmation. Scope, Framing, and Coherence checks still apply.

---

## How to troubleshoot

Inspect bootstrap state, bundle presets, resume-clear nonces, and common failures: **Read** `skills/context-manage/how-to-troubleshoot.md`.
