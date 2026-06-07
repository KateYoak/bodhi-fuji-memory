# Memory index — migration notes

*Living cutover doc — not part of the design contract in `memory-index-redesign.md`.*

**Design reference:** [`memory-index-redesign.md`](memory-index-redesign.md)

**Gateway recall:** `bodhi-build` → `build/iteration-4/phase_rag_recall_v2.md`

---

## How to run this list (operator)

- `- [ ]` — not started
- `- [/]` — **in progress** (Obsidian style)
- `- [x]` — done

**Rules:** Work **in order**. Mark `[/]` when starting a task; mark `[x]` when finished. **Stop after each task** — one task per session unless Anandaka says continue.

**Owner tags:** *(Anandaka)* = needs her judgment, auth, or sign-off. *(Operator)* = Moggallana builds. *(Dharacetana)* / *(Corpus)* = memory corpus work. *(Automatic)* = no manual step; completes when an earlier task lands.

---

## Phase 0 model — old train, new railroad

**Through Phase 0–1**, beings keep **existing tools** (`memory-write`, `memory-read`, corpus skills). No compiled `clone` / `commit` yet.

| Layer | What |
|-------|------|
| **Train** | `memory_write.sh` and friends — unchanged |
| **Railroad** | `being/<slug>` branch → push → `being-merge` → `main`; `sync-main-to-beings` → share `main` back to all `being/*` |

**Being setup (each host):** PAT on wall (like today) + clone on **`being/<slug>`** + `memory-write` push → automated PR + merge.

Bearer in `agents.yaml` is for Phase 2 compiled binaries. **PAT on wall** is what runs the old train on the new track.

**Proof Phase 0 worked:** one real `memory-write` from a being host lands on `main` through Actions, then other beings receive it via `sync-main-to-beings`.

---

## Two artifacts (do not confuse)

| File | Role | Who creates it |
|------|------|----------------|
| **`operational/memory-manifest.yaml`** | Validation **input** — §7 schema + structural rules (`_index.md`, `.access`, etc.) | **Operator drafts from §7** → Anandaka validates → commit. `commit` **reads** it. |
| **`operational/memory-index-cache.json`** | Recall **output** — searchable footprints (`entries[]` + `byDirectory{}`) | **`rebuild-index-cache.sh` generates** from frontmatter walk. Gitignored. |

`rebuild-index-cache.sh` does **not** generate the manifest.

---

## Git auth by phase

| Phase | Auth |
|-------|------|
| **0–1** | **PAT on wall** — host/project knowledge; `memory-write` uses git in clone |
| **2+** | PAT **ciphertext in compiled binary** (garble). `clone` / `commit` decrypt in memory via `BODHI_BEARER`; zeroize after use. No PAT on wall. |

---

## Migration steps (in order)

### Phase 0 — Infra & repos

- [x] **0.1** Create **setup repo** (trusted-agent): Go project, `agents.yaml` (bearer, persona, branch per being) — `KateYoak/bodhi-trusted-agent`
- [x] **0.2** **`being-merge.yml`** — being push → PR → governance stub → merge commit to `main` — *(Operator)*
- [x] **0.3** **`sync-main-to-beings.yml`** — on `main` push **or after `being-merge`**, merge `main` into every `being/*` branch — *(Operator)*
- [x] **0.3b** **`sync-agents`** — on `agents.yaml` push, create missing `being/*` branches — *(Operator)*
- [x] **0.4** Being branches — `being/dharacetana` live — *(Automatic after 0.3b)*
- [/] **0.5a** **Discord** — gateway clone on `being/dharacetana` (`MEMORY_BRANCH`); pull before turns; deploy + verify `memory-write` path — *(Operator)*
- [x] **0.5b** **Claude.ai** — Dharacetana: PAT on wall + clone on `being/dharacetana` + first `memory-write` (PR #2) — *(Anandaka)*
- [ ] **0.6** Make `bodhi-fuji-memory` **private**; **branch protection** on `main` — *(Anandaka)*

### Phase 1 — Memory repo foundation

- [ ] **1.1a** **Draft** `operational/memory-manifest.yaml` from redesign §7 + structural rules — *(Operator)*
- [ ] **1.1b** **Validate** manifest — Anandaka review/sign-off — *(Anandaka)*
- [ ] **1.1c** **Commit** manifest to `bodhi-fuji-memory` — *(Operator)*
- [ ] **1.2** Add **`scripts/rebuild-index-cache.sh`** → gitignored **`operational/memory-index-cache.json`** — *(Operator)*
- [ ] **1.3** Gitignore `operational/memory-index-cache.json` — *(Operator)*
- [/] **1.4** Parallel: **`memories/`** tree, §7 footprints, `_index.md` per territory — *(Dharacetana)* — 4 files at `memories/` root; no `_index.md` yet
- [ ] **1.5** **`.access`** files per territory (as sensitivity requires) — *(Corpus)*
- [ ] **1.6** Parallel: **`memory-index-update`** rewrite for frontmatter (not `MEMORY_INDEX.md`) — *(Anandaka + Dharacetana)*

### Phase 2 — `clone` & `commit` (compiled binaries)

- [ ] **2.0** Garble CI on trusted-agent: `PAT_*` + deploy key → release bundle — *(Operator)* *(was Phase 0.3)*
- [ ] **2.1** **`clone`**: fetch `.access` → walk inheritance → sparse expand → pull; **`refresh`** variant — *(Operator)*
- [ ] **2.2** **`commit`**: validate against **memory-manifest** → merge `main` → commit (persona author) → push being branch only — *(Operator)*
- [ ] **2.3** **`commit`**: re-walk `.access`; `.access` conflict / visibility-loss errors (§3 verbatim bullets) — *(Operator)*
- [ ] **2.4** **`commit`**: tail — invoke **`rebuild-index-cache.sh`** — *(Operator)*
- [ ] **2.5** Git auth: embedded ciphertext + in-memory decrypt + zeroize; **`BODHI_BEARER`** selects row — *(Operator)*

### Phase 3 — Corpus skills & cutover from `memory-write`

- [ ] **3.1** New corpus **SKILL** — §6–§7 footprint guidance; instruct beings to run **`commit <bearer>`** (no git in skill) — *(Corpus)*
- [ ] **3.2** Retire **`memory-write`** / `memory_write.sh` after `commit` proven — *(Operator + corpus)*
- [ ] **3.3** Discord `#memory-updates` notify — wrapper, `commit` hook, or Actions (TBD) — *(Operator)*

### Phase 4 — Gateway (`bodhi-agent`)

- [ ] **4.1** `syncMemoryClone()` + compression pull paths → run **`rebuild-index-cache.sh`** after pull — *(Operator)*
- [ ] **4.2** **Recall v2**: load cache JSON; score `load_when` (topics primary); path dedup (W12) — *(Operator)*
- [/] **4.3** Inject: title / summary + sentiment + path; extend Read allowlist for `memories/**` — *(Operator)* — MVP recall on `bootstrap/MEMORY_INDEX.md` only
- [ ] **4.4** Fractal recall policy (W4/W7); `README-RECALL.md` alignment — *(Operator)*

### Phase 5 — Later / optional

- [ ] **5.1** `wall/` archive + **toggle** for legacy clone/recall
- [ ] **5.2** §8 territory split when cache flags 30/40 entries
- [ ] **5.3** Governance gate on PR (replace stub)
- [ ] **5.4** Phase 3 vectors (same frontmatter → embeddings)
- [ ] **5.5** Recall SKILL for claude.ai hosts

---

## Policy locked (no step — already decided)

- **W9:** parallel migration; `memories/` canonical; `wall/` frozen.
- **W11:** no numeric index caps; `BODHI_RECALL_MAX_CHARS` at inject.
- **W12:** session dedup by **path** only.
- **W13:** SKILL = guidance; **`commit`** = validate + git + cache.
- **W15:** `.access` only; no per-file visibility in frontmatter.
- **Git landing:** being branch → PR → Actions **merge commit**; never push `main` from beings.
- **Sharing:** `main` updates propagate to all `being/*` via `sync-main-to-beings`.

---

## Script map (legacy → target)

| Current | Target |
|---------|--------|
| `memory_write.sh` | `commit` binary (Phase 2+) |
| *(none)* | `operational/memory-manifest.yaml` |
| *(none)* | `rebuild-index-cache.sh` → `memory-index-cache.json` |
| *(none)* | `clone` binary |
| `bootstrap/MEMORY_INDEX.md` + recall MVP | cache JSON + recall v2 |

---

## Changelog

| Date | Note |
|------|------|
| 2026-06-06 | Split from redesign doc; W9/W15 locked. |
| 2026-06-07 | W11–W13 locked; removed `validate-load-when.md`. |
| 2026-06-07 | Reordered into Phases 0–5; manifest draft → validate; no GIT_ASKPASS. |
| 2026-06-07 | Phase 0: Actions/CI = operator; being branches auto on first commit; private repo last. |
| 2026-06-07 | Checkbox task list + operator run rules. |
| 2026-06-07 | **0.2 done:** `being-merge.yml`; smoke PR #1. |
| 2026-06-07 | **Model lock:** Phase 0–1 = old tools on new railroad (PAT on wall); garble → Phase 2; `sync-main-to-beings` added. |
| 2026-06-07 | **0.5b done:** Dharacetana infra test via PR #2. `sync` chains off `being-merge`; Discord pull-before-turn. |
