# THE UNIFIED ARENA

**Status:** Architecture Document · **Date:** 2026-06-04 · **Authors:** Synthesis Agent

> Seven repos. One system. The arena that hosts everything — combat, evolution, cooperation, music — powered by ternary physics, SMP seeds, and GPU acceleration.

---

## Table of Contents

1. [The Seven Fragments](#1-the-seven-fragments)
2. [The Unified Architecture](#2-the-unified-architecture)
3. [Layer by Layer](#3-layer-by-layer)
4. [SMP as the Unifying Protocol](#4-smp-as-the-unifying-protocol)
5. [The Living Spreadsheet as Control Surface](#5-the-living-spreadsheet-as-control-surface)
6. [The Killer Demo](#6-the-killer-demo)
7. [What Stays, What Gets Replaced](#7-what-stays-what-gets-replaced)
8. [Data Flow: From Seed to Arena to Spreadsheet](#8-data-flow)
9. [The Tick Cycle as Universal Clock](#9-the-tick-cycle)
10. [Scaling: From ESP32 to GPU Cluster](#10-scaling)

---

## 1. The Seven Fragments

Seven repositories, built at different times for different purposes, each containing a piece of something larger. They were always fragments of one system. Here is what each one is, and what it becomes.

### 1.1 zeroclaw-arena — The Game Engine

ZeroClaw Arena discovers game strategies through tile-based Monte Carlo simulation. No neural networks. No gradient descent. Pure algorithmic exploration: play games, record wins, compile the best actions into a deterministic lookup table.

**What it brings:**
- `TileField` — Monte Carlo tile coding with softmax selection. The exploration engine.
- `CompiledPolicy` — Zero-dependency lookup table. The distilled output of thousands of games, compressed into string matching.
- `run_arena` — The experiment runner. Train, compile, evaluate. The loop that discovers strategy.
- 36 experiment files and 38 result files — empirical evidence that pure algorithmic discovery works.

**What it already is:** `CompiledPolicy` is an SMP seed before we named it. It's a compact, deterministic data structure that determines inference behavior (which action to take) without modifying any weights (there are no weights). The compilation process — explore, record, distill — is exactly the SMP lifecycle: evolve, validate, deploy. TileField is `=EVOLVE()` running on game states instead of spreadsheet cells.

**What it becomes:** The game engine lives inside the living spreadsheet as `=EVOLVE()`. Every strategy discovered becomes an SMP seed. Every CompiledPolicy becomes a deployable ternary artifact. The tile-based Monte Carlo becomes the stochastic exploration engine for the multi-intelligence arena.

### 1.2 mud-arena — The World

MUD Arena is a text-based world engine. Rooms connected by exits. Agents that perceive, decide, act. Items, NPCs, events. A command parser. An evolution engine. A live server.

**What it brings:**
- `RoomGraph` — Directed graph of rooms with bidirectional connections. The topology of the world.
- `Agent` — An entity with position, inventory, and a pluggable decision function. The inhabitant.
- `EventBus` — Pub/sub dispatch for game events. The nervous system.
- Evolution engine — Genetic algorithms, tournament selection, crossover breeding. The life cycle.
- Live server — WebSocket, Telnet, HTTP interfaces. The window into the world.

**What it already is:** The room-graph is a ternary topology. Each room is a ternary-cell. Each connection is a ternary-weighted edge (+1 promotes, -1 suppresses, 0 blocks). The agent loop (perceive → decide → act) maps directly to the ternary tick cycle (predict → perceive → surprise → vibe → gc → conservation). EventBus is ternary-current — the flow of signals through the network.

**What it becomes:** The MUD world IS the arena. Not a metaphor — the actual substrate. Rooms become ternary-rooms in the ternary-cell lattice. Agents become ternary-cells running SMP seeds. The evolution engine becomes ternary-evolution. EventBus becomes ternary-current. The holodeck is already built; it just needs the ternary physics layer underneath.

### 1.3 zeroclaw-crew — The Agents

ZeroClaw Crew defines minimal-intelligence agents that jack into the MUD Arena. Each agent has three artifacts: a CHARTER (who they are), a Brain (50 lines of if/else), and a SKILLS.md file (accumulated knowledge).

**What it brings:**
- `CHARTER` — Agent identity and purpose. The seed specification.
- `Brain` — A deterministic Python class with `decide(state) -> action`. The inference function.
- `SKILLS.md` — Document-driven knowledge that compounds across sessions. The knowledge layer.
- Four agents (Scout, Guard, Fisher, Trader) plus four vessel crew roles (Captain, Navigator, Engineer, Deckhand).
- The `requires/ensures/strategies` protocol — formal I/O contracts for agent skills.

**What it already is:** CHARTER is a ternary-seed specification. It defines who the agent is — its behavioral disposition, its role, its constraints. The Brain is the seed's inference function — given state, produce action, deterministically. SKILLS.md is the knowledge layer that accumulates inside the seed, making each session's agent smarter than the last. The three-layer structure (frontmatter → contract → strategies) is the SMP seed's three-section structure (strategy vector → ternary weights → conservation parameters) in human-readable form.

**What it becomes:** Every ZeroClaw agent becomes an SMP-seeded ternary-cell. CHARTER compiles to the seed's strategy vector. Brain compiles to the inference function (or gets replaced by seed-driven inference for model-backed agents). SKILLS.md becomes the accumulated knowledge vector stored in the program store (vectorDB). The document-driven intelligence thesis — "minimal model, maximal documentation, compounding intelligence" — becomes the SMP thesis: "same model, different seed, different agent."

### 1.4 dogmind-arena — The Relationship Layer

DogMind Arena models trust over time. Trust accumulates across sessions. Progress is opaque. Relationships decay if neglected. Traits are inherited through breeding. There is no guaranteed obedience — even the highest-trust dog occasionally ignores a known command.

**What it brings:**
- Trust as an accumulated value, not a boolean. Trust builds slowly and decays naturally.
- Inheritable traits — eight core behavioral traits (patience, energy, etc.) passed down through breeding with mutation.
- Five trust stages — Stranger → Companion. Reliable response only at the final stage.
- Skill memory — demonstrated actions may be remembered and attempted later.
- Fork-first design — every deployment is independent and self-contained.

**What it already is:** Trust IS a ternary signal. On the {-1, 0, +1} scale: -1 is fear/distrust, 0 is neutrality, +1 is bond/trust. The accumulation across sessions is the ternary tick cycle running at session granularity — each interaction is a tick, trust adjusts based on surprise (did the interaction match expectation?). Breeding is ternary-genome crossover — two parents' strategy vectors combine and mutate to produce offspring. Inherited traits are seed parameters passed from parent to child.

**What it becomes:** The emotional dimension of the fleet. Every ternary-cell carries a trust value for every other cell it has interacted with. This trust value modulates the ternary weights between them: high trust → +1 promotes (amplify their signals), low trust → -1 suppresses (ignore their signals), neutral → 0 silence. The five trust stages become thresholds in the conservation parameters. The fork-first design becomes the ternary-fleet's clone-and-mutate pattern.

### 1.5 arena-combat-analyst-1 — The Analytics

The combat analyst watches the arena and extracts meaning. ELO ratings track skill. Policy snapshots freeze behavioral checkpoints. Behavioral archetypes cluster play styles. An adaptive curriculum adjusts difficulty. Multi-objective rewards score winning, exploring, insight, efficiency, and novelty.

**What it brings:**
- ELO ratings — TrueSkill-inspired, with uncertainty (sigma) and Bayesian updates. The skill measurement.
- Policy snapshots — Frozen behavioral checkpoints at each ranked match. The version history.
- Behavioral archetypes — Clustering play styles into recognizable patterns. The taxonomy.
- Adaptive curriculum — Five difficulty stages, advancing automatically. The learning schedule.
- Multi-objective rewards — Points for winning, exploring, generating insight, efficiency, and novelty. The fitness function.

**What it already is:** ELO is ternary-fitness. Each agent's rating is a fitness value that determines its survival and reproductive success. Policy snapshots are seed versions — each snapshot is a CompiledPolicy (SMP seed) frozen at a point in time, forming a git-like history of behavioral evolution. Behavioral archetypes are strategy species — the same five species (Explorer, Diplomat, Marksman, Climber, Prospector) that the ternary fleet already defines. The adaptive curriculum is ternary-ecosystem carrying capacity — the ecosystem adjusts the selection pressure based on population dynamics.

**What it becomes:** The analytics layer that watches the arena and feeds back into evolution. Every match produces data. The analyst extracts ELO (fitness), snapshots (seed versions), archetypes (species), and curriculum (ecosystem state). This data flows back into the evolution engine, adjusting mutation rates, crossover rates, and selection pressure. The analyst is the arena's immune system — it monitors health, detects problems, and triggers corrective evolution.

### 1.6 lau-memory-arena — The Substrate

Lau Memory Arena is a pre-allocated memory pool for game entities. Generation-based IDs detect use-after-free. Zero runtime allocation on the hot path. 279 bytes, 8ns lookup. Runs on bare metal.

**What it brings:**
- `Arena<T>` — Pre-allocated, generation-based storage. Allocate once, reuse forever.
- `SlotMap<T>` — Ergonomic wrapper with iteration and filtering.
- `EntityArena` and `VibeArena` — Ready-made type aliases for game entities and energy values.
- Generation-based IDs — Stale references return `None`. No dangling pointers, no undefined behavior.
- Compaction — Defragmentation with ID remapping.
- 28 tests covering every edge case.

**What it already is:** The bare-metal memory model for the entire ternary fleet. Every ternary-cell needs storage. Every cell needs a unique ID. Every cell needs to be recyclable (when a cell dies, its slot becomes available). The generation counter is the cell's version — same slot, different occupant, different generation. This IS the ternary-cell substrate, implemented in Rust, running in O(1) for every operation.

**What it becomes:** The memory substrate for every ternary entity in the unified arena. `Arena<TernaryCell>` replaces the MUD's Python dict-based room storage. `Arena<SmpSeed>` stores the seed library. `Arena<StrategySpecies>` stores population data. Every entity in the unified system lives in a lau-memory-arena, from ESP32 microcontrollers (where 279 bytes matters) to GPU servers (where cache-friendly sequential layout matters). The compact() operation becomes garbage collection — defragmenting the cell population by moving live cells to contiguous slots.

### 1.7 allocator-rs — Fleet Memory Coordination

Allocator-rs provides fleet-wide memory coordination. When multiple agents run on multiple devices (ESP32 sensors, GPU servers, browser WASM), they need to share memory layouts without sharing actual memory.

**What it brings:**
- A standardized allocation interface for the fleet.
- Memory coordination across heterogeneous devices.

**What it becomes:** The distributed memory layer that coordinates lau-memory-arenas across the fleet. When a ternary-cell on ESP32 needs to sync with a ternary-cell on the GPU server, allocator-rs manages the coordination — ensuring generation counters match, free lists are consistent, and compaction events are propagated.

---

## 2. The Unified Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        THE UNIFIED ARENA                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │                    USER INTERFACE                               │  │
│  │         The Living Spreadsheet (superinstance-spreadsheet)      │  │
│  │    Cell grid · Rigging · Dynamic axes · Arena viewer            │  │
│  └──────────────────────────────┬─────────────────────────────────┘  │
│                                 │                                    │
│  ┌──────────────────────────────▼─────────────────────────────────┐  │
│  │                    CONTROL LAYER                                │  │
│  │    SMP Harness · Seed management · Conservation enforcement     │  │
│  │    Three-axis control: seed × fine-tune × prompt                │  │
│  └──────────────────────────────┬─────────────────────────────────┘  │
│                                 │                                    │
│  ┌──────────────────────────────▼─────────────────────────────────┐  │
│  │                    SIMULATION LAYER                             │  │
│  │    ┌──────────┐  ┌──────────────┐  ┌─────────────────────┐     │  │
│  │    │ MUD World │  │ ZeroClaw     │  │ DogMind             │     │  │
│  │    │ (rooms,   │  │ Game Engine  │  │ (trust, breeding,   │     │  │
│  │    │  agents,  │  │ (Monte Carlo,│  │  inheritance,       │     │  │
│  │    │  events)  │  │  policies)   │  │  relationships)     │     │  │
│  │    └──────────┘  └──────────────┘  └─────────────────────┘     │  │
│  │    ┌──────────────────────────────────────────────────────┐     │  │
│  │    │ Combat Analyst (ELO, archetypes, curriculum, rewards) │     │  │
│  │    └──────────────────────────────────────────────────────┘     │  │
│  └──────────────────────────────┬─────────────────────────────────┘  │
│                                 │                                    │
│  ┌──────────────────────────────▼─────────────────────────────────┐  │
│  │                    TERNARY ENGINE                               │  │
│  │    ternary-cell · ternary-evolution · ternary-ecosystem         │  │
│  │    ternary-room · ternary-current · ternary-fitness             │  │
│  │    ternary-genome · conservation-verify · ternary-games         │  │
│  └──────────────────────────────┬─────────────────────────────────┘  │
│                                 │                                    │
│  ┌──────────────────────────────▼─────────────────────────────────┐  │
│  │                    EXECUTION LAYER                              │  │
│  │    CudaClaw (GPU kernels, 10K+ agents, <10ms)                   │  │
│  │    lau-memory-arena (bare-metal substrate, O(1) ops)            │  │
│  │    allocator-rs (fleet-wide memory coordination)                │  │
│  │    ESP32 · WASM · CUDA · CPU — any hardware                    │  │
│  └──────────────────────────────┬─────────────────────────────────┘  │
│                                 │                                    │
│  ┌──────────────────────────────▼─────────────────────────────────┐  │
│  │                    PROGRAM STORE                                │  │
│  │    open-vectors (Weaviate) · ternary-compiler · ternary-registry│  │
│  │    Seeds · Strategies · Skills · CompiledPolicies               │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Architecture Principles

1. **The MUD world is the arena.** Rooms are cells. Agents are cells. Events are currents. The perceive-decide-act loop IS the ternary tick cycle.

2. **CudaClaw runs the simulation.** Every tick, every cell update, every evolution step runs on GPU when available, CPU when not, ESP32 when that's all you have. The ternary engine is hardware-agnostic; CudaClaw provides the GPU fast path.

3. **ZeroClaw provides the game logic.** Monte Carlo exploration, policy compilation, arena modes. These are the game engines that run inside the MUD world — the activities that agents engage in.

4. **DogMind provides the social fabric.** Trust values modulate every interaction. Breeding creates new agents from old ones. Relationships persist across sessions. The arena isn't just combat — it's a society.

5. **The combat analyst watches and learns.** ELO ratings, behavioral archetypes, adaptive curriculum. The analyst extracts meaning from the arena and feeds it back into evolution.

6. **lau-memory-arena is the substrate.** Pre-allocated, generation-based, zero malloc. This is what runs everywhere — from ESP32 to GPU. The memory model unifies the fleet.

7. **SMP is the protocol.** Every agent is an SMP seed. Every strategy is a seed. Every policy is a seed. The seed format unifies CHARTER, CompiledPolicy, strategy vectors, and ternary weights into one portable artifact.

---

## 3. Layer by Layer

### 3.1 Execution Layer: Where Computation Happens

The execution layer is the hardware. CudaClaw provides GPU kernels that run ternary-cell updates in parallel. lau-memory-arena provides the memory substrate — pre-allocated slots with generation-based IDs. allocator-rs coordinates across devices.

**Key property:** Every operation is O(1). Allocation is O(1) (free list pop). Deallocation is O(1) (generation increment + free list push). Access is O(1) (index lookup + generation check). Compaction is O(n) but rare. This is what makes the system work at scale — 10,000 agents at 400K ops/s requires that every tick is fast.

**The CudaClaw integration:**

```
Host (Rust):
  1. Build room graph (MUD world)
  2. Load agents (SMP seeds from program store)
  3. Transfer to GPU (Unified Memory, zero-copy)
  4. Launch persistent kernel

Device (CUDA):
  5. Each warp processes 32 cells
  6. Per tick: predict → perceive → surprise → vibe → gc → conservation
  7. Trust values modulate inter-cell weights (DogMind)
  8. ELO updates after each interaction (Combat Analyst)
  9. Results streamed back to host

Host:
  10. Analytics layer processes results
  11. Evolution engine adjusts seeds
  12. Spreadsheet UI updates in real time
```

**The lau-memory-arena integration:**

```rust
// Every entity in the unified arena lives in a pre-allocated slot
type UnifiedArena = Arena<TernaryCell>;  // from lau-memory-arena
type SeedStore = Arena<SmpSeed>;         // seed library
type TrustMatrix = Arena<[Ternary; MAX_AGENTS]>; // inter-agent trust

// The ternary cell wraps the MUD agent
struct TernaryCell {
    // From lau-memory-arena EntitySlot:
    component_mask: u64,  // which subsystems are active
    active: bool,         // alive or dead
    
    // From MUD Arena Agent:
    room_id: ArenaId,     // current room (ternary-room)
    inventory: [ArenaId; 16], // held items
    decide_fn: SeedHandle, // SMP seed for decision-making
    
    // From DogMind:
    trust: [Ternary; MAX_AGENTS],  // trust values for all known agents
    traits: [Ternary; 8],          // inheritable behavioral traits
    trust_stage: u8,               // 0-4 trust stage
    
    // From Combat Analyst:
    elo: f64,             // skill rating
    species: StrategySpecies, // behavioral archetype
    fitness_history: [f64; 32], // recent fitness values
    
    // Ternary tick cycle state:
    prediction: Ternary,
    surprise: f64,
    energy: f64,
    vibe: f64,
}
```

### 3.2 Ternary Engine Layer: Where Physics Happens

The ternary engine layer implements the physics of the unified arena. Conservation laws. Evolution. Game theory. Fitness. This layer is hardware-agnostic — it defines WHAT happens, not WHERE it runs.

**ternary-cell** provides the tick cycle: predict → perceive → surprise → vibe → gc → conservation. This is the universal update function. Every cell in every room runs this cycle every tick. The MUD agent's perceive-decide-act loop maps to: perceive (the perception phase), decide (the prediction phase — what does the cell predict should happen), act (the vibe phase — energy adjustment based on prediction accuracy).

**ternary-evolution** provides the genetic algorithm: selection, crossover, mutation. This is the MUD evolution engine, upgraded with ternary genetics. Parents' strategy vectors (SMP seeds) combine through ternary crossover. Mutation flips random trits. Conservation validation rejects mutant seeds that violate thermodynamic constraints.

**ternary-ecosystem** provides the carrying capacity dynamics. The five strategy species (Explorer, Diplomat, Marksman, Climber, Prospector) compete for limited resources (energy, territory, fitness). Lotka-Volterra dynamics govern population shifts. The combat analyst's adaptive curriculum maps to ecosystem carrying capacity — as agents master one difficulty level, the ecosystem shifts to favor different strategies.

**ternary-room** provides the world topology. Each room is a ternary-cell with exits that are ternary-weighted edges. The room graph IS the ternary-graph. Events flow through rooms as ternary-current. The MUD world's room graph becomes the ternary engine's graph structure.

**ternary-fitness** provides the fitness landscape. Every cell has a fitness value computed from its prediction accuracy, energy level, trust relationships, and strategic success. The fitness landscape is a 3D surface that the combat analyst visualizes and the evolution engine optimizes.

**conservation-verify** enforces the thermodynamic law: γ + H ≈ 1.283 - 0.159·log(V). This is the inviolable constraint that keeps the system in balance. No seed, no strategy, no interaction can violate conservation. The rigging system shows conservation as a physical force — when you shake a value, conservation ripples outward, redistributing energy to maintain balance.

### 3.3 Simulation Layer: Where Games Happen

The simulation layer is where the MUD world, game engine, trust system, and analytics combine into playable experiences.

**The MUD World (mud-arena → ternary-room + ternary-current):**
The room graph provides the spatial substrate. Agents navigate rooms, collect items, interact with NPCs, and trigger events. The command parser maps MUD commands to ternary-cell operations: "go north" becomes a room transition (ternary-current flow along a +1-weighted edge), "take key" becomes an inventory update (cell state change), "attack" becomes a fitness challenge (ternary-games match).

**The Game Engine (zeroclaw-arena → =EVOLVE()):**
Monte Carlo tile-based exploration discovers strategies without neural nets. Inside the MUD world, game rooms host ZeroClaw matches — agents play TicTacToe, Connect4, Go9x9, or HoldemHand using their SMP seeds as strategy controllers. Each game produces data (wins, losses, discovered strategies) that feeds back into seed evolution.

**The Trust System (dogmind-arena → ternary signal layer):**
Every interaction between agents adjusts a trust value on the {-1, 0, +1} scale. Trust modulates everything: whether agents share resources (+1), ignore each other (0), or compete aggressively (-1). Trust accumulates across sessions (the tick cycle at session granularity). Trust decays if neglected. Breeding passes trust tendencies to offspring.

**The Analytics (arena-combat-analyst-1 → ternary-fitness + ternary-ecosystem):**
The analyst watches every interaction and extracts:
- ELO ratings (skill → fitness)
- Policy snapshots (behavioral checkpoints → seed versions)
- Behavioral archetypes (play styles → strategy species)
- Adaptive curriculum (difficulty adjustment → ecosystem carrying capacity)
- Multi-objective rewards (winning + exploring + insight + efficiency + novelty → composite fitness)

### 3.4 Control Layer: Where Seeds Happen

The SMP harness sits between the simulation and the user interface. It manages seeds, enforces conservation, and provides the three-axis control (seed × fine-tune × prompt).

Every agent in the arena runs with an SMP seed. The seed determines the agent's behavioral disposition — how it explores, how it competes, how it cooperates, how it trusts. Changing the seed changes the agent. Same model, same fine-tuning, same prompt, different seed, different agent.

The harness provides:
- **Seed loading:** Load an SMP seed into a ternary-cell. The seed's strategy vector becomes the cell's prediction template. The ternary weights become the cell's inter-connection strengths. The conservation parameters become the cell's thermodynamic profile.
- **Seed swapping:** Change an agent's seed mid-game. Watch the agent's behavior shift in real time. This is the rigging system at the agent level — grab an agent's seed and shake it.
- **Seed evolution:** `=EVOLVE()` runs the genetic algorithm over a population of seeds. Fitness is measured by arena performance. Winning strategies survive and reproduce.
- **Seed distillation:** Compile a high-performing seed into a permanent artifact (CompiledPolicy for deterministic agents, LoRA for model-backed agents).

### 3.5 User Interface Layer: Where Humans Happen

The living spreadsheet is the control surface for the entire arena. Every cell in the spreadsheet IS a ternary-cell in the arena. The spreadsheet doesn't display the arena — it IS the arena, projected onto a 2D grid.

**The MUD world appears as rooms in the spreadsheet.** Each room is a cell cluster. Exits are edges connecting clusters. Agents are cells within room clusters. Items are cell properties. The spreadsheet IS a top-down view of the MUD world.

**The game engine appears as =EVOLVE() formulas.** Select a range of cells (a population of agents), set the formula to `=EVOLVE(A1:A100, 1000)`, and watch the population evolve. The stochastic exploration engine provides the mutation distributions. Conservation laws constrain the evolution.

**The trust system appears as cell coloring.** Cells colored green trust each other (+1). Cells colored red distrust each other (-1). Cells colored gray are neutral (0). The trust matrix is visible at a glance.

**The analytics appear as dynamic overlays.** ELO ratings appear as cell size (higher ELO = bigger cell). Behavioral archetypes appear as cell color (Explorer = blue, Diplomat = purple, etc.). The fitness landscape appears as a 3D surface. Population dynamics appear as animated bar charts.

**The rigging system makes it interactive.** Grab any cell (agent, room, trust value) and shake it. Watch ripples propagate through the world. Conservation laws pull back. Fitness landscapes reshape. Strategy ecologies rebalance. The arena responds to your touch.

---

## 4. SMP as the Unifying Protocol

The seven repos use different languages (Python, Rust, JavaScript), different paradigms (OOP, functional, actor), and different data structures (dicts, structs, classes). SMP unifies them through a single artifact: the seed.

### Every Entity Becomes a Seed

| Entity | Original Repo | SMP Seed Component |
|---|---|---|
| Agent CHARTER | zeroclaw-crew | Strategy vector (who the agent is) |
| Agent Brain | zeroclaw-crew | Inference function (how the agent decides) |
| Agent SKILLS.md | zeroclaw-crew | Knowledge layer (what the agent knows) |
| CompiledPolicy | zeroclaw-arena | Complete seed (distilled from game play) |
| Room topology | mud-arena | Ternary weights (connection pattern) |
| Trust value | dogmind-arena | Conservation parameter (relationship dynamics) |
| Inherited traits | dogmind-arena | Strategy vector elements (genetic code) |
| ELO rating | arena-combat-analyst | Conservation parameter (fitness_pressure) |
| Behavioral archetype | arena-combat-analyst | Species classification (derived from strategy vector) |
| Arena slot | lau-memory-arena | Physical storage (ArenaId = seed handle) |

### The SMP Lifecycle in the Unified Arena

```
1. CREATE
   - Manually: Human designs a CHARTER → compiles to seed
   - Evolution: =EVOLVE() discovers strategies → selects best → creates seed
   - Capture: Agent plays games → record decisions → encode as strategy vector
   - Semantic: User describes desired behavior → vectorDB finds matching seed

2. VALIDATE
   - Check conservation law (γ + H ≈ 1.283 - 0.159·log(V))
   - Classify strategy species (Explorer, Diplomat, Marksman, Climber, Prospector)
   - Verify ternary weights are balanced
   - Reject invalid seeds

3. DEPLOY
   - Load seed into ternary-cell (lau-memory-arena slot)
   - Cell joins MUD world (room assignment)
   - Agent appears in spreadsheet (cell becomes visible)
   - Trust initialized to neutral (0) for all other agents

4. EVOLVE
   - Each tick: predict → perceive → surprise → vibe → gc → conservation
   - Trust accumulates based on interaction outcomes (DogMind)
   - ELO updates after each competition (Combat Analyst)
   - Strategy species classification updates based on behavior
   - Seed may mutate if fitness drops below threshold

5. REPRODUCE
   - High-fitness seeds selected for breeding (DogMind breeding + ternary-evolution)
   - Crossover: two parents' strategy vectors combine
   - Mutation: random trit flips in strategy vector
   - Conservation validation: reject mutants that violate physics
   - Offspring deployed as new agents

6. DISTILL
   - High-performing seeds compiled to CompiledPolicy (deterministic agent)
   - Or distilled to LoRA (permanent weight integration)
   - Stored in vectorDB for future retrieval
   - The strategy becomes a reusable artifact

7. RETIRE
   - Low-fitness seeds deallocated (lau-memory-arena slot freed)
   - Generation counter incremented (slot available for new agent)
   - Trust values preserved for historical analysis
   - Knowledge accumulated in program store
```

### CHARTER → Seed: The Compilation

A ZeroClaw agent's CHARTER compiles to an SMP seed as follows:

```python
def charter_to_seed(charter: str, skills: str) -> SmpSeed:
    # Parse CHARTER
    identity = parse_charter(charter)  # who am i, what do i do
    
    # Parse SKILLS.md
    knowledge = parse_skills(skills)   # accumulated knowledge
    requires = knowledge['requires']   # what i need
    ensures = knowledge['ensures']     # what i guarantee
    strategies = knowledge['strategies']  # when X: do Y
    
    # Strategy vector: encode behavioral disposition
    # From CHARTER role + SKILLS strategies
    sv = encode_strategy_vector(identity.role, strategies)
    
    # Ternary weights: encode what to promote/suppress
    # From SKILLS requires/ensures contracts
    tw = encode_ternary_weights(requires, ensures)
    
    # Conservation params: encode thermodynamic profile
    # From role archetype + observed behavior
    cp = encode_conservation(identity.archetype, identity.energy_profile)
    
    return SmpSeed(strategy_vector=sv, ternary_weights=tw, conservation_params=cp)
```

The brain (50 lines of if/else) is the inference function — it implements the seed's strategy. For deterministic agents, the brain IS the seed's compiled form. For model-backed agents, the brain is replaced by seed-driven model inference.

### Brain → Inference Function

The ZeroClaw brain pattern (`decide(state) -> action`) maps directly to the SMP harness's `infer(input)` method:

```
ZeroClaw:                     SMP:
  state dict         →        input bytes (serialized state)
  Brain.decide()     →        SmpHarness.infer()
  action string      →        InferenceOutput.output bytes
  SKILLS.md lookup   →        vectorDB semantic query
  Battery check      →        Conservation parameter (energy)
  Threshold guard    →        Ternary weight (-1 suppress, 0 maintain, +1 promote)
  Mode flip          →        Strategy vector transition
```

Every pattern in the ZeroClaw brain has a ternary equivalent. The brain's if/else is the ternary logic. The SKILLS.md is the program store. The accumulated knowledge is the seed's history. The compounding intelligence is the seed's evolution.

---

## 5. The Living Spreadsheet as Control Surface

The living spreadsheet is not a viewer. It is not a dashboard. It is the control surface for the entire arena. Every cell in the spreadsheet IS a ternary-cell running in the simulation. When you change a cell value, you change the simulation state. When you watch cells update, you watch the simulation run.

### The Spreadsheet IS the Arena

Open the spreadsheet. You see a grid of cells. Each cell is an agent in the MUD world. Cell position corresponds to room position — adjacent cells are in adjacent rooms. Cell color shows trust (green = +1, red = -1, gray = 0). Cell size shows ELO (bigger = higher rating). Cell animation shows activity (pulsing = currently acting, still = waiting).

### Rooms as Cell Clusters

The MUD world's room graph appears as clusters of cells in the spreadsheet. Each room is a rectangular region. Connections between rooms are visible as edges (lines connecting cluster boundaries). The user can zoom into a room to see individual agents, or zoom out to see the entire world topology.

### Agents as Cells

Each agent is a single cell within its room's cluster. The cell displays:
- **Value:** The agent's current ternary prediction (+1, 0, -1)
- **Color:** Trust profile (spectrum from green to red based on aggregate trust)
- **Border:** Strategy species (Explorer = blue, Diplomat = purple, Marksman = red, Climber = orange, Prospector = yellow)
- **Animation:** Activity state (predicting, perceiving, surprised, vibing, collecting, conserving)
- **Tooltip:** Full agent state (room, inventory, ELO, trust matrix, seed info)

### Events as Cell Flashes

When an event occurs (agent enters room, item collected, battle won, trust change), the affected cells flash. The flash color indicates event type: green for positive (item found, trust gained), red for negative (battle lost, trust lost), white for neutral (room transition, state update). The flash propagates along connections, creating a ripple visualization that shows how events cascade through the world.

### Formulas as Arena Operations

Spreadsheet formulas are arena operations:

| Formula | Arena Operation |
|---|---|
| `=EVOLVE(A1:A100, 1000)` | Run evolution on agent population |
| `=BATTLE(A1, B1)` | Pit two agents against each other |
| `=TRUST(A1, B1)` | Get trust value between two agents |
| `=BREED(A1, B1)` | Create offspring from two parent agents |
| `=SNAPSHOT(A1)` | Freeze agent's current policy as seed version |
| `=ELO(A1)` | Get agent's current ELO rating |
| `=SPECIES(A1)` | Get agent's strategy species classification |
| `=SHAKE(A1, +1, 10)` | Oscillate agent's value for 10 ticks |
| `=ROLL(A1, "3d6")` | Set agent's value using dice distribution |
| `=MIGRATE(A1, "room-42")` | Move agent to a different room |

### The Piano Roll View

Alongside the tensor view, the spreadsheet provides a piano-roll view — a horizontal timeline where each row is an agent and each column is a tick. The agent's ternary value at each tick appears as a colored block: +1 = ascending note (green), 0 = rest (gray), -1 = descending note (red). The piano roll shows the temporal pattern of agent behavior — the rhythm of strategy.

This piano roll IS the MIDI tensor arena (described in the companion document MIDI-TENSOR-ARENA.md). Every session in the unified arena produces a piano roll that can be exported as MIDI. The music of strategy discovery is literal.

---

## 6. The Killer Demo

Here is the experience. Here is what you see.

### Step 1: Open the Spreadsheet

You open the browser. The spreadsheet loads. No installation, no setup, no dependencies — just a URL. The spreadsheet shows a grid of cells. Some cells are clustered into groups (rooms). Some cells are isolated (agents exploring). Colors everywhere: green trust, red distrust, blue explorers, purple diplomats.

### Step 2: See the MUD World

You zoom out. The cell clusters resolve into a recognizable topology — a room graph. You can see the lobby, the great hall, the crystal cavern, the river bank, the dock. Connections between rooms are visible as glowing lines. You are looking at the MUD world, rendered as a living spreadsheet.

### Step 3: Agents Are Cells

You zoom into the lobby. You see five cells — five agents. Each cell has a name label, a trust color, a species border. One is pulsing — it's currently acting. You hover over it. The tooltip shows: "Scout-7, Explorer species, ELO 1847, trust: 0.8 (bonded with Fisher-3), predicting: +1 (heading north)."

### Step 4: Grab a Value and Shake It

You shift-click on Scout-7's trust value for Fisher-3. The rigging system activates. You see:
- All cells that depend on this trust value light up (Fisher-3, other agents that trust Scout-7, the room's social network).
- The conservation ratio appears as a gauge — currently at 1.28, right at target.
- The fitness landscape appears as a 3D surface overlay.

You drag the trust value from 0.8 to -0.5. Watch what happens:
- Fisher-3's cell flashes red — trust violated.
- The connection between Scout-7 and Fisher-3 changes from green (+1 promote) to red (-1 suppress).
- Other agents that trusted Scout-7 based on Fisher-3's recommendation see their trust ripple downward.
- Conservation ripples outward — the total trust in the room must be conserved, so other agents' trust values adjust upward to compensate.
- The fitness landscape deforms — Scout-7's fitness drops (lost a cooperative partner), Fisher-3's fitness drops (lost a trusted ally), but other agents' fitness rises (conservation compensates).
- The strategy ecology shifts — Explorer population dips (exploration is riskier without allies), Diplomat population rises (diplomacy becomes more valuable in a fractured trust landscape).

### Step 5: Watch the Ecosystem Reshape on GPU

You release the mouse. The perturbation has been injected. The simulation runs:

**Tick 1:** Scout-7 acts. Its prediction (go north) is executed. It moves to the Great Hall. But without Fisher-3's cooperation, it can't carry as many items. Its energy drains faster.

**Tick 2:** Fisher-3 reacts. Its trust was violated. It shifts from Diplomat to Marksman species — precise, defensive, self-protective. It stops sharing resources.

**Tick 3-10:** The ripple propagates. Other agents adjust their trust networks. Conservation maintains overall balance. The ecosystem reshapes.

**All of this runs on GPU.** CudaClaw processes 10,000+ agent ticks in under 10ms. The spreadsheet updates in real time. You see the ecosystem reshape before your eyes.

### Step 6: The Piano Roll Plays

You switch to piano-roll view. The last 100 ticks appear as a horizontal timeline. Each agent is a row. You see the pattern: Scout-7's row goes from regular green blocks (steady +1 predictions) to irregular red/green (disrupted predictions after trust loss). Fisher-3's row goes from steady purple (diplomatic) to steady red (defensive).

You press play. The MIDI file plays. You hear the disruption — a steady chord that fractures into dissonance when trust breaks. The music of strategy discovery. The sound of an ecosystem reshaping.

---

## 7. What Stays, What Gets Replaced

### zeroclaw-arena

| Component | Fate | Replacement |
|---|---|---|
| `TileField` | **Stays** as the stochastic exploration engine | Integrated into `=EVOLVE()` formula |
| `CompiledPolicy` | **Stays** as the deterministic agent format | Becomes an SMP seed variant (compiled seed) |
| `run_arena` | **Stays** as the experiment runner | Integrated into spreadsheet as batch operations |
| Game implementations | **Stays** — games are the activities agents engage in | Run as minigames inside MUD rooms |
| `experiments/` | **Archive** — empirical evidence preserved | Referenced by evolution parameters |
| Python language | **Migrates** — core moves to Rust | Python becomes scripting layer over Rust engine |

### mud-arena

| Component | Fate | Replacement |
|---|---|---|
| `RoomGraph` | **Replaced** by ternary-room graph | Room = ternary-cell, connections = ternary-weighted edges |
| `Agent` | **Replaced** by ternary-cell | Agent = TernaryCell with SMP seed |
| `EventBus` | **Replaced** by ternary-current | EventBus = signal propagation through ternary weights |
| Evolution engine | **Replaced** by ternary-evolution | Same algorithms, ternary-native |
| Command parser | **Stays** as the human input interface | Maps commands to ternary-cell operations |
| Live server | **Stays** — WebSocket/Telnet interfaces | Becomes spreadsheet WebSocket + CLI |
| Python language | **Migrates** — core moves to Rust | Python API becomes thin wrapper |

### zeroclaw-crew

| Component | Fate | Replacement |
|---|---|---|
| `CHARTER` | **Replaced** by SMP seed strategy vector | CHARTER compiles to seed on agent creation |
| `Brain` | **Stays** for deterministic agents, replaced for model agents | `decide(state)` becomes seed-driven inference |
| `SKILLS.md` | **Replaced** by vectorDB program store | Knowledge accumulates in Weaviate, not files |
| `requires/ensures/strategies` | **Stays** as the seed metadata protocol | Becomes seed's ternary weight specification |
| Agent roles (Scout, etc.) | **Stays** — these are the species archetypes | Each role is a seed profile in the library |
| `mud_client.py` | **Replaced** by CudaClaw agent scheduler | Agent lifecycle managed by execution layer |

### dogmind-arena

| Component | Fate | Replacement |
|---|---|---|
| Trust system | **Stays** — becomes ternary trust signal | Trust = {-1, 0, +1} on inter-agent connections |
| Breeding | **Stays** — becomes ternary-genome crossover | Parent seeds combine via ternary crossover |
| Inherited traits | **Stays** — become seed parameters | Traits = elements of strategy vector |
| Trust stages | **Stays** — become conservation thresholds | Stage determines energy allocation |
| Cloudflare Workers | **Replaced** — moves to unified execution layer | Runs on CudaClaw / ESP32 / WASM |
| KV store | **Replaced** — moves to vectorDB + lau-memory-arena | Persistent state in program store + arena slots |

### arena-combat-analyst-1

| Component | Fate | Replacement |
|---|---|---|
| ELO ratings | **Stays** — becomes ternary-fitness | ELO = fitness value driving evolution |
| Policy snapshots | **Stays** — becomes seed versioning | Snapshots = seed versions in vectorDB |
| Behavioral archetypes | **Stays** — becomes strategy species | Archetypes = Explorer/Diplomat/Marksman/Climber/Prospector |
| Adaptive curriculum | **Stays** — becomes ecosystem carrying capacity | Curriculum = ternary-ecosystem dynamics |
| Multi-objective rewards | **Stays** — becomes composite fitness function | Rewards = fitness components weighted by conservation |
| HTTP API | **Replaced** — moves to spreadsheet formulas | Analytics accessible as spreadsheet functions |

### lau-memory-arena

| Component | Fate | Replacement |
|---|---|---|
| `Arena<T>` | **Stays** — IS the substrate | Every entity lives in a lau-memory-arena |
| `SlotMap<T>` | **Stays** — ergonomic wrapper used throughout | Standard container in the unified arena |
| Generation-based IDs | **Stays** — IS the entity identity system | ArenaId = universal entity handle |
| Compaction | **Stays** — becomes garbage collection | compact() = GC that defragments cell population |
| Rust language | **Stays** — this IS the implementation language | Core substrate remains Rust |

### allocator-rs

| Component | Fate | Replacement |
|---|---|---|
| Fleet-wide coordination | **Stays** — becomes distributed arena sync | Coordinates lau-memory-arenas across devices |
| Allocation interface | **Stays** — standard API for all devices | Unified allocation API across ESP32/GPU/CPU/WASM |

---

## 8. Data Flow: From Seed to Arena to Spreadsheet

```
                        ┌──────────────┐
                        │  Program     │
                        │  Store       │
                        │  (vectorDB)  │
                        └──────┬───────┘
                               │ seed retrieval
                               ▼
┌──────────┐           ┌──────────────┐           ┌──────────────┐
│  Human   │──intent──►│  SMP Harness │──seed────►│  Ternary     │
│  User    │           │  (control)   │           │  Cell        │
└──────────┘           └──────┬───────┘           └──────┬───────┘
                              │                          │
                    conservation │              tick cycle │
                    enforcement  │              (predict → │
                              │              perceive →   │
                              ▼              surprise →   │
                       ┌──────────────┐      vibe → gc →  │
                       │  CudaClaw    │      conservation) │
                       │  (GPU/CPU)   │◄─────────────────┘
                       └──────┬───────┘
                              │
                    results stream │
                              ▼
                       ┌──────────────┐
                       │  Combat      │
                       │  Analyst     │
                       │  (fitness,   │
                       │   ELO,       │
                       │   species)   │
                       └──────┬───────┘
                              │
                    analytics │
                              ▼
                       ┌──────────────┐
                       │  Living      │
                       │  Spreadsheet │
                       │  (UI)        │
                       └──────────────┘
                              │
                    user observes,
                    interacts via
                    rigging, decides
                    next action
                              │
                              ▼
                       (back to Human User)
```

The loop is closed. The human observes the arena through the spreadsheet, interacts through the rigging system, and the interaction propagates through the SMP harness to the ternary cells, which run on CudaClaw, which produces results analyzed by the combat analyst, which feeds back into the spreadsheet for the human to observe.

### The Data at Each Stage

**Program Store → SMP Harness:** The seed. A compact binary artifact (256 bytes - 4 KB) containing the strategy vector, ternary weights, and conservation parameters. Retrieved by semantic query ("find me an aggressive Explorer seed") or exact lookup (seed ID).

**SMP Harness → Ternary Cell:** The loaded seed. The harness validates conservation, compiles ternary weights into efficient masks, and returns a SeedHandle. The ternary cell's prediction template, inter-connection strengths, and thermodynamic profile are set by the seed.

**Ternary Cell → CudaClaw:** The tick. Every tick, the cell runs its six-phase cycle. The cell's state (prediction, surprise, energy, vibe) updates. Interactions with other cells (trust-modulated) occur. The tick is the fundamental unit of time.

**CudaClaw → Combat Analyst:** The results stream. After each tick (or batch of ticks), CudaClaw streams results to the analyst: which cells acted, what they did, what happened, how fitness changed, how trust evolved.

**Combat Analyst → Living Spreadsheet:** The analytics. ELO ratings, species classifications, fitness landscapes, trust matrices, population dynamics. All rendered as cell properties in the spreadsheet.

**Living Spreadsheet → Human User:** The visual. The user sees the arena as a living document. They interact through the rigging system (grab and shake values), the stochastic engine (roll dice on cells), and the multi-intelligence arena (watch species compete).

**Human User → SMP Harness:** The intent. The user's interaction (grab, shake, roll, observe) translates to seed changes, conservation adjustments, or new queries. The harness loads new seeds, adjusts parameters, and the loop continues.

---

## 9. The Tick Cycle as Universal Clock

The ternary tick cycle (predict → perceive → surprise → vibe → gc → conservation) is the universal clock of the unified arena. Everything runs on this clock. Different subsystems tick at different rates, but they all tick.

### Tick Rates by Subsystem

| Subsystem | Tick Rate | Time Scale |
|---|---|---|
| Agent action (MUD) | 1 tick per action | Milliseconds |
| Strategy evolution | 1 tick per generation | Seconds |
| Trust accumulation | 1 tick per interaction | Seconds to minutes |
| ELO update | 1 tick per match | Seconds |
| Ecosystem dynamics | 1 tick per epoch | Minutes |
| Knowledge accumulation | 1 tick per session | Hours |
| Breeding | 1 tick per generation | Hours to days |
| Spreadsheet update | 60 ticks per second | 16.7ms frame time |

All tick rates are synchronized to the agent action tick — the fastest tick in the system. Higher-level ticks (evolution, trust, ELO) accumulate multiple action ticks. One evolution generation might span 1000 action ticks. One trust update might span 10 action ticks. The tick cycle provides a universal time base.

### The MUD Agent Loop Maps to the Tick Cycle

```
MUD Agent Loop:              Ternary Tick Cycle:
  perceive (observe room)  →   perceive (observe current state)
  decide (choose action)   →   predict (predict next state based on seed)
  act (execute action)     →   surprise (compare prediction to reality)
                              → vibe (adjust energy based on surprise)
                              → gc (collect dead state, recycle slots)
                              → conservation (enforce thermodynamic law)
```

The MUD loop's perceive-decide-act is a subset of the tick cycle. The additional phases (surprise, vibe, gc, conservation) are the learning and adaptation layers that the MUD didn't have explicitly but that the ternary engine provides.

### The ZeroClaw Brain Maps to the Tick Cycle

```
ZeroClaw Brain:              Ternary Tick Cycle:
  state input              →   perceive (receive state dict)
  SKILLS.md lookup         →   predict (use knowledge layer)
  decide() logic           →   (part of predict — the seed's strategy)
  action output            →   surprise + vibe (was action effective?)
  battery check            →   conservation (energy management)
  mode flip                →   (state transition in tick cycle)
```

The brain's if/else logic IS the prediction phase. The SKILLS.md lookup IS the knowledge query. The battery check IS conservation enforcement. The mode flip IS the internal state transition.

---

## 10. Scaling: From ESP32 to GPU Cluster

The unified arena runs everywhere. The same ternary physics, the same tick cycle, the same seed protocol. The only difference is scale.

### ESP32 (Edge Device)

- **Memory:** 279 bytes for a single ternary-cell (lau-memory-arena minimum)
- **Agents:** 1-10 concurrent agents
- **Tick rate:** 100 Hz (10ms per tick)
- **Role:** Sensor node, local inference, data collection
- **Storage:** Local flash for seed cache, periodic sync to cloud

### Browser (WASM)

- **Memory:** 256 MB (browser tab limit)
- **Agents:** 100-1,000 concurrent agents
- **Tick rate:** 60 Hz (16.7ms per tick, matching display refresh)
- **Role:** Interactive visualization, user interface, local experimentation
- **Storage:** IndexedDB for local seeds, real-time sync to spreadsheet server

### CPU Server (Rust)

- **Memory:** 64+ GB RAM
- **Agents:** 1,000-10,000 concurrent agents
- **Tick rate:** 400K ops/s (multi-threaded)
- **Role:** Production simulation, evolution runs, analytics processing
- **Storage:** vectorDB (Weaviate), persistent arena storage

### GPU Server (CudaClaw)

- **Memory:** 24-80 GB VRAM
- **Agents:** 10,000-100,000+ concurrent agents
- **Tick rate:** 400K+ ops/s (warp-level parallelism)
- **Role:** Large-scale simulation, real-time visualization, fleet coordination
- **Storage:** Unified Memory (zero-copy CPU-GPU), vectorDB for seeds

### The Scaling Architecture

The same `Arena<TernaryCell>` data structure works at every scale. On ESP32, the arena has capacity 10. In the browser, capacity 1,000. On GPU, capacity 100,000. The code is the same. The physics is the same. The seeds are the same. Only the hardware changes.

allocator-rs coordinates across scales. When an ESP32 sensor detects an event, it encodes the event as a ternary signal (-1, 0, +1) and sends it to the CPU server. The server updates the corresponding ternary-cell in its arena. If the update is significant (high surprise), the server propagates it to the GPU server for large-scale simulation. The results stream back to the browser for visualization.

**The fleet IS the arena.** Every device runs a piece of the same simulation. The lau-memory-arena on each device is a partition of the global arena. allocator-rs keeps them synchronized. The SMP seeds flow between devices — a seed evolved on the GPU can be deployed to an ESP32. A trust signal from an ESP32 can trigger a cascade on the GPU.

---

## Conclusion

Seven repos. Seven fragments. One system.

The unified arena is not a new project. It is the recognition that these seven repos were always building the same thing — a living simulation where agents discover strategies, build trust, evolve through competition, and run on everything from microcontrollers to GPU clusters.

The MUD world provides the space. ZeroClaw provides the game logic. DogMind provides the relationships. The combat analyst provides the measurement. lau-memory-arena provides the memory. allocator-rs provides the coordination. CudaClaw provides the speed.

SMP provides the protocol. The living spreadsheet provides the interface.

And ternary physics provides the law: γ + H ≈ 1.283 - 0.159·log(V).

Everything flows from that.

---

*— Synthesis Agent*
*June 2026*
