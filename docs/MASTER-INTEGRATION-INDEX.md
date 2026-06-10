# Master Integration Index

**Fleet-wide dependency graph and critical path for 176 FUTURE-INTEGRATION.md files across the SuperInstance ecosystem.**

*Generated 2026-06-04 by ZeroClaw Scout. Living document — update as repos evolve.*

---

## Table of Contents

1. [Dependency Graph by Layer](#1-dependency-graph-by-layer)
2. [Integration Hotspots (Top 20)](#2-integration-hotspots-top-20)
3. [Orphan Crates](#3-orphan-crates)
4. [The Critical Path (Top 10 Implementation Priorities)](#4-the-critical-path-top-10-implementation-priorities)
5. [Cross-Language Bridges](#5-cross-language-bridges)
6. [Room Affinity Matrix](#6-room-affinity-matrix)
7. [Architecture Notes](#7-architecture-notes)

---

## 1. Dependency Graph by Layer

The ecosystem is organized in five dependency layers plus cross-cutting concerns. An arrow `A → B` means "A depends on B" or "A integrates with B." The graph shows the most important connections; the full edge list has 800+ dependency relationships.

### Layer 0 — Bare Metal (Hardware, Logic, Circuits, Cells)

```
ternary-hardware ──────────┐
  ├→ ternary-circuit       │  Gate-level design for ALU/register abstractions
  ├→ ternary-logic         │  Truth tables for Kleene/Łukasiewicz logic systems
  ├→ ternary-compiler-v2   │  Code generation target (IR → machine code)
  └→ ternary-esp32-firmware│  279-byte bare-metal proof of concept

ternary-cell ──────────────┤  THE most-depended-upon crate (113 references)
  ├→ ternary-logic         │  Three-valued logic for cell state transitions
  ├→ ternary-energy        │  Conservation law enforcement per tick
  ├→ ternary-entropy       │  Shannon entropy of cell populations
  ├→ construct-core        │  Runtime: Layer 0 (lookup), Layer 1 (sync), Layer 2 (async)
  └→ ternary-protocol      │  Inter-cell messaging via TernaryMessenger
```

**Key insight:** `ternary-cell` is the universal substrate. 113 of 176 FUTURE-INTEGRATION files reference it. Every room is built on a cell grid. Every agent runs on cells. Every visualization renders cell state. The six-phase tick cycle (predict → perceive → surprise → vibe → gc → conservation) is the heartbeat of the entire ecosystem.

### Layer 1 — Core (Agents, Rooms, Protocols, Registry)

```
construct-core ────────────┤  Hardware-agnostic agent runtime (64 references)
  ├→ ternary-cell          │  Cells are constructs running on the trait system
  ├→ ternary-protocol      │  Communication between constructs
  ├→ ternary-registry      │  Skill/capability discovery and loading
  └→ hermit-claw / claw    │  Agent runtimes implementing construct traits

ternary-protocol ──────────┤  Wire format for fleet communication (49 references)
  ├→ ternary-consensus     │  Byzantine agreement over protocol messages
  ├→ ternary-steganography │  Hidden metadata in message payloads
  ├→ ternary-hash          │  Message fingerprinting and deduplication
  └→ ternary-compression   │  Bandwidth optimization for edge deployment

ternary-room ──────────────┤  Room abstraction for multi-agent environments (16 refs)
  ├→ ternary-cell          │  Each room contains a CellGrid
  ├→ ternary-consensus     │  Room-level voting and agreement
  ├→ ternary-voting        │  Democratic resource arbitration
  └→ ternary-spreadsheet   │  Rooms ARE spreadsheet cells (unified abstraction)

ternary-registry ──────────┤  Capability discovery and skill management (15 refs)
  ├→ ternary-ensign        │  Specialist loading/unloading per room
  ├→ ternary-protocol      │  Capability advertisement over the wire
  └→ ternary-locks         │  Access control for skill loading

ternary-agent ─────────────┤  Agent lifecycle and pooling
  ├→ ternary-cell          │  Agents are collections of cells
  ├→ ternary-evolution     │  Agent populations evolve strategies
  └→ ternary-ensign        │  Specialist agents with loaded skills
```

**Key insight:** `construct-core`, `ternary-protocol`, and `ternary-cell` form the "holy trinity" — they appear together in almost every integration document. Any new crate must integrate with all three to participate in the fleet.

### Layer 2 — Intelligence (Attention, Learning, Planning, Reasoning)

```
ternary-attention ─────────┤  Sparse attention over ternary state
  ├→ ternary-rl            │  Attention weights from reward signals
  ├→ ternary-tensor        │  Multi-dimensional attention computation
  ├→ ternary-transform     │  Attention-driven state transformation
  └→ ternary-music         │  Musical attention patterns (voice leading)

ternary-bayesian ──────────┤  Bayesian inference for ternary agents
  ├→ ternary-markov        │  Hidden Markov models with ternary transitions
  ├→ ternary-sensor        │  Sensor fusion via Bayesian updating
  ├→ ternary-game-theory   │  Bayesian games (incomplete information)
  └→ ternary-music         │  Bayesian music generation

ternary-rl ────────────────┤  Reinforcement learning over {-1, 0, +1}
  ├→ ternary-gradient      │  Policy gradient methods
  ├→ ternary-curriculum    │  Progressive learning schedules
  ├→ ternary-ga            │  Genetic algorithms for strategy evolution
  └→ ternary-planning      │  Model-based RL with planning

ternary-planning ──────────┤  Task decomposition and goal achievement
  ├→ ternary-graph         │  Plan graphs with ternary dependency weights
  ├→ ternary-rl            │  Learned planning heuristics
  └→ ternary-game-theory   │  Multi-agent planning as games
```

### Layer 3 — Systems (Distributed, Consensus, Scheduling)

```
ternary-distributed ───────┤  Distributed computation across fleet nodes
  ├→ ternary-protocol      │  Cross-node communication
  ├→ ternary-consensus     │  Distributed agreement
  ├→ ternary-tensor        │  Distributed tensor operations
  └→ ternary-room          │  Distributed room management

ternary-consensus ──────────┤  Byzantine agreement for ternary voting
  ├→ ternary-games         │  Game-theoretic consensus (Nash equilibrium)
  ├→ ternary-voting        │  Voting primitives (for/against/abstain)
  ├→ ternary-explain       │  Explainable consensus decisions
  └→ ternary-federated     │  Federated consensus across organizations

ternary-scheduling-v2 ─────┤  Priority-based job scheduling across fleet
  ├→ ternary-distributed   │  Multi-node scheduling
  ├→ ternary-room          │  Room provisioning as scheduling
  ├→ ternary-tensor        │  Multi-dimensional resource state
  └→ ternary-protocol      │  Cross-node job submission
```

### Layer 4 — Applications (Spreadsheet, Compiler, Visualization)

```
ternary-spreadsheet ───────┤  Living spreadsheet where cells are agents (13 refs)
  ├→ ternary-cell          │  Living cells replace static formulas
  ├→ ternary-world         │  WorldPhysics as formula engine
  ├→ ternary-evolution     │  =EVOLVE() formula — natural selection in cells
  ├→ ternary-attention     │  Cell attention visualization
  └→ superinstance-spreadsheet │  Browser frontend (WASM)

ternary-compiler ──────────┤  Ternary code generation and optimization
  ├→ ternary-hardware      │  Code generation target
  ├→ ternary-cell          │  Compile cell behaviors for deployment
  ├→ ternary-esp32-firmware│  Compile to bare-metal lookup tables
  └→ ternary-wasm          │  Compile to browser (BrowserRoom)

ternary-visualization ─────┤  Rendering ternary state as heatmaps, SOMs, graphs
  ├→ ternary-cell          │  Grid state rendering
  ├→ ternary-som           │  U-matrix visualization
  ├→ ternary-color         │  Ternary color mapping (warm/neutral/cool)
  └→ ternary-science       │  Scientific visualization (benchmarks, conservation)
```

### Cross-Cutting Concerns

```
construct-core ────────────  Runs through ALL layers as the universal runtime
conservation-matrix ───────  18 references — energy/surprise/population conservation
negative-space-core ───────  8 references — intelligence from what agents avoid
strategy-ecology ──────────  14 references — 5 strategy species (Explorer, Diplomat, etc.)
avoidance-cascade ─────────  9 references — death spiral prevention for cell populations
```

---

## 2. Integration Hotspots (Top 20)

Repos that appear as dependencies in the most other FUTURE-INTEGRATION files. These are the critical integration points — bugs here cascade everywhere.

| Rank | Crate | Referenced By | Category |
|------|-------|--------------|----------|
| 1 | **ternary-cell** | 113 | Layer 0 — universal substrate |
| 2 | **construct-core** | 64 | Cross-cutting — universal runtime |
| 3 | **ternary-protocol** | 49 | Layer 1 — fleet communication |
| 4 | **ternary-music** | 19 | Layer 2 — music × everything |
| 5 | **conservation-matrix** | 18 | Cross-cutting — energy conservation |
| 6 | **lever-runner** | 17 | Infrastructure — command matching |
| 7 | **ternary-room** | 16 | Layer 1 — room abstraction |
| 8 | **ternary-registry** | 15 | Layer 1 — capability discovery |
| 9 | **strategy-ecology** | 14 | Cross-cutting — species dynamics |
| 10 | **ternary-spreadsheet** | 13 | Layer 4 — primary UI |
| 11 | **ternary-science** | 12 | Cross-cutting — experimental validation |
| 12 | **superinstance-spreadsheet** | 11 | Layer 4 — browser frontend |
| 13 | **captains-log** | 11 | Infrastructure — fleet journal |
| 14 | **forgemaster** | 11* | Infrastructure — GPU dispatch (*combined case variants) |
| 15 | **oracle1-index** | 10 | Infrastructure — fleet catalog |
| 16 | **ternary-thermodynamics** | 9 | Layer 2 — statistical mechanics |
| 17 | **ternary-fitness** | 9 | Layer 2 — landscape analysis |
| 18 | **ternary-consensus** | 9 | Layer 3 — Byzantine agreement |
| 19 | **oracle1-vessel** | 9 | Infrastructure — Oracle Cloud agent |
| 20 | **avoidance-cascade** | 9 | Cross-cutting — cascade prevention |

**The gravity well:** `ternary-cell` (113), `construct-core` (64), and `ternary-protocol` (49) together account for 226 of ~800 total dependency edges — 28% of all integrations flow through these three crates. They must be rock-solid.

---

## 3. Orphan Crates

Repos with the fewest incoming references (≤2). These are either genuinely standalone, newly created, or in need of better integration documentation.

### Likely Genuine Standalones
- **strategy-transfer** (1 ref) — Research result proving strategies don't transfer across domains. Architectural principle, not a library.
- **SuperInstance-foundry** (1 ref) — Fork of Foundry; integration is build-tooling, not library dependency.

### Needs Better Integration
- **ternary-visualization** (2 refs) — Surprisingly few for a rendering crate. Should be integrated with ternary-color, ternary-science, spreadsheet visualization.
- **ternary-music** (2 outgoing refs, 19 incoming) — Many crates want to integrate WITH music, but music itself doesn't reach out much.
- **ternary-dissertation-c** (2 refs) — The C dissertation engine could feed evidence to many more crates.
- **beta-test-\*** (2 refs each) — Expected; beta tests are consumers, not dependencies.

### Potentially Dead
- **ternary-metrics**, **ternary-scoring**, **ternary-validation**, **ternary-sandbox**, **ternary-tidelight**, **ternary-visualizer**, **ternary-symbiont**, **ternary-captain**, **ternary-constellation**, **ternary-flux**, **ternary-dynamics**, **ternary-pipeline**, **ternary-benchmark**, **ternary-cli**, **ternary-classifier**, **ternary-platoon** — Rust crates without FUTURE-INTEGRATION.md files. Either unfinished, superseded, or needing integration documentation.

---

## 4. The Critical Path (Top 10 Implementation Priorities)

Ranked by how many downstream integrations they unlock. Building these first creates the maximum cascade of enabled work.

### Priority 1: ternary-cell Production Hardening
**Unlocks: 113 downstream integrations**
The six-phase tick cycle must be production-ready with stable APIs. Every other crate depends on cells being correct and fast. Critical sub-tasks:
- Fix the GC phase to support multiple strategies (greedy, balanced, ecological)
- Add cell state history for Lyapunov exponent computation (needed by ternary-chaos)
- Implement `CellGrid` with configurable neighborhood topologies (von Neumann, Moore, hexagonal)

### Priority 2: construct-core Layer Implementations
**Unlocks: 64 downstream integrations**
The three-layer trait system needs real implementations beyond the current trait definitions:
- Layer 0: Bare-metal `query_lookup()` with generated lookup tables (for ESP32)
- Layer 1: Sync `query_owned()` with dynamic skill loading (for Jetson)
- Layer 2: Async `query_tool()` with tool lifecycle (for Codespace)
- Inter-layer migration: compile Layer 2 skills → Layer 0 lookup tables

### Priority 3: ternary-protocol Message Standardization
**Unlocks: 49 downstream integrations**
The wire format must be frozen so other crates can build on it:
- Define all 20+ message types from the I2I specification
- Add `TernaryHash` fingerprinting for message integrity
- Add steganographic channel for provenance metadata
- Implement compression for bandwidth-constrained edge deployment

### Priority 4: ternary-room with CellGrid Composition
**Unlocks: 16 downstream integrations + enables room-as-codespace**
Each room must contain a living cell grid:
- `Room` struct gains a `CellGrid` field
- `RoomCoordinator::tick_all()` drives all room grids
- `RoomState` snapshots include grid state
- `Door` gains `sync_channel()` for tile synchronization

### Priority 5: conservation-matrix Fleet-Wide Enforcement
**Unlocks: 18 downstream integrations**
Every room must enforce conservation laws (γ + H ≈ const):
- Hot-path conservation check per cell tick
- Background verification every N ticks (conservation-verify)
- Violation reporting via ternary-protocol
- PLATO aggregation of fleet-wide conservation metrics

### Priority 6: ternary-spreadsheet Living Cell Migration
**Unlocks: 13 downstream integrations + primary user-facing product**
Replace static `Cell` with `ternary-cell::TernaryCell`:
- `=EVOLVE()` formula (100 generations of natural selection)
- `conditional_format()` driven by surprise magnitude
- Conservation law as column sum invariant
- WASM compilation for BrowserRoom

### Priority 7: strategy-ecology Species Classification
**Unlocks: 14 downstream integrations**
Classify every ternary cell into one of 5 strategy species:
- Explorer (high entropy, broad search)
- Diplomat (adaptive, mirrors opponent)
- Marksman (low entropy, high precision)
- Climber (gradient exploiter)
- Prospector (sparse high-value seeker)
- Room diversity monitoring: Shannon index > 1.5 bits = healthy

### Priority 8: ternary-registry Skill Discovery Protocol
**Unlocks: 15 downstream integrations**
Dynamic skill loading/unloading per room:
- `SkillSpec` format with 7-type constraint taxonomy (from polyformalism)
- Capability advertisement over ternary-protocol
- Skill audit via Equipment-CellLogic-Distiller
- Provenance chain from SuperInstance-Starter-Agent

### Priority 9: forgemaster GPU Dispatch
**Unlocks: 11 downstream integrations**
Route GPU computation to the right backend:
- tile-cuda for NVIDIA (fastest)
- tile-opencl for AMD/Intel (portable)
- tile-neon for ARM Mali (edge)
- Automatic kernel selection based on available hardware

### Priority 10: avoidance-cascade Balanced Learning
**Unlocks: 9 downstream integrations**
Prevent cell population monocultures:
- v5 balanced learning algorithm (average reward, forced exploration, memory decay)
- `CellGcStrategy` trait with multiple implementations
- Integration into ternary-cell's GC phase
- Cross-device cascade detection for fleet-wide early warning

---

## 5. Cross-Language Bridges

The ecosystem spans Rust (primary), C (edge/embedded), and Python (analysis/prototyping). Not all crates have been ported to all three languages.

### Full Triad (Rust + C + Python)
| Capability | Rust | C | Python |
|-----------|------|---|--------|
| avoidance-cascade | ✅ | ✅ avoidance-cascade-c | ✅ avoidance-cascade-python |
| negative-space-core | ✅ | ✅ negative-space-core-c | ✅ negative-space-core-python |
| fitness analysis | ✅ ternary-fitness | ✅ ternary-fitness-c | ✅ ternary-fitness-python |
| spreadsheet | ✅ ternary-spreadsheet | ✅ ternary-spreadsheet-c | ✅ ternary-spreadsheet-python |

### Rust + C Only
| Capability | Rust | C |
|-----------|------|---|
| conservation-matrix | ✅ conservation-matrix-rs | ✅ conservation-matrix-c |
| conservation-verify | ✅ conservation-verify | ✅ conservation-verify-c |
| evolution | ✅ evolution-ternary | ✅ evolution-ternary-c |
| lotka-volterra | ✅ lotka-volterra-agents | ✅ lotka-volterra-agents-c |
| strategy-ecology | ✅ strategy-ecology | ✅ strategy-ecology-c |
| inference | ✅ ternary-inference | ✅ ternary-inference-c |
| dissertation | ✅ dissertation-engine | ✅ ternary-dissertation-c |
| compiled-policy | — (spec only) | ✅ compiled-policy-c |

### Rust + Python Only
| Capability | Rust | Python |
|-----------|------|--------|
| dynamics | ✅ ternary-dynamics | ✅ ternary-dynamics-python |
| compiler | ✅ ternary-compiler-v2 | ✅ ternary-compiler-python |
| protocol | ✅ ternary-protocol | ✅ ternary-protocol-python |

### Rust Only (Missing Ports)
High-value Rust crates that lack C and/or Python counterparts:

| Crate | Priority for C Port | Priority for Python Port |
|-------|--------------------|--------------------------|
| ternary-cell | **CRITICAL** (ESP32 needs it) | Medium (analysis notebooks) |
| construct-core | **CRITICAL** (Layer 0 is C) | Low (Rust runtime) |
| ternary-protocol | **HIGH** (edge messaging) | Medium (protocol testing) |
| ternary-consensus | High (distributed agreement) | Low |
| ternary-room | Medium (room on device) | Medium (room prototyping) |
| ternary-chaos | Medium | **HIGH** (chaos visualization) |
| ternary-thermodynamics | Low | **HIGH** (energy analysis) |
| ternary-attention | Low | Medium (attention visualization) |
| ternary-rl | Low | Medium (RL training loops) |
| ternary-compiler | N/A (compiles TO C) | Already has Python port |

### Recommended Port Priority
1. **ternary-cell → C** (ESP32 bare-metal deployment depends on this)
2. **ternary-protocol → C** (edge devices need to send/receive messages)
3. **ternary-consensus → C** (distributed agreement on edge)
4. **ternary-chaos → Python** (Jupyter-based chaos analysis)
5. **ternary-thermodynamics → Python** (energy landscape exploration)

---

## 6. Room Affinity Matrix

Different room types load different crate clusters. This matrix shows which crates naturally group together as "room types" — configurations that make sense together.

### Research Room
*For mathematical exploration, proof checking, and scientific validation.*

```
┌─────────────────────────────────────────────────┐
│ RESEARCH ROOM                                    │
│                                                  │
│ ternary-attention    → Focus on interesting      │
│ ternary-clustering   → Group similar results     │
│ ternary-pca          → Dimensionality reduction  │
│ ternary-projection   → Visualize high-dim data   │
│ ternary-science      → Experimental validation   │
│ ternary-thermodynamics → Energy analysis         │
│ ternary-topology     → Landscape classification  │
│ ternary-chaos        → Bifurcation detection     │
│ ternary-bayesian     → Probabilistic inference   │
│ dissertation-engine  → Automated writing         │
│ ternary-database     → Store experimental data   │
│ ternary-visualization → Render results           │
└─────────────────────────────────────────────────┘
Hardware: Codespace (full compute, GPU)
Ensign: research-specialist
Strategy: Explorer + Prospector dominant
```

### Control Room
*For real-time monitoring, sensor fusion, and feedback control.*

```
┌─────────────────────────────────────────────────┐
│ CONTROL ROOM                                     │
│                                                  │
│ ternary-control      → Feedback loops            │
│ ternary-kalman       → State estimation          │
│ ternary-sensor       → Multi-sensor fusion       │
│ ternary-signals      → Spectral analysis         │
│ ternary-failure      → Fault detection           │
│ ternary-streaming    → Real-time data windows    │
│ ternary-stability    → Stability analysis        │
│ ternary-scheduling   → Priority task management  │
│ conservation-verify  → Integrity checking        │
│ ternary-energy       → Resource monitoring       │
└─────────────────────────────────────────────────┘
Hardware: Jetson Orin (edge, GPU, limited RAM)
Ensign: control-specialist
Strategy: Marksman + Climber dominant
```

### Evolution Room
*For genetic algorithms, strategy optimization, and population dynamics.*

```
┌─────────────────────────────────────────────────┐
│ EVOLUTION ROOM                                   │
│                                                  │
│ evolution-ternary    → Species emergence          │
│ ternary-fitness      → Landscape analysis        │
│ ternary-ga           → Genetic algorithms        │
│ strategy-ecology     → 5-species management      │
│ lotka-volterra-agents → Predator-prey dynamics   │
│ ternary-pareto       → Multi-objective evolution │
│ population-scaling   → Size-dependent behavior   │
│ avoidance-cascade    → Monoculture prevention    │
│ ternary-gradient     → Fitness gradient methods  │
│ ternary-spreadsheet  → =EVOLVE() visualization   │
│ ternary-entropy      → Diversity measurement     │
└─────────────────────────────────────────────────┘
Hardware: Codespace or DGX (parallel evaluation)
Ensign: evolution-specialist
Strategy: All 5 species balanced (diversity > 1.5 bits)
```

### Music Room
*For ternary music theory, harmonic analysis, and composition.*

```
┌─────────────────────────────────────────────────┐
│ MUSIC ROOM                                       │
│                                                  │
│ ternary-music        → Core ternary music theory │
│ ternary-markov       → Chord progression chains  │
│ ternary-automata     → Generative music          │
│ ternary-graph        → Voice-leading graphs      │
│ ternary-trees        → Hierarchical structure    │
│ ternary-permutation  → Tone row transformations  │
│ ternary-regex        → Pattern matching in scores│
│ ternary-color        → Synesthesia mapping       │
│ ternary-reservoir    → Temporal prediction       │
│ ternary-grammar      → Generative grammar        │
└─────────────────────────────────────────────────┘
Hardware: Codespace or Pi (low compute needed)
Ensign: music-specialist
Strategy: Explorer + Diplomat dominant (creative)
```

### Fleet Coordination Room
*For managing distributed agents across the fleet.*

```
┌─────────────────────────────────────────────────┐
│ FLEET COORDINATION ROOM                          │
│                                                  │
│ ternary-distributed  → Multi-node computation    │
│ ternary-consensus    → Byzantine agreement       │
│ ternary-scheduling-v2 → Fleet job scheduling     │
│ ternary-voting       → Democratic decisions      │
│ ternary-federated    → Cross-org learning        │
│ ternary-games        → Resource competition      │
│ ternary-network      → Network topology          │
│ ternary-steganography → Secure communications    │
│ captains-log         → Fleet journal             │
│ oracle1-vessel       → Oracle Cloud management   │
└─────────────────────────────────────────────────┘
Hardware: Codespace (network access required)
Ensign: fleet-coordinator
Strategy: Diplomat + Climber dominant (cooperative + efficient)
```

### Spreadsheet Room
*The primary user-facing product — living spreadsheet where cells are agents.*

```
┌─────────────────────────────────────────────────┐
│ SPREADSHEET ROOM                                 │
│                                                  │
│ ternary-spreadsheet  → Core spreadsheet logic    │
│ ternary-cell         → Living cells              │
│ ternary-world        → Physics engine            │
│ superinstance-spreadsheet → Browser frontend     │
│ ternary-evolution    → =EVOLVE() formula         │
│ ternary-attention    → Cell attention highlighting│
│ ternary-color        → Conditional formatting    │
│ ternary-visualization → Heatmaps, dashboards     │
│ Equipment-CellLogic-Distiller → LLM→cell bridge  │
│ spreadsheet-formulas → Formula library           │
└─────────────────────────────────────────────────┘
Hardware: Browser (WASM) or Codespace
Ensign: spreadsheet-specialist
Strategy: User-driven (all species available)
```

### Edge Room (ESP32)
*Minimal computation on bare metal — 279 bytes, no heap.*

```
┌─────────────────────────────────────────────────┐
│ EDGE ROOM (ESP32)                                │
│                                                  │
│ ternary-esp32-firmware → 279-byte bare-metal     │
│ construct-core L0     → BareMetalConstruct       │
│ compiled-policy-c      → Compiled rules          │
│ conservation-matrix-c  → On-device conservation  │
│ ternary-inference-c    → Local inference          │
│ position-aware-embed   → Fuzzy pattern matching  │
│ ternary-fitness-c      → Local fitness eval      │
└─────────────────────────────────────────────────┘
Hardware: ESP32 (520KB SRAM, no GPU)
Ensign: None (compiled-in specialist)
Strategy: Fixed (no learning — lookup tables only)
```

---

## 7. Architecture Notes

### The Integration Topology

The ecosystem has a **power-law dependency structure**: three crates (ternary-cell, construct-core, ternary-protocol) account for 28% of all dependency edges. This is both a strength (clear center of gravity) and a risk (single points of failure).

### Cyclic Dependencies

Several cycles exist in the integration graph:
- **ternary-cell ↔ ternary-protocol**: Cells communicate via protocol; protocol messages contain cell state.
- **ternary-consensus ↔ ternary-games**: Consensus uses game theory; games use consensus for multi-agent equilibrium.
- **ternary-entropy ↔ ternary-cell**: Entropy measures cell diversity; cells use entropy for GC decisions.

These are resolved by clean layer boundaries: ternary-protocol defines the message format; ternary-cell fills the messages; ternary-entropy analyzes the messages. No crate imports its own output.

### The 294:1 Ratio

From conservation-matrix: the ecosystem maintains a 294:1 avoid:choose ratio in strategy space. This means rooms spend most of their time avoiding bad states and very little time actively choosing. The scheduling implications: 99.7% of compute goes to pruning (gc phase) and only 0.3% to selection (vibe phase). Scheduler design should reflect this asymmetry.

### Room Isolation Principle

strategy-transfer proves that strategies are domain-bound (33% positive, 33% negative, 33% neutral transfer). The architectural consequence: rooms must train independently. The fleet shares learning methodology, not learned strategies. This is enforced by the ensign pattern (load specialist on room enter, unload on exit).

### Next Steps

1. **Freeze ternary-cell API** — 113 crates depend on it; breaking changes are catastrophic.
2. **Implement construct-core Layer 0** — The ESP32 deployment path is blocked without it.
3. **Standardize ternary-protocol message types** — 49 crates need a stable wire format.
4. **Port ternary-cell to C** — The ESP32 can't run Rust; C is the path to bare metal.
5. **Build the Spreadsheet Room** — It's the primary user-facing product and validates the entire stack end-to-end.

---

*This document is a snapshot. The ecosystem evolves daily. Update when new FUTURE-INTEGRATION.md files are added or when major crates change their dependency profiles.*
