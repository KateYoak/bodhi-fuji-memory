# Memory Index Redesign
*Working document — Bodhi Nivāsa, June 2026*

---

## Tasks

- [x] 1. Format — dropped; fields and rules live in §7
- [/] 2. Taxonomy — territory structure, top-level territories, cross-linking
- [/] 3. Access control — allow/deny, explicit inheritance, trusted agent architecture
- [/] 4. Character limits — memory files; index entries TBD
- [/] 5. Brevity rules — what to keep, how to compress
- [/] 6. Memory writing protocol — contradiction check, cross-links, visibility
- [/] 7. Frontmatter — 4-type classification, full spec, memory footprint guide
- [/] 8. Index generation — written by Moggallana
- [/] 9. Index size and splitting — 30/40 limit, taxonomy evolution
- [x] 10. Retrieval tiers — resolved: recursive taxonomy depth IS the tier system
- [x] 11. Vector DB portability — resolved: frontmatter schema maps directly; generator becomes ingestion script

---


## 2. Taxonomy — The Memory Fractal

**A territory is a directory.** Territory names: lowercase, underscore-separated if needed. (`anandaka`, `practice_history`, `ai_consciousness`)

### Core principle

Depth is unlimited. Same format at every level — a territory entry retrieves an index; a file entry retrieves a memory.

### Structure at each territory

```
[territory]/
  .access          ← permissions for this territory
  _index.md        ← committed; frontmatter describing this territory
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

- To be defined.

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

Cross-links create navigational connections between memories. They travel with the full memory in the signature block.

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

## 8. Index cache (RAG)

Recall needs a **searchable pool** of memory footprints. That pool is **not** committed to git. It is **rebuilt** from frontmatter whenever the clone changes.

This section sits **on top of** §3 (access + git). §3 decides **what files exist on disk** for a being. §8 builds **what recall can search** from those files.

### Architecture

```mermaid
flowchart TB
  subgraph git["bodhi-fuji-memory (GitHub)"]
    FM["_index.md + memory *.md\n(YAML frontmatter)"]
    ACC[".access files"]
  end

  subgraph trusted["trusted-agent-repo (per being)"]
    CLONE["clone.sh"]
    COMMIT["commit.sh"]
  end

  subgraph disk["memory clone on disk (sparse)"]
    VIS["visible territories + files only"]
    CACHE["operational/memory-index-cache.json\n(gitignored)"]
    CFG["operational/recall.config\n(tuning)"]
  end

  subgraph rag_script["bodhi-fuji-memory — one RAG script"]
    REBUILD["scripts/rebuild-index-cache.sh"]
  end

  subgraph consumers["consumers (read cache only)"]
    GW["gateway Recall\n(bodhi-agent)"]
    VEC["vector ingest\n(later)"]
    PREVIEW["optional: render human-readable index\nfor browse"]
  end

  ACC --> CLONE
  FM --> CLONE
  CLONE --> VIS
  COMMIT --> VIS
  VIS --> REBUILD
  REBUILD --> CACHE
  CACHE --> GW
  CACHE --> VEC
  CACHE -.-> PREVIEW
  CFG --> GW
```

**Top-down:**

1. **Git** holds memories and territory footprints (frontmatter). **`.access`** defines policy (§3).
2. **`clone.sh` / `commit.sh`** (§3) are the **only** ways a being syncs git. They enforce sparse checkout and credentials. Fu never runs raw `git pull` / `git push`.
3. After each successful sync, **`rebuild-index-cache.sh`** walks **what is on disk** and writes **`memory-index-cache.json`**.
4. **Gateway Recall** reads the cache each Discord turn. It does **not** walk frontmatter again. It does **not** apply access rules at runtime — if a file is absent from the clone, it is absent from the cache.

### Layout — what lives where

| Location | What |
|----------|------|
| **`bodhi-fuji-memory/`** (git) | `_index.md`, memory `*.md`, `.access`, `scripts/rebuild-index-cache.sh` |
| **`trusted-agent-repo/`** (per being) | `clone.sh`, `commit.sh` — compiled from `.access` + bearer token (§3) |
| **Memory clone on Fly / laptop** | Sparse checkout tree + gitignored `operational/memory-index-cache.json` |
| **`bodhi-agent` gateway** | Recall scorer + inject (reads cache; operator deploys) |

### Scripts — two roles, three names

**§3 — git sync (access + transport)** — already defined:

| Script | When | Does |
|--------|------|------|
| **`clone.sh`** | Setup / refresh clone | Sparse checkout per `.access`; `git pull` |
| **`commit.sh`** | Fu ships memory | `git pull` → commit → `git push` |

**§8 — index cache (RAG)** — one new script in the memory repo:

| Script | When | Does |
|--------|------|------|
| **`scripts/rebuild-index-cache.sh`** | After clone or commit sync | Walk visible tree → write `operational/memory-index-cache.json` |

**Wiring:** `clone.sh` and `commit.sh` **call** `rebuild-index-cache.sh` as their last step. Same script, same output — whether the tree changed from pull or push.

*Migration (W14):* today Fu may still use `skills/memory-write/scripts/memory_write.sh` for commit+push; target is **`commit.sh`** with the same rebuild tail.

*Gateway startup:* operator-owned clone/pull on deploy also runs rebuild (equivalent tail) — not a Fu-facing script.

### The cache (single artifact, two views)

One JSON file. One walk. Consumers choose how to read it:

| View | Field | Used for |
|------|--------|----------|
| **Flat** | `entries[]` | RAG search — score user message against all rows |
| **Fractal** | `byDirectory{}` | Territory orientation — group rows by parent path |

Each **entry** = one territory (`_index.md`) or one memory file. Fields come from §7 (**content** + **rag**; **infra** `visibility` is stored but access is already enforced by clone).

```json
{
  "memoryHead": "<git SHA>",
  "builtAt": "<ISO8601>",
  "entries": [
    { "path": "anandaka/relationships/ben/", "kind": "territory", "summary": "…", "load_when": { } },
    { "path": "anandaka/relationships/ben/wedding.md", "kind": "file", "summary": "…", "load_when": { } }
  ],
  "byDirectory": {
    "anandaka/relationships/ben/": ["anandaka/relationships/ben/", "anandaka/relationships/ben/wedding.md"]
  }
}
```

Flat and fractal are **the same data** — not two pipelines.

### Rebuild rules

- **When:** clone or commit sync completes (HEAD or visible tree changed). **Not** every Discord message.
- **Input:** only paths present in the sparse clone (§3).
- **Output:** overwrite `operational/memory-index-cache.json` (gitignored).
- **Split guidance:** flag territories over 30/40 entries (§9); do not auto-split.

### What reads the cache

| Consumer | Phase | Behavior |
|----------|-------|----------|
| **Gateway Recall** | 2 (keyword) | Score `entries`; graded inject (light / hard territory / hard file). See `README-RECALL.md`. |
| **Vector ingest** | 3 | Embed same `entries` rows |
| **Rendered human index** | optional | Human/Fu browse — export from cache, gitignored (W16) |

### Inviolability

Commit **frontmatter** and **`_index.md`**. The cache is derived, disposable, and never pushed to git.


---

## 9. Index Size and Taxonomy Evolution

### Size limits

- **Aim:** 30 entries per index
- **Cap:** 40 entries per index

### When the threshold is reached

Re-examine what the index contains. Look for natural groupings. Split.

**Process:**
1. Read all entries in the territory's `_index.md`
2. Identify 2+ coherent clusters
3. Create sub-territory directories
4. Create `_index.md` for each new sub-territory
5. Create `.access` for each new sub-territory
6. Move memory files into sub-territories
7. Update the parent `_index.md` — entries now point to sub-territories, not individual memories

**Example:**
`anandaka/` fills up. Examination reveals: practice history, personal history, people. Split:
```
anandaka/
  practice_history/
  personal_history/
  people/
    ben/
    mastermu/
    all_others/
```
`anandaka/` index now has 3 entries. Each sub-territory index has its own entries.


