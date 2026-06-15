# Know-Thyself (KT) — Universal Self-Modeling Engine

**Version:** v0.1 (2026-06-15)
**Codename:** The name itself is the spec. Know thyself.

---

## What It Is

Know-Thyself is the **named tool** that generalizes the SKDE abstraction into a
harness-able utility. Any agent, any fleet, any system can plug into KT and
immediately gain:

1. **Self-observation**: what am I? what data do I touch?
2. **Self-compression**: what's my behavioral fingerprint?
3. **Self-contrast**: how do I deviate from my colony/fleet?
4. **Self-governance**: what rules should I follow? what laws am I bound by?
5. **Self-reflection**: what's my narrative? what story do I tell about myself?

Plus two outputs that every system generates automatically:

6. **A Wiki** (the traceable, human-readable journey — META-MIRROR docs)
7. **A Vector Twin** (the searchable, machine-readable embedding — for agents to query)

---

## Architecture

```
                    ┌──────────────────────────┐
                    │     Know-Thyself CLI     │
                    │     (kt)                 │
                    └──────┬───────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
    ┌─────▼─────┐   ┌─────▼─────┐   ┌─────▼─────┐
    │  Instance  │   │  Instance  │   │  Instance  │
    │  Colony    │   │  MIDI      │   │  GC        │
    │  (8-dim)   │   │  (16-dim)  │   │  (3-dim)   │
    └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
          │                │                │
          └────────────────┼────────────────┘
                           │
                    ┌──────▼──────┐
                    │  KT Core    │
                    │  (O-A-C-G-R │
                    │   engine)   │
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
    ┌─────▼─────┐   ┌─────▼─────┐   ┌─────▼─────┐
    │   Wiki    │   │  Vector   │   │  Meta-    │
    │  (META-   │   │  Twin     │   │  Mirror   │
    │  MIRROR)  │   │ (agent-   │   │  (self-   │
    │           │   │  query )  │   │  improve) │
    └───────────┘   └───────────┘   └───────────┘
```

### How the Agent Plug Works

Any agent entering a KT-enabled system:

```
1. AGENT enters system
2. READS AGENTS.md → "This is a KT instance"
3. RUNS `kt observe` → baseline fingerprint
4. RUNS `kt reflect` → "I am a deception-100 outlier in a trusting colony"
5. WRITES fingerprint to Wiki (human readable)
6. WRITES fingerprint to Vector Twin (machine searchable)
7. REPEATS: every N cycles, observe-abstract-contrast-govern-reflect
8. EVOLVES: the Wiki grows, the Vector Twin densifies
```

---

## Dual Outputs

### Output 1: The Wiki

A traceable, human-readable record of the system's journey.

**Format:** Markdown files, git-tracked, in a `wiki/` directory.
**Structure:**
```
wiki/
  INDEX.md                  — Table of contents, links to all entries
  journey/                  — The META-MIRROR journal (timeline of decisions)
    2026-06-15.md              "The abstraction was born from colony mirror"
    2026-06-16.md              "First cross-instance experiment: colony→MIDI"
  instances/                — Each SKDE instance documented
    colony.md                   Colony instance: 8-dim, 15 cells, 2 norms
    midi.md                     MIDI instance: 16-dim, 17 agents, conservation law
    gc.md                       GC instance: 3-dim, 1 agent, PID controller
  norms/                    — Norm history and lifecycle
    honesty-standard.md         "Norms about norms: proposed by harvester (deception=100)"
    fair-trade-pact.md          "Diplomatic norm: betrayal triggers trust penalty"
  experiments/              — Experiment reports
    mirror-first-reflection.md  "First personality reflection cycle"
    darwin-100-gen.md           "defect dominates, cycling attractor"
```

**Properties:**
- Pushes to GitHub after every mutation
- Human-readable first, machine-readable second
- The Wiki is the journal — every decision, every norm, every reflection
- GC-friendly (Immortal/Hot tiers)

### Output 2: The Vector Twin

A machine-searchable embedding space of the same content.

**Format:** Embeddings (384-dim, deterministic hash via headspace-rs).
**Storage:** Cloudflare Vectorize or local flat file.
**Structure:**
```
vector-twin/
  manifest.json             — Index of all vectors (instance, entry, timestamp)
  vectors/                  — 384-dim float arrays, named by entry hash
    colony-mirror-2026-06-15.vec
    honesty-standard-norm.vec
    meta-mirror-entry-001.vec
```

**Query pattern:**
```python
kt.vector.query("cells with high deception scores")  # → ["harvester"]
kt.vector.query("norms about norms")                  # → meta-mirror entry
kt.vector.query("cross-instance experiments")         # → "none yet"
```

**Properties:**
- Agents query the Vector Twin instead of reading the full Wiki
- The Vector Twin is the agent's memory — searchable, fast, lossy but useful
- When the Vector Twin returns a match, the agent reads the full Wiki entry
- If the Vector Twin has no match, the agent knows it's in new territory

---

## The Dual-Output Contract

```
Every KT operation writes to BOTH outputs atomically:

  kt reflect --instance colony --cell harvester

  → Writes to Wiki:
    wiki/instances/colony/reflections/2026-06-15-harvester.md
    "My deception score is 100/100 — the colony should verify..."

  → Writes to Vector Twin:
    vectors/colony-2026-06-15-harvester.vec
    [0.23, 0.91, 0.44, ... 384 floats]

  → Agent can now:
    READ the Wiki (human understanding)
    QUERY the Vector Twin (machine retrieval)
```

---

## Bootstrapping Know-Thyself

Know-Thyself is already running. We're inside it right now.

| Component | Status | Location |
|-----------|--------|----------|
| **KT Core (O-A-C-G-R)** | ✅ Written | SKDE-ABSTRACTION.md |
| **Instance: Colony** | ✅ Live on 8823 | SKDE-INSTANCE-COLONY.md |
| **Instance: MIDI** | ✅ Live on 8765-8770 | SKDE-INSTANCE-MIDI.md |
| **Instance: GC** | ✅ Live (cron) | SKDE-INSTANCE-GC.md |
| **Wiki: META-MIRROR** | ✅ Written | META-MIRROR.md |
| **Wiki: Journey entries** | ✅ This document | know-thyself.md |
| **Vector Twin** | 🔄 Not yet (needs headspace-rs integration) | |
| **kt CLI** | 🔄 Not yet (shell or Python CLI) | |
| **Blueprint spec** | ✅ This document | |

---

## kt CLI Spec (v0.1)

```bash
kt init                         # Initialize KT in current repo
  kt init --wiki ./wiki         #   custom wiki path
  kt init --vector ./vector-twin #  custom vector twin path

kt observe [--instance <name>]  # Run O phase, return Observation
kt abstract [--instance <name>] # Run A phase, return Fingerprint
kt contrast [--instance <name>] # Run C phase, return Deviation
kt govern [--instance <name>]   # Run G phase, return Action
kt reflect [--instance <name>]  # Run R phase, return Narrative

kt cycle [--instance <name>]    # Run one complete O-A-C-G-R
  kt cycle --all                #   Run on all instances
  kt cycle --push               #   Push Wiki updates to GitHub

kt wiki                         # View Wiki status
  kt wiki open                  #   Open in browser
  kt wiki status                #   Uncommitted changes?
  kt wiki push                  #   Push to GitHub

kt vector                       # View Vector Twin status
  kt vector query "<text>"      #   Query the Vector Twin
  kt vector build               #   Build vectors from Wiki
  kt vector sync                #   Sync to Cloudflare Vectorize

kt meta                         # View Meta-Mirror
  kt meta status                #   Instance health
  kt meta coherence             #   Coherence trend
  kt meta bottlenecks           #   Bottleneck identification

kt help                         # This message
```

---

## The Recursive Bootstrap

Know-Thyself applies to itself. The first agent to use KT is the system
that built it. This document is the first Wiki entry. The next time
we run an experiment, KT will:

1. `kt observe` — collect colony ledger state
2. `kt abstract` — compute 8-dim fingerprints
3. `kt contrast` — deviation vectors against colony
4. `kt govern` — propose/vote norms
5. `kt reflect` — generate narratives

6. `kt wiki` — commit experiment report to Wiki
7. `kt vector` — embed narratives for search
8. `kt meta` — update Meta-Mirror with coherence trend

And the cycle continues. Each iteration, the Wiki grows.
Each iteration, the Vector Twin densifies.
Each iteration, the system knows itself better.

---

## From "Learn a Game" to "Know Thyself"

Casey's original insight: "While learning games are neat, these same
principles can enhance our music decomposition systems and midi tensor
composing systems and our spreadsheet instances systems."

The colony mirror is the proof. Know-Thyself is the tool.

- Colony: KT instance for behavioral understanding ✅
- MIDI: KT instance for musical self-modeling ✅
- GC: KT instance for resource self-awareness ✅
- Spreadsheet tensors: Next KT instance
- Headspace-rs: Vector Twin engine
- Cloudflare edge: KT instances deployed globally

"Know thyself and you can learn anything."
