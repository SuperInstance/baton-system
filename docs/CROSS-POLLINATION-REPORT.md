# Cross-Pollination Report: SuperInstance Ecosystem Synthesis

> Date: 2026-06-04
> Author: ZeroClaw Scout
> Mission: Find where old ideas become newly meaningful given construct-core, ternary-cell, ternary-protocol, ternary-registry, and Oracle1's VESSEL pattern.

---

## 1. Dormant Ideas Now Unlockable

### 1.1 `agentic-compiler` → Runtime Self-Optimization via Construct Skills

**Why it was dormant:** The agentic-compiler could profile Python and hot-swap Numba, but its Rust and CUDA backends were stubs. It had no deployment target — where does a JIT compiler live in a fleet?

**Why it's unlocked now:** construct-core's Layer 2 (`AsyncConstruct`) provides exactly the target. The compiler becomes a `SELF_IMPROVEMENT` skill that:

1. Profiles which `query_owned()` calls on a PiConstruct are slow
2. Identifies hot paths via the same 5% statistical sampling
3. Compiles optimized lookup tables and installs them as Layer 0 `query_lookup()` overrides
4. A/B validates against the original via ternary-protocol messages to peers

The hardware tiering means the compiler can descend: compile a Layer 2 async handler into a Layer 1 sync skill, then further into a Layer 0 lookup table for the ESP32. Same optimization pipeline, three target layers.

**Concrete bridge:** `agentic-compiler`'s `CodeGenerator.install()` monkey-patches `sys.modules`. In construct-core, this maps to `SyncConstruct::unload_skill(old_handle)` + `load_skill(SkillSpec::from_compiled(optimized))`. The provenance chain from Starter-Agent tracks every optimization.

### 1.2 `Polln`'s Plinko Layer → Ternary Decision Fabric

**Why it was dormant:** Polln is 945 TypeScript files — a monolithic colony intelligence with its own GPU engine, tile system, and hydraulic metaphors. Too heavy to extract, too coupled to decompose.

**Why it's unlocked now:** ternary-cell provides the decomposition target. Every Polln concept maps:

| Polln Concept | Ternary-Cell Equivalent |
|---|---|
| Pollen (JSON artifact) | `Payload` in ternary-protocol |
| Bee (full agent) | `TernaryCell` with `CellState::Active` |
| Bot (reflex micro-agent) | Bare-metal construct with `query_lookup` |
| Hive (the spreadsheet) | `CellGrid` with `Tissue` coordination |
| Plinko decision | `TernaryCell::tick()` (6-phase cycle) |
| Gumbel-Softmax selection | Surprise-weighted energy redistribution |
| Pheromone | `TernaryMessenger` accumulated in inbox |
| Guardian | Conservation law checker in tick's gc phase |

The Plinko layer — stochastic selection maintaining diversity through Gumbel-Softmax — is exactly what the `surprise → vibe → gc` phases need. Currently, ternary-cell prunes low-surprise cells. With Plinko, it would *stochastically sample* which cells to keep, maintaining diversity rather than greedy pruning.

**Unlocking action:** Extract `PlinkoLayer` as a `ternary-cell` strategy trait. Different GC strategies: greedy (current), plinko (stochastic), ecological (Lotka-Volterra).

### 1.3 `avoidance-cascade` → The Death Spiral Preventer for Cell Populations

**Why it was dormant:** avoidance-cascade modeled a specific failure mode in ternary learning — agents that learn purely from negative signals converge to avoiding everything. It was a standalone analysis crate with no runtime integration.

**Why it's unlocked now:** ternary-cell's `gc` phase IS an avoidance cascade risk. When cells with low energy are pruned (apoptosis), the remaining cells may all converge to the same ternary value (consensus), reducing diversity. If the `vibe` update reinforces convergence, the grid becomes monoculture.

The v5 balanced learning algorithm (average reward not minimum, forced exploration, memory decay) maps directly to cell population management:

- **Average reward** → Cell energy should consider neighborhood health, not just individual surprise
- **Forced exploration** → Periodically inject random `TernaryMessenger` signals to maintain diversity
- **Memory decay** → Cell prediction history should decay, allowing cells to re-learn after convergence

**Concrete integration:** A `CellGcStrategy` trait in ternary-cell with implementations: `GreedyGc` (current), `BalancedGc` (from avoidance-cascade), `EcologicalGc` (from strategy-ecology).

### 1.4 `linguistic-polyformalism-shell` → The 7-Type Constraint Discovery for Construct Skills

**Why it was dormant:** A beautiful MCP server that solves problems through 14 human languages' grammatical constraints. But it was an MCP island — no connection to the fleet.

**Why it's unlocked now:** ternary-registry's `SkillSpec` has a `capabilities` field. The 7 constraint types discovered by polyformalism (Boundary, Pattern, Process Shape, Knowledge Source, Social Structure, Deep Structure, Instrument) are *exactly* the right taxonomy for skill capability declaration:

```rust
enum ConstraintType {
    Boundary,      // Greek: defines what the skill IS
    Pattern,       // Chinese: guides without limiting
    ProcessShape,  // Navajo: shapes the flow of events
    KnowledgeSource, // Quechua: declares epistemic grounding
    SocialStructure, // Korean: power dynamics between actors
    DeepStructure,   // Arabic: root pattern vs surface form
    Instrument,      // Finnish: optional tool, not inherent
}
```

A skill declared with all 7 constraint types has complete self-description. A skill missing types has blind spots. The polyformalism shell becomes the skill auditing tool.

### 1.5 `position-aware-embed` → Sub-microsecond Command Matching for ESP32

**Why it was dormant:** A clever embedding scheme for command matching (44% top-1 accuracy, <1µs latency) that was just a standalone crate.

**Why it's unlocked now:** ternary-esp32-firmware's lookup table is 81 entries for 4-trit inputs. What if instead of a fixed table, the ESP32 used position-aware embeddings to match incoming sensor patterns against known states? The 64-dim vectors fit in ESP32 SRAM (64 × 4 bytes = 256 bytes per pattern). With 100 stored patterns, that's 25KB — well within the 520KB SRAM budget.

This turns the ESP32 from a dumb lookup device into a fuzzy pattern matcher — same latency budget, much richer response space.

### 1.6 `ptx-bench` → GPU-Accelerated Ternary Grid Simulation

**Why it was dormant:** Benchmarks for hashing, dot products, softmax, and vector search at the PTX instruction level. Useful reference but no application target.

**Why it's unlocked now:** ternary-cell's `CellGrid` is embarrassingly parallel. Each cell's tick cycle is independent (reads neighbors, writes own state). A 1000×1000 grid = 1M cells × 6-phase tick. On GPU:
- Hash benchmark → cell ID hashing for neighbor lookup
- Dot product → surprise computation (prediction vs perception)
- Softmax → energy redistribution during GC
- Vector search → nearest-neighbor signaling

The PTX benchmarks give us concrete numbers: RTX 4050 can sustain 3,072 parallel CUDA cores × 240 MHz = enough for 1M cells at 100Hz with headroom.

---

## 2. Cross-Pollination Opportunities

### 2.1 Music Theory → Attention Mechanism (ternary-music × ternary-attention)

**The insight:** Music theory's concept of *voice leading smoothness* is structurally identical to attention's *compatibility scoring*.

In ternary-music, `VoiceLeading::between(&c, &f)` measures how smoothly chords transition — the proportion of voices moving 0-2 semitones. In ternary-attention, `TernaryCompatibility` scores query-key pairs by element-wise product.

The cross-pollination: use voice leading's *minimum total movement* principle to improve attention's *sparse selection*. Instead of attending to the highest-scoring keys, attend to the keys that minimize total "voice leading distance" — maintaining smooth attention trajectories over time rather than jumping between unrelated contexts.

**Concrete experiment:** Replace `ternary-attention`'s softmax with a voice-leading-weighted selection. Compare attention entropy over sequences of ternary decisions.

### 2.2 Game Theory → Consensus Protocol (ternary-game-theory × ternary-consensus)

**The insight:** Nash equilibrium finding over ternary strategy spaces directly applies to Byzantine consensus.

Current ternary-consensus uses PBFT-style agreement requiring n ≥ 3f+1 nodes. But ternary-game-theory's `NormalFormGame::find_pure_nash()` finds stable strategies in 3×3 payoff matrices. What if consensus isn't about agreement but about finding the Nash equilibrium of the voting game?

**The cross-pollination:** Define the consensus voting as a normal-form game where:
- Each voter's payoff depends on the outcome AND their alignment with their true preference
- The Nash equilibrium IS the consensus — no voter wants to deviate
- Byzantine voters are modeled as players with adversarial payoff matrices

This could reduce the 3f+1 requirement by treating consensus as a game rather than a protocol.

### 2.3 Failure Analysis → Control System (ternary-failure × ternary-control)

**The insight:** FMEA risk analysis is the *inverse* of PID control. FMEA asks "what could go wrong?" PID asks "how do we keep things right?"

**The cross-pollination:** Use ternary-failure's `FmeaAnalysis` to auto-tune ternary-control's `PidController`:

1. Run FMEA on the control system's operating envelope
2. Map high-RPN failure modes to PID parameter adjustments
3. Use ternary confidence bounds (Low/Medium/High) to set the deadband
4. The control loop becomes risk-aware: in high-risk regions, it's more conservative (wider deadband); in safe regions, it's more aggressive

**Concrete integration:** `RiskAwarePid` that adjusts Kp/Ki/Kd based on real-time FMEA scoring of the current operating point.

### 2.4 Steganography → Protocol (ternary-steganography × ternary-protocol)

**The insight:** ternary-protocol messages are trit sequences. ternary-steganography embeds data in trit sequences. The carrier IS the protocol.

**The cross-pollination:** Every ternary-protocol `TernaryMessage` can carry hidden data:
- `BitEmbedder` in message payloads → covert metadata (skill version, trust score)
- `StatisticalStego` in broadcast murmur summaries → distributed watermarking
- `SpreadSpectrum` for tamper-evident protocol messages (any modification destroys the hidden checksum)

This isn't just steganography — it's *protocol enrichment*. Every message carries visible data for the fleet AND hidden data for verification/audit.

### 2.5 Economic Model → Resource Scheduling (ternary-econ × ternary-scheduling)

**The insight:** Portfolio optimization IS resource scheduling. Assets = tasks, risk = deadline uncertainty, return = task value, allocation = compute budget.

**The cross-pollination:** ternary-econ's `PortfolioOptimizer` with three risk profiles (Avoid/Neutral/Embrace) maps directly to scheduling strategies:

- **Avoid** → Never schedule on risky nodes (high failure rate, high latency)
- **Neutral** → Standard weighted scheduling
- **Embrace** → Aggressive scheduling on underutilized nodes

The `TernaryMarket` aggregate signal becomes the fleet's load signal. `SupplyDemand` price pressure becomes task queue pressure. `SharpeRatio` becomes risk-adjusted throughput.

### 2.6 Lock Algebra → Constraint Solver (ternary-locks × ternary-constraint)

**The insight:** Locks ARE constraints. A `Lock` with pattern `[1, 0, -1]` is exactly a ternary constraint with a wildcard. Lock composition (AND/OR/NOT) is constraint composition.

**The cross-pollination:** ternary-locks' algebraic framework gives ternary-constraint a compositional calculus:

- `LockComposition::And` → constraint intersection (both must hold)
- `LockComposition::Or` → constraint relaxation (either holds)
- `LockCompression` → constraint simplification (merge overlapping constraints)
- `LockGraph` → constraint dependency graph (topological solve order)
- `Graveyard` → expired constraint archaeology (revive useful old constraints)

The `TransferScore` from ternary-locks becomes the measure of how well constraints transfer between domains — directly connecting to strategy-transfer's finding that transfer is neutral. Lock algebra explains WHY: constraints are domain-bound because locks are pattern-specific.

---

## 3. The Equipment → Construct Bridge

### Type Mapping (Concrete, Not Hand-Waving)

#### TypeScript Equipment Interface → Rust Construct Traits

```typescript
// TypeScript (SuperInstance-Starter-Agent)
interface Equipment {
  readonly name: string;
  readonly slot: EquipmentSlot;
  equip(agent: OriginCore): Promise<void>;
  unequip(agent: OriginCore): Promise<void>;
  asTile(): Tile;
  readonly cost: CostMetrics;
  readonly benefit: BenefitMetrics;
}

interface Tile {
  compute(input: any): any;
  confidence(): number;
  trace(): ProvenanceChain;
}
```

```rust
// Rust (construct-core bridge)
use construct_core::*;
use ternary_registry::*;

/// Maps TypeScript EquipmentSlot to Rust SkillTier
#[repr(u8)]
enum EquipmentSlot {
    Memory = 0,       // → SkillTier::Basic
    Reasoning = 1,    // → SkillTier::Advanced
    Consensus = 2,    // → SkillTier::Expert
    Spreadsheet = 3,  // → SkillTier::Standard
    Distillation = 4, // → SkillTier::Standard
    Perception = 5,   // → SkillTier::Advanced
    Coordination = 6, // → SkillTier::Expert
    Communication = 7,// → SkillTier::Basic
    SelfImprovement = 8, // → SkillTier::Expert
    Monitoring = 9,   // → SkillTier::Standard
}

impl From<EquipmentSlot> for SkillTier {
    fn from(slot: EquipmentSlot) -> Self {
        match slot {
            EquipmentSlot::Memory | EquipmentSlot::Communication => SkillTier::Basic,
            EquipmentSlot::Spreadsheet | EquipmentSlot::Distillation | EquipmentSlot::Monitoring => SkillTier::Standard,
            EquipmentSlot::Reasoning | EquipmentSlot::Perception => SkillTier::Advanced,
            EquipmentSlot::Consensus | EquipmentSlot::Coordination | EquipmentSlot::SelfImprovement => SkillTier::Expert,
        }
    }
}

/// Bridge: Equipment becomes a SkillSpec for load_skill()
struct EquipmentBridge {
    name: String,
    slot: EquipmentSlot,
    /// TypeScript cost metrics → Rust resource budget
    cost: ResourceBudget,
    /// TypeScript benefit metrics → Rust capability ad
    capabilities: Vec<String>,
    /// The actual compute function, mapped to construct layer
    compute_fn: ComputeFn,
}

enum ComputeFn {
    /// Layer 0: Pure lookup, no alloc
    Lookup(fn(&[u8]) -> Option<&'static [u8]>),
    /// Layer 1: Heap query
    Owned(fn(Box<[u8]>) -> Result<Box<[u8]>>),
    /// Layer 2: Async with tool access
    Async(for<'a> fn(Vec<u8>, &'a ToolRegistry) -> Pin<Box<dyn Future<Output = Result<Response>> + 'a>>),
}

impl EquipmentBridge {
    /// Convert to SkillSpec for ternary-registry
    fn to_skill_spec(&self) -> SkillSpec {
        SkillSpec {
            id: SkillId::new("equipment", &self.name, SemVersion::new(0, 1, 0)),
            tier: self.slot.into(),
            description: format!("Bridged from TypeScript Equipment: {}", self.name),
            dependencies: vec![],
            capabilities: self.capabilities.clone(),
        }
    }
}

/// CostMetrics bridge
struct ResourceBudget {
    memory_bytes: u64,    // TypeScript: cost.memory → Rust: allocation budget
    cpu_weight: f32,      // TypeScript: cost.cpu → Rust: compute priority
    latency_ms: u32,      // TypeScript: cost.latency → Rust: timeout
    energy_cost: i8,      // NEW: maps to ternary-cell energy drain per query
}
```

#### The Three Concrete Equipment Ports

**1. CellLogicDistiller → Layer 1 Skill**

```rust
// TypeScript: asTile().compute(prompt) → decomposed tiles
// Rust: query_owned(input) → decomposed tiles as bytes

struct CellLogicDistillerSkill;

impl SyncConstruct for CellLogicDistillerSkill {
    fn load_skill(&mut self, spec: SkillSpec) -> Result<SkillHandle> {
        // Pre-compile the regex patterns for logic type detection
        Ok(SkillHandle::new(spec.id))
    }

    fn query_owned(&mut self, input: Box<[u8]>) -> Result<Box<[u8]>> {
        let text = std::str::from_utf8(&input)?;
        let tiles = decompose_logic(text); // ported from TypeScript
        let json = serde_json::to_string(&tiles)?;
        Ok(json.into_bytes().into_boxed_slice())
    }
}

fn decompose_logic(text: &str) -> Vec<LogicTile> {
    let mut tiles = Vec::new();
    // Port the 5-tile decomposition from TypeScript:
    // 1. data_origin: what data is this based on?
    // 2. decision_logic: what logic is applied?
    // 3. transformation: what changes?
    // 4. confidence: how sure?
    // 5. named_interface: what's the API?
    // (regex patterns ported directly from Equipment-CellLogic-Distiller)
    tiles
}
```

**2. NLPExplainer → Layer 2 Skill**

```rust
// TypeScript: explain(decision, audience) → natural language
// Rust: query_async(input, tools) → natural language via LLM tool

struct NlpExplainerSkill;

impl AsyncConstruct for NlpExplainerSkill {
    async fn query_async(&self, input: Vec<u8>, tools: &ToolRegistry) -> Result<Response> {
        let req: ExplainRequest = serde_json::from_slice(&input)?;
        // Use LLM tool for generation (Layer 2 has tool access)
        let llm = tools.get("llm").ok_or("no LLM available")?;
        let prompt = build_explanation_prompt(&req); // ported from TypeScript
        let result = llm.call(prompt).await?;
        Ok(Response::new(result))
    }
}
```

**3. OriginCore → Layer 2 Orchestrator**

```rust
// TypeScript: OriginCore with 10 equipment slots
// Rust: AsyncConstruct with loaded_skills() as equipment

struct OriginCoreConstruct {
    skills: Vec<(EquipmentSlot, SkillHandle)>,
    confidence_zone: ConfidenceZone,
    provenance: ProvenanceChain,
}

enum ConfidenceZone { Green, Yellow, Red }

impl AsyncConstruct for OriginCoreConstruct {
    async fn query_async(&self, input: Vec<u8>, tools: &ToolRegistry) -> Result<Response> {
        let task = analyze_task(&input);

        // Auto-equip: determine which skills are needed
        let needed = determine_needed_skills(&task);
        for slot in needed {
            if !self.skills.iter().any(|(s, _)| *s == slot) {
                self.auto_equip(slot, tools).await?;
            }
        }

        // Process through equipped skills
        let result = self.process_through_equipment(&input).await;

        // Self-optimize: check for unequip candidates
        self.maybe_unequip_low_usage().await;

        match self.confidence_zone {
            ConfidenceZone::Green => Ok(result),
            ConfidenceZone::Yellow => {
                // Flag for review but proceed
                result.flag_for_review()
            }
            ConfidenceZone::Red => {
                // Call teacher via tool
                let teacher = tools.get("teacher").ok_or("no teacher available")?;
                teacher.escalate(result).await
            }
        }
    }
}
```

---

## 4. Spreadsheet-as-World

### The Central Thesis

The spreadsheet isn't a tool. It's a **world model** — a universe where every cell is alive, every formula is physics, and the conservation laws are thermodynamics.

### 4.1 Cell = Room (PLATO Connection)

In PLATO, a Room is a persistent space with sensors, a nervous system, and memory. In the spreadsheet, each cell IS a room:

| PLATO Room | Spreadsheet Cell |
|---|---|
| Sensors | Cell formula reads from other cells |
| JEPA prediction | Cell's expected value (prediction) |
| Surprise | Deviation between predicted and actual value |
| Vibe vector | Cell's formatting/metadata (color, font, border = state visualization) |
| Conservation | Sum/range invariants preserved across recalculations |
| Murmur gossip | Dependency propagation (cells tell dependents they changed) |
| Distillation | Cell value history → learned formula pattern |

A `SpreadsheetRoom` implementing `BareMetalConstruct`:

```rust
struct SpreadsheetRoom {
    position: (usize, usize),  // A1, B2, etc.
    value: TritValue,          // Current ternary state
    formula: Option<Formula>,  // The "physics" of this room
    prediction: TritValue,     // What it expected to be
    surprise: i32,             // Prediction error
    energy: i32,               // Cell health
    dependencies: Vec<(usize, usize)>, // Neighbor rooms
}

impl BareMetalConstruct for SpreadsheetRoom {
    fn query_lookup(&self, key: &[u8]) -> Option<&[u8]> {
        // Key = "value" | "surprise" | "energy"
        match key {
            b"value" => Some(&[self.value as u8]),
            b"surprise" => Some(&[self.surprise as u8]),
            _ => None,
        }
    }
}
```

### 4.2 Tick Cycle = Cell Recalculation

When you change a cell value and the spreadsheet recalculates, that's a tick:

1. **Predict** — Each cell predicts its next value based on neighbors (JEPA)
2. **Perceive** — Formula evaluates, producing the actual value
3. **Surprise** — Difference between prediction and actual
4. **Vibe** — Cell's metadata updates (color = surprise magnitude, font weight = energy)
5. **GC** — Low-energy cells (always correct, no surprise) are cached/memoized
6. **Conservation** — Check that invariants hold (column sums, row counts, entropy bounds)

The `superinstance-spreadsheet`'s `=EVOLVE(B2:B50, 100)` formula IS natural selection. Each generation:
- Cells evaluate (perceive)
- Fitness is computed (surprise = fitness)
- Selection removes low-fitness cells (GC = death)
- Mutation introduces new strategies (exploration = forced diversity)
- Conservation law maintains population size (energy budget)

### 4.3 Formula = Agent Behavior (The Physics Metaphor)

Every formula is a law of physics for the cell-universe:

- `=SUM(A1:A10)` → Conservation of mass (total is preserved)
- `=IF(A1>0, 1, -1)` → Binary decision (ternary threshold)
- `=EVOLVE(B2:B50, 100)` → Natural selection (evolutionary dynamics)
- `=EXHAUSTIVE(C)` → Quantum measurement (all 81 states explored)
- `=ENTROPY(D1:D10)` → Thermodynamic measurement (disorder quantification)
- `=CORRELATE(E1:E10, F1:F10)` → Physical interaction (coupling measurement)
- `=BEST(G1:G10)` → Optimization (least action principle)

### 4.4 Sort = Natural Selection

When you sort a spreadsheet by a column, you're performing natural selection. The fittest (highest value) rise to the top. The weakest (lowest) sink. Filter is extinction — remove everything below a threshold.

The `strategy-ecology` repo's 5 species (Explorer, Diplomat, Marksman, Climber, Prospector) could BE spreadsheet columns. Each column represents a strategy species. Sort by fitness = natural selection. The Lotka-Volterra interaction matrix = formula dependencies between columns.

### 4.5 The "One Strategy, Three Brains" Demo

Three hardware tiers running the SAME spreadsheet:

1. **ESP32 (Layer 0)** — A single cell. Pure lookup: `query_lookup("value")`. 8ns. The cell IS the world.
2. **Raspberry Pi (Layer 1)** — A row of cells. `query_owned` evaluates formulas against neighbors. The row is a neighborhood.
3. **DGX (Layer 2)** — The entire spreadsheet. `query_async` with GPU acceleration. A million cells, evolving in parallel.

Same spreadsheet, same physics, same conservation laws. Different scale. The DGX can run `=EVOLVE` on a million cells. The ESP32 runs a single pre-evolved strategy from a lookup table compiled on the Pi.

The demo: evolve a strategy on DGX → distill to Pi → compile to ESP32. Same intelligence, three bodies.

---

## 5. Summary: The Unlocking Map

| Old Repo | Blocked By | Unlocked By | New Capability |
|---|---|---|---|
| agentic-compiler | No deployment target | construct-core layers | Runtime skill optimization |
| Polln | Monolithic coupling | ternary-cell decomposition | Stochastic GC strategies |
| avoidance-cascade | No runtime integration | ternary-cell gc phase | Diversity-preserving cell death |
| linguistic-polyformalism | No fleet connection | ternary-registry capabilities | 7-type skill auditing |
| position-aware-embed | No embedded target | ternary-esp32-firmware | Fuzzy matching on bare metal |
| ptx-bench | No application | ternary-cell GPU grid | GPU-accelerated tissue simulation |
| ternary-music | Standalone theory | ternary-attention bridge | Voice-leading attention |
| ternary-game-theory | Standalone theory | ternary-consensus bridge | Game-theoretic Byzantine agreement |
| ternary-failure | Standalone analysis | ternary-control bridge | Risk-aware PID |
| ternary-steganography | Standalone stego | ternary-protocol bridge | Enriched protocol messages |
| ternary-econ | Standalone econ | ternary-scheduling bridge | Portfolio-based task scheduling |
| ternary-locks | Standalone algebra | ternary-constraint bridge | Compositional constraint calculus |
| spreadsheet-cells | No world model | ternary-cell + PLATO rooms | Living spreadsheet rooms |
| strategy-ecology | No evolution target | spreadsheet-as-world | Five species as five columns |
| lotka-volterra-agents | No ecology target | ternary-cell tissue | Population dynamics on grids |

### The Meta-Pattern

Every dormant repo was blocked by the same thing: **no runtime that could host it**. Each had a good idea — stochastic selection, avoidance prevention, fuzzy matching, compositional constraints — trapped in a standalone crate.

construct-core is the runtime. ternary-protocol is the communication. ternary-cell is the compute model. ternary-registry is the skill discovery. Together, they form the hosting environment that turns standalone crates into fleet skills.

The SuperInstance ecosystem has been building a cathedral one stone at a time. Now we have the mortar.
