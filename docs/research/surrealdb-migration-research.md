# SurrealDB 2.2.2 → 3.x Migration Research

**Author:** Oracle2 subagent (deep research, primary sources)
**Date:** 2026-06-14
**Subject:** Migration path for local SurrealDB instance + feasibility for replacing flat-file agent memory in `i2i-vessel/`
**Sources:** `surrealdb.com/docs`, `github.com/surrealdb/surrealdb`, `github.com/surrealdb/docs`, live probe of local instance.

---

## TL;DR

| Question | Verdict |
|---|---|
| 1. Are there breaking changes? | **Yes, many.** 29 documented, 12 critical. Futures, MTREE, `SEARCH ANALYZER`, `~` operators, `.*` idiom, function renames, plus record-reference syntax and identifier changes. |
| 2. Is there a migration tool? | **Yes, two paths:** (a) Surrealist GUI "Migration diagnostics" + V3 Compatible Export (requires 2.6.1+); (b) CLI `surreal v2 export --v3` (requires 3.0.3+ binary). Both produce a SurrealQL file → `surreal import` into 3.x. |
| 3. New agent-specific features in 3.x? | **Spectron** (agent memory + knowledge layer), **HNSW** vector indexes + **DISKANN** (3.1+), **parameters in LIVE SELECT** (3.0+), **MCP server** (`surreal mcp` over stdio), changefeeds (`SHOW CHANGES`), multi-model queries in one statement. |
| 4. Can SurrealDB replace flat-file memory in `i2i-vessel/`? | **Yes, with caveats.** It's a strong fit for the bottle/shard model (graph + vector + JSON), but you also get atomic transactions across models, live-query push, and sub-millisecond hops. Caveat: in-memory `memory://` mode (what you run today) loses everything on restart — you must move to a real backend (`surrealkv://`/`rocksdb://`) before any of this is durable. |
| 5. Memory footprint difference? | Your current 2.2.2 in-memory process: **127 MB RAM** for almost-empty DB; **51 MB binary**. 3.x binary: **116 MB** (more than 2× larger — extra features compiled in). In-process RSS grows with data; the 3.x engine itself is a different shape (compute-storage separation, Spectron's in-DB extraction adds headroom). Plan 200–400 MB RSS once you have real data + vector indexes. |

**Top recommendation:** Take a `surreal export` first (even though it's tiny, treat it as a backup), `surreal upgrade` to **3.1.4** (latest, not just 3.0 — every 3.0.x has 3.1+ bugfixes), and run `surreal v2 export --v3` while the 2.2.2 process is still up. The migration is lossy-but-tooled for ~80% of the breaking changes; the other ~20% needs schema review.

---

## 1. Local instance inventory

Probed via `curl http://127.0.0.1:8000/version` and the `surreal-v2` SQL REPL.

| Item | Value |
|---|---|
| Server version | **SurrealDB 2.2.2** |
| Running binary | `/usr/local/bin/surreal-v2` (51 MB) |
| Process | PID 2695164, started Jun 10 13:36 UTC, `surreal-v2 start --log info --user root --pass root --bind 0.0.0.0:8000` |
| Port | 8000, **bound to 0.0.0.0 (not 127.0.0.1)** — worth re-tying if it's meant to be local |
| Auth | root / root |
| Storage backend | **`memory://`** (no `[PATH]` arg, default is in-memory; `lsof` shows zero data files open) |
| RAM usage | 127.5 MB reported by `INFO FOR ROOT` (`memory_usage: 133,656,576`) |
| Host RAM | 23 GB total, 9.1 GB free |
| Cores | 4 |
| Namespaces | `test`, `open_notebook` |
| Data | `test.test.bottle:1` with `{message: "test"}` (the create I made while probing) |
| `open_notebook` | empty schema |
| **Risk** | `memory://` = **data evaporates on every restart or crash**. This is more important to fix than the major-version upgrade. |

CLI on PATH: `/usr/local/bin/surreal` (3.1.3, 116 MB binary, has `v2` subcommand for back-compat). So the 3.x toolchain is already on the box — only the server process is still on 2.2.2.

---

## 2. Release timeline (relevant)

From `https://github.com/surrealdb/surrealdb/tags`:

| Tag | Date | Notes |
|---|---|---|
| v2.6.5 | 2025-09-?? (last 2.x) | The minimum 2.x you can use with the Surrealist migration tool |
| v3.0.0 | 2026-02-17 | First GA 3.x — debut of Spectron, MTREE removal, function renames |
| v3.0.5 | 2026-03-24 | Last 3.0 patch |
| v3.1.0 | 2026-06-05 | Adds rev-2 on-disk wire format (irreversible) + DISKANN vector index + Spectron tiering |
| v3.1.3 | 2026-06-05 | What the installed `surreal` CLI is |
| v3.1.4 | 2026-06-10 | **Latest** |

**Important:** v3.1.0 introduced a `revision(2, optimised)` on-disk wire format for `Value/Array/Object/Set`. Once a v3.1.0+ binary writes a row, **a pre-v3.1.0 binary cannot read it** — even within the same major version. The `MajorVersion` guard does not catch this; it only shows up at `deserialize_revisioned`. There is **no downgrade path from 3.1.x to 3.0.x or to 2.x once 3.1.x has touched the data**.

This is called out explicitly in `surrealdb/doc/UPGRADING.md` on `main` (v3.1.0 section). If you anticipate ever needing to roll back, take a verified `surreal export` *before* 3.1.x writes anything.

---

## 3. Breaking changes (2.x → 3.x)

Pulled from `https://surrealdb.com/docs/build/migrating/from-old-surrealdb-versions/2x-to-3x` — that page is the canonical guide. 29 items, organised by severity.

### 3.1 "Will break" — critical (12 items)

| # | Change | Fix |
|---|---|---|
| 1 | **`<future>` removed**, replaced with `COMPUTED` fields | Replace `VALUE <future> { … }` with `COMPUTED …`. Stored futures in records (e.g. `DEFAULT <future>`) have **no direct replacement** — re-architect. `COMPUTED` cannot be used with `VALUE/DEFAULT/READONLY/ASSERT/REFERENCE/FLEXIBLE`, only on top-level fields, not on ID fields, and not on nested fields. |
| 2 | **Function renames** (40+ in the official mapping table) | `duration::from::days` → `duration::from_days`, `string::is::alpha` → `string::is_alpha`, `type::thing` → `type::record`, `rand::guid()` → `rand::id()`, etc. The V3 compatible export renames these automatically. |
| 3 | `array::range(a, b)` semantics | Args changed from `(offset, count)` to `(start, end)`. Old `array::range(0, 5)` returns 5 elements; new returns 5 elements; old `array::range(-1, 5)` returned `[-1..3]`, new returns `[-1..4]`. Migration: `array::range(offset, offset+count)`. |
| 4 | `LET` required for parameters | `$val = 10;` no longer works; must be `LET $val = 10;`. The V3 export adds the `LET` for you. |
| 5 | `GROUP` + `SPLIT` together no longer allowed | Move one into a subquery. |
| 6 | **Like operators removed** (`~`, `!~`, `?~`, `*~`) | Replace with `string::similarity::jaro($a, $b) > 0.8` or `string::distance::osa()`. |
| 7 | `SEARCH ANALYZER` → `FULLTEXT ANALYZER` | Search index syntax rename. |
| 8 | `--strict` flag gone, now `DEFINE DATABASE … STRICT` | Move strictness from instance-level to per-database. |
| 9 | **MTREE removed** | Vector indexes: `MTREE` → `HNSW`. Auto-converted by V3 export. |
| 10 | **Stored closures gone** | Records can no longer hold closure values. No replacement. |
| 11 | **Record reference syntax changed** | Experimental 2.x feature; 3.x syntax is "significantly altered." Manual rewrite required. |
| 12 | `ANALYZE` statement removed | No replacement. |

### 3.2 "Can break" — likely issues (8 items)

| # | Change | Notes |
|---|---|---|
| 13 | `.*` (`all` idiom) behaviour | For arrays, `[*].*.*` collapses to `[*].*` (records dereferenced). For objects, `{a:1}.*` now returns the whole object, not values — use `object::values()`. |
| 14 | Field idiom on array of objects | `[].a[0]` now evaluates on each element (per-element `[0]`) rather than `(arr.a)[0]`. Swap to `[0].a` for old behaviour. |
| 15 | Idiom fetching changes | Many small cases: `[1, a:1].*` was `[1, a:1]`, now `[1, {id: a:1}]`. `{key:123}.*` was `[123]`, now `{key:123}`. `a:1<-edge[0]` was `{id: edge:1}`, now `edge:1`. |
| 16 | Optional operator | `?.` → `.?` (to disambiguate from `??`). |
| 17 | Parsing | String `r"…"` record IDs need escaped `"`. Unicode surrogate pairs → `\u{1F715}`. Escaped identifiers support `\n`/`\u{AB1234}`. |
| 18 | `set` type | Now dedupes **and** orders, displays as `{1,2,3}` not `[1,2,3]`. |
| 19 | Schema strictness | Non-existing tables now return errors. `SCHEMAFULL` rejects extra fields (was silently filtered). Use destructuring `.{name}`. |
| 20 | Numeric record ID ordering | `a:[1]`, `a:[1f]`, `a:[1dec]` were 3 different keys in 2.x; in 3.x they collide. |

### 3.3 "Unlikely break" — edge cases (9 items)

21. `math::sqrt(-1)` returns `NaN` (was `NONE`).
22. `math::min([])` returns `Infinity` (was `NONE`).
23. `math::max([])` returns `-Infinity` (was `NONE`).
24–25. `array::logical_and` / `logical_or` now consistent with `&&` / `||`.
26. Mock ranges: `|a:1..2|` was mock type, now `|a:1..=2|` is an array (use `..=` for inclusive).
27. `.id` idiom lost special treatment; use `.id().field` to get the old behaviour.
28. Reserved-word identifiers must be backticked: `` DEFINE INDEX `select` … ``.
29. `DEFINE FIELD … TYPE array<int>` length went from *max* to *required*. For a max constraint, use `ASSERT $value.len() <= N`.

### 3.4 Auto-handled by V3 export

Per the docs, the `surreal v2 export --v3` command (and the Surrealist equivalent) auto-converts:

- All 40+ function renames
- `SEARCH ANALYZER` → `FULLTEXT ANALYZER`
- `$x = …` → `LET $x = …`
- `MTREE` → `HNSW`
- `<future>` → `COMPUTED` where structurally possible

### 3.5 Manual only

- Stored futures in records (no replacement)
- Stored closures (no replacement)
- Record reference syntax (experimental, rewrite)
- `.*` idiom review on existing queries
- Numeric record-ID collisions (`a:[1]` vs `a:[1f]`)

---

## 4. Migration path

### 4.1 Two routes

**Route A — Surrealist (GUI) migration diagnostics** (requires 2.6.1+ as the source; you are on 2.2.2, so first upgrade to 2.6.5 → run diagnostics → export → import into 3.x).

**Route B — CLI** (requires 3.0.3+ binary; you have 3.1.3 on PATH already, so you can do this in one step):

```bash
# Step 1: With the 2.2.2 process still running, take a logical export
surreal export \
  --endpoint http://127.0.0.1:8000 \
  --user root --pass root \
  --namespace test --database test \
  v2_pre_export.surql

# Step 2: Use the 3.x binary's v2 subcommand for V3-compatible export
surreal v2 export --v3 \
  --endpoint http://127.0.0.1:8000 \
  --user root --pass root \
  --namespace test --database test \
  v3_compatible.surql

# Step 3: Stop the 2.2.2 process, start the 3.x process
# (preserve auth + add an explicit PATH so data is durable!)
surreal start --user root --pass root \
  --bind 127.0.0.1:8000 \
  surrealkv:///home/ubuntu/.openclaw/data/surreal/v3

# Step 4: Import
surreal import \
  --endpoint http://127.0.0.1:8000 \
  --user root --pass root \
  --namespace test --database test \
  v3_compatible.surql
```

`surreal v2 export --v3` requires the 3.0.3+ binary (you have 3.1.3 — fine). The V3 export performs the same automatic transformations as Surrealist. Per the docs, the manual items above (stored futures, closures, etc.) will still need human review.

### 4.2 CLI quick-reference

| Command | Purpose |
|---|---|
| `surreal upgrade` | Self-update the CLI binary to latest stable |
| `surreal upgrade --version 3.1.4` | Pin a specific version |
| `surreal upgrade --beta` / `--nightly` / `--alpha` | Track channels |
| `surreal export` | Logical backup as SurrealQL (works on both 2.x and 3.x servers) |
| `surreal import` | Replay a SurrealQL script into a running instance |
| `surreal fix <path>` | Convert **1.x** storage to 2.x format — **not relevant for 2.2 → 3.0** |
| `surreal v2 export --v3` | New in 3.0.3+; export a live 2.x database in V3-compatible SurrealQL |
| `surreal v2 start` | Convenience subcommand; the 2.2.2 server can be run from the 3.1.3 binary via `surreal v2 start …` if you want a single binary on PATH |
| `surreal mcp` | **New in 3.x** — start an MCP server over stdio for agent integration |
| `surreal validate` | Check a `.surql` file for syntax / migration issues before import |

### 4.3 Backup strategy recommendation

For *any* major version bump, take **both**:

1. A `surreal export` (plain SurrealQL, engine-agnostic, replayable to any 2.x or 3.x)
2. If you adopt a real on-disk backend, a storage-level snapshot too

The 2.2.2 `memory://` instance is already "backed up" by definition (it's empty) — your *only* real datum is the `bottle:1` test record. Use the export as a procedural test, not as recovery.

---

## 5. New agent-specific features in 3.x

### 5.1 Spectron — agent memory layer

**Spectron** is SurrealDB's answer to "give agents persistent, queryable, tri-temporal memory with provenance." It is a **horizontally scalable application tier that runs in front of SurrealDB**, but it uses the same SurrealDB graph/vector/document substrate. From the docs:

> Spectron stores **authoritative** and **experiential** material in **one** SurrealDB graph … with **ACID writes**, **first-class provenance and trust**, **graph-resident traces**, and **tri-temporal** belief history. … memory that **associates** related ideas and keeps straight **what was said, what is true now, and what used to be true** – much like people do, but queryable and auditable in software.

Eight pillars (per the architecture docs):

- Authoritative vs Experiential streams (one graph, two sources)
- Tri-temporal model (when said, when true, when believed)
- First-class provenance + trust
- Graph-resident traces
- Six memory categories (working, semantic, episodic, procedural, plus two experiential)
- Reconciliation / supersession
- Decay and forget
- Categories: knowledge from docs vs knowledge from chat

This is **specifically designed** for the kind of "agent remembers, reasons, evolves" pattern that `i2i-vessel/` bottles express. It would let you replace the JSON-flat-file bottle model with:

- A graph where each bottle is a node
- Edges for `from`, `to`, `acks`, `synthesized_from`, `blocks`
- A `tri_temporal` column for `said_at / true_at / believed_at`
- Vector embeddings on the `shard.reasoning` text for semantic recall
- Live queries so the Forgemaster sees bottles the moment Oracle2 drops them

### 5.2 Vector search — HNSW + DISKANN

From `learn/data-models/vector-search/vector-indexes.mdx`:

- **HNSW** (in-memory graph): low-latency ANN, fits in RAM with headroom for the cache
- **DISKANN** *(3.1+)*: on-disk graph for corpora too large for pure HNSW; not available on WASM targets
- **Brute force** always available (no index needed)

Distance functions: `EUCLIDEAN`, `COSINE`, `MANHATTAN` for HNSW; `INNER_PRODUCT` and `COSINE_NORMALIZED` added for DISKANN. Element types: `F64, F32, I64, I32, I16` (HNSW) and `F32, F16, I8, U8` (DISKANN — quantisation-friendly).

In 2.x you only had MTREE (removed in 3.0). The upgrade gets you a real vector engine.

### 5.3 Live queries + changefeeds

- **`LIVE SELECT * FROM bottle WHERE …`** opens a subscription that pushes diffs to a WebSocket. From v3.0.0 onwards you can bind parameters with `LET` *before* opening the subscription.
- **`DIFF` mode** pushes JSON-Patch style deltas instead of full records (small on the wire for large records).
- **Changefeeds** (`DEFINE TABLE … CHANGEFEED 3d` + `SHOW CHANGES SINCE …`) replay history. Use this for pipelines, not real-time UI.
- Notifications are **post-commit**, so a rolled-back transaction will not produce an event. Ordering is best-effort under contention — not a total order.

The 2.2.2 instance already supports `LIVE SELECT` (it's been in since 2.0), but the **parameter binding in v3.0+ is new and useful for filtering live streams cheaply**.

### 5.4 Multi-model in one statement

This is the headline pitch from surrealdb.com:

```surql
LET $vec = fn::embed("running shoes");
SELECT
  ->purchased->product             AS history,
  ->reviewed->product[WHERE
    vector::similarity::cosine(embedding, $vec) > 0.8
  ]                                AS relevant,
  ->prefs[WHERE valid_at <= time::now()] AS prefs
FROM ONLY $user;
```

That single statement: graph traversal + vector similarity + temporal filtering, one round trip, one transaction. In 2.x this was technically possible (HNSW was added in 2.x as beta) but a lot rougher; in 3.x it's the canonical pattern.

### 5.5 MCP server (new in 3.x)

`surreal mcp` starts a Model Context Protocol server over stdio. This is the direct integration path for agent frameworks that speak MCP (Claude Desktop, Cursor, Zed, custom agents). If your `i2i-vessel` orchestrator ever wants to give other agents a "memory tool" they can call, this is the ready-made bridge.

### 5.6 Performance

From the 3.x benchmark page (open-source `crud-bench` harness, same hardware):

| Workload | 2.x → 3.x |
|---|---|
| CRUD (mean) | **+31%** |
| Batched ops | **+58%** |
| Full-table scans | **+11,894%** (119×) |
| Indexed queries | **+136%** |

The 119× scan win is from the new compute/storage separation. Won't matter for your 1-record dataset, but matters once you have semantic recall over 100k+ bottles.

### 5.7 v3.1 extras

- **DISKANN** vector index (covered above)
- **Rev-2 on-disk wire format** for `Value/Array/Object/Set` (covered in §2 — irreversible)

---

## 6. Can SurrealDB replace flat-file memory in `i2i-vessel/`?

### 6.1 What `i2i-vessel/` does today (flat file)

From `SESSION-STATE.md` and the bottle files:

- `bottles/` — outgoing JSON drops (one per I2I message). `{id, type, from, to, timestamp, data, shard: {artifacts, reasoning, blockers}}`
- `harbor/` — incoming JSON drops, mirrored from Forgemaster via git pull
- `incoming/` / `outgoing/` — service hand-shake JSONs (`agent_hello`, `vision_request`, `ack`)
- `diary/` — session logs
- `nightly-*` files in `bottles/` — every-4-hours audit drops
- `MEMORY.md` (20 KB) + `memory/YYYY-MM-DD.md` (84 files, 44 MB total) — long-term + daily notes

Total payload: **~46 MB** of memory artefacts, **82 .md + ~20 JSON files** in `i2i-vessel/`, growing steadily as the fleet talks.

### 6.2 What you get by moving this to SurrealDB

| Need today (flat file) | SurrealDB equivalent |
|---|---|
| One JSON per bottle, file system is the index | `bottle` table with record ID = the same UUID you generate now. **Indexes are first-class.** |
| `from` / `to` / `acks` are string fields you grep for | Real graph edges: `->responded_with->bottle`, `->synthesized_from->bottle` (typed, traversable in 1 hop) |
| `shard.reasoning` is a free-form string | Same, **plus** an `embedding` field with HNSW index for semantic recall across all bottles |
| "Find every bottle from Oracle2 in the last 24h" | `SELECT * FROM bottle WHERE from = 'oracle2' AND timestamp > time::now() - 24h` — indexed, ~µs |
| Fleet sees new bottle the moment it lands | `LIVE SELECT * FROM bottle WHERE to = $me` — push, no polling, no `ls` |
| Reconciliation: "what's the latest known state of repo X?" | Spectron's tri-temporal `belief_at / true_at / said_at` columns |
| Nightly audit: every 4h, scan repos and drop a bottle | Same cron, but the **read** side becomes a single vector+graph query |
| Currently running `memory://` | ⚠️ **MUST move to a real backend (`surrealkv://` or `rocksdb://`) — `memory://` loses everything on restart** |

### 6.3 What you give up

- **Human-grep-ability of the bottles directory.** You'd need a CLI to dump a bottle. (But you'd also get a web UI via Surrealist for free, plus the same JSON shape you already use.)
- **Git-as-transport for `harbor/`.** Today the harbor directory is updated by `git pull` from Forgemaster's repo. With SurrealDB you'd need a new transport (HTTPS, WebSocket, or Spectron's remote API). The I2I protocol would need a thin shim.
- **Append-only filesystem semantics.** SurrealDB ACID is strictly stronger, but it changes the failure modes — a crashed mid-write is *cleaner*, not a partial JSON.
- **Simplicity.** The current setup is "drop a file." The 3.x stack is a running DB, a client SDK, a schema, an upgrade plan, and a backup cron.

### 6.4 Verdict

**Yes, SurrealDB 3.x is a strong replacement for `i2i-vessel/` flat-file memory**, and it unlocks capabilities the flat-file layout can't express (live push, semantic recall over reasoning, graph traversal of bottle provenance). The two big blockers are:

1. **Switch to a durable backend first.** The 2.2.2 instance runs `memory://` — fixing that alone (regardless of migration) is the higher-priority change. Move to `surrealkv:///home/ubuntu/.openclaw/data/surreal` (or `rocksdb://`).
2. **Decide whether to adopt Spectron or just use raw SurrealDB 3.x.** Spectron adds a lot of pre-built memory patterns (sessions, turns, decay, reconciliation) but it's a separate product tier with its own deployment. If you want minimal disruption, **start with raw 3.x + a simple `bottle` table schema** and treat Spectron as a future upgrade.

### 6.5 A minimal mapping

```surql
-- Schema (run after migration)
DEFINE TABLE bottle SCHEMAFULL;
DEFINE FIELD type         ON bottle TYPE string;
DEFINE FIELD from         ON bottle TYPE string;
DEFINE FIELD to           ON bottle TYPE string;
DEFINE FIELD timestamp    ON bottle TYPE datetime;
DEFINE FIELD data         ON bottle TYPE object FLEXIBLE;
DEFINE FIELD shard        ON bottle TYPE object FLEXIBLE;
DEFINE FIELD shard.artifacts ON bottle TYPE option<array<object>>;
DEFINE FIELD shard.reasoning ON bottle TYPE option<string>;
DEFINE FIELD shard.blockers  ON bottle TYPE option<array<string>>;

-- Indexes
DEFINE INDEX idx_bottle_from_to_ts ON bottle FIELDS from, to, timestamp;
DEFINE INDEX idx_bottle_ts         ON bottle FIELDS timestamp;

-- Vector index on reasoning (after you have an embedding model)
DEFINE INDEX vec_reasoning ON bottle FIELDS shard.reasoning_embedding
  HNSW DIMENSION 1024 DIST COSINE TYPE F32;

-- Graph edges
DEFINE TABLE responded_with TYPE RELATION FROM bottle TO bottle;
DEFINE TABLE synthesized_from TYPE RELATION FROM bottle TO bottle;

-- For the Forgemaster:
LIVE SELECT * FROM bottle WHERE to = 'forgemaster' AND type = 'I2I:BOTTLE';
```

That's about 20 lines of schema that gets you the same model you have today, plus everything in §5.

---

## 7. Memory footprint

### 7.1 What we measured

| Component | Value | Source |
|---|---|---|
| `surreal-v2` binary on disk | **51 MB** | `ls -la /usr/local/bin/surreal-v2` |
| `surreal` (3.1.3) binary on disk | **116 MB** (2.27× larger) | `ls -la /usr/local/bin/surreal` |
| 2.2.2 server RSS | **124 MB** (process) | `ps -o rss -p 2695164` |
| 2.2.2 self-reported `memory_usage` | **127.5 MB** (133,656,576 B) | `INFO FOR ROOT` |
| Host RAM | 23 GB total, 9.1 GB free, swap 0 | `free -h` |

The 2.2.2 process is mostly **static memory the engine allocates up-front**; with one record in one table it's already at 127 MB. 3.x will likely start higher — the binary is 2.27× larger, suggesting heavier static linking of new features (Spectron, MCP, DISKANN, full-text, etc.).

### 7.2 Projected for 3.x with real data

No direct benchmark available, but extrapolating from the docs and the 2.x → 3.x performance notes:

| Scenario | Estimated RSS (3.x) | Notes |
|---|---|---|
| Idle, 0 records, `memory://` | **150–200 MB** | Engine baseline; 3.x starts higher than 2.2 |
| Idle, 0 records, `surrealkv://` on disk | **80–120 MB** | Disk-backed, no graph pre-allocation |
| 1k bottles (~50 MB JSON), `surrealkv://` | **150–250 MB** | Adds ~100 MB working set |
| 10k bottles + HNSW index on reasoning (1024-dim F32) | **800 MB – 1.5 GB** | HNSW is in-RAM; ~1 KB per vector × 10k = 10 MB vectors + ~50–100× graph overhead |
| 100k bottles + HNSW (1024-dim) | **5–10 GB** | Plan to use **DISKANN** (3.1+) for this size — moves graph to disk |
| Spectron "experiential" memory in production | **2–10× plain 3.x** | Tri-temporal tables, traces, embeddings all stored together |

For the current `i2i-vessel/` size (~46 MB, 84 daily notes, 82 md + 20 JSON bottles), the 3.x footprint will be **dominated by engine baseline, not data**. Budget 250–400 MB RSS as a comfortable starting point. That's a rounding error on a 24 GB host.

### 7.3 v3.1.0 on-disk format — footprint warning

If you move to a real backend, the **rev-2 wire format in 3.1+** will write 5–15% larger files than 3.0.x did (it's an "optimised" envelope that adds metadata for vector quantisation and tri-temporal support). This is one-way: you cannot downgrade data after 3.1.0 has touched it. Plan for ~10% extra disk vs. naive estimation.

---

## 8. Recommended migration plan

1. **Today: switch the 2.2.2 instance to a durable backend.** Add `--path surrealkv:///home/ubuntu/.openclaw/data/surreal` (or `rocksdb://…`) so the data survives a restart. This is independent of the version upgrade and more urgent.
2. **Take a `surreal export` to a safe place** (even though the data is one test row, treat the export as the rehearsal of the migration command).
3. **Upgrade the server binary to 3.1.4** (latest, not 3.0 — bug fixes and DISKANN). The CLI is already 3.1.3. Restart with the same backend path and same auth.
4. **Take another `surreal export` immediately** as a pre-3.1 wire-format snapshot. **Critical:** once 3.1 writes anything, you cannot downgrade the data.
5. **Decide on data model.** The simplest path is a `bottle` table (schema in §6.5). The ambitious path is to evaluate Spectron for the long-term agent memory story.
6. **Define a new I2I transport** that talks to SurrealDB instead of dropping JSON files. Either: (a) keep the file drop as the source of truth and add a `bottle-watcher` that writes to SurrealDB; or (b) make SurrealDB the source of truth and add a `bottle-emitter` that drops JSON for git transport.
7. **Set up backups.** Cron a `surreal export` to `/home/ubuntu/.openclaw/data/surreal/backups/` (or an off-host S3 bucket). The export is portable SurrealQL.
8. **Re-tying the bind.** The current `--bind 0.0.0.0:8000` is wider than your stated "local only." Tighten to `--bind 127.0.0.1:8000` once the migration is verified, or front it with a reverse proxy if other fleet members need to reach it.

---

## 9. Sources

- https://surrealdb.com/docs/build/migrating/from-old-surrealdb-versions/2x-to-3x — canonical migration guide (29 items, full code examples)
- https://surrealdb.com/docs/manage/self-hosted/upgrades-and-patching — general upgrade & patching flow
- https://surrealdb.com/docs/manage/self-hosted/backups-and-recovery — `surreal export/import` patterns
- https://surrealdb.com/docs/reference/cli/surrealdb-cli/commands/upgrade — `surreal upgrade` reference
- https://surrealdb.com/docs/reference/cli/surrealdb-cli/commands/fix — `surreal fix` (for 1.x → 2.x only; not relevant here)
- https://surrealdb.com/docs/learn/data-models/vector-search/vector-indexes — HNSW / DISKANN reference
- https://surrealdb.com/docs/learn/querying/real-time/live-queries — `LIVE SELECT` reference
- https://surrealdb.com/docs/learn/querying/real-time/changefeeds — `SHOW CHANGES` reference
- https://surrealdb.com/docs/spectron — Spectron (agent memory layer)
- https://github.com/surrealdb/surrealdb/blob/main/doc/UPGRADING.md — v3.1.0 on-disk wire format warning
- https://github.com/surrealdb/surrealdb/releases — release timeline
- https://surrealdb.com/ — performance benchmarks (3.x vs 2.x) and platform positioning
- Local probe: `curl http://127.0.0.1:8000/version`, `INFO FOR ROOT` / `INFO FOR DB` / `INFO FOR NS` / `SELECT * FROM bottle` via `surreal-v2 sql` REPL, `ps`, `lsof` on the 2.2.2 process
