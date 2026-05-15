# Context-manage — inspect, change, and troubleshoot bootstrap context

Work from the **memory repo root** (`MEMORY_CLONE_PATH` on the gateway).

---

## 1. Vocabulary (three different things)

| Concept | What it is | How you learn its state |
|--------|------------|-------------------------|
| **Bootstrap bundle** | Which fixed files (`SOUL`, `USER`, …) get prepended on a *fresh* turn | Read `bootstrap/bundle-config` (see §2) |
| **`ACTIVE_CONTEXT.md`** | Extra markdown layered after the bundle | Read `bootstrap/ACTIVE_CONTEXT.md` |
| **Discord “resume”** | Claude session id stored per thread so the next message continues the same Code session | You **cannot** Read it from the corpus. A successful **resume clear** is proven by **two Bodhi Discord posts** with the same **nonce** (see §2.5) |

**`!fu compact`** is **Claude session compaction** — it is **not** the same as clearing Discord resume or rewriting `ACTIVE_CONTEXT`.

---

## 2. How to **check** context state (step-by-step)

Do these in order.

### Step 1 — Which bundle preset is configured?

1. **Read** `bootstrap/bundle-config` if it exists.
2. The **entire effective file** is **one line**, lowercase: `complete`, `basic`, or `minimal`.
3. If the file **does not exist**, the gateway uses env **`BODHI_BOOTSTRAP_BUNDLE`** on the server, or defaults to **`complete`**. You cannot read that env from the corpus; if the file is missing, assume **`complete`** unless ops says otherwise.

### Step 2 — Which files belong to that preset?

| Preset | Read these under `bootstrap/` (if present) |
|--------|---------------------------------------------|
| **`complete`** | `SOUL.md`, `USER.md`, `AGENTS.md`, `MEMORY_INDEX.md` |
| **`basic`** | `SOUL.md`, `USER.md`, `AGENTS.md` |
| **`minimal`** | `AGENTS.md` only |

**Read** each path. That is the **static** identity/bootstrap material that will load on a turn that **does not** use Discord resume (or when `BODHI_BOOTSTRAP_EVERY_TURN=true`).

### Step 3 — Optional curated layer

**Read** `bootstrap/ACTIVE_CONTEXT.md`.

- **Missing**: no curated layer is appended.
- **Present**: body is appended **after** the bundle on eligible turns.

To reason about **size**, use the length of the text returned by **Read** (there is no separate “token counter” tool in the corpus).

### Step 4 — Discord resume (you cannot read the session map here)

Whether this thread currently has a **stored resume id** is **not** exposed as a file in the corpus. Practical rule:

- If the last turn ended with a **successful** `write_active_context.sh` from **Discord**, you should have seen **two** “Bodhi” messages with the **same nonce** → resume was cleared for **that** turn’s completion; the **next** user message starts **without** resume (bundle + `ACTIVE_CONTEXT` injected per gateway rules).

### Step 5 — Confirming a **resume clear** actually happened

After running **`write_active_context.sh`** **during a Discord-triggered turn** (so `BODHI_DISCORD_POST_CHANNEL_ID` is set):

1. **First post** — from the script: **“Bodhi: ACTIVE_CONTEXT saved — resume-clear requested (nonce `…`)”**.
2. **Second post** — from the gateway **after** the turn finishes: **“Bodhi: Discord resume cleared (nonce `…`) …”** (or the “nothing was persisted” variant).

**Matching nonce on both posts** = gateway consumed `bootstrap/.bodhi_resume_clear.<thread-or-channel-id>.json` and removed the stored session id **for this Discord surface**.

3. Check the marker file is **gone** (optional): **Glob** or **Read** `bootstrap/.bodhi_resume_clear.<id>.json` — after success it should **not** exist (`<id>` is the same snowflake as the active thread/channel posting target).

---

## 3. How to **change the bundle only** (no resume clear)

From the memory repo root:

```bash
bash skills/context-manage/scripts/write_bundle_config.sh minimal
```

or stdin:

```bash
printf '%s\n' basic | bash skills/context-manage/scripts/write_bundle_config.sh
```

Then **Read** `bootstrap/bundle-config` again to verify.

This does **not** emit a resume-clear marker and does **not** post Bodhi confirmations.

---

## 4. How to **rewrite `ACTIVE_CONTEXT` and request Discord resume clear**

### 4.1 What to run (curated body on stdin)

```bash
bash skills/context-manage/scripts/write_active_context.sh <<'EOF'
Your curated markdown summary (goals, constraints, carrying facts).
EOF
```

**During a live Discord turn** this should also create the nonce + marker + first Bodhi Discord post (and may also post via **discord-say** when that script is present).

### 4.2 Operator override

Send: **`!fu skill run context-manage`** — same scripts from the corpus; gateway **requires** a valid marker at end of forced turn or it errors.

### 4.3 Local / CI (no Discord channel env)

If **`BODHI_DISCORD_POST_CHANNEL_ID`** is unset, the script still writes **`bootstrap/ACTIVE_CONTEXT.md`** but **does not** write a resume-clear marker or call `post-message`. That is appropriate for **`curl`** / **`POST /v1/query`** without Discord.

---

## 5. Full live Claude context size

Exact **conversation token counts** inside Claude Code are **not** exposed as a dedicated tool today. Approximate corpus footprint = **Read** the bundle files + `ACTIVE_CONTEXT` as above. Infra-level usage (API spend, traces) uses **Datadog / operator dashboards**.

---

## 6. Troubleshooting

| Symptom | Likely cause |
|--------|----------------|
| No Bodhi posts after writer | Discord env not set (non-Discord turn), or `post-message` failed (script exits non-zero). |
| Forced skill error about marker | Writer did not run, or Discord post failed, or marker stale → run writer again inside the same forced turn. |
| Stale nonce / old marker | Gateway deletes stale markers on consume failure; rerun writer for a fresh nonce. |
| Only one Bodhi post with nonce | Turn did not finish or gateway did not consume marker — check Fly logs; rerun `write_active_context.sh` on a Discord turn. |
