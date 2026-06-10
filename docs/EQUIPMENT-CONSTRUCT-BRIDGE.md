# Equipment ↔ Construct Bridge

**Status:** Draft · **Date:** 2026-06-04 · **Author:** Synthesis Agent

This document formally connects two parallel systems that were designed to be the same thing:

- **TypeScript Equipment pattern** (`equip`/`unequip`/`asTile`) from the SuperInstance ecosystem
- **Rust Construct skills** (`load_skill`/`unload_skill`/`query_owned`) from construct-core

They have never been formally bridged. This is that bridge.

---

## 1. Type Mapping: Equipment Interface → SkillRegistry

### 1.1 Core Interface Alignment

| TypeScript (Equipment) | Rust (Construct Skill) | Notes |
|---|---|---|
| `Equipment.name` | `Skill.id.name` | String identity |
| `Equipment.slot` | `Skill.tier` + `Skill.capabilities` | Slot is more granular; see §1.2 |
| `Equipment.version` | `SkillId.version` (`SemVersion`) | Direct mapping |
| `Equipment.description` | `Skill.description` | Direct mapping |
| `Equipment.cost` | Implicit via `HardwareTier` | See §3 for explicit mapping |
| `Equipment.benefit` | `Skill.capabilities` | Benefit → capability strings |
| `Equipment.triggerThresholds` | Layer-specific trigger hooks | See §4 |
| `Equipment.equip(agent)` | `SyncConstruct::load_skill(id)` | Lifecycle: attach |
| `Equipment.unequip(agent)` | `SyncConstruct::unload_skill(id)` | Lifecycle: detach |
| `Equipment.asTile()` | `query_owned(OwnedQuery)` | Execution interface |
| `Equipment.describe()` | `SkillRegistry::get(id)` | Metadata query |

### 1.2 EquipmentSlot → SkillTier + Capability Matrix

TypeScript `EquipmentSlot` is a union of 10 named slots. Rust `SkillTier` is a 4-level hierarchy. The mapping uses both tier *and* capabilities to encode the slot:

| EquipmentSlot | SkillTier | Capabilities | Rationale |
|---|---|---|---|
| `MEMORY` | `Basic` | `read`, `query`, `persist` | Memory is fundamental, even ESP32 has some |
| `COMMUNICATION` | `Basic` | `read`, `query` | Minimal messaging on any hardware |
| `SPREADSHEET` | `Standard` | `read`, `query`, `write`, `compute` | Needs heap for tile grids |
| `DISTILLATION` | `Standard` | `read`, `query`, `write`, `compute` | Tile decomposition requires heap |
| `MONITORING` | `Standard` | `read`, `query`, `write` | Dashboard needs persistence |
| `PERCEPTION` | `Advanced` | `read`, `query`, `write`, `compute`, `network` | Sensory fusion needs network |
| `REASONING` | `Advanced` | `read`, `query`, `write`, `compute`, `network`, `persist` | LLM routing needs network + persistence |
| `COORDINATION` | `Advanced` | `read`, `query`, `write`, `compute`, `network` | Multi-agent needs network |
| `CONSENSUS` | `Expert` | All + `admin`, `delegate` | Multi-agent deliberation = highest tier |
| `SELF_IMPROVEMENT` | `Expert` | All + `admin`, `delegate` | Meta-cognition = highest tier |

The NLP-Explainer defines additional slots (`EXPLANATION`, `TEACHING`, `ORCHESTRATION`, `SCALING`) that map:

| NLP Slot | SkillTier | Capabilities |
|---|---|---|
| `EXPLANATION` | `Standard` | `read`, `query`, `write`, `compute` |
| `TEACHING` | `Advanced` | `read`, `query`, `write`, `compute`, `network` |
| `ORCHESTRATION` | `Expert` | All + `admin`, `delegate` |
| `SCALING` | `Advanced` | `read`, `query`, `write`, `compute`, `network` |

### 1.3 Exact Type Translations

```typescript
// TypeScript
interface Equipment {
  readonly name: string;
  readonly slot: EquipmentSlot;
  readonly version: string;
  readonly description: string;
  readonly cost: CostMetrics;
  readonly benefit: BenefitMetrics;
  readonly triggerThresholds: TriggerThresholds;
  equip(agent: OriginCore): Promise<void>;
  unequip(agent: OriginCore): Promise<void>;
  asTile(): Tile;
  describe(): EquipmentDescription;
}
```

```rust
// Rust equivalent (what the bridge produces)
struct EquipmentSkill {
    id: SkillId,           // namespace::name@version
    tier: SkillTier,       // derived from EquipmentSlot
    description: String,
    capabilities: Vec<String>,  // derived from BenefitMetrics.capabilityGain
    cost: BridgedCostMetrics,   // see §3
    trigger_config: TriggerConfig, // see §4
}

// In construct-core's world, this becomes:
// SyncConstruct::load_skill(SkillId) → loads the skill
// query_owned(OwnedQuery) → invokes the skill (equivalent to asTile().compute())
```

---

## 2. EquipmentSlot Tier → Construct-Core Layer Mapping

Construct-core has three layers (L0/L1/L2). Equipment slots map to minimum required layers:

| Layer | Trait | Environment | Equipment Slots |
|---|---|---|---|
| **L0** | `BareMetalConstruct` | `no_std`, no alloc | `MEMORY` (lookup only), `COMMUNICATION` (signal only) |
| **L1** | `SyncConstruct` | `no_std` + alloc | All `Basic`/`Standard` tier slots: `SPREADSHEET`, `DISTILLATION`, `MONITORING`, `EXPLANATION` |
| **L2** | `AsyncConstruct` | `std` + async | All `Advanced`/`Expert` tier slots: `REASONING`, `PERCEPTION`, `COORDINATION`, `CONSENSUS`, `SELF_IMPROVEMENT` |

### Layer Capability Matrix

```
L0 (BareMetalConstruct):
  query_lookup(index) → TritAction     // EQUIVALENT: Tile.compute() on bare metal
  capabilities() → BareMetalCapabilities
  query(Query) → Response

L1 (SyncConstruct) extends L0:
  load_skill(SkillId)                   // EQUIVALENT: Equipment.equip(agent)
  unload_skill(SkillId)                 // EQUIVALENT: Equipment.unequip(agent)
  loaded_skills() → &[SkillId]          // EQUIVALENT: agent.equipment.keys()
  query_owned(OwnedQuery) → OwnedResponse  // EQUIVALENT: Equipment.asTile().compute()

L2 (AsyncConstruct) extends L1:
  request_tool(ToolSpec) → ToolHandle   // EQUIVALENT: acquiring external resources (LLM, DB)
  release_tool(ToolHandle)
  query_async(OwnedQuery) → Future<OwnedResponse>  // EQUIVALENT: async tile computation
```

---

## 3. CostMetrics → ResourceBudget Mapping

TypeScript `CostMetrics` provides fine-grained resource estimates. Rust construct-core uses `HardwareTier` as a proxy. The bridge creates an explicit `ResourceBudget`:

```rust
/// Bridged cost metrics from TypeScript Equipment.
#[derive(Debug, Clone)]
pub struct ResourceBudget {
    /// Maximum memory the skill may use (bytes).
    pub memory_bytes: u64,
    /// CPU utilization target (0-100%).
    pub cpu_percent: u8,
    /// Maximum acceptable latency per invocation (ms).
    pub latency_ms: u32,
    /// Cost per invocation in microdollars.
    pub cost_per_use_micro: u32,
}

/// Bridged benefit metrics from TypeScript Equipment.
#[derive(Debug, Clone)]
pub struct BenefitProfile {
    /// Expected accuracy improvement (0.0-1.0).
    pub accuracy_boost: f32,
    /// Speedup factor (1.0 = no change).
    pub speed_multiplier: f32,
    /// Confidence improvement (0.0-1.0).
    pub confidence_boost: f32,
    /// Named capabilities gained.
    pub capability_gains: Vec<String>,
}

impl ResourceBudget {
    /// Determine the minimum HardwareTier that can support this budget.
    pub fn min_hardware_tier(&self) -> HardwareTier {
        if self.memory_bytes > 10_000_000 || self.cost_per_use_micro > 0 {
            // Skills with >10MB or non-zero cost need at least Workstation
            HardwareTier::Workstation
        } else if self.memory_bytes > 100_000 || self.latency_ms > 100 {
            // Skills with >100KB or high latency need at least SingleBoard
            HardwareTier::SingleBoard
        } else {
            // Small skills can run on Embedded
            HardwareTier::Embedded
        }
    }
}

/// Conversion from TypeScript Equipment.cost
impl From<TsCostMetrics> for ResourceBudget {
    fn from(ts: TsCostMetrics) -> Self {
        Self {
            memory_bytes: ts.memory_bytes,
            cpu_percent: ts.cpu_percent as u8,
            latency_ms: ts.latency_ms as u32,
            cost_per_use_micro: (ts.cost_per_use * 1_000_000.0) as u32,
        }
    }
}
```

### Concrete Mappings for Existing Equipment

| Equipment | CostMetrics (TS) | ResourceBudget (Rust) | Min Tier |
|---|---|---|---|
| HierarchicalMemory | 10MB, 5% CPU, 1ms, $0 | 10_000_000B, 5%, 1ms, 0µ$ | SingleBoard |
| EscalationEngine | 1MB, 2% CPU, 0.1ms, $0.001 | 1_000_000B, 2%, 0ms, 1000µ$ | Workstation |
| TripartiteConsensus | 5MB, 10% CPU, 500ms, $0.01 | 5_000_000B, 10%, 500ms, 10000µ$ | Workstation |
| POLLNInterface | 2MB, 3% CPU, 10ms, $0 | 2_000_000B, 3%, 10ms, 0µ$ | SingleBoard |
| CellLogicDistiller | 50MB, 15% CPU, 500ms, $0.001 | 50_000_000B, 15%, 500ms, 1000µ$ | Workstation |
| NLPExplainer | 30MB, 10% CPU, 200ms, $0.0005 | 30_000_000B, 10%, 200ms, 500µ$ | Workstation |

---

## 4. Trigger System Mapping

TypeScript `TriggerThresholds` define when to equip/unequip. Rust needs a similar mechanism:

```rust
/// Trigger conditions for skill loading/unloading.
#[derive(Debug, Clone)]
pub struct TriggerConfig {
    pub equip_when: Vec<TriggerCondition>,
    pub unequip_when: Vec<TriggerCondition>,
    pub call_teacher: TeacherThreshold,
}

#[derive(Debug, Clone)]
pub struct TriggerCondition {
    pub metric: String,       // "complexity", "confidence", "load", "memory"
    pub operator: CompOp,     // <, >, <=, >=, ==, !=
    pub value: f64,
}

#[derive(Debug, Clone, Copy)]
pub enum CompOp { Lt, Gt, Lte, Gte, Eq, Neq }

#[derive(Debug, Clone)]
pub struct TeacherThreshold {
    pub low: f64,
    pub high: f64,
}
```

In construct-core's `SyncConstruct`, triggers are evaluated in `load_skill`/`unload_skill` by the host agent — not by the construct itself. The bridge provides trigger metadata that the host can poll.

---

## 5. WASM Bridge: TypeScript Skills in Rust

The goal: take TypeScript `Equipment` implementations, compile them to WASM, and load them as construct-core skills.

### 5.1 Architecture

```
┌─────────────────────────────────────────────┐
│  Rust Host (construct-core)                  │
│                                              │
│  ┌──────────────────┐  ┌─────────────────┐  │
│  │ SyncConstruct    │  │ WASM Runtime    │  │
│  │ load_skill()     │──│ (wasmtime)      │  │
│  │ query_owned()    │  │                 │  │
│  └──────────────────┘  │  ┌───────────┐  │  │
│                         │  │ TS Equip  │  │  │
│  ┌──────────────────┐  │  │ (WASM)    │  │  │
│  │ SkillRegistry    │  │  │           │  │  │
│  │ (ternary-registry)│  │  │ equip()   │  │  │
│  └──────────────────┘  │  │ unequip() │  │  │
│                         │  │ compute() │  │  │
│                         │  └───────────┘  │  │
│                         └─────────────────┘  │
└─────────────────────────────────────────────┘
```

### 5.2 WASM Interface Specification

The bridge defines a canonical WASM ABI that TypeScript Equipment must implement:

```typescript
// equipment-wasm-bridge.ts
// This is the interface TypeScript Equipment must export to WASM

// Shared types (serialized as JSON bytes via WASM memory)
interface WasmEquipmentManifest {
  name: string;
  slot: string;
  version: string;
  description: string;
  cost: CostMetrics;
  benefit: BenefitMetrics;
  capabilities: string[];
}

// Exported functions (the WASM ABI)
export function getManifest(): ArrayBuffer;     // → JSON-encoded WasmEquipmentManifest
export function equip(agentJson: ArrayBuffer): void;    // called on load_skill
export function unequip(): void;                         // called on unload_skill
export function compute(inputJson: ArrayBuffer): ArrayBuffer;  // called on query_owned
export function confidence(inputJson: ArrayBuffer): number;    // confidence for input
export function describe(): ArrayBuffer;               // → JSON EquipmentDescription
```

```rust
// wasi_bridge.rs — Rust side of the bridge

use wasmtime::*;
use construct_core::types::*;

/// A WASM-backed skill loaded from a compiled TypeScript Equipment module.
pub struct WasmSkill {
    engine: Engine,
    instance: Instance,
    manifest: EquipmentManifest,
}

#[derive(Debug, Clone)]
pub struct EquipmentManifest {
    pub name: String,
    pub slot: String,
    pub version: String,
    pub description: String,
    pub cost: ResourceBudget,
    pub benefit: BenefitProfile,
    pub capabilities: Vec<String>,
}

impl WasmSkill {
    /// Load a WASM module as a skill.
    pub fn load(wasm_bytes: &[u8]) -> Result<Self, Box<dyn std::error::Error>> {
        let engine = Engine::default();
        let module = Module::new(&engine, wasm_bytes)?;
        let mut store = Store::new(&engine, ());

        // Create WASI environment for the module
        let linker = Linker::new(&engine);

        let instance = linker.instantiate(&mut store, &module)?;

        // Call getManifest() to get skill metadata
        let manifest_fn = instance
            .get_typed_func::<(), u32>(&mut store, "getManifest")?;
        let manifest_ptr = manifest_fn.call(&mut store, ())?;

        // Read manifest from WASM memory
        let memory = instance
            .get_memory(&mut store, "memory")
            .ok_or("no memory export")?;
        let manifest_json = read_wasm_string(&memory, &mut store, manifest_ptr);
        let manifest: EquipmentManifest = serde_json::from_str(&manifest_json)?;

        Ok(Self { engine, instance, manifest })
    }

    /// Invoke the skill's compute function.
    pub fn compute(&self, input: &[u8]) -> Result<Vec<u8>, Box<dyn std::error::Error>> {
        let mut store = Store::new(&self.engine, ());
        let compute_fn = self.instance
            .get_typed_func::<(u32, u32), u32>(&mut store, "compute")?;

        // Write input to WASM memory
        let memory = self.instance
            .get_memory(&mut store, "memory")
            .ok_or("no memory")?;

        let input_ptr = self.alloc_in_wasm(&mut store, input.len())?;
        let data = memory.data_mut(&mut store);
        data[input_ptr..input_ptr + input.len()].copy_from_slice(input);

        let output_ptr = compute_fn.call(&mut store, (input_ptr as u32, input.len() as u32))?;

        // Read output from WASM memory
        let output = read_wasm_bytes(&memory, &mut store, output_ptr);
        Ok(output)
    }

    /// Get the equipment manifest.
    pub fn manifest(&self) -> &EquipmentManifest {
        &self.manifest
    }

    fn alloc_in_wasm(&self, store: &mut Store<()>, len: usize)
        -> Result<usize, Box<dyn std::error::Error>>
    {
        let alloc_fn = self.instance
            .get_typed_func::<u32, u32>(&mut *store, "alloc")?;
        let ptr = alloc_fn.call(store, len as u32)?;
        Ok(ptr as usize)
    }
}
```

### 5.3 TypeScript → WASM Compilation Pipeline

```bash
# Step 1: Install AssemblyScript (TypeScript → WASM compiler)
npm install -g assemblyscript

# Step 2: Create WASM-compatible wrapper for each Equipment
# (See §5.2 for the ABI)

# Step 3: Compile
asc equipment-wrapper.ts \
  --outFile equipment.wasm \
  --runtime minimal \
  --exportRuntime

# Step 4: Register with ternary-registry
# The .wasm file becomes the skill payload
```

### 5.4 Hybrid Skill Loading

The Rust host needs to detect whether a skill is native Rust or WASM-backed:

```rust
pub enum SkillKind {
    /// Native Rust skill, directly loaded.
    Native(Box<dyn NativeSkill>),
    /// WASM-backed TypeScript Equipment.
    Wasm(WasmSkill),
}

/// Unified skill loader that handles both native and WASM skills.
pub struct UnifiedSkillLoader {
    registry: SkillRegistry,
    wasm_skills: HashMap<String, WasmSkill>,
}

impl UnifiedSkillLoader {
    /// Load a skill from either a native Rust implementation or WASM module.
    pub fn load_skill(
        &mut self,
        id: &SkillId,
        kind: SkillKind,
    ) -> Result<(), ConstructError> {
        match kind {
            SkillKind::Native(skill) => {
                let ts_skill = Skill::new(
                    id.clone(),
                    skill.tier(),
                    &skill.description(),
                );
                self.registry.register(ts_skill);
                Ok(())
            }
            SkillKind::Wasm(wasm) => {
                let manifest = wasm.manifest();
                let tier = manifest.cost.min_hardware_tier();
                let ts_tier = match tier {
                    HardwareTier::Embedded => SkillTier::Basic,
                    HardwareTier::SingleBoard => SkillTier::Standard,
                    HardwareTier::Workstation => SkillTier::Advanced,
                    HardwareTier::Cluster => SkillTier::Expert,
                };
                let skill = Skill::new(
                    id.clone(),
                    ts_tier,
                    &manifest.description,
                );
                self.registry.register(skill);
                self.wasm_skills.insert(id.full_id(), wasm);
                Ok(())
            }
        }
    }
}
```

---

## 6. Tile ↔ Query Mapping

The `Tile` interface (TypeScript) and `OwnedQuery`/`OwnedResponse` (Rust) are the execution layer:

| TypeScript Tile | Rust Equivalent |
|---|---|
| `Tile.compute(input)` | `query_owned(OwnedQuery { kind: Action, payload: serialize(input) })` |
| `Tile.confidence(input)` | `OwnedResponse.confidence` field |
| `Tile.trace(input)` | `OwnedResponse.metadata` (JSON-encoded trace string) |
| `Tile.inputType` | `OwnedQuery.kind` + schema validation |
| `Tile.outputType` | `OwnedResponse.metadata` schema |

### Serialization Format

All cross-boundary data uses MessagePack (compact, schema-free, WASM-friendly):

```rust
// Serialize TypeScript input → OwnedQuery
fn tile_input_to_query(input: &[u8], kind: QueryKind) -> OwnedQuery {
    OwnedQuery::new(kind, input.to_vec())
}

// Deserialize OwnedResponse → TypeScript-like output
fn response_to_tile_output(resp: &OwnedResponse) -> Vec<u8> {
    // response.metadata contains the serialized output
    resp.metadata.clone()
}
```

---

## 7. Migration Checklist

For each TypeScript Equipment being ported to Rust:

1. **Define `SkillId`** in ternary-registry format: `namespace::name@version`
2. **Map `EquipmentSlot`** → `SkillTier` + capabilities (use table in §1.2)
3. **Convert `CostMetrics`** → `ResourceBudget` (use §3 formulas)
4. **Choose implementation path**:
   - **Pure Rust**: Rewrite as native `SyncConstruct` skill (preferred for L0/L1)
   - **WASM bridge**: Keep TypeScript, compile to WASM, load via §5 bridge (for L2)
5. **Register with `SkillRegistry`**: Use `Skill::new().with_capability().with_dependency()`
6. **Test via `SkillDependencyResolver`**: Ensure dependency chain resolves
7. **Validate with `CapabilityMatrix`**: Check hardware tier supports all capabilities

---

## 8. Ensign Integration

The ternary-ensign `Ensign` trait wraps Equipment-style skills:

```rust
/// An Equipment wrapped as an Ensign.
pub struct EquipmentEnsign {
    domain: String,
    skill_id: SkillId,
    bridge: EnsignBridge,
}

impl Ensign for EquipmentEnsign {
    fn domain(&self) -> &str { &self.domain }
    fn handle(&self, task: &str) -> EnsignResult {
        // Route through EnsignBridge → construct-core skill
        let skill_name = self.bridge.skill_for(&self.domain);
        match skill_name {
            Some(name) => {
                // Invoke the construct-core skill
                // (in practice, through the SyncConstruct interface)
                EnsignResult::ok(&format!("[{}] processed via skill {}", self.domain, name))
            }
            None => EnsignResult::err("no skill mapped"),
        }
    }
}
```

Every `Equipment` is an `Ensign` with `domain = slot_name`. The `EnsignRegistry::load()` = `SyncConstruct::load_skill()`.

---

## Appendix: File Cross-Reference

| Source | What it defines |
|---|---|
| `SuperInstance-Starter-Agent/src/types.ts` | `Equipment` interface, `EquipmentSlot`, `CostMetrics`, `Tile` |
| `SuperInstance-Starter-Agent/src/equipment/Equipment.ts` | Concrete equipment: Memory, Reasoning, Consensus, Spreadsheet |
| `SuperInstance-Starter-Agent/src/core/OriginCore.ts` | `OriginCore` with `equip`/`unequip`/`autoEquip` |
| `Equipment-CellLogic-Distiller/src/CellLogicDistiller.ts` | Distiller Equipment (DISTILLATION slot) |
| `Equipment-NLP-Explainer/src/NLPExplainer.ts` | NLP Explainer Equipment (EXPLANATION slot) |
| `construct-core/src/types.rs` | `SkillId`, `TritAction`, `Query`, `Response`, `HardwareTier` |
| `construct-core/src/layer1.rs` | `SyncConstruct` trait (`load_skill`, `unload_skill`, `query_owned`) |
| `construct-core/src/layer2.rs` | `AsyncConstruct` trait (`query_async`, `request_tool`) |
| `ternary-registry/src/lib.rs` | `SkillRegistry`, `SkillTier`, `Skill`, `CapabilityMatrix` |
| `ternary-ensign/src/lib.rs` | `Ensign` trait, `EnsignRegistry`, `EnsignBridge` |
