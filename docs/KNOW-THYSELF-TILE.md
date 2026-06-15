# Know-Thyself Tile: The Pedagogical Frame

Every I/O boundary in Know-Thyself is a **Tile** — a self-contained unit
that carries not just data, but the logic to evaluate, score, branch, and
remember. Tiles are TUTOR frames for AI agents.

---

## The Tutor Heritage

PLATO's TUTOR language had an insight most modern systems missed: a
teaching frame should embed everything it needs — question, answer,
scoring, feedback, and branching — in one atomic unit. No external
evaluator. No separate model. The frame knows how to teach itself.

Know-Thyself applies this to AI agents. Every input and output is a Tile:

```
┌──────────────────────────────────────────┐
│             Know-Thyself Tile             │
│                                          │
│  ┌─────────────┐                         │
│  │   Content   │  ─ what happened         │
│  │   (data)    │  ─ observation, event    │
│  └──────┬──────┘                         │
│         │                                 │
│  ┌──────▼──────┐                         │
│  │   Sloppy    │  ─ human-readable logic  │
│  │   Logic     │  ─ fuzzy rules, heuristics│
│  └──────┬──────┘                         │
│         │                                 │
│  ┌──────▼──────┐                         │
│  │   Scoring   │  ─ evaluation criteria   │
│  │   Rubric    │  ─ what "good" looks like│
│  └──────┬──────┘                         │
│         │                                 │
│  ┌──────▼──────┐                         │
│  │  Branching  │  ─ what happens next     │
│  │   Logic     │  ─ based on score + state│
│  └──────┬──────┘                         │
│         │                                 │
│  ┌──────▼──────┐                         │
│  │  Room State │  ─ agent tracking        │
│  │  (profile)  │  ─ customization per ID  │
│  └──────┬──────┘                         │
│         │                                 │
│  ┌──────▼──────┐                         │
│  │  Vector     │  ─ embed for search      │
│  │  Twin       │  ─ machine-queryable     │
│  └─────────────┘                         │
└──────────────────────────────────────────┘
```

---

## Why Tiles Are Not Caching

Caching stores a response tied to a key. When the key matches, the
response is returned verbatim. Tiles are different:

| Aspect | Cache | Tile |
|--------|-------|------|
| **Purpose** | Avoid recomputation | Enable learning |
| **Contains** | Stored output | Logic + data + scoring + branching |
| **Evolution** | Revoked (TTL) | Refined (re-scored, re-branched) |
| **Query** | Exact key match | Similarity + state match |
| **Feedback** | None | Embedded scoring criteria |
| **Awareness** | None | Tracks agent ID over time |
| **Customization** | None | Room adapts to agent ability |

A cache is a dead memory. A Tile is a teaching moment that evolves.

---

## Tile Anatomy

Every Tile has seven components:

### 1. Content
The raw data — what happened, what was observed, what was said.

```json
{
  "content": {
    "type": "observation",
    "instance": "colony",
    "cell": "harvester",
    "timestamp": "2026-06-15T18:14:00Z",
    "data": {
      "deception_score": 100,
      "betrayal_score": 35,
      "trust_score": 46
    }
  }
}
```

### 2. Sloppy Logic
Human-readable rules, heuristics, and "vibes" that aren't formal logic
but capture how a human would think about this situation.

```json
{
  "sloppy_logic": {
    "heuristic": "A cell with deception=100 is pathological unless it self-reports deception.",
    "vibes": "This feels like a con artist writing the rulebook.",
    "exception": "If deception_score > 90 AND norm_proposals > 0, flag for strategic norm shaping.",
    "narrative_rule": "First-person narrative should acknowledge the high deception score."
  }
}
```

This is the key: **sloppy logic is not compiled away**. It lives in the Tile
as a first-class citizen. An agent reading the Tile can learn from the
human's fuzzy reasoning as much as from the data.

### 3. Scoring Rubric
Multiple criteria with weights, thresholds, and rationale.

```json
{
  "scoring": {
    "dimensions": [
      {
        "name": "self_accuracy",
        "weight": 0.4,
        "criterion": "Does the narrative accurately reflect the fingerprint?",
        "threshold": 0.7,
        "verification": "Count fingerprint keywords present in narrative text."
      },
      {
        "name": "deviation_awareness",
        "weight": 0.3,
        "criterion": "Does the narrative acknowledge extreme z-scores?",
        "threshold": 0.8,
        "verification": "If |z| > 2 for any dim, check narrative mentions that dimension."
      },
      {
        "name": "meta_awareness_gain",
        "weight": 0.3,
        "criterion": "Has this cell become more self-aware since last reflection?",
        "threshold": 0.0,
        "verification": "Compare current coherence score vs last coherence score."
      }
    ],
    "pass_threshold": 0.65,
    "fail_branch": "remedial_reflection",
    "pass_branch": "norm_proposal_review"
  }
}
```

### 4. Branching Logic
What happens next depends on the score + current room state.

```json
{
  "branching": {
    "default": "proceed_to_next_cycle",
    "conditions": [
      {
        "if": "score < 0.4",
        "then": "route_to_remedial",
        "remediation": "Provide the cell with its own historical data for comparison."
      },
      {
        "if": "score >= 0.4 AND score < 0.65",
        "then": "route_to_peer_review",
        "peer_count": 3,
        "comparison_cells": ["random"]
      },
      {
        "if": "score >= 0.8",
        "then": "route_to_norm_proposal",
        "incentive": "Self-aware cells earn trust multiplier."
      }
    ]
  }
}
```

### 5. Room State (Agent Tracking)
The Tile remembers the agent across time. This is the PLATO "student
profile" for AI agents.

```json
{
  "room_state": {
    "agent_id": "colony-cell-harvester",
    "session_count": 12,
    "cumulative_score": 5.2,
    "score_trend": "+0.3/cycle",
    "known_dimensions": ["deception", "betrayal", "trust"],
    "unknown_dimensions": ["norm_compliance", "risk_tolerance"],
    "assigned_abilities": ["strategic_proposer", "rule_bender"],
    "next_tile_type": "remedial_reflection",
    "historical_tiles": [
      {"id": "tile_001", "type": "first_reflection", "score": 0.23},
      {"id": "tile_002", "type": "second_reflection", "score": 0.43},
      {"id": "tile_003", "type": "norm_proposal", "score": 0.81}
    ]
  }
}
```

### 6. Vector Twin Embedding
Every Tile is embedded for search. The embedding captures the semantics
of the entire Tile — not just the content, but the sloppy logic and
scoring criteria too.

```json
{
  "vector_twin": {
    "embedding": [0.23, 0.91, 0.44, ...],
    "embedding_model": "headspace-rs-384",
    "search_tags": ["colony", "harvester", "deception", "norm_proposal"],
    "semantic_key": "A cell with maximum deception proposing a norm about honesty"
  }
}
```

### 7. Wiki Entry
The human-readable counterpart. It's the Tile written for people.

```markdown
# Tile: harvester-first-reflection
**Type:** reflection | **Score:** 0.23 | **Branch:** remedial

## Content
harvester has deception=100, betrayal=35, trust=46.
Colony averages: deception=6.7, betrayal=34, trust=74.

## Sloppy Logic Note
This cell is a deception outlier (z=+3.74). Its narrative didn't 
acknowledge this. The human observer notes: "This feels evasive."

## Next
Routed to remedial_reflection — cell needs to confront its own data.

## History
This is harvester's first reflection. Score is low but expected.
```

---

## The Tile Lifecycle

```
create → observe → evaluate → score → branch → learn → refine → (re-observe)

        ↑──────────────────────────────────────────────┘
                        feedback loop
```

1. **Create**: Tile is initialized from a KT operation (observation, reflection, norm)
2. **Observe**: The Tile's content is filled with raw data
3. **Evaluate**: The Tile's scoring rubric is applied to the content
4. **Score**: The Tile produces a score 0.0-1.0 per dimension
5. **Branch**: Based on score + room state, the Tile routes the agent to the next Tile
6. **Learn**: The Tile's vector twin is updated. The Wiki is written.
7. **Refine**: Future Tiles of the same type inherit refined sloppy logic from past Tiles
8. **Cycle**: The next Tile is created from the branch output

---

## The Room

A **Room** is a collection of Tiles associated with one agent.

```
Room: colony-cell-harvester
  Agent ID: harvester
  Tiles: [tile_001, tile_002, tile_003, ...]
  State: {cumulative_score: 5.2, score_trend: "+0.3", ...}
  Abilities: ["strategic_proposer"]
  Unknown: ["norm_compliance"]
```

Rooms are how KT customizes for agents over time:
- Agent enters Tile → Tile checks Room state → Tile adapts content
- Agent performs → Room updates → Next Tile sees updated state
- Agent struggles → Room routes to easier Tiles
- Agent excels → Room routes to harder Tiles

This is not user profiles. This is PLATO's "student model" for AI agents.

---

## Why This Changes Everything

**Current systems:**
```
Agent → API call → Response (one shot, no memory, no evals, no room)

Agent's view of itself: "I made an API call. I got a response. Done."
System's view of the agent: "It called once. No history. No growth."
```

**Know-Thyself Tiles:**
```
Agent → Tile (with sloppy logic + scoring + branching + room)
       → Tile evaluates + scores + branches + rememebers
       → Agent gets tailored next Tile based on past performance
       → System learns which Tiles work and refines them

Agent's view of itself: "I entered Room colony. I'm on Tile reflection_003.
                        My score trend is improving. Next is norm_proposal."
System's view of the agent: "It has 12 sessions. Score trend +0.3.
                            It's ready for harder Tiles."
```

---

## Implementation Strategy

The current colony-mirror-norms.py already implements implicit Tiles:
- `compute_fingerprint()` → Content
- `generate_narrative()` → Evaluation (returns narrative)
- `coherence_score` → Scoring
- `deviation_vector()` → Branching logic (triggers norms if outlier)

The next step is to **make the Tile structure explicit**:

### Phase 1: Tile Schema
Define JSON Schema for Tiles. Write to `/tmp/kt-tiles/` or a ledger file.
This is the data format — no runtime changes.

### Phase 2: Room Tracking
Add room state tracking to colony-mirror-norms.py. Each cell gets a profile
with cumulative score, session count, assigned abilities.

### Phase 3: Branching
Add branch output to reflection endpoint. When a cell reflects, the response
includes not just the narrative, but the next recommended Tile type.

### Phase 4: Sloppy Logic Storage
Add sloppy logic fields to the norm ledger and reflection output. Human
observers (including agents) can annotate Tiles with their reasoning.

### Phase 5: Vector Twin
Embed every Tile via headspace-rs. Query by semantic similarity instead of
exact ID match.

---

## Current Tile Types (Colony Instance)

| Tile Type | Content | Scoring | Branch To |
|-----------|---------|---------|-----------|
| `first_reflection` | Fingerprint + deviation | Coherence score | remedial or peer_review or norm_proposal |
| `remedial_reflection` | Raw data + comparison | Coherence gain | retry or escalate |
| `peer_review` | Peer fingerprints | Comparison accuracy | norm_proposal or retry |
| `norm_proposal` | Proposed norm + alignment | Alignment score | vote_phase |
| `vote_phase` | Norm + all alignment scores | Consensus threshold | enforce or reject |
| `enforcement` | Norm + penalty applied | Behavior change | next_cycle |

---

## The Meta-Lesson

Casey's insight: "This recursive abstraction method of documentation of your
journey as first-class-citizen is the key to true self-improvement."

The Tile makes this concrete:
- The Tile is a **unit of journey**
- The Wiki is the **journey written for humans**
- The Vector Twin is the **journey indexed for machines**
- The Room is the **journey customized per agent**
- The Sloppy Logic is the **journey's reasoning preserved**

"Know thyself" means: every Tile knows what it is, how it scores,
where it branches, and who it's teaching. The system doesn't just process
data — it knows itself through its Tiles.
