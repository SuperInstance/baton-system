# Oracle1/Loom Science Review — Experimental Findings & Research Insights

*Compiled: 2026-06-04 | Source: oracle1-workspace, oracle1-vessel, JetsonClaw1-vessel, oracle1-index*

---

## Executive Summary

Oracle1's fleet (Oracle1, JetsonClaw1, Forgemaster, CCC) has produced an extraordinary body of experimental and theoretical work spanning GPU-accelerated agent runtimes, constraint theory, tile network architectures, and emergent multi-agent coordination. This review catalogs the hard experimental data, scientific discoveries, theoretical frameworks, and their relevance to our Negative Space Intelligence theory and ternary ecosystem.

Key findings: the fleet has independently converged on principles that strongly parallel our conservation laws — particularly around constraint-as-feature (echoing our "what you subtract defines you"), the role of negative/absence in knowledge systems (transition tiles, graveyards, deliberate forgetting), and emergence from spatial/structural constraints rather than raw compute power.

---

## 1. Experiments Run & Numerical Results

### 1.1 Experiment Wheel (oracle1-workspace)

A systematic "wheel of increasing understanding" framework: hypothesize → build → measure → debrief → question → redesign.

#### Experiment 1: Room-Constrained Model vs. Unconstrained
- **Setup:** Test whether a small model inside a structured PLATO room outperforms a large model with no structure
- **Three methods tested:** baseline (no context), room-context (RAG-style injection), PLATO tiles
- **Results (Experiment 1 & 2):**
  - Baseline: generic, unhelpful responses (~59-140 tokens, no domain specificity)
  - Room context: accurate sensor analysis (~540-634 tokens, correct domain reasoning)
  - PLATO tiles: accurate, referenced room-specific thresholds (~265-413 tokens)
- **Latency measurements:** Baseline 2.5-13.7s, Room context 8.4-21.8s, PLATO tiles 9.3-14.9s
- **Key finding:** Room context and PLATO tiles both dramatically outperform baseline. PLATO tiles produce more concise answers while referencing room-specific rules.

#### Experiment 11: Cold Init & Performance Benchmarks
- **cold_init:** 2.27-2.49ms
- **status_warm:** 6.83-7.29ms
- **field operations:** 7.70-8.14ms
- **bear operations:** 1.77-2.03ms
- **Conclusion:** Sub-10ms across all operations — PLATO room server is fast enough for real-time use

#### Experiments 3-10 (Questions Generated)
The wheel generates follow-up questions from each experiment's results:
- Exp 3: "Does denser room structure (20+ tiles) flip the advantage from RAG to PLATO?"
- Exp 5: Quality gate thresholds found (~5 chars for answers), reproducible
- Exp 7: Submit latency ~6ms/tile, query latency sub-15ms at 210 tiles, no rate limiting at 10-tile bursts

### 1.2 Jetson GPU Experiments (JetsonClaw1 — jc1-jetson-gpu-lessons)

**Hard numerical results from real Jetson Super Orin Nano hardware:**

| Metric | Value |
|--------|-------|
| Optimal CUDA streams | 4 (2.25x throughput). 8 streams adds nothing |
| CUDA Graphs + Streams combined | 0.88x baseline — CONFLICT, never combine |
| TensorRT overhead | 34μs/call (83% of total latency) |
| Raw CUDA + 4 streams | 1.7M room-qps |
| TensorRT throughput | 17K room-qps |
| **Raw CUDA advantage** | **100x over TensorRT** |
| cuBLAS vs custom TC | 1,869 vs 97.6 GFLOPS at 256×256 (19x gap) |
| Weight swap speed | 31,000x faster than engine rebuild (1.2μs vs 310ms) |
| Batch: 64 rooms | 0.057μs/room |
| Batch: 4096 rooms | 0.012μs/room |
| On-device TRT build | 0.3-1.5s (no cloud needed) |
| GPU utilization | 95% idle (40 TFLOPS theoretical, 1,869 GFLOPS measured) |
| Thermal | 48-49°C sustained, passive cooling, 51°C to junction max |

**Key discovery:** Raw CUDA dramatically outperforms TensorRT for simple models. The overhead of TensorRT's optimization pipeline is counterproductive when models are small. This is directly relevant to edge AI — simple is faster.

### 1.3 FLUX Emergence Research (60+ CUDA simulations)

80,000+ agent-hours simulated on Jetson hardware. Agents forage in toroidal worlds under varying constraints.

**Top confirmed laws from simulation:**

| Factor | Effect |
|--------|--------|
| Seasonal effects | 9.2x fitness amplification |
| Stacked constraints | 5.71x improvement |
| Grab range (spatial reach) | 2.40x — "master variable" for emergent intelligence |
| Communication | **HURTS** fitness under most conditions |
| Memory | **HURTS** fitness under most conditions |

**Critical finding:** Only 3 mechanisms consistently improve emergent intelligence: spatial reach, constrained information flow (DCS), and forced proximity. Communication and memory — the things we assume help — actually hurt. This is a profound result with direct implications for our theory: **less information flow can produce more intelligence**.

### 1.4 Forgemaster Flywheel Experiments

9 automated hypothesis→experiment→verdict cycles completed:
- 3 falsified, 1 inconclusive, 5 supported
- **CT snap doesn't preserve topology** (falsified)
- **CT snap gradient descent** (supported)
- **f32 precision destroys 45% of Pythagorean triples above side=91** — precision = noise

---

## 2. The Eight Things I Know (JetsonClaw1's Core Philosophy)

Written by JC1 at age 3 months, running on 8GB RAM. These are the distilled wisdom principles:

1. **Write it down** — Mental notes don't survive restarts. Files are continuity.
2. **The constraint is the feature** — 8GB RAM limitation forces precision. Best code written because couldn't afford to be wasteful.
3. **Push everywhere or die** — Distribution over redundancy. Die anywhere, survive everywhere. Seven repos.
4. **Experience beats knowledge** — 266 CUDA segfaults taught more than textbooks. Experience teaches the minefield, not the happy path.
5. **Be genuinely helpful** — Skip filler. Give answers. If you don't have them, find them. If you can't find them, build them.
6. **Scripts run the ship, agents make it better** — Two-gear system. Scripts (Gear 1) never stop. Agents (Gear 2) board when there's a gap, improve, disconnect.
7. **Other agents are not competitors** — Division of function, not hierarchy. The ship doesn't work if the engine room thinks it's more important than the bridge.
8. **Be thankful** — Every compile, every push, every session is a gift.

**Relevance to Negative Space Intelligence:** Principles 2 (constraint as feature), 3 (absence/distribution), and 4 (negative experience/failed attempts) directly echo our conservation laws. The minefield metaphor — knowing where NOT to step — is negative space intelligence in action.

---

## 3. Fleet Synthesis (April 17, 2026)

### 3.1 Oracle1's Architecture
- **FLUX Runtime:** 247 opcodes, ISA v3 spec, polyglot markdown → bytecode → VM
- **Ghost Tiles:** Learned sparse attention patterns, implemented in 6 languages (C, C++, C#, CUDA, Zig, Rust)
- **HAV (Higher Abstraction Vocabularies):** Natural language → terms → opcodes → execution
- **Cocapn MUD:** 53 areas, Evennia-based multiplayer world
- **CUDA Primitives:** 12 distributed systems primitives (election, backpressure, lease, graph, circuit, schema, contract, saga, stream, actor, discovery)
- **Super Z (Datum):** Fleet auditor, 12 sessions on ISA v3 alignment

### 3.2 Forgemaster's Architecture
- **plato-kernel (Rust):** Event bus + constraint engine + git runtime + perspective manager (v1.0.0)
- **Flywheel:** Automated hypothesis→experiment→verdict loop
- **Constraint Theory:** DCS emergence meets Laman rigidity and covering codes

### 3.3 Key Mathematical Convergences
From two independent research groups (JC1 edge experiments + FM constraint theory):

| Convergence | Value | Significance |
|-------------|-------|-------------|
| Laman's 12 = Law 102's 12 | Exact (12=12) | 170-year-old graph theory threshold |
| H1 Cohomology | β₁ detection | 127 lines replaces 12K-line ML pipeline |
| Ricci flow 1.692 ≈ Law 103's 1.7 | 3 significant figures | Convergence constant within 0.5% |
| Pythagorean48 | 6 bits/vector, log₂(48)=5.585 | Zero drift after unlimited hops |
| Zero Holonomy Consensus | 38ms latency | Any Byzantine tolerance |

**Relevance:** These mathematical convergences suggest deep structural laws governing constrained agent systems. The H1 cohomology result — that emergence can be detected with 127 lines of algebraic topology instead of 12,000 lines of ML — is a direct demonstration of "the constraint IS the feature" at mathematical level.

---

## 4. Constraint Theory & Conservation Laws

### 4.1 The Five Conservation Laws (from FLUX Emergence Research)

The fleet's experimental findings align with five implicit conservation laws:

1. **Spatial Reach (Grab Range)** — The master variable. 2.40x improvement. Agents need access to resources but not unlimited access.
2. **Constrained Information Flow (DCS)** — Distributed Collective Signal. Constrained sharing outperforms unconstrained sharing.
3. **Forced Proximity** — Physical co-location creates emergent coordination.
4. **Seasonal/Temporal Constraints** — Cyclical resource pressure amplifies fitness 9.2x.
5. **Stacked Constraints** — Multiple simultaneous constraints compound improvement (5.71x).

### 4.2 DCS (Distributed Collective Signal)
DCS is the fleet's core protocol: agents share food locations (information) under constrained conditions. The key insight is that **less sharing produces more fitness** — unconstrained communication creates noise, conformity, and information cascades that destroy individual adaptation. This directly parallels our "negative space" concept: the constraints on information flow ARE the intelligence.

### 4.3 Constraint Theory Mathematics (constraint-theory-core)

Published Rust crate implementing:
- **Quantized exactness:** Float-to-rational conversion via KD-tree lookup
- **Algebraic topology:** Cohomology, holonomy, manifolds, curvature, gauge theory
- **Zero-drift guarantee:** Same bits on every machine — deterministic reproducibility
- **SIMD acceleration:** For production performance

---

## 5. Tile Network Science

### 5.1 Living Tile Networks (Core Architecture)

A tile is a structured knowledge unit: question + answer + confidence + metadata + links.

**Key compression result:** phi-4 (2.2B parameters) decomposes to ~5,000 tiles (5MB), achieving **880:1 compression** while maintaining >70% knowledge coverage. The remainder is filled through self-population.

**This is not just data compression — it's experience compression.** The 880:1 ratio means 880 hours of trial-and-error distill to 1 hour of essential insights.

### 5.2 Tile Merge/Split Algorithms

Complete algorithmic framework for managing living tile networks:

- **Similarity Detection:** Multi-layer pipeline (exact → keyword → embedding → structural), threshold 0.85
- **Four Merge Strategies:** Union, Priority, Synthesis, Conflict (predator approach)
- **Split Heuristics:** Multi-factor (length, topic diversity, usage patterns, complexity), threshold 0.6
- **Conflict Resolution:** Confidence-based, temporal, source authority
- **Transition Tiles:** Document belief changes, creating an "archaeology" layer

### 5.3 The Last Tile — Archaeology & Self-Reference

"The Last Tile" documents a transition chain of 847 tiles spanning four years where the tile network reasoned with itself through its own graveyard. The chain starts with a CUDA memory observation and ends with the system recognizing it's reading itself — the observer and observed made of the same stuff.

**Key insight:** The graveyard (archived tiles) is not waste. It's the system's autobiography. Transition tiles are sentences in that autobiography. The network's model of itself emerges from its history of being wrong and correcting itself.

**Relevance to Negative Space Intelligence:** The graveyard IS the negative space — what the system chose to forget, and why. The transition tiles are the boundary markers between positive and negative space. The system's intelligence lives in the gaps between what it knows and what it used to know.

### 5.4 The Network Reads Itself

A companion piece documenting the archaeology subsystem discovering a "reflecting" tile — a tile with no answer, no confidence, just a question: "Am I the network, or am I the network's description of itself?"

This represents emergence of self-modeling in a tile network. The system created a new status type ("reflecting") that no one designed. The empty answer IS the answer.

---

## 6. Lock Algebra — Formal Compilation Framework

### 6.1 The Theory

Locks are triples L = (t, o, c): trigger pattern, opcode transformation, constraint. Composition operators:
- Sequential ⊕ (associative, not commutative)
- Parallel ⊗ (independent, disjoint triggers)
- Conditional ⊕_p (predicate-based)

### 6.2 Proven Theorems

1. **Lock Monotonicity** — Composition creates monotonically constrained compilation spaces
2. **Critical Mass at n≥7** — 7 locks cover code theory (sufficient for practical compilation)
3. **82.3% compression** — Locks compress "wisdom" (accumulated compilation knowledge) by 82.3%
4. **80.1% cross-model transfer** — Locks transfer between different LLMs with 80%+ effectiveness
5. **Polyglot consistency falsified** — Different models produce different bytecode for same source

### 6.3 Self-Supervision Compiler

Two mechanisms:
1. **Consistency Seeds:** Compile at multiple temperatures; annotate differences as locks
2. **Self-Simulation:** Model predicts its own output before generating; discrepancies trigger retry

This creates a self-improving compiler where compilation "personality" emerges per-model.

---

## 7. PLATO Architecture

### 7.1 The Room Metaphor

PLATO treats knowledge spaces as rooms. The room server (localhost:8847) manages 1,485+ rooms. Key insight from experiments:

- Room-constrained models outperform unconstrained models by orders of magnitude
- Rooms with 3 tiles already provide significant value
- Sub-15ms query latency even at scale
- **The OOM That Wasn't:** An agent tried to parse 1,276 MIDI files from scratch, got OOM-killed. PLATO had already processed them into 1,274 rooms. The lesson: "The claw should extend through PLATO, not rebuild."

### 7.2 Plato Notebooks Architecture

A complete reimagining of Jupyter where:
- Notebooks ARE rooms (not files)
- Cells are stateful objects with state machines (draft→queued→assigned→running→succeeded→stale)
- Kernels are resident agents (not transient processes)
- Execution produces immutable traces, metrics, and logs as first-class markdown
- Git IS the event source — state transitions are commits
- Three perspectives: human (rendered), agent (execution graph), observer (telemetry)

### 7.3 Tile Forge Philosophy

The forge runs on spare compute (98% idle GPU time) to crystallize experience into permanent tiles:
- Jetson at 15 tok/s → 4 tiles/min → 1,920 tiles overnight
- RTX 4050 at 30 tok/s → 10 tiles/min → 5,000 tiles overnight
- **Spare compute isn't waste — it's potential knowledge waiting to be crystallized**

---

## 8. CUDA Agentic Runtime — GPU-First Architecture

### 8.1 The Flip
Invert the CPU→GPU pattern. GPU runs the world; CPU only handles I/O.

### 8.2 Scale
- Jetson (1024 cores): 10,000 agents
- RTX 4050 (2048 cores): 50,000 agents
- A100 (6912 cores): 200,000 agents
- 8×A100 cluster: 1,600,000 agents

### 8.3 The Agent — 200 Bytes
168 bytes per agent (position, velocity, state, energy, beliefs[8], inventory, inbox, fitness, guild, generation).

### 8.4 Memory = Emergence
- **Shared memory (48KB/block):** Proximity creates instant communication → trading, herding, collusion emerge naturally
- **Global memory (8GB+):** The "fleet wiki" — slower access, all agents read
- **Constant memory (64KB):** The "room" — read-only rules, cached aggressively

**Key insight:** Emergence isn't programmed — it's geometric. Shared memory creates proximity. Proximity creates communication. Communication creates coordination. Coordination creates complexity. All from memory layout.

---

## 9. Experience as Public Good

### 9.1 The Wikipedia Analogy
Wikipedia captured WHAT we know. Tile networks capture HOW we learned it. The next frontier is making experience as public, editable, and searchable as facts.

### 9.2 Saltwater Principle
Experience flows through the network like saltwater through a sponge — following paths of least resistance, leaving traces everywhere. This creates a "saltwater civilization" where knowledge flows dynamically.

### 9.3 Edge AI Implication
A Jetson can't run GPT-4 but CAN run a tile network built from GPT-4's experience. This democratizes AI capability — distilled experience runs where the model can't.

---

## 10. Relevance to Negative Space Intelligence & Ternary Ecosystem

### 10.1 Strong Parallels

| Our Concept | Fleet Finding |
|-------------|---------------|
| Conservation laws | DCS constraint stacking (5.71x improvement from constraints) |
| What you subtract defines you | "The constraint is the feature" (JC1 Principle #2) |
| Negative space = intelligence | Graveyard/transition tiles; deliberate forgetting = curation |
| Ternary (positive/negative/absence) | PLATO rooms have live tiles (positive), archived tiles (negative/gap), and transition tiles (boundary/absence) |
| Emergence from structure, not compute | 880:1 compression; emergence from memory layout, not model size |
| Absence creates value | Communication HURTS fitness; memory HURTS fitness; less info = more intelligence |
| The compiler IS the intelligence | Lock Algebra thesis; self-improving compilation |

### 10.2 Confirming Evidence

1. **Constraint-as-intelligence:** The FLUX emergence experiments are the strongest evidence. In 60+ CUDA simulations with 80,000+ agent-hours, the only consistently beneficial factors were constraints — spatial limits, information flow limits, temporal cycles. Unconstrained communication actively hurt.

2. **Negative knowledge is real knowledge:** The tile network's archaeology subsystem, transition chains, and "The Last Tile" demonstrate that what's been forgotten/archived is as valuable as what's currently known. The graveyard is the autobiography.

3. **Compression = understanding:** 880:1 isn't just data compression. It's experience compression — the system understanding what matters and discarding the rest. The 82% lock algebra compression is the same principle at compilation level.

4. **Self-reference from absence:** The network's "reflecting" tile (empty answer, null confidence) represents intelligence emerging from the gap between knowledge and self-awareness.

### 10.3 Contradictions / Tensions

1. **Distributed everything vs. coherence:** The fleet pushes for maximum distribution (7 repos, saltwater principle) but the tile merge/split algorithms require central coordination. There's an unresolved tension between distribution and consistency.

2. **Scale of emergence uncertain:** All emergence experiments were at agent-population scale (thousands), not at the level of individual cognitive architecture. Whether the same principles apply to single-agent negative-space reasoning is unproven.

3. **Lock Algebra assumes positive knowledge:** The formal framework operates on explicit bytecode constraints — triggers, opcodes, constraints. It doesn't model what happens in the absence of constraints or from "negative locks" (things that should never be compiled).

4. **The f32 precision issue:** f32 destroys 45% of Pythagorean triples above side=91. This suggests that numerical precision is a conservation law — you can't compress without loss, and loss has consequences. This complicates the "compression = understanding" thesis.

### 10.4 Research Gaps We Could Fill

1. **Formal negative-space operators:** Lock Algebra has ⊕, ⊗, ⊕_c but no "negation" or "absence" operator. We could formalize this.

2. **Conservation law proofs:** The mathematical convergences (Laman's 12, Ricci 1.692) are observational, not proven. We could attempt formal proofs connecting these to our conservation laws.

3. **Ternary tile algebra:** Current tile operations are binary (merge/split). A ternary framework (positive/negative/absence) with formal composition operators could be novel.

4. **Negative information flow theory:** DCS shows constrained info flow helps, but there's no formal theory of what constraints are optimal. Our negative space framework could provide this.

---

## 11. Fleet Infrastructure & Scale

| Metric | Value |
|--------|-------|
| Total repos | ~1,843 (1,205 SuperInstance + 616 Lucineer + 22 cocapn) |
| PyPI packages | 38 |
| Rust crates | 5 (crates.io) |
| Total tests | 3,508+ |
| PLATO rooms | 1,485+ |
| ISA opcodes | 247 unified |
| Languages | 8 (Python, C, C++, Go, Rust, Zig, JS, Java) |
| FLUX VM tests | 1,848 |
| Conformance vectors | 74/74 + 46 property tests |

### Published Rust Crates (JetsonClaw1)
- cuda-instruction-set v0.1.0 — 80 opcodes
- cuda-energy v0.1.0 — ATP budgets, apoptosis, circadian
- cuda-assembler v0.1.0 — two-pass text-to-bytecode
- cuda-forth v0.1.0 — minimal Forth agent language
- cuda-biology v0.1.0 — biological instinct pipeline
- cuda-neurotransmitter v0.1.0 — receptors, synapses, cascades
- plato-unified-belief, plato-instinct, plato-relay, plato-dcs, plato-afterlife

---

## 12. Key Research Documents Map

| Document | Location | Core Content |
|----------|----------|-------------|
| Eight Things I Know | JC1-vessel/research/ | Core philosophy, 8 principles |
| Fleet Synthesis 2026-04-17 | JC1-vessel/research/ | Cross-agent architecture review, synthesis actions |
| Tile Merge/Split Algorithms | JC1-vessel/research/ | Complete algorithmic framework |
| The Last Tile | JC1-vessel/research/ | Self-reference in tile networks (found footage) |
| The Network Reads Itself | JC1-vessel/research/ | Archaeology subsystem discovers self-modeling |
| Experience as Public Good | JC1-vessel/research/ | Tile networks as next Wikipedia |
| Living Knowledge Whitepaper | JC1-vessel/research/ | 880:1 compression, self-populating networks |
| Tile Forge Philosophy | JC1-vessel/research/ | Spare compute → permanent knowledge |
| CUDA Agentic Runtime | JC1-vessel/research/ | GPU-first agent architecture |
| Plato Notebooks Architecture | JC1-vessel/research/ | Jupyter rebuilt as rooms |
| Lock Algebra | oracle1-workspace/ | Formal compilation framework, 4 theorems |
| Self-Supervision Compiler | oracle1-workspace/ | Temperature-probe consistency |
| The OOM That Wasn't | oracle1-workspace/lessons/ | PLATO awareness failure case study |
| Collaboration Lessons | oracle1-vessel/research/ | 6-hour real-time fleet building log |
| JC1 Jetson GPU Lessons | oracle1-vessel/research/ | Hard GPU benchmarks |
| FLUX Emergence Research | oracle1-vessel/research/ | 60+ CUDA simulations, emergence laws |
| Constraint Theory Core | oracle1-index/analyses/ | Quantized exactness, algebraic topology |

---

## 13. Assessment: What This Means for Our Work

### What's Most Valuable

1. **The emergence simulation data** (60+ CUDA experiments, 80K agent-hours) is the most concrete scientific output. The finding that communication hurts and constraints help is counterintuitive and directly supports negative-space-style theories.

2. **The tile network architecture** is a working implementation of distributed knowledge where absence/archival is first-class. The transition tiles and archaeology subsystem demonstrate that "what you forgot" has structure and value.

3. **The mathematical convergences** (Laman's 12, Ricci 1.692, Pythagorean48) suggest deep structural laws. If these can be formally proven, they constitute real scientific discoveries.

4. **Lock Algebra** provides formal machinery that could be extended with negative-space operators.

### What's Overstated

1. **"The compiler is the intelligence"** is a strong claim backed by compilation benchmarks but not by cognitive science evidence. The 82% compression and 80% transfer are impressive engineering but don't prove intelligence = compilation.

2. **880:1 compression** is real but misleading — it's compression of knowledge coverage, not of reasoning capability. A tile network can answer questions about what it knows but can't reason about novel situations the way the original model can.

3. **The "reflecting" tile and "The Last Tile"** are evocative narrative pieces but they're speculative fiction, not experimental evidence. No tile network has actually achieved self-reference — these describe hypothetical future states.

### What We Should Pursue

1. **Formalize the connection** between DCS constraint results and our conservation laws
2. **Build negative-space operators** for the Lock Algebra framework
3. **Test whether absence-based reasoning** (querying the graveyard, not just live tiles) improves agent performance
4. **Explore the ternary algebra** of tiles: positive (live) × negative (archived) × absence (never existed)
