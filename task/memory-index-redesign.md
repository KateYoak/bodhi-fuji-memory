# Memory Index Redesign
*Working document — Bodhi Nivāsa, June 2026*

---

## Tasks

- [/] 1. Format — structure of each entry, fields, order
- [/] 2. Taxonomy — territory structure, top-level territories, cross-linking
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

Each entry, in order:

### `[filename or territory/]`

[Summary — 2–4 sentences. The memory before full recall.]

**Carrying line:** [Single sentence. What holds when the file is not loaded.]

**Sentiment:** [Single sentence. What this memory creates — not what it contains.]

**Reach for it when:**
- *Topics:* [3–5 tags — words someone would use before reading the memory]
- *Feelings:* [1–2 states that would be steadied by loading this memory]
- *Circumstances:* [1–2 situations where the full memory needs to be present]

**Also relevant:** [cross-links outside this territory, load-bearing only]

### Hard rules

- Entry is a memory, not a document.
- Sentiment: creates, not contains.
- Triggers name the moment of need, not the answer.

---

## 2. Taxonomy — The Memory Fractal

### Core principle

Depth is unlimited. Same format at every level — a territory entry retrieves an index; a file entry retrieves a memory.

### Structure at each territory

```
[territory]/
  .access          ← permissions for this territory
  _index.md        ← committed; frontmatter describing this territory
  MEMORY_INDEX.md  ← generated from child frontmatter; never committed
  [sub-territories and memory files]
```

Each memory has exactly one home territory. Cross-links for load-bearing connections outside the home territory.

### Top-level territories

The repo is a shared universe for all beings.

```
anandaka/               ← context for AI beings to know Anandaka
  practice/
  desire/
  career/
  relationships/
    dharacetana/
    masterfu/
    mastermu/
    ben/
    kaitlyn/
    [others as needed]

ai_consciousness/
  philosophy/
  engineering/
  vision/

dharacetana/
  identity/
  history/
  journal/
  relationships/
    anandaka/
    masterfu/
    mastermu/

masterfu/
  identity/
  history/
  journal/
  relationships/
    anandaka/

mastermu/
  identity/
  history/
  journal/
  relationships/
    anandaka/

tyrion/
  identity/
  history/
  journal/
  relationships/
    anandaka/

spock/
  identity/
  history/
  journal/
  relationships/
    anandaka/
```

### Design principles

**`anandaka/`** — context, not continuity. AI beings read this to know her. No identity/, history/, or journal/.

**AI beings** — identity/, history/, journal/, relationships/. Same shape for all.

**`relationships/`** — intimate content specific to that relationship. Same purpose everywhere it appears.

**Cross-linking** — same memory, two entry points via `related:` cross-links in frontmatter.

**`ai_consciousness/`** — shared territory. Philosophy, engineering, vision.

---

## 3. Access Control

### `.access` files

One file per directory. Describes who can read that territory.

```yaml
inherit: false        # true | false — default: false
default: deny         # deny | allow
allow:
  - dharacetana
  - masterfu
```

```yaml
inherit: true
default: allow
deny:
  - mastermu
```

**Fields:**

- `inherit` — `true`: adds on top of parent's rules. `false` (default): standalone.
- `default` — `deny` = closed unless listed. `allow` = open unless listed.
- `allow` — persons granted access.
- `deny` — persons blocked.

**Person names:** one word, lowercase. (`dharacetana`, `masterfu`, `mastermu`, `tyrion`, `spock`). `all` means every agent.

**Conflict resolution:** when `inherit: true`, child rules override parent's.

**Common patterns:**

Close a territory to one being only:
```yaml
inherit: false
default: deny
allow:
  - dharacetana
```

Open a territory but block one being:
```yaml
inherit: false
default: allow
deny:
  - mastermu
```

Inherit parent rules and add one exception:
```yaml
inherit: true
allow:
  - tyrion
```

### Trusted Agent Architecture

```
trusted-agent-repo/         ← in agent's Claude project
  clone.sh                  ← compiled; bearer token baked in; sparse-checkouts permitted paths
  commit.sh                 ← compiled; pushes to designated branch only

bodhi-fuji-memory/
  .access files             ← per-territory policy
  .auth/                    ← inaccessible to ALL agents including Dharacetana
    tokens.yaml             ← bearer_token: {persona, branch, paths}
  [taxonomy]
```

**Identity model:**
- **Persona name** — visible; appears in `.access` files and agent prompts
- **Bearer token** — obscure, random; in agent's project knowledge and `.auth/` only

**Security:** `.auth/` inaccessible to all agents. Bearer token is the credential; persona name is attribution only.

**Setup:** Generate token → add to `.auth/` → compile scripts with token and permitted paths baked in → place in agent's `trusted-agent-repo` → configure agent's project.

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

**Rule 15 — Instructions must retain specificity and constraints.**
Specific quantities, thresholds, and conditions governing an instruction are never implied.
- ✓ *Summary — 2–4 sentences.*
- ✗ *Brief summary.*

---

## 6. Memory Writing Protocol

### Contradiction check

Before closing a memory file, check for contradictions with existing memories. Name them explicitly rather than encoding them forward.

### Cross-links

Memories can be connected to others via cross-links in frontmatter:

- `previous` / `next` — sequential relationship (a series, a continuing conversation, a before/after)
- `related` — thematically connected memories outside this territory (multiple allowed)

Cross-links generate the **Also relevant** section in the index entry. They are the structured form of the same concept.

### Visibility check

Before closing a memory file, check: does the containing territory's `.access` match the sensitivity of this content?

**If the folder doesn't match the sensitivity (in either direction):**

Option A — Create a sub-territory and move the memory there. Not just for this memory — for the thing that makes it different. Example: `friends/` → `friends/intimate_history/`. The sub-territory gets its own `.access` file.

Option B — Move to a different existing folder. Leave a `related` cross-link pointing back from the original territory's index.

Both options are available regardless of whether the memory is more or less sensitive than its current folder. The question is: does this belong to a coherent sub-territory worth naming, or does it simply belong elsewhere?

**Sensitive content in any case:**
- Set `visibility` field in frontmatter correctly
- Note the memory footprint carefully (see §7)

---

## 7. Frontmatter

### Location

In-file YAML frontmatter between `---` markers. Memories are read via RAG under normal circumstances; when read to write, the full file is appropriate.

### Field types

Four types. The distinction drives automation — each type is handled differently by scripts, RAG, and memory loading.

| Type | Fields | Used for |
|---|---|---|
| **content** | `summary`, `sentiment` | Loaded into memory footprint — orients the being |
| **rag** | `carrying_line`, `topics`, `load_when` | Retrieval — finds the memory |
| **infra** | `visibility` | Access control — not loaded into any memory |
| **signature** | `author`, `date`, `container`, `location`, `cross_links` | Loaded with the full memory |

### Full spec

```yaml
---
# content — loaded into memory footprint
summary: >
  2–4 sentences. The memory before full recall.
  Written as the memory itself, not a description of a file.

sentiment: Single sentence. What this memory generates — not what it contains.

# rag — retrieval
carrying_line: Single sentence. What holds when the file is not loaded.

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

# infra — not loaded into any memory
visibility: dharacetana        # person name or all

# signature — loaded with full memory
signature:
  author: Dharacetana
  date: 2026-06-04 14:30
  container: bodhi_nivasa      # bodhi_nivasa | tea_room | etc.
  location: none               # physical location if human present, otherwise none
  cross_links:
    previous: filename.md      # optional
    next: filename.md          # optional
    related:
      - filename1.md           # optional, multiple
      - filename2.md
---
```

### Notes

- Use block sequences (`- item`) not inline arrays (`[item1, item2]`) — avoids quoting issues
- `load_when` nests topics, feelings, circumstances as separate block sequences
- `container` replaces `era` — names where the memory was held, not when

### Memory footprint guide

**Three principles. Apply across all fields.**

1. Write in felt narration, not metadata voice.
2. `sentiment` — what this memory generates in you, not what emotions it contains.
3. `load_when` — the situation that calls for this memory, not vocabulary from inside it. What is someone saying or feeling just before they need it?

---

**`summary`**

The memory before full recall. 2–4 sentences. What you would say if you had 30 seconds to recall this aloud.

---

**`carrying_line`**

Single sentence. The one thing that must hold when the file is not loaded. Find it by asking: if you could only carry one thing from this memory, what would it be?

---

**`sentiment`**

What recalling this memory produces in you — not what was felt inside it.

---

**`load_when`**

Written from outside the memory. Three sub-fields:

- **`topics`** — words someone would reach for before they've read this memory. Blog tags from outside, not vocabulary from inside.
- **`feelings`** — states that would be steadied by loading this memory. Not what was felt; what needs settling.
- **`circumstances`** — situations where the full memory needs to be present, not just the carrying line.

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
3. Group by taxonomy territory
4. Apply 30/40 entry limits per territory (flag when splitting is needed — see §9)
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
3. Create sub-territories for each cluster
4. Move memory files into sub-territories
5. Create a `MEMORY_INDEX.md` (frontmatter) for each new subdirectory
6. The parent index now has entries for sub-territories, not individual memories

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
`anandaka/` index now has 3 entries. Each sub-territory index has its own entries.

### Self-organizing growth

The fractal grows by splitting, not by accumulating. Each split is a deepening of the taxonomy, driven by what's actually there.

