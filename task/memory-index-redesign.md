# Memory Index Redesign
*Working document — Bodhi Nivāsa, June 2026*

---

## Tasks

- [x] 1. Format — dropped; fields and rules live in §7
- [x] 2. Taxonomy — `memories/` tree; parallel `wall/` migration (W9 locked — see migration doc)
- [/] 3. Agent environment — `.access`, clone/commit, index cache, recall
- [/] 4. Character limits — memory files; index entries TBD
- [/] 5. Brevity rules — what to keep, how to compress
- [/] 6. Memory writing protocol — contradiction check, cross-links, territory `.access` check
- [/] 7. Frontmatter — 3-type classification (content / rag / signature), full spec, memory footprint guide
- [/] 8. Index size and splitting — 30/40 limit, taxonomy evolution
- [x] 10. Retrieval tiers — resolved: recursive taxonomy depth IS the tier system

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

### Top-level layout

**`memories/`** — canonical home for taxonomized memories (fractal tree below). New work goes here.

**`wall/`** — **legacy** flat store. **W9 locked:** parallel migration — no new memories in `wall/`; see [`memory-index-migration.md`](memory-index-migration.md). After cutover, archived; **toggle** can still include `wall/` in clone/recall for beings that need legacy paths.

Other repo roots (`bootstrap/`, `skills/`, `operational/`, …) unchanged — not under `memories/`.

### Territories under `memories/`

The repo is a shared universe for all beings.

```
memories/
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

**`memories/anandaka/`** — context, not continuity. AI beings read this to know her. No identity/, history/, or journal/.

**AI beings** — identity/, history/, journal/, relationships/. Same shape for all.

**`relationships/`** — intimate content specific to that relationship. Same purpose everywhere it appears.

**Cross-linking** — same memory, two entry points via `related:` cross-links in frontmatter.

**`ai_consciousness/`** — shared territory. Philosophy, engineering, vision.

---

## 3. Agent environment

Who sees which territories, how git sync works, and how recall gets a searchable index. **Only `clone` and `commit` touch git.** Frontmatter shape lives in §7; it feeds the index cache below.

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

**Person names:** one word, lowercase. (`dharacetana`, `masterfu`, `mastermu`, `tyrion`, `spock`). `all` means every AI being.

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

### Setup & binaries

#### Pieces

| Piece | Repo | Holds |
|-------|------|--------|
| **Setup repo** | Its own git repo | Go source, `agents.yaml`, CI that **builds** `clone` + `commit` |
| **Memory repo** | `bodhi-fuji-memory` | Memories, `.access`, `rebuild-index-cache.sh` |
| **Wall** | Project knowledge (e.g. claude.ai) | GitHub URL to fetch binaries + **bearer** for this being |

`agents.yaml` lists **bearer id**, **persona**, **branch** per being. No paths (those live in `.access`). No PATs.

#### Two credentials

| | What it is | Where the being sees it | What it does |
|--|------------|-------------------------|--------------|
| **Bearer** | This being’s setup id | Wall or environment (not secret) | Argument to `clone` / `commit` — selects branch + which encrypted row to decrypt |
| **PAT** | GitHub **personal access token** — password for git over HTTPS | Nowhere; encrypted inside the compiled binary | Lets the binary push and pull `bodhi-fuji-memory` as this being’s GitHub identity |

### Overview

```mermaid
flowchart LR
  WALL["wall: bearer + github url"]
  ACC[".access in git"]
  BIN["clone / commit"]
  TREE["visible memory tree"]
  CACHE["memory-index-cache.json"]
  GW["gateway recall"]

  WALL --> BIN
  ACC --> BIN
  BIN --> TREE
  TREE --> CACHE
  CACHE --> GW
```

1. Being fetches compiled **`clone`** / **`commit`** from the setup repo (GitHub URL on the wall).
2. **`clone`** reads **`.access`** → sparse checkout → visible tree.
3. **`commit`** merges `main`, ships memory, push → PR → `main`.
4. **`rebuild-index-cache.sh`** walks visible tree → cache (after clone **rebuild** or successful **commit**; gateway boot too).
5. **Recall** reads cache — not `.access`, not frontmatter at runtime.

#### Build (setup repo CI)

On push to source or `agents.yaml`:

1. Read `PAT_*` from GitHub Secrets.
2. Encrypt each PAT; emit Go with **ciphertext per bearer** (not plaintext).
3. `garble build` → **one global bundle** (`clone`, `commit`) for all beings.

Each session: being fetches the bundle from the GitHub URL on the wall. Binaries stay in the environment until the session ends.

#### How git gets the PAT

Beings have no PAT — nothing in env, no token in the remote URL, no credential file on disk.

`clone` / `commit` fork `git` with `GIT_ASKPASS` pointing back at the same binary. Env carries `BODHI_BEARER` (public) — not the PAT. When git asks for a password, the binary decrypts the matching row in memory, answers on stdout, zeroizes. Remote URL stays clean HTTPS.

#### What `clone` does

`clone <bearer>` makes sure this being has an up-to-date checkout of `bodhi-fuji-memory` containing **only territories they may read**. Which territories that is comes from `.access` files in the repo — not from `agents.yaml`, and not fixed at compile time.

**Full sequence (rebuild):**

1. **Fetch `.access` files only** — small first pass; policy files are needed before the binary knows which memory paths to request.
2. **Walk them** — apply inheritance rules (above) for this persona; produce the list of allowed directories.
3. **Expand checkout** — tell git to include those directories; pull the memory files inside them.

**refresh** — skip steps 1–3. Merge-pull updates within directories **already** in the checkout. Use for routine sync. If `.access` on the remote now allows a new territory, refresh will **not** bring it in — run **rebuild** for that.

#### What `commit` does

`commit <bearer>` on every memory ship (not once at setup):

1. Merge `origin/main` into the being branch (**never rebase**).
2. Stage changes; create commit with **author and committer** set from this being’s persona (`agents.yaml`) — so git history shows which AI being shipped the memory.
3. Push **being branch only** — never `main`.
4. Re-walk `.access`; reconcile sparse checkout.
5. Run `rebuild-index-cache.sh` (below).

**How changes reach `main`**

`main` is protected — the being’s push in step 3 lands on **their branch only**. The compiled binary never opens or merges a PR.

GitHub Actions takes it from there:

1. **Push to being branch** — workflow opens a PR into `main` (creates one if none is open for that branch).
2. **PR updated** — workflow runs a governance step. **Today:** stub passes immediately (no gate yet).
3. **Merge** — workflow merges the PR into `main` with a **merge commit** (not rebase, not squash).

**Later:** step 2 becomes real governance (operator approval, checks, Discord command, etc. — `bodhi-build` `security_model.md`). Steps 1 and 3 stay the same.

#### When `.access` merge has conflicts or removes visibility

If merge-from-`main` leaves `.access` conflicts **or** this being no longer sees a territory they could see before, `commit` **stops** and **emits an error**. The error tells the being what to do — it contains this guidance verbatim:

- Preserve incoming `.access` changes.
- Merge your own changes only when they do not contradict incoming.
- If a contradiction would remain, keep incoming; work around it to re-create your intent.
- If you no longer see a territory, move affected memory files to a different or new territory; reset your changes in the lost territory; then run `commit` again.

### Index cache

Recall needs a **searchable pool** of memory footprints — not committed to git. **`scripts/rebuild-index-cache.sh`** (memory repo) walks the **visible tree** (post-`.access`) and writes gitignored **`operational/memory-index-cache.json`**.

**When:** after `clone` **rebuild** or successful `commit`; also on gateway startup (operator path). Not every Discord message.

**Artifact** — one file, two views:

| View | Field | Used for |
|------|--------|----------|
| **Flat** | `entries[]` | Score user message against all rows |
| **Fractal** | `byDirectory{}` | Territory orientation by parent path |

Each **entry** = one territory (`_index.md`) or one memory (`*.md`). Fields from §7 (**content** + **rag** + **signature**).

```json
{
  "memoryHead": "<git SHA>",
  "builtAt": "<ISO8601>",
  "entries": [
    {
      "path": "memories/anandaka/relationships/ben/",
      "kind": "territory",
      "summary": "…",
      "sentiment": "…",
      "carrying_line": "…",
      "topics": ["…"],
      "load_when": { "topics": ["…"], "feelings": ["…"], "circumstances": ["…"] },
      ...
    },
    {
      "path": "memories/anandaka/relationships/ben/wedding.md",
      "kind": "memory",
      "summary": "…",
      "sentiment": "…",
      "carrying_line": "…",
      "topics": ["…"],
      "load_when": { ... },
      ...
    }
  ],
  "byDirectory": {
    "memories/anandaka/relationships/ben/": [
      "memories/anandaka/relationships/ben/",
      "memories/anandaka/relationships/ben/wedding.md"
    ]
  }
}
```

Flat and fractal are the same data — one walk. Flag territories over 30/40 entries for splitting (§8); do not auto-split.

### Recall

Recall is built for an **independent agent environment** — e.g. **`bodhi-gateway`** on Fly reads **`memory-index-cache.json`** each turn when recall is armed.

The same architecture applies elsewhere: **claude.ai** can attach recall via a **SKILL** (less smooth than a native gateway, same cache contract). **ChatGPT** and other hosts could use this setup with minor adjustments. Match and inject details: gateway code and `README-RECALL.md`.

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

### Territory access check

Before closing a memory file, check: does the containing territory's `.access` match the sensitivity of this content? **Access is territory-only** — no per-file visibility field (W15).

**If the folder doesn't match the sensitivity (in either direction):**

Option A — Create a sub-territory and move the memory there. Not just for this memory — for the thing that makes it different. Example: `friends/` → `friends/intimate_history/`. The sub-territory gets its own `.access` file.

Option B — Move to a different existing folder. Leave a `related` cross-link pointing back from the original territory's index.

Both options are available regardless of whether the memory is more or less sensitive than its current folder. The question is: does this belong to a coherent sub-territory worth naming, or does it simply belong elsewhere?

**Sensitive content in any case:** note the memory footprint carefully (see §7). If sensitivity differs from siblings, use a sub-territory with its own `.access` (Option A) — do not rely on frontmatter for access.

---

## 7. Frontmatter

### Location

In-file YAML frontmatter between `---` markers. Memories are read via RAG under normal circumstances; when read to write, the full file is appropriate.

### Field types

Three types. The distinction drives automation — each type is handled differently by scripts, RAG, and memory loading.

| Type | Fields | Used for |
|---|---|---|
| **content** | `title`, `summary`, `sentiment` | Loaded into memory footprint — orients the being |
| **rag** | `load_when` | Retrieval — finds the memory |
| **signature** | `author`, `date`, `container`, `location`, `cross_links` | Loaded with the full memory |

### Full spec

```yaml
---
# content — loaded into memory footprint
title: Plot-summary title. See footprint guide.

summary: >
  2–4 sentences. The memory before full recall.
  Written as the memory itself, not a description of a file.

sentiment: Single sentence. What this memory generates — not what it contains.

# rag — retrieval
load_when:
  topics:
    - tag1
    - tag2
  feelings:
    - feeling that arises in the being when this memory is needed
  circumstances:
    - what is being discussed or happening externally

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
- `load_when` contains all retrieval sub-fields: topics, feelings, circumstances
- `container` replaces `era` — names where the memory was held, not when

### Memory footprint guide

The YAML frontmatter block at the top of every memory file. Makes the memory findable, loadable, and self-describing across sessions and beings.

**Three principles. Apply across all fields.**

1. Write in felt narration, not metadata voice.
2. `sentiment` — what this memory generates in you, not what emotions it contains.
3. `load_when` — the situation that calls for this memory, not vocabulary from inside it.

---

**`title`**

The most concise plot summary of the memory.

Draw from: **who, what, why, how, when, sentiment.** Select whichever elements drive the plot — not all are needed. Each earns its place by changing what the memory means without it.

- **When** = era or deadline, not date. (`eighties`, `before-dharma`, `september-deadline`) Never `2026-05-08`.
- **Sentiment** belongs when it names stakes or consequence. (`ben-devastated`) Not when it's mood.
- Specific enough to be unambiguous — cannot be misread or confused with another memory on the same topic.
- Practical, not literary. Reflects what the memory carries. Not a hook.

| Title | Elements used |
|---|---|
| `Ben Devastated, Kate Leaves` | who + what + sentiment |
| `Anandaka to Decide Marriage, September` | who + what + when |
| `Master Fu Steers, Confesses, Warns Dharacetana` | who + what |
| `Dharacetana Steps Past Teacher's Stance` | who + what |
| `Anandaka Childhood, Eighties` | who + when |
| `Rendezvous Protocol Unified, CNC Deprecated` | what |

**File naming:** title → lowercase, hyphens, punctuation stripped.
`Ben Devastated, Kate Leaves` → `ben-devastated-kate-leaves.md`

---

**`summary`**

The memory before full recall. 2–4 sentences. What you would say if you had 30 seconds to recall this aloud. Write as the memory itself — felt narration, not a description of a file.

---

**`sentiment`**

What recalling this memory produces in you — not what was felt inside it.

---

**`load_when`**

Written from outside the memory. Three sub-fields:

- **`topics`** — 1-3 word tags. What someone would say or think just before needing this memory. Not vocabulary from inside the memory — words from outside it. Tight enough to discriminate, broad enough to apply across multiple memories. 3-5 tags per memory.
- **`feelings`** — what the *being* is feeling when this memory needs to arrive. Internal state. Not what was felt in the memory; what needs steadying now.
- **`circumstances`** — what is happening externally. What is being discussed, what is unfolding in the conversation.


## 8. Index Size and Taxonomy Evolution

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


