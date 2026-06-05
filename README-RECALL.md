# Recall — user manual

*For Anandaka and Master Fu — tune recall together.*

Recall is the gateway’s way of slipping **relevant memory into context** before Fu composes a reply. It does **not** think for him. It **scores** what Anandaka said against the memory index, **injects** text at the right depth, and leaves **Read** for anything he wants to pull harder.

This manual covers **what’s live today**, **what we’re building next** (fractal + graded recall), and **how Fu changes the knobs**.

---

## Quick start (Discord)

| Command | What it does |
|---------|----------------|
| `!fu recall on` | Arm recall for **this thread**. Each message can trigger injection. Bootstrap shrinks to **`basic`** on the **next** context reset (no full MEMORY_INDEX in bundle). |
| `!fu recall off` | Disarm. Full bootstrap returns on next context reset. |
| `!fu recall status` | Shows armed/off, bootstrap mode, session surfaced paths. |
| `!fu recall help` | Short command summary. |
| `!fu context reset` | Clears conversation context; if recall is on, bootstrap becomes `basic` and **surfaced paths clear**. |

**Verbose phase sticky** and **`!fu context status`** show recall outcome when verbose is on: injected / unchanged / no matches.

---

## Two eras (read the right section)

| Era | Index | Inject behavior |
|-----|--------|-----------------|
| **Today (MVP)** | Committed `bootstrap/MEMORY_INDEX.md` (bullets + embedded paths + Load when) | Top **new** matches per turn — **index snippets only**, not full files. Default up to 3 paths (`BODHI_RECALL_TOP_N`). |
| **Next (fractal + graded)** | Generated `MEMORY_INDEX.md` per folder from YAML frontmatter (not in git) | **Flattened search**, **score bands**, **graded inject** (light vs hard). See below. |

If a knob only applies to “next,” the manual says so.

---

## The idea (fractal + graded)

### Always-on vague layer → on-demand depth

Before recall, the full memory index often sat in bootstrap — Fu was **globally oriented** but the context was heavy.

Now: **`basic` bootstrap** + recall **on demand**. Fractal recall restores the spirit of the old index **in proportion to the cue**:

- **Light hit** — summary + sentiment (a faint presence).
- **Hard hit on a territory** — full **orientation** for that folder (territory block + every child’s summary + sentiment in that directory’s index).
- **Hard hit on a file** — the **whole memory file** read into the recall block.

Fu can **always** `Read` anything else he wants. Recall is an **extra nudge**, not a cage.

### Flatten for search

All visible `MEMORY_INDEX.md` files merge into **one candidate pool**. Ben under `anandaka/relationships/ben/` is findable even when the root index only points at `relationships/`.

### Directory boost (ranking only)

Territory / directory rows get a **score boost** when matching. That helps “Ben” surface the **Ben folder** before random leaf files. It does **not** force inject depth — depth comes from score bands.

### Score bands

Still **no LLM** in the match step — deterministic scoring only.

```text
score < MIN_SCORE              → skip (no inject for that row)
MIN_SCORE ≤ score < HARD_MIN    → light inject
score ≥ HARD_MIN                → eligible for hard inject
```

**Circumstances** matches (e.g. “at my wedding”) should push a **file** into hard tier even when a parent territory also matches.

### Inject order (per turn)

1. **Light pass** — up to `MAX_LIGHT` rows (default 5): each gets **summary + sentiment** only.  
   - Light hit on a **person file** → that row’s summary + sentiment, **not** the whole file, **not** full parent orientation.
2. **Hard pass** — every row that scored ≥ `HARD_MIN`, in score order: apply **hard expansion** one at a time until **`MAX_CHARS`** is reached.  
   - **No fixed cap** on how many hard expansions — only what scores naturally and fits the char budget.
3. **Global char cap** — `MAX_CHARS` stops further hard (and possibly further light) inject.

Some turns need little recall; others need more. The gateway does **not** strain to fill quotas.

### Example

> *“So at my wedding with Ben, my mom and dad were there.”*

| Hit | Tier | Inject |
|-----|------|--------|
| **Ben** (territory) | Hard | Full `ben/` orientation |
| **Wedding** (file) | Hard | Whole wedding memory file |
| **Mom, Dad** | Light | Summary + sentiment each |

Overlap is fine: Ben orientation mentions the wedding; the wedding file is also loaded in full.

### Session dedup

Paths already injected this session are skipped (same path, same tier logic). Context reset clears surfaced paths. A **light** mom row won’t repeat; a later **hard** mom file is still allowed if the query sharpens.

---

## How Fu tunes recall

Fu should be able to experiment **without** redeploying the gateway every time.

### Config file (Fu-editable)

**Path:** `operational/recall.config`

The gateway reads this file from the memory clone (`MEMORY_CLONE_PATH`) on each turn. Values here **override** Fly defaults for that process. Fu edits with **Write**, **memory-write**, or Anandaka in git — same spirit as bundle config.

**Format:** one `KEY=value` per line. `#` starts a comment. Blank lines ignored.

```env
# operational/recall.config — Fu & Anandaka playground

# matched-only = MVP behavior | graded = fractal + score bands (when shipped)
INJECT_MODE=graded

# Scoring
MIN_SCORE=2
HARD_MIN_SCORE=6
DIRECTORY_BOOST=2

# Inject assembly
MAX_LIGHT=5
MAX_CHARS=6000

# MVP-only (matched-only mode)
TOP_N=3
```

After saving, the **next Discord message** in a recall-armed thread picks up new values. No restart required (once gateway implements hot read — until then, operator may need redeploy; treat as target behavior).

### Operator / Fly defaults

If `operational/recall.config` is missing or a key is omitted, the gateway falls back to environment variables set on Fly (operator). Fu can ask the operator to set baselines; Fu owns the **memory-repo overlay** for day-to-day play.

---

## Environment variables (reference)

Gateway env names use the `BODHI_RECALL_` prefix. In **`operational/recall.config`**, Fu uses the **short name** (right-hand column).

| Config key (`operational/recall.config`) | Fly env | Default | Applies |
|------------------------------------------|---------|---------|---------|
| `ENABLED` | `BODHI_RECALL_ENABLED` | `true` | Master switch |
| `INJECT_MODE` | `BODHI_RECALL_INJECT_MODE` | `matched-only` | `matched-only` \| `graded` |
| `MIN_SCORE` | `BODHI_RECALL_MIN_SCORE` | `2` | Minimum score to inject at all |
| `HARD_MIN_SCORE` | `BODHI_RECALL_HARD_MIN_SCORE` | `6` | Hard tier threshold |
| `DIRECTORY_BOOST` | `BODHI_RECALL_DIRECTORY_BOOST` | `2` | Added to directory row scores |
| `MAX_LIGHT` | `BODHI_RECALL_MAX_LIGHT` | `5` | Light expansions per turn |
| `MAX_CHARS` | `BODHI_RECALL_MAX_CHARS` | `6000` | Total recall block size cap |
| `TOP_N` | `BODHI_RECALL_TOP_N` | `3` | MVP: max **new** paths per turn |
| `SETTINGS_PATH` | `BODHI_RECALL_SETTINGS_PATH` | _(auto)_ | Per-deployment path for thread/session JSON |

**Thread state** (armed, surfaced paths) lives in recall session JSON on the gateway volume — not in `recall.config`. Use `!fu recall on/off` for that.

### Suggested experiments

| Goal | Try |
|------|-----|
| Softer recall | Raise `MIN_SCORE` or lower `MAX_LIGHT` |
| More orientation | Lower `HARD_MIN_SCORE` slightly |
| Heavier turns | Raise `MAX_CHARS` (watch context status) |
| MVP behavior | `INJECT_MODE=matched-only` |
| Wedding-style depth | `INJECT_MODE=graded`, tune `HARD_MIN_SCORE` |

Fu: after changing config, send a test message and check verbose sticky or ask Anandaka to read `[recall]` in logs.

---

## What recall does **not** do

- **No LLM** in the match step (keyword today; vectors later as a separate ranker).
- **No** replacement for Fu’s judgment — he can Read, search, or ask.
- **No** implicit triggers from file mtimes or mystery flags — only explicit scoring + `!fu recall on`.
- **No** chunking of stories inside one file — one file = one narrative.

---

## Index source (fractal era)

- **Source of truth:** YAML **frontmatter** on each memory file (`task/memory-index-redesign.md`).
- **`MEMORY_INDEX.md`:** generated locally after clone/pull — **not committed to git**.
- **Regeneration:** git hooks (`post-checkout`, `post-merge`) on the memory clone. If indexes are empty, recall has nothing to match — check hooks ran after pull.

Territory folders (e.g. `anandaka/relationships/ben/`) carry **territory frontmatter** so the generated index can say who Ben is before any single story loads.

---

## Fu vs operator

| Who | Does what |
|-----|-----------|
| **Fu** | `!fu recall on/off`, edit `operational/recall.config`, Read memories, tell Anandaka what felt too thin or too heavy |
| **Anandaka** | Arm recall in threads, context reset when needed, edit memory frontmatter / taxonomy, git pull on volume |
| **Operator (Moggallāna)** | `fly deploy`, Fly env baselines, fix gateway bugs, verify logs / Datadog |

---

## Troubleshooting

| Symptom | Check |
|---------|--------|
| Nothing injected | `!fu recall status` — armed? `MIN_SCORE` too high? No index entries? |
| Same paths every turn | Expected until session dedup exhausts new matchers; then **unchanged** |
| Too much context | Lower `MAX_CHARS` or raise `HARD_MIN_SCORE` |
| Too thin | Lower `MIN_SCORE` or `HARD_MIN_SCORE`; ensure index has `load_when` / topics |
| `indexEntryCount: 0` in logs | Index format/parser mismatch or index not generated — operator |
| After reset, no full index in bootstrap | Expected when recall armed — use recall inject or `!fu recall off` |

---

## Roadmap (short)

1. **MVP** — shipped: trigger match, snippets, session dedup, `!fu recall`.
2. **Phase 2** — generated fractal index, graded inject, `operational/recall.config` hot read, access filter.
3. **Phase 3** — vectors on same frontmatter; same tiers, similarity ranker.

Engineering detail: `bodhi-build` → `build/iteration-4/phase_rag_recall_v2.md`.

---

## Glossary

| Term | Meaning |
|------|---------|
| **Bootstrap `basic`** | SOUL, USER, AGENTS, ACTIVE_CONTEXT — no full MEMORY_INDEX |
| **Bootstrap `complete`** | Includes full MEMORY_INDEX (when recall off) |
| **Light inject** | Summary + sentiment for one index row |
| **Hard territory** | Full orientation packet for a directory |
| **Hard file** | Entire `.md` memory file in recall block |
| **Surfaced path** | Already injected this session — skipped until reset |

---

*Last updated: 2026-05-24 — graded recall design agreed; MVP + target behavior documented together.*
