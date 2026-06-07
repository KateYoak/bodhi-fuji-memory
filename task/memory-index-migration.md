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

## Two artifacts (do not confuse)

| File | Role | Who creates it |
|------|------|----------------|
| **`operational/memory-manifest.yaml`** | Validation **input** — §7 schema + structural rules (`_index.md`, `.access`, etc.) | **Operator drafts from §7** → Anandaka validates → commit. `commit` **reads** it. |
| **`operational/memory-index-cache.json`** | Recall **output** — searchable footprints (`entries[]` + `byDirectory{}`) | **`rebuild-index-cache.sh` generates** from frontmatter walk. Gitignored. |

`rebuild-index-cache.sh` does **not** generate the manifest.

---

## Git auth (§3 — no `GIT_ASKPASS`)

PAT is **ciphertext embedded in the compiled binary** (garble build). `clone` / `commit` decrypt **in memory only** using `BODHI_BEARER` to select the row; zeroize after use. No askpass, no PAT in env, no plaintext on disk.

---

## Migration steps (in order)

### Phase 0 — Infra & repos

- [x] **0.1** Create **setup repo** (trusted-agent): Go project, `agents.yaml` (bearer, persona, branch per being) — `KateYoak/bodhi-trusted-agent`
- [/] **0.2** GitHub **Actions** on memory repo — **only allowed path to `main`**: being-branch push → open/update PR → governance stub → **merge commit** — `.github/workflows/being-merge.yml` — *(Operator)*
- [ ] **0.3** CI on setup repo: `PAT_*` per being + **`MEMORY_REPO_DEPLOY_KEY`** (one-time) → garble build → release bundle — *(Operator)*
- [x] **0.3b** **`sync-agents` workflow** — on `agents.yaml` push, create missing `being/*` branches on memory repo via deploy key — *(Operator)*
- [x] **0.4** Being branches — `being/dharacetana` live — *(Automatic after 0.3b)*
- [ ] **0.5** Make `bodhi-fuji-memory` **private**; enable **branch protection** on `main` (no force-push — needs GitHub Pro on private) — *(Anandaka)*

### Phase 1 — Memory repo foundation

- [ ] **1.1a** **Draft** `operational/memory-manifest.yaml` from redesign §7 + structural rules — *(Operator)*
- [ ] **1.1b** **Validate** manifest — Anandaka review/sign-off — *(Anandaka)*
- [ ] **1.1c** **Commit** manifest to `bodhi-fuji-memory` — *(Operator)*
- [ ] **1.2** Add **`scripts/rebuild-index-cache.sh`** → gitignored **`operational/memory-index-cache.json`** — *(Operator)*
- [ ] **1.3** Gitignore `operational/memory-index-cache.json` — *(Operator)*
- [/] **1.4** Parallel: **`memories/`** tree, §7 footprints, `_index.md` per territory — *(Dharacetana)* — 4 files at `memories/` root; no `_index.md` yet
- [ ] **1.5** **`.access`** files per territory (as sensitivity requires) — *(Corpus)*
- [ ] **1.6** Parallel: **`memory-index-update`** rewrite for frontmatter (not `MEMORY_INDEX.md`) — *(Anandaka + Dharacetana)*

### Phase 2 — Setup repo binaries

- [ ] **2.1** **`clone`**: fetch `.access` → walk inheritance → sparse expand → pull; **`refresh`** variant — *(Operator)*
- [ ] **2.2** **`commit`**: validate against **memory-manifest** → merge `main` → commit (persona author) → push being branch only — *(Operator)*
- [ ] **2.3** **`commit`**: re-walk `.access`; `.access` conflict / visibility-loss errors (§3 verbatim bullets) — *(Operator)*
- [ ] **2.4** **`commit`**: tail — invoke **`rebuild-index-cache.sh`** — *(Operator)*
- [ ] **2.5** Git auth: embedded ciphertext + in-memory decrypt + zeroize; **`BODHI_BEARER`** selects row; **no `GIT_ASKPASS`** — *(Operator)*

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

---

## Script map (legacy → target)

| Current | Target |
|---------|--------|
| `memory_write.sh` | `commit` binary |
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
