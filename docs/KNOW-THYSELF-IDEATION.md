# Know-Thyself Overnight Ideation + Pruning Pipeline

How a cheap local model fills the Vector Twin overnight, and the Wiki's
structural data lets expensive models prune and organize the results.

---

## The Core Loop

```
Night (cheap compute):
  Small/free model → ideate → Tiles → Vector Twin (everything)

Day (expensive curated):
  Large model → query Vector Twin by score → prune low → analyze high
               → read Wiki structural data → organize → refine → learn
```

This is the production scaling strategy. The tile structure is what makes
it possible — not despite the slop, but *because* the scoring metadata
lets you filter the slop.

---

## Phase 1: Overnight Ideation

A local or free model runs in the background (overnight cron, Cloudflare
Worker during off-peak, headless terminal). It generates Tiles *without
human supervision* using the schema.

### Input
The model has access to:
- The instance's AGENTS.md (what it is)
- The instance's fingerprint schema (its dimensions)
- The instance's existing Tiles (for style continuity)
- A generation prompt like:

```
Generate 100 Tiles for the colony instance's "norm_proposal" type.
Each Tile should propose a plausible behavioral norm with:
  - Content: the norm rule in natural language
  - Sloppy Logic: why this norm makes sense (even if wrong)
  - Scoring: how to evaluate compliance
  - Branching: what happens if accepted or rejected
  - Room state: which cell types would support/oppose this norm

You are encouraged to be creative. Imperfect ideas are welcome —
they will be scored later.

Generate in JSON format matching the Tile schema.
```

### Output
The model writes raw Tiles to a staging area:

```
/tmp/kt-ideation/
  batch-2026-06-15-night/
    tile-colony-norm-proposal-001.json
    tile-colony-norm-proposal-002.json
    ...
    tile-colony-norm-proposal-100.json
```

No filtering. No scoring. Just raw generation.
**100% of output is captured, including 70% slop.**

---

## Phase 2: Vector Twin Ingestion

Every raw Tile gets embedded into the Vector Twin immediately.
No quality check — the Vector Twin holds everything.

```bash
# For each raw Tile:
kt vector ingest /tmp/kt-ideation/batch-2026-06-15-night/tile-*.json

# Vector Twin now contains all 100 Tiles, indexed by semantic similarity
```

The Vector Twin doesn't know quality. It knows "these 100 Tiles exist and
they're about norm proposals." Search works even on slop:

```python
kt.vector.query("norms about resource sharing")  
# Returns all 100 Tiles about resource sharing — good and bad
```

---

## Phase 3: Wiki Structural Metadata

The Wiki twin is the **quality layer**. It writes structural metadata for
every Tile:
- Generation timestamp
- Model used (so you can track which models produce better Tiles)
- Instance, cell, tile type
- **Sloppy logic summary** (for human skimming)
- Vector Twin reference (link back to the embedding)

```markdown
# Ideation Batch: 2026-06-15 Night

**Model:** llama-3.2-1b (free, local)
**Instance:** colony
**Tile Type:** norm_proposal
**Count:** 100

## Summary
10% great ideas — norms with unexpected angles
20% pretty good — plausible norms with reasonable scoring
70% slop — repetitive, incoherent, or trivial norms

## Ideas Worth Reviewing
| Tile | Content | Why Interesting |
|------|---------|----------------|
| tile-023 | "Return Rate Standard: cells that accept gifts must reciprocate within 3 cycles" | Extends gift ledger to create reciprocity norm. Good scoring dimension. |
| tile-047 | "Silence Protocol: cells with low cooperate_rate cannot propose norms for 10 cycles" | Meta-norm about norm proposal eligibility. Controversial but interesting. |
| tile-089 | "Memory Tax: cells that forget their own past behavior lose trust" | Direct application of Tile lifecycle to colony behavior. Recursive. |

## Quick Discard
| Tile | Problem | 
|------|---------|
| tile-003 | "Don't be mean" — too vague, no scoring criteria |
| tile-044 | Duplicate of tile-041 with different wording |
| tile-077 | Coherence incoherent — AI hallucinated cell type |
```

---

## Phase 4: Expensive Model Eval

The human (or large expensive model) runs a query against the Wiki's
structural data:

```python
# Step 1: Find promising Tiles from structural metadata
candidates = wiki.query("""
    SELECT tile_id FROM ideation_batch_2026-06-15
    WHERE slop_classification IN ('great', 'pretty_good')
    AND instance = 'colony'
    AND tile_type = 'norm_proposal'
""")

# Step 2: Pull full Tile content from Vector Twin
best_tiles = vector_twin.get(candidates)
# Returns: [tile-023.full, tile-047.full, tile-089.full, ...]

# Step 3: Deep analysis
analysis = expensive_llm.analyze(best_tiles)
# "These 3 norms are structurally sound. tile-023 would extend the gift
#  ledger. tile-047 would require a constitutional change. tile-089 is
#  the most novel — it applies KT principles to colony rules."
```

**The expensive model only touches 3-10 of 100 Tiles.** The 90 others
are cheaply generated, embedded, and then structurally filtered out
without ever costing an LLM call.

---

## The Ratio

```
100 Tiles generated (cheap, local model)
  → 10% great (10 Tiles)
  → 20% pretty good (20 Tiles)
  → 70% slop (70 Tiles)

Vector Twin: all 100 stored (0 cost, just disk+embed)
Wiki: structural summary of all 100 (git push, cheap)
Filtering: 30 Tiles pass (structural metadata query, cheap)
Deep eval: 3-10 Tiles actually analyzed (expensive LLM, focused)
Pruning: 90 Tiles remain in Vector Twin but flagged as "low priority"
         (not deleted — might be useful later in different context)
```

The Vector Twin **never deletes**. The Wiki **flags and summarizes**.
The expensive model **only reads the curated subset**.

This is different from caching because:
- Caching = store response, retrieve by exact key, no evolution
- Vector Twin = store everything, retrieve by similarity, evolves
- Wiki = structural metadata, queryable, filterable, grows
- Pruning = metadata-driven, not TTL-driven, reversible

---

## Implementation on Oracle2

### What We Have Now
- **headspace-rs** (port 9090): 384-dim deterministic embedding service
- **Fleet-Harbor** (Cloudflare): bottle protocol endpoint
- **Fleet-Pulse** (Cloudflare): metric ingestion

### What We Need

```
1. Nightly ideation cron
   → Uses `openclaw cron add` to trigger at 01:00 UTC
   → Spawns subagent with small model (or calls local model)
   → Generates Tiles into /tmp/kt-ideation/{date}/

2. Auto-ingest to Vector Twin
   → headspace-rs embeds each Tile
   → Appends to vector-twin/manifest.json
   → Writes .vec file to vector-twin/vectors/

3. Auto-Wiki structural write
   → Reads newly ingested Tiles
   → Categorizes into "great / pretty good / slop"
   → Writes wiki/ideation/{date}.md
   → Git commit + push

4. Pruning CLI
   kt prune --batch 2026-06-15-night --min-score 0.7
   kt prune --batch 2026-06-15-night --tile-type norm_proposal --dry-run
   kt prune --batch 2026-06-15-night --model llama-3.2-1b --all
```

### Self-Funding Pipeline

Once the Vector Twin has enough Tiles, agents can query it without any
LLM call:

```python
# An agent entering the colony wants to propose a norm.
# Instead of calling an LLM, it queries the Vector Twin:
candidates = kt.vector.query("existing norm proposals about reciprocity")
# Returns: tile-023, tile-045, tile-078 — all previously generated

# Agent reads the best ones, learns from their sloppy logic,
# and proposes an improved version. The LLM cost was zero.
# The improvement was guided by past ideation, not fresh compute.
```

---

## Relation to PLATO

PLATO had the same ratio: students (agents) generated thousands of
responses in TUTOR frames. Most were wrong. The instructor (Wiki +
Vector Twin structure) identified the good ones and taught from them.

Know-Thyself does the same at scale:
- **Student** = cheap local model, generating Tiles all night
- **Instructor** = large LLM, curated by structural metadata
- **Gradebook** = Vector Twin (everything ever generated)
- **Lesson Plans** = Wiki (organized, summarized, teachable)

The slop is not waste. It's the training data for the metadata filters.
Every sloppy Tile teaches the system what to filter — and the filtered
Tiles remain in the Vector Twin for edge cases the instructor didn't
anticipate.

**"Even if only 10% are great, the vectordb can be easily organized and pruned because the Wiki twin makes structural data to be assessed."** — Casey, 2026-06-15

This is the insight. The Wiki structure is the lever that makes mass
generation practical. Without structural metadata, 100 Tiles is noise.
With it, 100 Tiles is a searchable, curatable, evolving dataset.
