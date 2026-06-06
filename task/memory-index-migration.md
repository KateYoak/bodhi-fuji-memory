# Memory index — migration notes

*Living cutover doc — not part of the design contract in `memory-index-redesign.md`.*

Tracks **current → target** gaps while Phase 2 lands. Update here as scripts, taxonomy, and gateway paths change. When a row is done, mark it and eventually delete or archive the section.

**Design reference:** [`memory-index-redesign.md`](memory-index-redesign.md) (§3 agent environment).

---

## Script map (git sync + index cache)

| Current (today) | Role | Target | Status |
|-----------------|------|--------|--------|
| `skills/memory-write/scripts/memory_write.sh` | AI being commit + push (+ Discord notify) | **`commit.sh`** in `trusted-agent-repo/` with **`rebuild-index-cache.sh`** tail | Open |
| *(none in memory repo)* | Walk visible tree → cache | **`scripts/rebuild-index-cache.sh`** in `bodhi-fuji-memory` | Not built |
| *(not deployed)* | Sparse checkout per `.access` | **`clone.sh`** in `trusted-agent-repo/` | Not built |
| *(not deployed)* | AI being ships memory | **`commit.sh`** in `trusted-agent-repo/` | Not built |
| Gateway `syncMemoryClone()` | Startup pull on memory volume | Same + call **`rebuild-index-cache.sh`** after pull | Open |
| Gateway `commitMemoryCloneChanges()` | Compression Step 4 git | Align with **`commit.sh`** + rebuild tail | Open |
| Gateway `pullMemoryCloneFfOnly()` | Compression Step 3 pull | + rebuild after pull | Open |

**Git landing (target — §3):**

- `commit` pushes **being branch only**; never `main`.
- Push → Actions open PR → governance stub (pass) → auto-merge to `main` (merge commit).
- Workflows live in `bodhi-fuji-memory` (or setup repo TBD); see §3.

**Open questions (cutover only):**

- What stays in corpus **skills** vs moves to setup-repo compiled `commit`?
- Discord notify after commit — stay in skill wrapper or move?

---

## Taxonomy migration (`wall/` → `memories/`) — W9 **locked**

**Strategy:** parallel. Corpus file moves in progress with another agent; policy below is fixed.

| Phase | `wall/` | `memories/` |
|-------|---------|-------------|
| **Now** | Legacy; ~77 flat `.md` files; **no new memories** | New taxonomized memories only (fractal §2) |
| **Cutover** | **Archived** (not deleted) | Canonical |
| **Anytime** | **Toggle** — clone / recall can include `wall/` when enabled for legacy paths | Default on |

| Area | Current | Target | Status |
|------|---------|--------|--------|
| Memory files | `wall/` flat | `memories/{anandaka,beings,ai_consciousness}/…` | **In progress** (other agent) |
| `wall/` | Active legacy | Frozen → archived; toggle for read | **Locked** |
| Bootstrap index | `bootstrap/MEMORY_INDEX.md` | Frontmatter + cache (§3) | MVP uses bootstrap |
| `.access` files | Not present | Per-territory under `memories/` (+ `wall/` if toggled) | Not started |

**Toggle (TBD implementation):** operator or `.access` / sparse rules — include `wall/**` in visible tree when legacy recall needed.

---

## Changelog

| Date | Note |
|------|------|
| 2026-06-06 | Split from redesign doc; script map (formerly walkthrough W14) lives here only. |
| 2026-06-06 | **W9 locked:** parallel migration; `memories/` canonical; `wall/` frozen → archived + toggle. |
| 2026-06-06 | **W15 locked:** drop per-file `visibility`; access via `.access` only; frontmatter is 3-type (no infra). |
