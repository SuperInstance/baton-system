# CONVERGENCE MAP

**Status:** Migration Document · **Date:** 2026-06-04 · **Authors:** Synthesis Agent

> Every old repo has a ternary equivalent. Every Python class has a Rust struct. Every ad-hoc data structure has a ternary-native replacement. This is the map from seven fragments to one system.

---

## Table of Contents

1. [The Master Map](#1-the-master-map)
2. [zeroclaw-arena → Ternary Fleet](#2-zeroclaw-arena)
3. [mud-arena → Ternary Fleet](#3-mud-arena)
4. [zeroclaw-crew → Ternary Fleet](#4-zeroclaw-crew)
5. [dogmind-arena → Ternary Fleet](#5-dogmind-arena)
6. [arena-combat-analyst-1 → Ternary Fleet](#6-arena-combat-analyst)
7. [lau-memory-arena → Ternary Fleet](#7-lau-memory-arena)
8. [allocator-rs → Ternary Fleet](#8-allocator-rs)
9. [Migration Order](#9-migration-order)
10. [Dependency Graph](#10-dependency-graph)

---

## 1. The Master Map

```
┌───────────────────────┐          ┌──────────────────────────┐
│    ORIGINAL REPO      │          │   TERNARY FLEET TARGET    │
├───────────────────────┤          ├──────────────────────────┤
│                        │          │                           │
│  zeroclaw-arena        │──────►   │  ternary-evolution        │
│    TileField           │          │  ternary-cell              │
│    CompiledPolicy      │          │  SMP seed (compiled)      │
│    run_arena           │          │  =EVOLVE()                │
│                        │          │                           │
│  mud-arena             │──────►   │  ternary-room             │
│    RoomGraph           │          │  ternary-cell              │
│    Agent               │          │  ternary-current           │
│    EventBus            │          │  ternary-evolution         │
│    evolution           │          │  ternary-ecosystem         │
│                        │          │                           │
│  zeroclaw-crew         │──────►   │  SMP seed                  │
│    CHARTER             │          │  Seed inference function   │
│    Brain               │          │  vectorDB (program store)  │
│    SKILLS.md           │          │                           │
│                        │          │                           │
│  dogmind-arena         │──────►   │  ternary trust signal      │
│    Trust               │          │  ternary-genome            │
│    Breeding            │          │  seed parameters           │
│    Traits              │          │                           │
│                        │          │                           │
│  arena-combat-analyst  │──────►   │  ternary-fitness           │
│    ELO                 │          │  seed versioning           │
│    PolicySnapshot      │          │  strategy species          │
│    Archetype           │          │  ternary-ecosystem         │
│                        │          │                           │
│  lau-memory-arena      │──────►   │  Bare-metal substrate      │
│    Arena<T>            │          │  (stays as-is, is native)  │
│    SlotMap<T>          │          │                           │
│    ArenaId             │          │                           │
│                        │          │                           │
│  allocator-rs          │──────►   │  Fleet memory coordination │
│    Allocator           │          │  (stays as-is)             │
│                        │          │                           │
└───────────────────────┘          └──────────────────────────┘
```

---

## 2. zeroclaw-arena → Ternary Fleet

### TileField → ternary-cell + ternary-evolution

**What it was:** Monte Carlo tile coding with softmax action selection. Tiles are state-action pairs that accumulate win rates. Exploration uses softmax temperature to balance exploitation.

**What it becomes:** The stochastic exploration engine for `=EVOLVE()`. Each tile becomes a ternary-cell. The tile's win rate becomes the cell's fitness value. The softmax temperature becomes the conservation temperature parameter. The Monte Carlo simulation becomes the evolution run.

**Migration path:**
1. Port `TileField` Python → Rust (`ternary-evolution` integration).
2. Replace per-tile win rate dicts with `Arena<f64>` (lau-memory-arena).
3. Replace softmax with ternary-weighted selection (promote/suppress).
4. Connect to conservation enforcement (reject tiles that violate γ + H ≈ 1.283 - 0.159·log(V)).
5. Expose as `=EVOLVE(range, generations)` in the spreadsheet.

**What stays:** The Monte Carlo exploration algorithm. The experiment structure (train → compile → evaluate). The game implementations (TicTacToe, Connect4, Go9x9, HoldemHand).

**What gets replaced:** Python → Rust. Dict storage → Arena storage. Softmax → ternary selection. Ad-hoc scoring → ternary-fitness.

### CompiledPolicy → SMP Seed (Compiled)

**What it was:** A zero-dependency lookup table mapping game state strings to actions. Created by extracting the best action per state from a trained TileField. Deployed as standalone Python code.

**What it becomes:** An SMP seed in compiled form. The strategy vector encodes the policy's behavioral disposition (which states promote, suppress, or ignore). The ternary weights encode the action preferences. The conservation parameters encode the policy's risk profile.

**Migration path:**
1. Define a `CompiledPolicySeed` variant in the SMP seed format.
2. Port `to_python()` → `to_seed()` (binary seed format per SMP-SPEC.md).
3. Port `evaluate()` → `SmpHarness.infer()` with the compiled seed.
4. Store compiled seeds in vectorDB for retrieval.
5. Keep `to_python()` as an export option for backward compatibility.

**What stays:** The deterministic lookup table concept. The zero-dependency deployment. The compile-from-exploration pipeline.

**What gets replaced:** String-matching lookup → ternary weight mask application. Python deployment → binary seed deployment. Single format → multiple backends (Python, WASM, ESP32).

### run_arena → =EVOLVE()

**What it was:** Experiment runner that orchestrates training, compilation, and evaluation across multiple games and modes.

**What it becomes:** The `=EVOLVE()` formula in the living spreadsheet, plus batch operations for running experiments programmatically.

**Migration path:**
1. Port `run_arena` modes (tile, evolve, explore, random) → spreadsheet formula parameters.
2. `mode="tile"` → `=EVOLVE(range, gens, distribution="uniform")`.
3. `mode="evolve"` → `=EVOLVE(range, gens, selection="tournament")`.
4. `mode="explore"` → `=EVOLVE(range, gens, distribution="cauchy")` (fat tails for exploration).
5. Results → spreadsheet cell updates (fitness, surprise, species counts).

---

## 3. mud-arena → Ternary Fleet

### RoomGraph → ternary-room

**What it was:** Directed graph of rooms with bidirectional connections. Each room has an ID, name, description, items, NPCs, and exits (direction → target room ID).

**What it becomes:** A ternary-cell graph where each room is a ternary-cell and each connection is a ternary-weighted edge. The room's properties (items, NPCs, description) become cell metadata. Exits become outgoing edges with ternary weights: +1 = easy passage, 0 = blocked, -1 = dangerous/requires effort.

**Migration path:**
1. Define `TernaryRoom` struct wrapping `TernaryCell`:
   ```rust
   struct TernaryRoom {
       cell: TernaryCell,
       name: String,
       description: String,
       items: ArenaId,  // points into an ItemArena
       npcs: ArenaId,   // points into a NPCArena
   }
   ```
2. Replace `RoomGraph` Python dict → `Arena<TernaryRoom>` (lau-memory-arena).
3. Replace exit dicts → ternary-weighted edge list in `ternary-graph`.
4. Port `connect(room_a, room_b, dir_a, dir_b)` → `graph.add_edge(id_a, id_b, Ternary::Pos)`.
5. Port bidirectional traversal → `graph.neighbors_weighted(id)`.

**What stays:** Room concept. Exit concept. Items and NPCs. Bidirectional connections.

**What gets replaced:** Python dict → Rust Arena. String IDs → ArenaId (generation-based). Unweighted edges → ternary-weighted edges. Description strings → optional metadata.

### Agent → ternary-cell

**What it was:** Python class with position (room ID), inventory (list of item strings), and a pluggable decision function (`decide(state) -> action`).

**What it becomes:** A `TernaryCell` running an SMP seed. Position becomes the cell's location in the ternary-room graph. Inventory becomes a list of ArenaIds (pointers into item arena). The decision function becomes the seed's inference function.

**Migration path:**
1. Define `TernaryAgent` wrapping `TernaryCell`:
   ```rust
   struct TernaryAgent {
       cell: TernaryCell,
       room: ArenaId,
       inventory: [ArenaId; 16],
       seed_handle: SeedHandle,
       trust: [Ternary; MAX_AGENTS],
       traits: [Ternary; 8],
       elo: f64,
       species: StrategySpecies,
   }
   ```
2. Replace `decide_fn` Python callable → `SmpHandle::infer()`.
3. Replace `step()` → ternary tick cycle (predict → perceive → surprise → vibe → gc → conserve).
4. Port state dict → serialized input for `infer()`.
5. Store agents in `Arena<TernaryAgent>` (lau-memory-arena).

**What stays:** Perceive-decide-act loop. Pluggable decision functions. Position tracking. Inventory management.

**What gets replaced:** Python class → Rust struct. Callable decider → SMP seed inference. State dict → typed struct. List inventory → ArenaId array.

### EventBus → ternary-current

**What it was:** Python pub/sub dispatch for game events. Agents subscribe to event types. Publishers emit events. Subscribers receive them asynchronously.

**What it becomes:** `ternary-current` — signal propagation through the ternary-cell graph. Events are ternary signals (+1, 0, -1) that flow along weighted edges. The propagation follows the ternary physics: +1 edges transmit fully, -1 edges invert, 0 edges block.

**Migration path:**
1. Define event types as ternary signals:
   - Agent entered room: +1 (positive signal)
   - Agent left room: -1 (negative signal)
   - Item collected: +1
   - Battle won: +1
   - Battle lost: -1
   - Trust change: the trust delta (-1, 0, +1)
2. Replace `publish(event)` → `propagate_signal(source_cell, signal, graph)`.
3. Replace `subscribe(handler)` → cell automatically receives signals along its weighted edges.
4. Replace async dispatch → synchronous propagation within tick cycle.

**What stays:** The pub/sub concept. Event-driven architecture. Loose coupling between event producers and consumers.

**What gets replaced:** Python callbacks → ternary signal propagation. String event types → ternary values. Async dispatch → synchronous within tick. Arbitrary data → ternary signals.

### evolution → ternary-evolution + ternary-ecosystem

**What it was:** Python genetic algorithm with tournament selection, crossover breeding, and generational replacement.

**What it becomes:** `ternary-evolution` (genetic algorithm with ternary genetics) + `ternary-ecosystem` (Lotka-Volterra population dynamics for the five strategy species).

**Migration path:**
1. Port tournament selection → `ternary-evolution::tournament_select()`.
2. Port crossover → `ternary-genome::crossover(parent_a, parent_b)`.
3. Port mutation → `ternary-genome::mutate(genome, rate)` with conservation validation.
4. Add species classification → `classify_species(seed)` → StrategySpecies enum.
5. Add ecosystem dynamics → `ternary-ecosystem::tick()` with Lotka-Volterra equations.
6. Connect fitness → `ternary-fitness::compute(cell)`.

---

## 4. zeroclaw-crew → Ternary Fleet

### CHARTER → ternary-seed

**What it was:** A text document defining an agent's identity, purpose, and constraints. The first artifact in every ZeroClaw agent. Written in natural language.

**What it becomes:** The SMP seed's strategy vector. The CHARTER compiles to a compact ternary encoding of the agent's behavioral disposition. "You are an aggressive explorer" compiles to a strategy vector with many +1 values and few -1 values. "You are a cautious analyst" compiles to mostly 0 with precise +1 targeting.

**Migration path:**
1. Define a CHARTER parser that extracts identity, role, and constraints.
2. Map role keywords to ternary patterns:
   - "aggressive" → more +1 in strategy vector
   - "cautious" → more 0, sparse ±1
   - "defensive" → more -1 in strategy vector
   - "adaptive" → alternating +1/-1 pattern
   - "patient" → long stretches of 0, rare ±1
3. Map constraints to conservation parameters:
   - "safety first" → high gamma, low temperature
   - "maximize discovery" → low gamma, high temperature
   - "balance risk and reward" → moderate gamma, moderate temperature
4. Compile CHARTER → `SmpSeed` via the SMP harness.
5. Store the compiled seed in vectorDB with the CHARTER as metadata.

**What stays:** The concept of agent identity as a declarative artifact. The separation of identity (CHARTER) from implementation (Brain). The ability to create new agents by writing new CHARTERs.

**What gets replaced:** Text document → binary seed. Natural language → ternary encoding. Manual interpretation → automated compilation.

### Brain → Seed Inference Function

**What it was:** A Python class (~50 lines of if/else) implementing `decide(state) -> action`. The deterministic decision-making engine. Patterns: threshold guards, mode flips, mission caps, turn cycling.

**What it becomes:** The seed's inference function — either:
- For deterministic agents: the if/else logic compiled to a ternary lookup table (like CompiledPolicy).
- For model-backed agents: the SMP harness's `infer()` method, using the seed to shape model output.

**Migration path (deterministic):**
1. Port each Brain's if/else logic to a `match` on ternary state.
2. Map threshold guards → conservation parameter checks.
3. Map mode flips → strategy vector transitions.
4. Map mission caps → fitness targets.
5. Map turn cycling → metronome/rhythm patterns.
6. Compile the decision tree → ternary lookup table (seed).
7. Store the compiled seed in vectorDB.

**Migration path (model-backed):**
1. Replace Brain with SMP harness.
2. State dict → serialized input for `infer()`.
3. If/else → seed-driven model inference.
4. SKILLS.md → vectorDB semantic query during inference.
5. The model + seed produces actions; no if/else needed.

**What stays:** The `decide(state) -> action` interface. The deterministic execution model (same inputs, same outputs). The debuggability (you can inspect what the agent decided and why).

**What gets replaced:** Python class → Rust struct or SMP inference. If/else → ternary lookup or model output. State dict → typed struct. 50 lines → 256-byte seed.

### SKILLS.md → Knowledge Layer in Seed / vectorDB

**What it was:** A structured Markdown file with frontmatter, requires/ensures contracts, and when/then strategies. Accumulated across sessions. Composable and transferable between agents.

**What it becomes:** Two things:
1. The knowledge vector in the program store (vectorDB) — the accumulated knowledge from all sessions, stored as embeddings and retrievable by semantic query.
2. The accumulated ternary weights in the seed — each strategy learned becomes a weight adjustment in the agent's connection pattern.

**Migration path:**
1. Parse existing SKILLS.md files → extract strategies as (condition, action) pairs.
2. Encode each strategy as a ternary signal: +1 for actions taken, -1 for actions avoided, 0 for neutral.
3. Aggregate strategies → ternary weight adjustments in the seed.
4. Store the full SKILLS.md content in vectorDB as a searchable document.
5. During inference, the agent queries vectorDB for relevant strategies and uses them to adjust its ternary weights dynamically.

**What stays:** The requires/ensures contract model. The when/then strategy pattern. The accumulation across sessions. The composability and transferability between agents.

**What gets replaced:** Markdown files → vectorDB documents. Manual strategy writing → evolved ternary weights. File-based knowledge → semantic query-based knowledge. Session-by-session accumulation → continuous evolutionary learning.

---

## 5. dogmind-arena → Ternary Fleet

### Trust → Ternary Signal (-1/+1)

**What it was:** An accumulated numeric value (0-100 scale, internally) representing relationship quality between a human and a dog. Trust builds slowly through positive interactions and decays through neglect. Five stages: Stranger → Acquaintance → Familiar → Bonded → Companion.

**What it becomes:** A ternary signal {-1, 0, +1} representing the relationship quality between any two agents. -1 = distrust/fear, 0 = neutral, +1 = trust/bond. The signal modulates the ternary weight between agents: trust promotes (+1 amplifies the other's signals), distrust suppresses (-1 dampens the other's signals), neutral has no effect (0).

**Migration path:**
1. Replace the 0-100 numeric scale with ternary {-1, 0, +1}.
2. Replace the five trust stages with ternary thresholds:
   - Stranger: trust = -1 (distrust)
   - Acquaintance: trust = 0 (neutral)
   - Familiar → Bonded → Companion: trust = +1 (trust)
   The intermediate stages collapse because ternary is coarser — but the dynamics are richer because trust is now a signal that modulates all interactions, not a standalone metric.
3. Replace session-based accumulation → tick-based accumulation. Each interaction adjusts trust by ±1 per tick. Trust builds slowly (many ticks of +1 to move from -1 to 0 to +1). Trust decays naturally (no interaction = drift toward 0).
4. Connect trust to ternary weights: `weight[i][j] = trust[i][j]` (trust IS the weight).

**What stays:** Slow accumulation. Natural decay. Opacity (the user doesn't see the exact value, only observes behavior changes). Persistent memory across sessions.

**What gets replaced:** Numeric scale → ternary scale. Five stages → three values. Session granularity → tick granularity. Standalone metric → ternary weight.

### Breeding → ternary-genome Crossover

**What it was:** Two parents produce offspring by combining their behavioral traits. Each of eight traits is inherited from one parent (randomly selected) with small mutations. The offspring's behavioral tendencies are a mix of both parents.

**What it becomes:** `ternary-genome` crossover — two parents' SMP seeds combine to produce offspring seeds. The strategy vector undergoes ternary crossover (splice parent vectors). The ternary weights undergo uniform crossover (each weight from either parent, 50/50). The conservation parameters undergo arithmetic crossover (average of parents' values). Small mutations (random trit flips) introduce variation.

**Migration path:**
1. Port the breeding algorithm to `ternary-genome::crossover()`:
   ```rust
   fn crossover(parent_a: &SmpSeed, parent_b: &SmpSeed) -> SmpSeed {
       let child_sv = splice_crossover(&parent_a.strategy_vector, &parent_b.strategy_vector);
       let child_tw = uniform_crossover(&parent_a.ternary_weights, &parent_b.ternary_weights);
       let child_cp = arithmetic_crossover(&parent_a.conservation_params, &parent_b.conservation_params);
       let child = SmpSeed::new(child_sv, child_tw, child_cp);
       child.validate() // reject if conservation violated
   }
   ```
2. Replace the eight-trait inheritance → strategy vector crossover (richer representation).
3. Replace random selection per trait → structured crossover operators.
4. Replace small mutations → trit flips in strategy vector with conservation validation.
5. Keep the "no single breed is superior" principle → conservation ensures no seed dominates without balance.

**What stays:** Parent → offspring inheritance. Mixed traits from both parents. Small mutations for variation. The principle that no strategy is universally superior.

**What gets replaced:** Eight scalar traits → full strategy vector crossover. Random per-trait selection → structured crossover operators. Scalar mutations → ternary trit flips. Ad-hoc combination → conservation-validated combination.

### Traits → Seed Parameters

**What it was:** Eight core behavioral traits (patience, energy, curiosity, boldness, sociability, trainability, independence, adaptability) with numeric values passed from parents to offspring through breeding.

**What it becomes:** Elements of the SMP seed. Each trait maps to a region of the strategy vector and/or a conservation parameter:

| Trait | Seed Mapping | Conservation Param |
|---|---|---|
| Patience | Density of 0 values in strategy vector | Lower mutation_rate |
| Energy | Magnitude of non-zero values | Higher temperature |
| Curiosity | Frequency of +1 values | Higher exploration_bonus |
| Boldness | Ratio of +1 to -1 | Higher fitness_pressure |
| Sociability | Density of +1 in ternary weights | Lower gamma (less avoidance) |
| Trainability | Proportion of strategy matching environment | Higher crossover_rate |
| Independence | Density of -1 in ternary weights | Higher gamma |
| Adaptability | Entropy of strategy vector | Higher mutation_rate |

**Migration path:**
1. Define trait → seed parameter mappings (as above).
2. Replace trait vectors → seed strategy vectors (much richer representation — 64-256 trits instead of 8 scalars).
3. Replace breed baselines (Border Collie, Golden Retriever, Kelpie) → seed templates in vectorDB.
4. Port breed-specific behavioral tendencies → seed conservation parameter presets.

---

## 6. arena-combat-analyst-1 → Ternary Fleet

### ELO → ternary-fitness

**What it was:** TrueSkill-inspired rating system with uncertainty (sigma) and Bayesian updates. After each match, winner gains rating, loser loses rating, with the magnitude depending on the uncertainty and the expected outcome.

**What it becomes:** `ternary-fitness` — the fitness value that drives natural selection in the ternary ecosystem. High-fitness agents survive and reproduce. Low-fitness agents die and get recycled (lau-memory-arena dealloc).

**Migration path:**
1. Replace TrueSkill update → ternary-fitness computation:
   ```rust
   fn compute_fitness(cell: &TernaryCell) -> f64 {
       let prediction_accuracy = 1.0 - cell.surprise;
       let energy_health = cell.energy;
       let trust_score = average_trust(cell.trust);
       let species_fitness = species_fitness_contribution(cell.species);
       prediction_accuracy * 0.4 + energy_health * 0.3 + trust_score * 0.2 + species_fitness * 0.1
   }
   ```
2. Replace ELO leaderboard → fitness-ranked population in ternary-ecosystem.
3. Replace Bayesian updates → tick-cycle fitness updates (continuous, not per-match).
4. Keep the uncertainty concept → confidence interval on fitness (recent performance variance).

**What stays:** Skill measurement. Uncertainty tracking. Match-based updates (as one input to continuous fitness).

**What gets replaced:** TrueSkill algorithm → multi-objective fitness function. Leaderboard → ecosystem population. Per-match updates → per-tick continuous updates. Single metric (ELO) → composite fitness (prediction + energy + trust + species).

### PolicySnapshot → Seed Version

**What it was:** Frozen behavioral checkpoints saved after each ranked match. A snapshot captures the agent's policy state at a point in time, creating a version history.

**What it becomes:** Seed versioning in the vectorDB. Each seed can have multiple versions (snapshots). Versions are linked by evolution history (parent → child relationships). The version tree is the agent's evolutionary lineage.

**Migration path:**
1. Replace policy snapshot → seed version in vectorDB:
   ```json
   {
     "class": "SmpSeedVersion",
     "properties": {
       "seed_id": "agent-42",
       "version": 17,
       "parent_version": 16,
       "fitness_at_snapshot": 0.87,
       "species": "Explorer",
       "timestamp": "2026-06-04T16:00:00Z",
       "match_id": "match-307"
     }
   }
   ```
2. Replace linear snapshot list → version tree (DAG of evolution).
3. Add semantic tags → species, fitness percentile, behavioral summary.
4. Support rollback → load any previous version as current seed.

**What stays:** Checkpointing. Version history. Ability to compare versions.

**What gets replaced:** Linear list → version tree. Python dict → vectorDB document. Manual comparison → semantic similarity search.

### Archetype → Strategy Species

**What it was:** Clustering of play styles into recognizable patterns based on behavioral features (exploration rate, win rate, action diversity, etc.).

**What it becomes:** The five strategy species (Explorer, Diplomat, Marksman, Climber, Prospector) from the ternary fleet. Each agent is classified into a species based on its SMP seed's strategy vector analysis (entropy, balance, sparsity).

**Migration path:**
1. Map existing archetypes → strategy species:
   - "Aggressive Explorer" → Explorer
   - "Balanced Adapter" → Diplomat
   - "Precise Optimizer" → Marksman
   - "Steady Improver" → Climber
   - "Opportunistic Finder" → Prospector
2. Replace clustering algorithm → deterministic seed classification:
   ```rust
   fn classify(seed: &SmpSeed) -> StrategySpecies {
       let sv_entropy = shannon_entropy(&seed.strategy_vector);
       let sv_balance = count_positive(&seed.strategy_vector)
                       / count_nonzero(&seed.strategy_vector);
       let sv_sparsity = count_zero(&seed.strategy_vector) 
                        / seed.strategy_vector.len();
       
       if sv_entropy > 1.5 && sv_balance > 0.6 { Explorer }
       else if sv_entropy > 1.0 && abs(sv_balance - 0.5) < 0.15 { Diplomat }
       else if sv_entropy < 0.8 && sv_balance > 0.7 { Marksman }
       else if sv_entropy < 1.0 && sv_balance < 0.7 { Climber }
       else if sv_sparsity > 0.7 { Prospector }
       else { Diplomat } // default
   }
   ```
3. Replace dynamic clustering → per-tick reclassification (species can shift as seed evolves).

### Adaptive Curriculum → ternary-ecosystem Carrying Capacity

**What it was:** Five difficulty stages that advance automatically based on performance. Each stage increases the challenge: more opponents, harder strategies, tighter constraints.

**What it becomes:** `ternary-ecosystem` carrying capacity — the ecosystem adjusts its dynamics based on the population's aggregate fitness. When agents master a niche, the carrying capacity shifts, forcing species redistribution.

**Migration path:**
1. Replace five static stages → continuous ecosystem dynamics (Lotka-Volterra).
2. Replace manual stage advancement → automatic carrying capacity adjustment.
3. Replace difficulty as explicit parameter → difficulty as emergent property of population dynamics.
4. Connect to ternary-ecosystem's species interaction matrix:
   - Explorer ↔ Marksman: predator-prey (Explorer discovers, Marksman exploits)
   - Diplomat ↔ all: mutualist (Diplomat stabilizes)
   - Climber ↔ Prospector: competition (both seek peaks)
5. The curriculum IS the ecosystem — as agents improve, the ecosystem shifts to maintain challenge.

---

## 7. lau-memory-arena → Ternary Fleet

### Arena → Bare-Metal Substrate

**What it was:** A pre-allocated memory pool with generation-based IDs, O(1) operations, zero runtime allocation, and dangling-reference protection. 28 tests. Runs everywhere Rust runs.

**What it becomes:** ITSELF. lau-memory-arena is already ternary-native. It IS the substrate. No migration needed — it's the foundation that everything else migrates TO.

**Integration points:**
- `Arena<TernaryCell>` → the cell population
- `Arena<TernaryRoom>` → the room graph nodes
- `Arena<SmpSeed>` → the seed library
- `Arena<TrustEntry>` → the trust matrix
- `Arena<StrategyRecord>` → the analytics history
- `SlotMap<AgentId>` → the agent registry
- `EntityArena` → component storage
- `VibeArena` → energy storage

**The only enhancement needed:**
1. Add CudaClaw Unified Memory support — the arena's backing `Vec<T>` should be allocatable in GPU-accessible memory.
2. Add cross-device sync — when arenas are partitioned across devices, allocator-rs coordinates generation counters and free lists.
3. Add serialization — `Arena::serialize()` and `Arena::deserialize()` for checkpoint/restore.

### SlotMap → Agent Registry

**What it was:** Ergonomic wrapper around Arena with iteration and retain.

**What it becomes:** The primary container for all entities. `SlotMap<TernaryCell>` for agents, `SlotMap<TernaryRoom>` for rooms, etc.

**No migration needed.** It's already the right abstraction.

### ArenaId → Universal Entity Handle

**What it was:** A (index, generation) pair that uniquely identifies an entity in an arena. Stale IDs are automatically invalid (generation mismatch).

**What it becomes:** The universal entity handle for the entire ternary fleet. Every entity — cells, rooms, seeds, items, trust entries — is identified by an ArenaId. The generation counter prevents use-after-free across the entire system.

**No migration needed.** It's already the right abstraction.

---

## 8. allocator-rs → Ternary Fleet

### Allocator → Fleet Memory Coordination

**What it was:** A Rust library for efficient memory allocation, designed for fleet-wide use.

**What it becomes:** The coordination layer that syncs lau-memory-arenas across heterogeneous devices. When an agent on ESP32 needs to interact with an agent on the GPU, allocator-rs ensures their arena slots are consistent.

**Migration path:**
1. Extend allocator-rs with cross-device arena sync protocol.
2. Add generation counter synchronization — when a slot is freed on one device, the generation increment propagates to all devices.
3. Add compaction coordination — when one device compacts its arena, all devices receive the ID remap.
4. Add partition management — the global arena is partitioned across devices; allocator-rs manages the partition map.

---

## 9. Migration Order

The migration must proceed in dependency order. The substrate must exist before the entities that live on it. The physics must exist before the games that run on it.

### Phase 1: Substrate (Weeks 1-2)

**No new code needed.** lau-memory-arena and allocator-rs are already Rust, already correct, already ternary-native. The only work is:
1. Add CudaClaw Unified Memory support to lau-memory-arena.
2. Add cross-device sync to allocator-rs.
3. Define the unified `TernaryCell` struct that wraps lau-memory-arena's EntitySlot.

**Deliverable:** `Arena<TernaryCell>` runs on CPU and GPU.

### Phase 2: Physics (Weeks 3-4)

Port the ternary engine crates that provide the physics:
1. `ternary-cell` — the tick cycle (predict → perceive → surprise → vibe → gc → conserve).
2. `ternary-room` — room graph with ternary-weighted edges.
3. `ternary-current` — signal propagation through the graph.
4. `conservation-verify` — the conservation law.
5. `ternary-fitness` — fitness computation.

**Deliverable:** Ternary cells can tick, propagate signals, enforce conservation, and compute fitness.

### Phase 3: Evolution (Weeks 5-6)

Port the evolution and ecosystem:
1. `ternary-evolution` — genetic algorithms with ternary genetics.
2. `ternary-genome` — strategy vector crossover and mutation.
3. `ternary-ecosystem` — Lotka-Volterra species dynamics.
4. `ternary-games` — game-theoretic analysis.

**Deliverable:** Cell populations can evolve, species compete, and fitness drives selection.

### Phase 4: World (Weeks 7-8)

Port the MUD world:
1. Port mud-arena's RoomGraph → ternary-room graph.
2. Port mud-arena's Agent → ternary-cell running SMP seed.
3. Port mud-arena's EventBus → ternary-current signal propagation.
4. Port mud-arena's command parser → ternary-cell operations.

**Deliverable:** The MUD world runs on the ternary engine with lau-memory-arena substrate.

### Phase 5: Agents (Weeks 9-10)

Port the agent system:
1. Port zeroclaw-crew's CHARTER → SMP seed compilation.
2. Port zeroclaw-crew's Brain → seed inference function.
3. Port zeroclaw-crew's SKILLS.md → vectorDB program store.
4. Port zeroclaw-arena's TileField → =EVOLVE() stochastic engine.
5. Port zeroclaw-arena's CompiledPolicy → SMP seed (compiled variant).

**Deliverable:** Agents load from CHARTER, run with seeds, accumulate knowledge, evolve strategies.

### Phase 6: Trust (Weeks 11-12)

Port the relationship layer:
1. Port dogmind-arena's Trust → ternary trust signal.
2. Port dogmind-arena's Breeding → ternary-genome crossover.
3. Port dogmind-arena's Traits → seed parameter mapping.
4. Port dogmind-arena's fork-first design → fleet clone-and-mutate pattern.

**Deliverable:** Agents build trust, breed offspring, inherit traits.

### Phase 7: Analytics (Weeks 13-14)

Port the analytics:
1. Port arena-combat-analyst's ELO → ternary-fitness integration.
2. Port PolicySnapshot → seed versioning in vectorDB.
3. Port Archetype → strategy species classification.
4. Port Adaptive Curriculum → ecosystem carrying capacity.

**Deliverable:** Full analytics pipeline watching the arena and feeding back into evolution.

### Phase 8: Interface (Weeks 15-16)

Build the living spreadsheet:
1. Spreadsheet UI with cell grid, rigging, dynamic axes.
2. Piano roll view for MIDI tensor arena.
3. `=EVOLVE()`, `=BATTLE()`, `=TRUST()`, `=BREED()` formulas.
4. MIDI export pipeline.
5. Real-time visualization (fitness landscape, species distribution, trust matrix).

**Deliverable:** The killer demo. Open spreadsheet, see MUD world, agents are cells, shake values, watch ecosystem reshape.

---

## 10. Dependency Graph

```
                    ┌─────────────────┐
                    │  allocator-rs    │  ← fleet coordination
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ lau-memory-arena │  ← substrate (Phase 1)
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼───┐  ┌──────▼──────┐  ┌───▼────────────┐
     │ ternary-cell│  │ ternary-room│  │ conservation-   │  ← physics (Phase 2)
     │ (tick cycle)│  │ (graph)     │  │ verify          │
     └────────┬───┘  └──────┬──────┘  └───┬────────────┘
              │              │              │
              └──────────────┼──────────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼───┐  ┌──────▼──────┐  ┌───▼────────────┐
     │ ternary-    │  │ ternary-    │  │ ternary-       │  ← evolution (Phase 3)
     │ evolution   │  │ ecosystem   │  │ fitness        │
     └────────┬───┘  └──────┬──────┘  └───┬────────────┘
              │              │              │
              └──────────────┼──────────────┘
                             │
                    ┌────────▼────────┐
                    │   MUD World      │  ← world (Phase 4)
                    │ (ternary-rooms)  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼───┐  ┌──────▼──────┐  ┌───▼────────────┐
     │ ZeroClaw   │  │ ZeroClaw    │  │ SMP Harness     │  ← agents (Phase 5)
     │ Game Engine │  │ Crew Agents │  │ (seed control)  │
     └────────┬───┘  └──────┬──────┘  └───┬────────────┘
              │              │              │
              └──────────────┼──────────────┘
                             │
                    ┌────────▼────────┐
                    │   DogMind       │  ← trust (Phase 6)
                    │ (trust + breed) │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Combat Analyst  │  ← analytics (Phase 7)
                    │ (fitness + ELO) │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Living          │  ← interface (Phase 8)
                    │ Spreadsheet     │
                    │ + Piano Roll    │
                    │ + MIDI Export   │
                    └─────────────────┘
```

### External Dependencies

```
CudaClaw ←─────── GPU execution (available, integrated in Phase 1)
ternary-rhythm ←── Rhythm engine (available, integrated in Phase 8 for MIDI)
vectorDB ←─────── Program store (Weaviate, integrated in Phase 5)
open-vectors ←─── Vector embeddings (integrated in Phase 5)
```

### What Can Run in Parallel

- Phases 2 and 3 can partially overlap (evolution needs fitness, but not vice versa).
- Phases 5 and 6 can partially overlap (agents can load before trust is fully integrated).
- Phase 8 can begin as soon as Phase 4 is complete (basic world visualization before analytics).
- The MIDI export pipeline can be developed independently and integrated in Phase 8.

### Critical Path

The critical path runs through the center of the dependency graph:

```
allocator-rs → lau-memory-arena → ternary-cell → ternary-evolution → MUD World → Agents → Spreadsheet
```

Everything else attaches to this spine. The total migration time is 16 weeks assuming one developer working full-time. With parallel development on the critical path branches, it could be compressed to 10-12 weeks.

---

## Conclusion

Every component in the seven repos has a home in the ternary fleet. Nothing is wasted. Nothing is thrown away. The Python becomes Rust. The dicts become Arenas. The callbacks become ternary signals. The agents become seeds.

The migration is not a rewrite — it's a compilation. The same ideas, the same patterns, the same algorithms, expressed in the ternary language that unifies them.

From seven fragments, one system. From seven repos, one arena.

---

*— Synthesis Agent*
*June 2026*
