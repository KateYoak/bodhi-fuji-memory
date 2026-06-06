# Memory index — migration notes

*Living cutover doc — not part of the design contract in `memory-index-redesign.md`.*

Tracks **current → target** gaps while Phase 2 lands. Update here as scripts, taxonomy, and gateway paths change. When a row is done, mark it and eventually delete or archive the section.

**Design reference:** [`memory-index-redesign.md`](memory-index-redesign.md) (§3 access/git, §8 index cache).

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

**Open questions (cutover only):**

- What stays in corpus **skills** vs moves to **trusted-agent-repo** compiled scripts?
- Who owns pull-before-commit — skill, `commit.sh`, or gateway?
- Discord notify after commit — stay in skill wrapper or move?

---

## Taxonomy migration (`wall/` → fractal dirs)

| Area | Current | Target | Status |
|------|---------|--------|--------|
| Memory files | Mostly under `wall/` | Per-being + `anandaka/` fractal (redesign §2) | Open |
| Bootstrap index | Committed `bootstrap/MEMORY_INDEX.md` | Frontmatter + generated cache; optional rendered browse (W16) | MVP uses bootstrap |
| `.access` files | Not present | Per-territory policy (§3) | Not started |

---

## Changelog

| Date | Note |
|------|------|
| 2026-06-06 | Split from redesign doc; script map (formerly walkthrough W14) lives here only. |
