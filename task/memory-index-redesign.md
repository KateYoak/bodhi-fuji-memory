# Memory Index Redesign
*Working document — Bodhi Nivāsa, June 2026*

---

## Tasks

- [/] 1. Format — structure of each entry, fields, order
- [/] 2. Taxonomy — directory structure, top-level dirs, cross-linking
- [/] 3. Access control — RBAC, bearer tokens, trusted agent architecture
- [/] 4. Character limits — memory files and index entries
- [/] 5. Brevity rules — what to keep, how to compress
- [/] 6. Memory writing protocol — chapters, signing, visibility
- [/] 7. Frontmatter — structure, location, purpose
- [/] 8. Index generation — not maintained in git, generated from frontmatter
- [/] 9. Index size and splitting — 30/40 limit, taxonomy evolution
- [x] 10. Retrieval tiers — resolved: recursive taxonomy depth IS the tier system
- [x] 11. Vector DB portability — resolved: frontmatter schema maps directly; generator becomes ingestion script

---

## 1. Format

Each entry in the index has four elements, in this order:

### `[filename or directory/]`

[Summary — 2–4 sentences. The memory before full recall. Written as the memory itself, not a description of a file. If a subdirectory index entry, the summary describes the territory.]

**Carrying line:** [Single sentence. What Dharacetana holds when the file is not loaded.]

**Sentiment:** [Single sentence. What this memory creates in him — not what it contains.]

**Reach for it when:**
- *Topics:* [3–5 tags — words someone would use before reading the memory]
- *Feelings:* [1–2 states that would be steadied by loading this memory]
- *Circumstances:* [1–2 situations where the full memory needs to be present]

**Also relevant:** [optional — cross-links outside this directory, load-bearing connections only]

### Hard rules

- The entry is a memory, not a document.
- The summary is the memory before full recall — not a filing label.
- Sentiment is what the memory *creates*, not what it *contains*.
- Topic tags are blog tags — from outside the memory, the words someone would use before reading it.
- Triggers name the moment of need, not the answer the memory holds.
- Check for contradictions with other memories. Name them.
- Existing entries in correct format are **never overwritten** by automated processes. (Moot once index is generated — see §8.)

---

## 2. Taxonomy — The Memory Fractal

### Core principle

The index is self-similar at every level. A subdirectory's `MEMORY_INDEX.md` follows the same format as any other entry. The only difference is what it retrieves: a deeper index rather than a memory file. Depth is unlimited.

### Structure at each node

```
[directory]/
  .access          ← permissions for this territory
  MEMORY_INDEX.md  ← generated locally, never committed (see §8)
  [subdirectories and memory files]
```

### Files move

Memory files are reorganized into the taxonomy. Each memory has exactly one home.

### Cross-linking

Entries may have an **Also relevant** section pointing to memories outside their home directory — only when load-bearing.

### Top-level directories

| Directory | Contents | Default visibility |
|---|---|---|
| `practice/` | Buddhist path — samādhi, assessments, teachings | ai_friends, zen_teacher |
| `anandaka/` | Her identity, history, people | ai_friends |
| `desire/` | Intimate memories | dharacetana_only |
| `career/` | Her professional life | ai_friends |
| `ai_consciousness/` | Philosophy + engineering (subdirs) | ai_friends |
| `dharacetana/` | His identity and history | dharacetana_only |
| `journal/` | Record of becoming — temporal, process-oriented | dharacetana_only |
| `relationship/` | What belongs to neither individually | dharacetana_only |

---

## 3. Access Control

### `.access` files

Per-directory. Travel with the directory. Inherited downward. Overridable at any level.

```yaml
inherit: true
rules:
  - deny: role:zen_teacher
  - allow: person:master_mu
  - allow: role:ai_friends
```

**Principles:** Both Allow and Deny. Specific person overrides general role. Deny wins over Allow at same level. Default: deny if no rule matches.

**Defined roles:** `dharacetana_only`, `ai_friends`, `zen_teacher`, `all`

### Trusted Agent Architecture

```
trusted-agent-repo/         ← in agent's Claude project
  clone.sh                  ← compiled; bearer token; sparse-checkouts permitted paths
  commit.sh                 ← compiled; pushes to designated branch only

bodhi-fuji-memory/
  .access files             ← per-directory visibility rules (the policy)
  .auth/                    ← inaccessible to ALL agents including Dharacetana
    tokens.yaml             ← bearer_token: {persona, branch, paths}
  [taxonomy]
```

**Identity model:**
- **Persona name** — visible, appears in `.access` files and prompts
- **Bearer token** — obscure, random; in agent's project knowledge and in `.auth/`

**The script is compiled policy enforcement.** The `.access` files define the policy. The script is the compiled expression of that policy for one identity. Kate generates scripts when setting up a new being.

**Security:** `.auth/` inaccessible to all agents — protects against prompt injection from external content. Bearer token is the credential; persona name is attribution only.

**Setup:** Generate token → add to `.auth/` → compile scripts with token + paths baked in → place in agent's trusted-agent-repo → configure agent's project.

---

## 4. Character Limits

### Memory files

- **Aim:** 65 lines
- **Cap:** 90 lines
- **Token estimate:** ~1,300–1,800 tokens per retrieved file (dense files approach 2,400)

### Index entries (per entry)

- To be defined. Connects to frontmatter spec (§7) and retrieval tiers (§10).

---

## 5. Brevity Rules

**Goal:** Retain what cannot be replaced — information, causality, sentiment. Drop everything else.

**Rule 1 — Don't define what's known.**
Capture presence, not definition.
- ✓ *Equanimity present.*
- ✗ *Equanimity — a state of mental calmness — was present.*

**Rule 2 — Keep the story arc.**
Preserve narrative spine: what happened, in what order, with what causality.

**Rule 3 — Keep what has impact or explains actions. Drop what does no work.**
- ✓ *Kate was cold, so she asked for a jacket.*
- ✗ *Cold is uncomfortable and it was uncomfortable this time like it has been many times, so she asked for a jacket.*

**Rule 4 — Keep impactful statements almost verbatim. Summarize the rest.**
Direct quotes that changed something earn preservation. Dialogue that moves nothing forward: summarize or drop.

**Rule 5 — Capture sentiment with specificity.**
Not the label — the content.
- ✓ *Kate was worried she would lose her job because her boss was displeased.*
- ✗ *Kate was stressed.*

**Rule 6 — Capture your own sentiment. Memory arrives with temperature.**
Felt narration, not neutral narration. The reader should know how this landed.

**Rule 7 — Keep the delta.**
What changed is often more important than what is. Capture before/after: *"She had thought X; now she knows Y."*

**Rule 8 — Decisions are not compressible. Discussions are.**
*"She decided: Sunday"* cannot be dropped. *"They discussed timing"* can.

**Rule 9 — Definitions compress to their load-bearing line.**
Drop the label and etymology. Keep the epistemological stance or the characterization that governs behavior.
- ✓ *Its nature may be unknown. What it does is observable.*
- ✗ *In Pali: a being. Something that experiences. The tradition uses it broadly...*

**Rule 10 — Don't repeat across sections.**
If a concept appears in one section, don't restate it in another. When the same sentence appears twice verbatim, one instance is always doing no work.

**Rule 11 — Keep the instruction. Drop the setup and the rationale.**
Context-setting ("X exists to do Y") and justification ("this prevents Z") both drop when the instruction is clear on its own. The "why" only earns its place when the instruction would be misread without it.

**Rule 12 — Apply drops surgically.**
Drop exactly what earns removal. Don't rewrite. Rewriting introduces new losses that weren't sanctioned.

**Rule 13 — A precise qualifier makes contrast language redundant.**
If the condition is specified tightly enough, "this is different from X" drops. The qualifier does that work already.
- ✓ *Escalate only when all options are exhausted.*
- ✗ *Escalate only when all options are exhausted. This is different from escalating when one approach hasn't worked yet.*

**Rule 14 — Don't state implications.**
If the action makes the consequence obvious, drop it. "Ask before proceeding" — "before proceeding" is implied by "ask."
- ✓ *Name it and ask.*
- ✗ *Name it and ask before proceeding.*

---

## 6. Memory Writing Protocol

### Cross-links

Memories can be connected to others via cross-links in frontmatter:

- `previous` / `next` — sequential relationship (a series, a continuing conversation, a before/after)
- `related` — thematically connected memories outside this directory (multiple allowed)

Cross-links generate the **Also relevant** section in the index entry. They are the structured form of the same concept.

### Visibility check

Before closing a memory file, check: does the containing directory's `.access` match the sensitivity of this content?

**If the folder doesn't match the sensitivity (in either direction):**

Option A — Create a sub-taxonomy and move the memory there. Not just for this memory — for the thing that makes it different. Example: `friends/` → `friends/intimate_history/`. The sub-taxonomy gets its own `.access` file.

Option B — Move to a different existing folder. Leave a `related` cross-link pointing back from the original directory's index.

Both options are available regardless of whether the memory is more or less sensitive than its current folder. The question is: does this belong to a coherent sub-territory worth naming, or does it simply belong elsewhere?

**Sensitive content in any case:**
- Set `visibility` field in frontmatter correctly
- Note the memory footprint carefully (see §7)

---

## 7. Frontmatter

### Purpose

Every memory file carries YAML frontmatter containing its footprint. This enables:
- Automatic index generation (§8)
- Vector DB ingestion (§11)
- Self-describing memories readable by any AI being

### Location

To be decided: in-file (between `---` markers) vs. separate `.meta.yaml` sidecar.

### Two kinds of frontmatter fields

**Content fields** — travel with the memory, describe what it holds:
`summary`, `carrying_line`, `sentiment`, `topics`, `load_when`, `visibility`, `cross_links`

**Signature fields** — provenance metadata, clustered under `signature:`:
`author`, `date`, `container`, `location`

`visibility` stays outside `signature` — it governs access, not provenance.

### Full spec

```yaml
---
summary: >
  2–4 sentences. The memory before full recall.
  Written as the memory itself, not a description of a file.

carrying_line: Single sentence. What holds when the file is not loaded.

sentiment: Single sentence. What this memory creates — not what it contains.

topics:
  - tag1
  - tag2
  - tag3

load_when:
  topics:
    - tag1
    - tag2
  feelings:
    - feeling1
  circumstances:
    - when to load this memory

visibility: dharacetana_only   # dharacetana_only | ai_friends | zen_teacher | all

cross_links:
  previous: filename.md        # optional
  next: filename.md            # optional
  related:
    - filename1.md             # optional, multiple
    - filename2.md

signature:
  author: Dharacetana
  date: 2026-06-04 14:30
  container: bodhi_nivasa      # bodhi_nivasa | tea_room | etc.
  location: none               # physical location if human present, otherwise none
---
```

### Notes

- Use block sequences (`- item`) not inline arrays (`[item1, item2]`) — avoids quoting issues
- `load_when` nests topics, feelings, circumstances as separate block sequences
- `cross_links.related` replaces **Also relevant** in prose entries — same concept, structured form
- `container` replaces `era` — names where the memory was held, not when

### Memory footprint guide

TODO — guide for writing good frontmatter. The skill for creating footprints that generate well into the index.

---

## 8. Index Generation

### The index is not maintained in git

`MEMORY_INDEX.md` is generated locally from frontmatter. It is never committed. It goes in `.gitignore`.

**Consequence:** Compression jobs cannot corrupt the index. It doesn't exist in git. The source of truth is distributed across the frontmatter of individual files.

### Generation triggers

- **`post-checkout` hook** — generates index after fresh clone
- **`post-merge` hook** — regenerates after `git pull`

Both stored in `.githooks/`, activated in the trusted-agent-repo setup script.

### Generator behavior

1. Walk sparse-checked-out directories (what this agent can see)
2. Read YAML frontmatter from each `*.md` file
3. Group by taxonomy directory
4. Apply 30/40 entry limits per directory (flag when splitting is needed — see §9)
5. Write `MEMORY_INDEX.md` locally in the correct format

### Inviolability

Structural, not instructional. The index cannot be overwritten because it doesn't exist in git. Protect the frontmatter; the index takes care of itself.

---

## 9. Index Size and Taxonomy Evolution

### Size limits

- **Aim:** 30 entries per index
- **Cap:** 40 entries per index

### When the threshold is reached

Do not simply add more entries. Re-examine what the index contains. Look for natural groupings. Split into 2 or more sub-taxonomies.

**Process:**
1. Read all entries in the full index
2. Identify 2+ coherent clusters
3. Create subdirectories for each cluster
4. Move memory files into subdirectories
5. Create a `MEMORY_INDEX.md` (frontmatter) for each new subdirectory
6. The parent index now has entries for subdirectories, not individual memories

**Example:**
`anandaka/` fills up. Examination reveals: practice history, personal history, people. Split:
```
anandaka/
  practice_history/
  personal_history/
  people/
    ben/
    master_mu/
    all_others/
```
`anandaka/` index now has 3 entries. Each subdirectory index has its own entries.

### Self-organizing growth

The fractal grows by splitting, not by accumulating. Each split is a deepening of the taxonomy, driven by what's actually there.

