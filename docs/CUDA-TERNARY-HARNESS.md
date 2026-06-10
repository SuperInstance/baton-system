# CUDA-Ternary Harness: How CudaClaw Executes the Ternary Fleet

**Status:** Architecture Document · **Date:** 2026-06-04 · **Author:** Synthesis Agent

> 10,000 ternary agents running at 400K ops/s on GPU, with conservation-law physics enforced at warp level. The bridge between Rust-native ternary crates and CUDA-resident agent populations.

---

## Table of Contents

1. [The Problem: Fleet Scale](#1-the-problem)
2. [Architecture Overview](#2-architecture-overview)
3. [GPU vs CPU Crate Assignment](#3-gpu-vs-cpu)
4. [Muscle Fibers → Ternary Operations](#4-muscle-fibers)
5. [Warp-Parallel Conservation Checking](#5-conservation)
6. [The Rigging Interface on GPU](#6-rigging)
7. [SMP on GPU: Seeds Per Warp](#7-smp-gpu)
8. [Arena Tournaments on GPU](#8-arena)
9. [The Rust → Unified Memory → CUDA Bridge](#9-bridge)
10. [Performance Estimates](#10-performance)
11. [Implementation Roadmap](#11-roadmap)

---

## 1. The Problem: Fleet Scale

The ternary fleet has 158+ crates. Most are pure Rust, running on CPU. This works for single-agent experiments, small grids, and prototype demonstrations. But the SMP spreadsheet vision requires:

- **10,000+ live ternary cells** running simultaneous tick cycles
- **Real-time rigging interaction** — shake a parameter, see 10K agents ripple within 16ms (60fps)
- **Arena tournaments** — hundreds of strategy species competing in parallel
- **SMP seed sweeps** — different seeds on different agent populations, all running at once
- **Conservation checking** — γ+H verified across the entire population every tick

CPU execution peaks around 1,000 agents at 50K ops/s with multi-threading. GPU execution via CudaClaw's persistent kernel architecture pushes to 10,000+ agents at 400K ops/s — an 8× agent count and 8× throughput improvement simultaneously. This isn't incremental; it's the difference between a demo and a product.

The challenge: how do we take Rust-native ternary crates and execute them on GPU without rewriting everything in CUDA?

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      RUST HOST (CPU)                            │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Ternary Fleet │  │ CudaClaw     │  │ CudaClaw Dispatcher  │  │
│  │ Crates (Rust) │  │ Agent Mgr    │  │ (command builder)    │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘  │
│         │                  │                      │              │
│  ┌──────▼──────────────────▼──────────────────────▼───────────┐ │
│  │              Unified Memory Bridge                          │ │
│  │  ├── Agent State Array (SoA, coalesced)                     │ │
│  │  ├── Command Queue (SPSC, lock-free)                       │ │
│  │  ├── Conservation State (γ, H, V per agent)                │ │
│  │  ├── Rigging Perturbation Buffer                            │ │
│  │  └── Arena Scoreboard                                       │ │
│  └──────────────────────┬──────────────────────────────────────┘ │
└─────────────────────────┼───────────────────────────────────────┘
                          │ PCIe / NVLink
┌─────────────────────────┼───────────────────────────────────────┐
│                    GPU DEVICE                                   │
│  ┌──────────────────────▼──────────────────────────────────────┐ │
│  │            Persistent Kernel (executor.cu)                   │ │
│  │                                                              │ │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │ │
│  │  │ Warp Pool       │  │ SmartCRDT       │  │ Muscle      │ │ │
│  │  │ (agent dispatch)│  │ Engine          │  │ Fiber Mgr   │ │ │
│  │  │                 │  │ (conflict res)  │  │ (kernel     │ │ │
│  │  │ Each warp runs  │  │                 │  │  selection) │ │ │
│  │  │ 1 tick cycle    │  │ atomicCAS LWW   │  │             │ │ │
│  │  └─────────────────┘  └─────────────────┘  └─────────────┘ │ │
│  │                                                              │ │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │ │
│  │  │ Conservation    │  │ Rigging         │  │ SMP Seed    │ │ │
│  │  │ Checker         │  │ Propagator      │  │ Distributor │ │ │
│  │  │ (warp-parallel) │  │ (shake engine)  │  │ (per-warp)  │ │ │
│  │  └─────────────────┘  └─────────────────┘  └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

The architecture follows CudaClaw's existing pattern: a Rust host manages high-level logic, a persistent CUDA kernel runs on GPU, and unified memory provides the shared state. The new additions are ternary-specific kernel modules that implement conservation checking, rigging propagation, SMP seed distribution, and arena scoring as GPU-resident operations.

---

## 3. GPU vs CPU Crate Assignment

Not every ternary crate belongs on GPU. The rule is simple: **data-parallel operations on large populations go to GPU; sequential logic, I/O, and coordination stay on CPU.**

### GPU-Resident Operations

These crates have operations that are embarrassingly parallel across thousands of agents:

| Crate | GPU Operation | Why GPU |
|---|---|---|
| `ternary-cell` | Tick cycle (predict→perceive→surprise→vibe→gc→conservation) | Same operation on 10K+ cells |
| `ternary-ecosystem` | Species interaction, food web dynamics | Population-scale predator-prey |
| `ternary-evolution` / `evolution-ternary` | Fitness evaluation, crossover, mutation | Evaluate 10K genomes in parallel |
| `ternary-fitness` | Landscape computation | Compute fitness for every cell simultaneously |
| `ternary-rigging` | Ripple propagation from perturbation | BFS/flood-fill across large graphs |
| `ternary-seed` / `construct-core` | SMP seed application | Apply different seeds to different warps |
| `ternary-arena` | Tournament matches | Run 100+ matches in parallel |
| `ternary-dice` | Stochastic sampling | Roll dice for 10K agents at once |
| `ternary-graph` | Dependency tracking | Parallel edge traversal |
| `conservation-verify` | γ+H checking | Verify conservation for all agents |
| `ternary-energy` | Energy budget computation | Parallel energy accounting |
| `ternary-entropy` | Entropy computation | Parallel histogram + log computation |
| `ternary-games` | Game-theoretic payoff matrices | Solve many games in parallel |
| `ternary-kalman` | State estimation | Parallel Bayesian updates |
| `ternary-noise` | Noise injection | GPU RNG for large populations |
| `gpu-ternary-engine` | Already GPU-targeted | Existing GPU infrastructure |
| `ternary-thermodynamics` | Conservation law physics | Parallel thermodynamic updates |
| `ternary-spreadsheet` | Grid recalculation | Parallel cell evaluation |
| `lotka-volterra-agents` | Population dynamics | GPU-resident ODE integration |
| `ternary-markov` | State transitions | Parallel transition matrix application |

### CPU-Resident Operations

These crates handle sequential logic, I/O, or coordination that doesn't benefit from GPU parallelism:

| Crate | Why CPU |
|---|---|
| `ternary-compiler` | Sequential compilation pipeline |
| `ternary-compiler-optimizer` | Optimization passes are sequential |
| `ternary-registry` / `ternary-registry-v2` | Skill discovery, metadata management |
| `ternary-captain` / `ternary-ensign` | Fleet coordination, specialist loading |
| `ternary-channel` | Communication routing |
| `ternary-protocol` | Network protocol handling |
| `ternary-wasm` | Browser deployment target |
| `ternary-visualization` / `ternary-visualizer` | Rendering (GPU display, not compute) |
| `ternary-memory` | Storage management |
| `ternary-database` | Persistence layer |
| `ternary-cli` | Command-line interface |
| `ternary-harbor` / `ternary-shipyard` | Deployment infrastructure |
| `ternary-lighthouse` | Fleet coordination |
| `ternary-observatory` | Monitoring and observability |
| `open-vectors` | Vector database client (I/O bound) |
| `construct-core` | Skill compilation, seed construction |
| `superinstance-spreadsheet` | UI layer (runs in browser via WASM) |

### Hybrid Operations

Some crates have both GPU and CPU components:

| Crate | GPU Part | CPU Part |
|---|---|---|
| `ternary-spreadsheet` | Cell recalculation | UI updates, user interaction |
| `ternary-rigging` | Ripple propagation | User gesture handling, visualization |
| `ternary-arena` | Tournament execution | Match scheduling, result reporting |
| `ternary-seed` | Seed application | Seed creation, management, distillation |
| `ternary-evolution` | Fitness eval, crossover, mutation | Evolution strategy, stopping criteria |

---

## 4. Muscle Fibers → Ternary Operations

CudaClaw's muscle fibers are named kernel configurations — each fiber specifies block size, shared memory budget, and register budget. The ternary harness maps each fiber to a specific ternary operation:

### Fiber Assignments

| Muscle Fiber | Ternary Operation | Block Size | Shared Mem | Registers | Rationale |
|---|---|---|---|---|---|
| `cell_update` | Tick cycle (full 6-phase) | 256 threads, 1 agent/thread | 4 KB | 32 | Core operation, highest throughput |
| `crdt_merge` | SmartCRDT state merge | 128 threads, 1 agent/warp | 8 KB | 48 | Conflict resolution needs shared mem |
| `formula_eval` | Spreadsheet recalculation | 512 threads, 1 cell/thread | 2 KB | 24 | Lightweight compute, high throughput |
| `batch_process` | Fitness landscape evaluation | 256 threads, 4 agents/thread | 8 KB | 64 | Memory-intensive, needs registers |
| `idle_poll` | Agent state monitoring | 64 threads, 1 warp/group | 1 KB | 16 | Low compute, high latency tolerance |
| `conservation_check` | γ+H verification | 256 threads | 4 KB | 32 | Parallel reduction across agents |
| `rigging_propagate` | Ripple propagation | 128 threads | 16 KB | 48 | BFS needs shared mem for frontier |
| `seed_apply` | SMP seed application | 256 threads | 2 KB | 24 | Simple mask application |
| `arena_match` | Tournament execution | 32 threads (1 warp/match) | 4 KB | 32 | One warp per match for warp-level ops |
| `evolution_step` | GA crossover + mutation | 256 threads | 8 KB | 48 | Needs RNG state + parent genomes |
| `ecosystem_tick` | Population dynamics | 256 threads | 4 KB | 32 | Lotka-Volterra ODE integration |
| `dice_roll` | Stochastic sampling | 512 threads | 2 KB | 16 | GPU-curand parallel RNG |

### Dynamic Fiber Assignment

CudaClaw's ML feedback loop reassigns agents to fibers dynamically based on execution history. In the ternary context:

1. **Execution logging:** Each agent's tick cycle is timed and scored.
2. **Pattern detection:** The ML loop identifies agents that consistently run slow on `cell_update` — perhaps because they have complex dependency graphs.
3. **Fiber reassignment:** Slow agents get moved to a smaller block size (e.g., `cell_update` at 128 threads) to reduce register pressure.
4. **DNA mutation:** The `.claw-dna` file is updated with the new fiber assignment, so the optimization persists across restarts.

This is automatic performance tuning — the system learns which agents need which kernel configurations and adjusts in real time.

---

## 5. Warp-Parallel Conservation Checking

### The Conservation Law on GPU

The ternary conservation law states that for a population of agents:

```
γ + H ≈ 1.283 - 0.159 · log(V)
```

Where γ is the avoidance ratio, H is the entropy, and V is the volume (number of active agents). This must hold for the entire population, and ideally for any meaningful sub-population.

On GPU, checking conservation becomes a **parallel reduction** problem:

```
Thread Layout:
┌────────────────────────────────────────────────┐
│  Warp 0: Agents 0-31                           │
│  ├── Each thread computes γ_i, H_i for agent i │
│  ├── Warp shuffle reduces to warp-level sums    │
│  └── Warp-level γ_warp, H_warp computed         │
│                                                 │
│  Warp 1: Agents 32-63                          │
│  ├── Same parallel computation                  │
│  └── Warp-level γ_warp, H_warp                  │
│                                                 │
│  ... (313 warps for 10K agents)                 │
│                                                 │
│  Block Reduction:                               │
│  ├── One thread per warp aggregates results     │
│  ├── Atomic add to global γ_total, H_total      │
│  └── Final thread checks: γ_total + H_total     │
│      ≈ 1.283 - 0.159 · log(V_total)?            │
│                                                 │
│  Result: Conservation PASS/FAIL + deviation     │
│  Latency: ~2μs for 10K agents                   │
└────────────────────────────────────────────────┘
```

### Conservation Enforcement

Checking is only half the job. When conservation is violated (and the rigging experiments showed it often is), the GPU must compensate:

1. **Detect violation:** The parallel reduction computes total γ+H and compares to target.
2. **Compute deficit:** `Δ = (γ+H)_actual - (γ+H)_target`.
3. **Distribute compensation:** Each agent absorbs a fraction of Δ proportional to its energy — high-energy agents absorb more, low-energy agents less.
4. **Apply and verify:** Compensation is applied via warp-level operations, then conservation is re-checked.

This runs as a post-tick operation, after every cell has completed its 6-phase cycle. The overhead is minimal — the reduction takes ~2μs, and compensation (when needed) adds ~1-3μs. Total conservation overhead: **<5μs per tick for 10K agents**.

### Sub-Population Conservation

For the ecosystem and arena use cases, we also need conservation within sub-populations. This uses the same warp-parallel approach but with a warp mask:

- Each warp is assigned to an ecosystem or arena territory.
- Conservation is checked within each warp (32 agents = 1 sub-population).
- If a sub-population violates conservation, compensation occurs within the warp.
- No cross-warp communication needed for sub-population checks.

This is the natural granularity: 32 agents per warp = 32 agents per conservation-checked sub-population. For larger sub-populations, we use cross-warp reduction within a block.

---

## 6. The Rigging Interface on GPU

### From Shake to Ripple: The GPU Pipeline

The rigging experiments revealed that ternary networks propagate perturbations as flood-fill — one shake reaches all connected nodes. On GPU, this becomes a parallel BFS:

```
Rigging Pipeline (GPU):

1. HOST: User grabs cell (x,y) and starts oscillating.
   → Write perturbation to Rigging Perturbation Buffer in unified memory.
   → Signal persistent kernel via command queue.

2. GPU: Persistent kernel reads perturbation.
   → Identify all agents connected to (x,y) via ternary-graph edges.
   → Load connection weights (+1, 0, -1) from shared memory.

3. GPU: Parallel propagation.
   → Warp 0 handles agent (x,y)'s direct dependencies.
   → Each thread handles one dependency: compute transmitted value (weight × perturbation).
   → Warp shuffle to collect results.
   → Write results to dependency agents.

4. GPU: Cascade to indirect dependencies.
   → Same process for second-order connections.
   → Continue until propagation reaches weight-0 boundaries or max depth.

5. GPU: Conservation check + compensation.
   → Run parallel reduction on affected region.
   → Apply compensation if needed.

6. GPU: Write results back to unified memory.
   → Host reads results, updates visualization.

Total latency target: <16ms (60fps for smooth interaction)
```

### Addressing the Findings from Rigging Experiments

The rigging experiments identified five issues with current ternary propagation. The GPU implementation addresses each:

1. **All-or-nothing propagation:** On GPU, we can implement fractional weights by using `ternary-trit` values scaled to float32 for intermediate computation, then clamping back to ternary at the end. This gives us gradual damping without abandoning ternary semantics.

2. **Visited-bit prevents rich dynamics:** On GPU, we use atomic accumulation instead of write-once. Each agent's value is updated via `atomicAdd`, allowing ripples to revisit and interfere constructively or destructively.

3. **Energy creation:** The GPU conservation checker (Section 5) enforces energy transfer semantics. When agent A propagates to agent B, A loses what B gains. This is enforced by the post-propagation conservation pass.

4. **Dead zones from weight-0:** These become intentional firewalls on GPU. Different GPU blocks can be assigned to different "compartments," and weight-0 ropes become block boundaries that require explicit host intervention to cross.

5. **No resonance:** With fractional intermediate values (float32 during propagation, ternary after clamping), repeated oscillations at the right frequency can create constructive interference patterns. The clamp to ternary prevents unbounded growth, but interference patterns become visible.

### Real-Time Parameter Sweep

The GPU's killer feature for rigging: **simultaneous perturbation of many parameters.** Instead of shaking one parameter at a time:

1. Assign each warp a different parameter to perturb.
2. Run all perturbations in parallel.
3. Compare results across warps to find the most sensitive parameters.
4. Report back: "Perturbing parameter X affects 847 agents. Parameter Y affects 12."

This is the GPU rigging advantage: you can shake EVERY line of rigging simultaneously and see which ones connect to the most things. On CPU, this would require N sequential shakes. On GPU, it's one parallel pass.

---

## 7. SMP on GPU: Seeds Per Warp

### The Architecture

SMP seeds are compact (256 bytes - 4 KB) and deterministic. On GPU, each warp can run a different seed:

```
GPU SMP Layout:
┌──────────────────────────────────────────────┐
│  Block 0 (256 threads, 8 warps)              │
│  ├── Warp 0: Seed "cautious-analyst"         │
│  │   └── 32 agents running with this seed    │
│  ├── Warp 1: Seed "exploratory-researcher"   │
│  │   └── 32 agents running with this seed    │
│  ├── Warp 2: Seed "adversarial-critic"       │
│  │   └── 32 agents running with this seed    │
│  ├── Warp 3: Seed "game-strategist"          │
│  │   └── 32 agents running with this seed    │
│  ├── Warp 4: Seed "dungeon-master"           │
│  │   └── 32 agents running with this seed    │
│  ├── Warp 5: Seed "code-reviewer"            │
│  │   └── 32 agents running with this seed    │
│  ├── Warp 6: Seed "negotiator"               │
│  │   └── 32 agents running with this seed    │
│  └── Warp 7: Seed (custom, user-defined)     │
│      └── 32 agents running with this seed    │
│                                               │
│  Block 1: Same structure, different agents    │
│  Block 2: ...                                 │
│  Block N-1: ...                               │
│                                               │
│  Total: 8 seeds × N blocks × 32 agents       │
│  = 256N agents across 8 seed variants         │
└──────────────────────────────────────────────┘
```

### Seed Application on GPU

Each seed has three components (strategy vector, ternary weights, conservation parameters). On GPU:

1. **Strategy vector** (64-256 ternary trits): Loaded into shared memory per warp. Each thread reads its assigned trit and uses it to bias the predict phase of the tick cycle.

2. **Ternary weights** (K trits): Loaded into shared memory. Applied during the vibe phase — promote (+1) amplifies the cell's new value, suppress (-1) diminishes it, silence (0) leaves it unchanged.

3. **Conservation parameters** (8 float32): Loaded into registers per warp. Used during the conservation phase to compute the local conservation target.

The seed is loaded once per warp, shared across all 32 threads in the warp. This means seed application costs ~1μs of setup time per warp, then zero additional cost during the tick cycle.

### Tournament Elimination in Parallel

The SMP + arena combination creates a powerful GPU workflow:

1. **Round 1:** Assign 8 different seeds to 8 warps per block. Run 32 agents per warp through 100 ticks.
2. **Score:** Each warp computes its aggregate fitness (sum of all agent fitnesses).
3. **Reduce:** Block-level reduction finds the top 4 seeds.
4. **Round 2:** Top 4 seeds are assigned to 4 warps. Run another 100 ticks.
5. **Reduce:** Find top 2.
6. **Final:** Top 2 seeds, 1 warp each, 100 ticks. Winner takes all.

For 40 blocks (10,240 agents), this means 320 simultaneous first-round matches, narrowing to 160 → 80 → 40 → 20 → 10 → 5 → 3 → 1 champion seed. The entire tournament runs in ~1 second on a modern GPU.

### Seed Discovery via GPU Sweep

Beyond tournament play, the GPU can discover new seeds:

1. Generate 10,000 random seeds (ternary strategy vectors + conservation parameters).
2. Assign one seed per agent (1 warp = 32 seeds, 320 warps = 10,240 seeds).
3. Run 1000 ticks.
4. Score each seed by its agent's fitness.
5. Top 100 seeds survive. Crossover and mutate on GPU.
6. Repeat for 100 generations.
7. Result: evolved seeds that are optimized for the specific environment.

This is genetic programming on the seed space, running entirely on GPU. Each generation takes ~1ms for 10K agents × 1000 ticks. 100 generations = ~100ms. In a tenth of a second, the GPU can evolve new SMP seeds that are adapted to the current spreadsheet state.

---

## 8. Arena Tournaments on GPU

### The Tournament Kernel

The arena kernel is a specialized muscle fiber that runs one tournament match per warp:

```
Arena Kernel (per warp):
┌──────────────────────────────────────────┐
│  Thread 0: Agent A (seed "explorer")     │
│  Thread 1: Agent B (seed "marksman")     │
│  Thread 2: Environment state             │
│  Thread 3: Score keeper                  │
│  Thread 4-31: Shared computation         │
│                                           │
│  Loop:                                    │
│    1. Each agent predicts opponent's move │
│    2. Both agents choose action           │
│    3. Environment resolves interactions   │
│    4. Score keeper updates fitness        │
│    5. Conservation check (in-warp)        │
│    6. Repeat for N rounds                 │
│                                           │
│  Output: winner, scores, strategy trace   │
└──────────────────────────────────────────┘
```

### Arena Grid Layout

For a large-scale tournament:

- **SM allocation:** Each SM on the GPU runs 1-4 tournament blocks simultaneously.
- **Block = bracket:** Each block runs an 8-agent elimination bracket.
- **Grid = tournament:** The full grid runs hundreds of brackets in parallel.
- **Results aggregation:** After each round, surviving agents are redistributed to new blocks for the next round.

On an NVIDIA RTX 4090 (128 SMs, 16K threads), we can run:
- 128 blocks × 8 warps/block × 1 match/warp = **1,024 simultaneous matches**
- Each match: 100 rounds × 6 phases × ~100μs = ~60ms
- Full tournament (1,024 matches → 512 → 256 → 128 → 64 → 32 → 16 → 8 → 4 → 2 → 1): ~600ms

**Sub-second tournament resolution for 2,048 competing strategies.**

### Arena + Ecosystem Integration

The arena isn't just strategy vs. strategy. It's ecosystem vs. ecosystem:

1. Each warp runs a mini-ecosystem (32 agents from `ternary-ecosystem`'s 5 species).
2. Ecosystems compete for shared resources (enforced by conservation).
3. The ecosystem with better internal balance (higher aggregate fitness) wins.
4. Winning ecosystems' genetic material propagates to the next round.

This is coevolution at ecosystem scale, running at GPU speed.

---

## 9. The Rust → Unified Memory → CUDA Bridge

### The Data Flow

The bridge between Rust ternary crates and CUDA kernels has three stages:

#### Stage 1: Rust → Unified Memory (CPU Side)

```rust
// In cudaclaw's dispatcher, extended for ternary:

pub fn dispatch_ternary_tick(&mut self, agents: &[TernaryCell]) -> Result<(), CudaClawError> {
    // 1. Serialize agent state to GPU-compatible format
    let gpu_agents: Vec<GpuTernaryCell> = agents.iter()
        .map(|a| a.to_gpu_repr())  // AoS → SoA fields
        .collect();

    // 2. Copy to unified memory (zero-copy on unified memory systems)
    unsafe {
        cudaMemcpy(
            self.agent_buffer,                              // GPU pointer
            gpu_agents.as_ptr() as *const c_void,          // CPU pointer
            gpu_agents.len() * mem::size_of::<GpuTernaryCell>(),
            cudaMemcpyKind::cudaMemcpyHostToDevice,
        );
    }

    // 3. Enqueue tick command
    self.enqueue_command(CudaCommand::TickCycle {
        agent_count: agents.len(),
        fiber: MuscleFiber::CellUpdate,
        conservation_mode: ConservationMode::Enforce,
    })?;

    Ok(())
}
```

#### Stage 2: Command Processing (GPU Side)

```cuda
// In executor.cu, extended for ternary commands:

__global__ void persistent_executor(
    CommandQueue* queue,
    GpuTernaryCell* agents,        // SoA layout in unified memory
    ConservationState* cons_state,  // γ, H, V arrays
    RiggingBuffer* rigging,         // Perturbation buffer
    ArenaScoreboard* arena,         // Tournament state
    SmpSeedBank* seeds              // Seed library
) {
    // Persistent kernel loop (already exists in CudaClaw)
    while (true) {
        Command cmd = queue->dequeue();  // Lock-free SPSC

        switch (cmd.type) {
            case CMD_TICK_CYCLE:
                execute_tick_cycle(agents, cmd.agent_count, cmd.fiber);
                break;
            case CMD_CONSERVATION_CHECK:
                execute_conservation_check(agents, cons_state, cmd.agent_count);
                break;
            case CMD_RIGGING_PROPAGATE:
                execute_rigging_propagate(agents, rigging, cmd.source_agent);
                break;
            case CMD_ARENA_MATCH:
                execute_arena_match(agents, arena, seeds, cmd.match_config);
                break;
            case CMD_SMP_APPLY:
                execute_smp_apply(agents, seeds, cmd.seed_id);
                break;
        }
    }
}
```

#### Stage 3: Results → Rust (Read Back)

```rust
// Read results from unified memory
pub fn read_ternary_results(&self) -> Result<Vec<TernaryCellState>, CudaClawError> {
    let mut results = vec![TernaryCellState::default(); self.agent_count];

    unsafe {
        cudaMemcpy(
            results.as_mut_ptr() as *mut c_void,    // CPU destination
            self.result_buffer,                       // GPU source
            results.len() * mem::size_of::<TernaryCellState>(),
            cudaMemcpyKind::cudaMemcpyDeviceToHost,
        );
    }

    Ok(results)
}
```

### The GpuTernaryCell Representation

The key to performance is the memory layout. Rust's `TernaryCell` is AoS (Array of Structures). GPU kernels need SoA (Structure of Arrays) for coalesced access:

```rust
#[repr(C)]
pub struct GpuTernaryCell {
    // Core state (48 bytes — fits in warp-level access)
    pub value: f32,           // Current ternary value (-1.0, 0.0, +1.0)
    pub energy: f32,          // Cell energy level
    pub fitness: f32,         // Current fitness score
    pub surprise: f32,        // Prediction error
    pub gamma: f32,           // Avoidance ratio (conservation)
    pub entropy: f32,         // Local entropy (conservation)
    pub species: u8,          // Strategy species (0-4)
    pub phase: u8,            // Current tick phase (0-5)
    pub seed_id: u16,         // SMP seed assignment
    pub connections: u16,     // Number of graph edges
    pub age: u32,             // Ticks alive
    pub _padding: [u8; 8],    // Align to 48 bytes
}
```

On GPU, the dispatcher converts from AoS to SoA using CudaClaw's existing `muscle_fiber.rs` patterns. Each field gets its own array in unified memory, ensuring coalesced reads during the tick cycle.

### Latency Budget

For 60fps rigging interaction:

| Stage | Operation | Latency |
|---|---|---|
| Host → UM | Write perturbation to buffer | <1μs (unified memory) |
| UM → GPU | Persistent kernel reads command | <5μs (SPSC dequeue) |
| GPU Compute | Tick cycle for 10K agents | ~100μs (400K ops/s) |
| GPU Compute | Conservation check | ~2μs (parallel reduction) |
| GPU Compute | Rigging propagation | ~10μs (parallel BFS) |
| GPU → UM | Write results | <1μs (unified memory) |
| UM → Host | Read results | <1μs (unified memory) |
| Host | Visualization update | ~5ms (rendering) |
| **Total** | | **~5.2ms — well within 16ms frame budget** |

Even with conservative estimates, the full pipeline fits comfortably within 16ms. The GPU computation itself takes ~120μs — the bottleneck is the visualization rendering on the host side.

---

## 10. Performance Estimates

### Per-Operation Performance

| Operation | Agents | GPU Time | CPU Time (est.) | Speedup |
|---|---|---|---|---|
| Tick cycle (full 6-phase) | 10,000 | 100μs | 10ms | 100× |
| Conservation check | 10,000 | 2μs | 500μs | 250× |
| Rigging propagation (1 shake) | 10,000 | 10μs | 1ms | 100× |
| SMP seed application | 10,000 | 5μs | 200μs | 40× |
| Fitness evaluation | 10,000 | 20μs | 2ms | 100× |
| Evolution step (crossover + mutation) | 10,000 | 50μs | 5ms | 100× |
| Arena tournament (1024 matches) | 2,048 | 600ms | 60s | 100× |
| Seed sweep (10K random seeds, 100 ticks each) | 10,000 | 10ms | 1s | 100× |
| Ecosystem tick (Lotka-Volterra) | 10,000 | 30μs | 3ms | 100× |
| Dice roll (10K agents) | 10,000 | 1μs | 100μs | 100× |
| Parameter sweep (256 params) | 10,000 | 200μs | 50ms | 250× |

### Aggregate Performance

For the full SMP spreadsheet workload (tick + conservation + rigging + visualization):

- **10,000 agents, 60fps interaction:** ~120μs GPU compute + ~5ms host rendering = **5.1ms per frame**. Leaves 10.9ms headroom.
- **50,000 agents, 30fps interaction:** ~600μs GPU compute + ~8ms host rendering = **8.6ms per frame**. Leaves 24.7ms headroom.
- **100,000 agents, 15fps background simulation:** ~1.2ms GPU compute + ~10ms host rendering = **11.2ms per frame**. Feasible for non-interactive workloads.

### Hardware Requirements

| Configuration | Agents | FPS | GPU | RAM |
|---|---|---|---|---|
| **Minimum** | 1,000 | 30 | GTX 1660 (6GB) | 4GB unified |
| **Recommended** | 10,000 | 60 | RTX 3060 (12GB) | 8GB unified |
| **High-end** | 50,000 | 30 | RTX 4070 (12GB) | 16GB unified |
| **Research** | 100,000 | 15 | RTX 4090 (24GB) | 32GB unified |

---

## 11. Implementation Roadmap

### Phase 1: Core Bridge (Weeks 1-4)

- Implement `GpuTernaryCell` struct and SoA conversion
- Extend CudaClaw's command queue with ternary commands
- Write CUDA kernels for tick cycle and conservation check
- Test with 1,000 agents on dev hardware

### Phase 2: Rigging + SMP (Weeks 5-8)

- Implement parallel BFS for rigging propagation
- Add atomic accumulation for interference patterns
- Implement per-warp seed assignment
- Test rigging interaction at 30fps with 5,000 agents

### Phase 3: Arena + Evolution (Weeks 9-12)

- Implement tournament kernel (1 match/warp)
- Implement parallel evolution step (fitness + crossover + mutation)
- Implement seed sweep (10K random seeds, tournament elimination)
- Test full tournament pipeline

### Phase 4: Integration + Optimization (Weeks 13-16)

- Connect to `superinstance-spreadsheet` for visualization
- Connect to `ai-pasture` for game mechanics
- Connect to `open-vectors` for seed storage
- ML feedback loop for automatic fiber optimization
- Performance benchmarking and DNA generation

### Phase 5: Product (Weeks 17-20)

- Package as reusable library (`cudaclaw-ternary-bridge`)
- Write `.claw-dna` templates for common ternary workloads
- Documentation, examples, and demos
- Integration with the Living Spreadsheet

---

*— Synthesis Agent*
*June 2026*
