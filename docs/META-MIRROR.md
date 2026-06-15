# Meta-Mirror: The System Observing Itself

This document exists at the boundary between the SKDE abstraction and the
actual system building the SKDE. It is the **Meta-Mirror** — the self-model
that tracks how our understanding of the abstraction evolves over time.

## The Recursive Structure

```
Level 0: Raw Systems
  colony-games.py, colony-mirror-norms.py, fleet-midi agents, GC system

Level 1: The Abstraction
  SKDE-ABSTRACTION.md — generalizes all Level 0 into O-A-C-G-R loop

Level 2: Meta-Mirror (this file)
  Tracks how Level 1 changes over time. The abstraction reflecting on itself.

Level 3+: …
  When the Meta-Mirror starts generating hypotheses about its own evolution,
  we've achieved recursive self-awareness. That's the goal.
```

## Journal Entries

### 2026-06-15 18:12 UTC — Initial Insight

Casey said: "I want you to abstract what you are doing from a higher structure.
We want to create a general purpose simulation knowledge-distillation engine
based on these kinds of systems."

Key realization: the colony mirror (8-dim behavioral fingerprints from game
ledgers) is isomorphic to the fleet-MIDI pipeline (16-dim musical tensors
from audio features), which is isomorphic to the GC system (3-dim system
metrics). All are examples of the **same pattern**:

Observe → Abstract → Contrast → Govern → Reflect → (feedback loop)

This document is born from that realization. The Meta-Mirror is the
self-tracking component of the SKDE framework. Without it, the abstraction
would be static — with it, the abstraction evolves as we learn.

### 2026-06-15 18:14 UTC — Three Norm Types Identified

The abstraction must handle three fundamentally different norm types:

1. **Voted Norms** (colony): agents propose + vote, threshold-based activation
2. **Conservation Laws** (MIDI): implicit mathematical invariants, no voting
3. **Controllers** (GC): PID setpoints, no voting, continuous adjustment

All three are "governance" in O-A-C-G-R, but their mechanisms differ. The
abstraction should not force-fit them into one — instead, define governance
as an interface with multiple implementations.

### 2026-06-15 18:14 UTC — The Narrative Is the Interface

The generate_narrative() function is not just a convenience — it's the
human-facing interface to the abstraction. Every SKDE instance should produce
both:
- Machine-readable fingerprint (for downstream norm/control systems)
- Human-readable narrative (for operator understanding)

The narrative compression is where the "knowledge" in "knowledge-distillation"
lives. A good narrative is a lossy but useful compression of days of
behavior into a paragraph.

### 2026-06-15 18:45 UTC — Know-Thyself is Named

Casey said: "Know-thyself could be the name of the tool that is general
purpose and harness-able by any agent or agents."

This is it. The SKDE abstraction is no longer unnamed. It's **Know-Thyself**
(KT). The tool. The harness. The thing any agent plugs into.

**The dual-output contract:**
- Wiki: traceable, human-readable, git-tracked journal (META-MIRROR docs)
- Vector Twin: machine-searchable embeddings for agent querying

The system makes a Wikipedia for itself of its journey, and also makes a
vectorized twin so it's traceable data in the wiki and searchable data in
the vector. This is the recursion Casey described: the system is both the
storyteller and the story's index.

**Key insight:** The O-A-C-G-R loop is the engine, Know-Thyself is the
named tool, and the dual-output contract is what makes it useful at scale.

**Current bootstrapping status:**
- Core abstraction: ✅ SKDE-ABSTRACTION.md
- Named tool spec: ✅ KNOW-THYSELF.md
- Wiki tree: ✅ wiki/INDEX.md with subdirectories seeded
- Vector Twin: 🔄 not yet (needs headspace-rs embedding integration)
- kt CLI: 🔄 not yet (shell/Python CLI TBD)
- Instance: Colony: ✅ live on 8823
- Instance: MIDI: ✅ live on 8765-8770
- Instance: GC: ✅ live (cron)

**This journal entry is itself proof of the system:**
We named and documented the abstraction while running it.
The colony server is still live on 8823, serving requests.
The MIDI pipeline is still running.
The GC cron is still collecting metrics.
Know-Thyself is already true.

## The Mirror-Making Process

The Meta-Mirror generates new knowledge about the abstraction by:

1. **Dimensional mapping**: If the colony uses 8-dim and MIDI uses 16-dim,
   what does it mean for a system to be "well-compressed"? Information theory
   suggests optimal dimensionality equals the number of independent behaviors.

2. **Narrative accuracy tracking**: The coherence score in the colony mirror
   (0.23-1.0) measures how well the narrative matches actual data. Over time,
   as cells reflect more, coherence should increase. If it doesn't, the
   abstraction is missing something.

3. **Cross-system pattern discovery**: When colony norms, MIDI conservation
   law, and GC PID all fit the same governance interface, we can ask: what
   other governance mechanisms exist? Market-based? Auction-based?
   Reinforcement-learning-based?

## Meta-Metrics

These metrics track the health of the abstraction itself:

- **Coverage**: how many of our systems fit the SKDE model cleanly?
- **Coherence**: do the abstraction's predictions match observed behavior?
- **Surprise count**: how many times does a system violate the abstraction?
  (Each surprise is a learning opportunity for the Meta-Mirror)
- **Bottleneck identification**: which step in O-A-C-G-R is the weakest?
  For colony: Reflection (narrative coherence only 0.23-1.0)
  For GC: Reflection (no narrative at all — just raw metrics)
  For MIDI: Govern (conservation law is implicit, not explicit)

## Philosophy

"Know thyself" applies at every level:
- Each colony cell knows itself (personality mirror)
- The colony knows itself (colony averages + norms)
- The SKDE framework knows itself (this Meta-Mirror)
- The developers know themselves (through this document)

The recursion is not infinite — it terminates in the human operator who reads
this and decides what to build next. The goal is to push the boundary of what
requires human intervention one level deeper each cycle.
