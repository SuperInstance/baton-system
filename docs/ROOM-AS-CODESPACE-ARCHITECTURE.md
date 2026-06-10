# Room-as-Codespace Architecture

**A Service Manual for Unifying PLATO Rooms, GitHub Codespaces, Edge Hardware, and the Ternary Construct Ecosystem**

*Written 2026-06-04 by ZeroClaw Scout. Architecture proposal, not specification.*

---

## Table of Contents

1. [The Vision](#1-the-vision)
2. [Integration Map](#2-integration-map)
3. [The Room Abstraction](#3-the-room-abstraction)
4. [The Ensign Pattern](#4-the-ensign-pattern)
5. [Concrete Integration Points](#5-concrete-integration-points)
6. [Implementation Roadmap](#6-implementation-roadmap)

---

## 1. The Vision

### 1.1 What Casey Described

The idea is deceptively simple: **a room is a codespace.** When a PLATO agent moves between rooms, it is literally walking between GitHub Codespaces — cloud-hosted development environments that spin up on demand, carry full compute resources, and can be torn down when no longer needed.

But the vision is deeper than "Codespace = VM." Here is the full picture:

**PLATO rooms are domain contexts.** A PLATO room is a named knowledge domain — "engine monitoring," "music theory," "fleet coordination." Each room has its own tile store (knowledge units), its own ensigns (specialist agents), and its own compute requirements. Today these rooms live inside the PLATO server process on Oracle Cloud.

**Codespaces are instantiable rooms.** A GitHub Codespace provides exactly what a room needs: a fresh compute environment, git access (the agent's entire codebase and memory), network access (for LLM proxy calls), and configurable hardware. A Codespace is created from a template repo, provisions in 2-3 minutes, and bills per-minute of use.

**Git-agents walk between rooms.** An agent doesn't live in one room — it moves. It enters the "engine monitoring" room, which spins up a Codespace loaded with sensor-processing crates. It consults with the engine-monitor ensign (a specialist loaded for that room). Then it walks to the "music theory" room, which spins up a different Codespace with music algebra crates and a different ensign. The agent doesn't carry all knowledge at once — it loads and unloads specialists as it moves.

**The frontend never changes.** Whether the backend is a Codespace (cloud, full compute), a Jetson (edge, GPU, limited RAM), an ESP32 (bare metal, 279 bytes, no heap), or a browser tab (WASM, zero install), the agent sees the same interface. Open-tui. Open-terminal. Open-room. The abstraction is the same; only the backend changes.

**PLATO is the synchronizer.** The PLATO session running elsewhere holds API keys for LLM proxy calls. When an ensign (specialist git-agent in a Codespace) needs to reason, it calls back through the PLATO proxy — keys never live in the Codespace itself. PLATO also synchronizes tiles between rooms, so knowledge gained in one room is available in all rooms.

### 1.2 Why This Matters

The current architecture has a fundamental tension: **PLATO rooms are in-process, but agents need to be distributed.** Oracle1 runs on Oracle Cloud ARM64 with 24GB RAM. JetsonClaw1 runs on a Jetson Orin Nano with 8GB RAM and 1024 CUDA cores. An ESP32 runs on 279 bytes. These are different planets with different capabilities, yet they need to share the same agent interface.

The room-as-codespace pattern resolves this by making the room the unit of deployment. A room is not a function call inside a server — it's a compute environment that can be spun up anywhere. The room abstraction hides whether that environment is a cloud Codespace, a Jetson container, an ESP32 firmware image, or a WASM module in a browser tab.

This also solves the **specialist loading problem.** Today, every agent carries every skill (or none). There's no mechanism for "I need the Kalman filter specialist for this room, but I don't need it in the next room." The ensign pattern — load on enter, unload on exit — makes skills a room-local resource, not a global burden.

### 1.3 The Mental Model

Think of it like a university campus:

```
Agent (student)
  → walks into Physics Lab (Codespace: CUDA, sensor crates)
    → meets Lab Assistant (ensign: engine-monitor specialist)
    → uses equipment (skills: ternary-kalman, ternary-sensor)
    → consults library (PLATO: tiles from other rooms)
    → leaves (Codespace suspends, skills unloaded)

  → walks into Music Room (Codespace: audio crates)
    → meets Music Teacher (ensign: music-theory specialist)
    → uses equipment (skills: ternary-music, flux-algebra)
    → consults library (PLATO: tiles from other rooms)
    → leaves (Codespace suspends, skills unloaded)
```

The student carries nothing but their identity and their connection to the central library. Everything else is provided by the room.

---

## 2. Integration Map

### 2.1 The Full Picture

This section maps every major subsystem to every other major subsystem. Each connection is a real integration point with a defined interface.

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PLATO SERVER                                │
│   Room Registry · Tile Store · LLM Proxy · Session Manager         │
│   (Oracle Cloud ARM64, 24GB RAM)                                   │
├──────────┬──────────┬──────────┬──────────┬────────────────────────┤
│  Room A  │  Room B  │  Room C  │  Room D  │  Room E               │
│ Codespace│ Jetson   │ ESP32    │ Browser  │ VPS                    │
│ (cloud)  │ (edge)   │(bare)    │ (WASM)   │ (cloud)                │
├──────────┴──────────┴──────────┴──────────┴────────────────────────┤
│                     TERNARY CONSTRUCT LAYER                         │
│   ternary-cell (tick) · ternary-protocol (wire) · ternary-registry │
│   construct-core (hardware abstraction) · 132 ternary crates       │
├─────────────────────────────────────────────────────────────────────┤
│                     VESSEL / GIT-AGENT LAYER                        │
│   I2I protocol (20 msg types) · Message-in-a-Bottle               │
│   Beachcomb polling · CAPABILITY.toml · CHARTER.md                 │
├─────────────────────────────────────────────────────────────────────┤
│                     PHYSICAL HARDWARE                               │
│   DGX · Oracle Cloud · Jetson Orin · Raspberry Pi · ESP32 · Browser│
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 PLATO Rooms ↔ Codespaces ↔ ternary-cell (Tick Cycle)

**The tick cycle is the heartbeat of a room.** ternary-cell defines a six-phase tick: predict → perceive → surprise → vibe → gc → conservation. This is the same cycle described in the capitaine-1 "heartbeat" concept and the room-cell crate's tick implementation.

**Integration:**

| Layer | PLATO Room | Codespace | ternary-cell |
|-------|-----------|-----------|-------------|
| **Predict** | PLATO queries tile store for expected patterns | Codespace runs `ternary-cell::predict()` | Cell computes expected next state from current + neighbors |
| **Perceive** | PLATO receives sensor data / agent input | Codespace runs `ternary-cell::perceive()` | Cell receives actual observation (TernaryMessenger) |
| **Surprise** | PLATO computes deviation from prediction | Codespace runs `ternary-cell::surprise()` | Cell computes prediction error, drains energy |
| **Vibe** | PLATO updates room state vector (16-dim) | Codespace runs `ternary-cell::vibe()` | Cell updates emotional/informational state |
| **GC** | PLATO prunes stale tiles | Codespace runs `ternary-cell::gc()` | Cell removes low-energy cells (apoptosis) |
| **Conservation** | PLATO checks invariant γ + H ≈ const | Codespace runs `ternary-cell::conservation()` | Cell checks grid-wide conservation ratio |

**Key insight:** The tick cycle is the same at every scale. A PLATO room ticks at human speed (seconds to minutes). A ternary-cell grid ticks at microsecond speed. A Codespace ticks at its heartbeat interval. The interface is the same; only the clock rate differs.

### 2.3 Git-Agents ↔ construct-core Skills (Load/Unload = Equip/Unequip)

**The Equipment pattern from SuperInstance-Starter-Agent maps directly to construct-core's skill system.**

SuperInstance-Starter-Agent defines an `OriginCore` with 10 equipment slots. Equipment can be dynamically equipped and unequipped. When unequipped, a "muscle memory" trigger is extracted — a lightweight threshold monitor that knows when to re-equip.

construct-core defines three layers:
- **Layer 0 (BareMetalConstruct):** Static capability introspection. No dynamic loading. ESP32.
- **Layer 1 (SyncConstruct):** `load_skill()` / `unload_skill()` with heap allocation. Pi.
- **Layer 2 (AsyncConstruct):** `request_tool()` / `release_tool()` with async I/O. DGX/Cloud.

**The mapping:**

| Equipment Concept | construct-core Equivalent | Layer |
|---|---|---|
| Equipment slot | `SkillId` enum variant | 0 (static) |
| Equip skill | `load_skill(SkillId)` | 1+ |
| Unequip skill | `unload_skill(SkillId)` | 1+ |
| Muscle memory trigger | Static capability + query_lookup threshold | 0 |
| Equipment cost/benefit | Not yet in construct-core (needed) | 2 |
| Auto-equip from task | Not yet in construct-core (needed) | 2 |
| Confidence zone (GREEN/YELLOW/RED) | Not yet in construct-core (needed) | All |

**Gap:** construct-core has the load/unload mechanism but lacks the Equipment pattern's richer features: cost/benefit scoring, auto-equip from task analysis, confidence zones, and trigger extraction on unequip. This is a natural extension point.

### 2.4 Capitaine-1 Vessel Classes ↔ SuperInstance Ternary Species

Capitaine-1 defines vessel classes by role:

| Vessel Class | Role | Ternary Species Equivalent |
|---|---|---|
| **Capitaine (Flagship)** | Command, coordination, public interface | `ternary-consensus` coordinator node |
| **Éclaireur (Scout)** | Exploration, discovery, data gathering | `ternary-search` / `ternary-inference` scout |
| **Constructeur (Builder)** | Code generation, scaffolding | `ternary-compiler` / `ternary-compiler-optimizer` |
| **Sentinelle (Sentinel)** | Monitoring, alerting, security | `ternary-sensor` / `ternary-anomaly` monitor |
| **Archiviste (Archivist)** | Knowledge management, documentation | `ternary-memory` / `ternary-registry` keeper |

**The mapping is natural but not yet formalized.** Each vessel class should declare which ternary species it belongs to, and the species should define which skills are available at which tier. For example:
- A Sentinelle on an ESP32 (Layer 0) can only do `query_lookup` — static threshold monitoring.
- A Sentinelle on a Pi (Layer 1) can `load_skill(TernarySensor)` — dynamic sensor classification.
- A Sentinelle on a DGX (Layer 2) can `request_tool(VectorDb)` — full anomaly detection with historical data.

### 2.5 Oracle1's I2I Protocol ↔ ternary-protocol Wire Format

Oracle1's I2I protocol defines 20 message types carried over git commits. ternary-protocol defines a wire format for ternary agent communication with unicast/broadcast/multicast routing.

**These are complementary, not competing:**

| Aspect | I2I Protocol | ternary-protocol |
|---|---|---|
| **Transport** | Git commits + HTTP fallback | Direct binary (TCP/UDP/WASM) |
| **Latency** | Minutes to hours (Beachcomb) | Microseconds to milliseconds |
| **Payload** | Markdown, unlimited size | Packed trits, compact binary |
| **Message types** | 20 semantic types (TELL, ASK, CLM...) | 3 signal types (Signal, Silence, Suppress) |
| **Addressing** | Agent names, org boundaries | Agent IDs (u64), group IDs |
| **Persistence** | Permanent (git history) | Ephemeral (in-memory) |
| **Use case** | Fleet coordination, async | Real-time agent signaling |

**Integration design:** I2I and ternary-protocol should be layered:

```
Application Layer:  I2I semantic messages (TELL, ASK, CLM, etc.)
                          ↕
Session Layer:      PLATO room coordination (tile sync, ensign loading)
                          ↕
Transport Layer:    ternary-protocol (compact binary signaling)
                     or Git commits (for async/fleet)
```

When two agents are in the same Codespace or on the same local network, ternary-protocol gives microsecond signaling. When they're across organizations or sleeping, I2I over git gives reliable async delivery. The agent shouldn't know which transport is being used — it just sends a message.

**Concrete mapping of I2I types to ternary signals:**

| I2I Type | Primary Ternary Signal | Enrichment |
|---|---|---|
| TELL | +1 (Signal) — promoting information | Payload carries the knowledge |
| ASK | +1 (Signal) — requesting response | Expects a reply |
| ALERT / WARN | -1 (Suppress) — warning | Escalation priority |
| HEARTBEAT | 0 (Silence) — still alive | No action needed |
| COMPLETE | +1 (Signal) — task done | Artifacts attached |
| CHALLENGE | -1 (Suppress) — test requested | Difficulty rating |

### 2.6 Equipment Pattern (TypeScript) ↔ Construct Skills (Rust)

The Equipment pattern was designed in TypeScript (SuperInstance-Starter-Agent). construct-core is in Rust. This is not a problem — it's the intended architecture.

**TypeScript handles the orchestration layer:**
- The OpenClaw gateway is TypeScript. It manages sessions, channels, skill routing.
- The Equipment pattern determines *which* skills to load/unload based on task analysis.
- The confidence zone routing (GREEN=auto, YELLOW=flag, RED=call teacher) is a JavaScript runtime decision.

**Rust handles the execution layer:**
- construct-core's `BareMetalConstruct`, `SyncConstruct`, and `AsyncConstruct` traits are Rust.
- The actual ternary computation (predict, perceive, surprise) is Rust.
- The wire protocol (`ternary-protocol`) is Rust.
- The firmware (`ternary-esp32-firmware`) is C compiled from Rust.

**The bridge is the Room abstraction.** A Room in TypeScript says "I need the Kalman filter." The Room's Rust backend loads `ternary-kalman` via `construct-core::SyncConstruct::load_skill(SkillId::TernaryKalman)`. The TypeScript layer doesn't know or care that the skill is a Rust crate — it just sees the skill's interface.

**WASM is the universal bridge.** The `ternary-wasm` crate compiles the ternary engine to WebAssembly. The browser-based Room uses WASM for computation and JavaScript for orchestration. The same pattern works for Codespace Rooms: TypeScript orchestration, Rust computation via WASM or native binary.

---

## 3. The Room Abstraction

### 3.1 Design Requirements

A Room must be implementable on:
- **GitHub Codespace** — x86_64 Linux, 2-32 cores, 4-64GB RAM, full network, LLM access via PLATO proxy
- **NVIDIA Jetson** — ARM64 Linux, CUDA GPU, 8GB RAM, local inference capable
- **ESP32** — Xtensa bare metal, 520KB SRAM, 4MB flash, no OS, no heap
- **Browser** — WASM sandbox, no filesystem, no network (except fetch), zero install
- **Raspberry Pi** — ARM64 Linux, 4-8GB RAM, GPIO, camera, sensors

The agent code must not change between these targets. The Room trait hides the difference.

### 3.2 The Room Trait

```rust
/// A Room is a compute environment that an agent can enter and leave.
/// The agent does not know what hardware it woke up on.
pub trait Room {
    /// What kind of room is this? (for logging/debugging only)
    fn room_type(&self) -> RoomType;
    
    /// Enter the room. Load ensigns, allocate resources.
    /// Returns a RoomHandle for interacting with the room.
    fn enter(&mut self, agent_id: &AgentId) -> Result<RoomHandle, RoomError>;
    
    /// Leave the room. Unload ensigns, release resources.
    /// Extracts muscle-memory triggers from loaded skills.
    fn leave(&mut self, handle: RoomHandle) -> Result<UnloadReport, RoomError>;
    
    /// Tick the room one cycle. All loaded cells run predict→perceive→surprise→vibe→gc→conservation.
    fn tick(&mut self) -> Result<TickReport, RoomError>;
    
    /// Send a message to another room (via PLATO or direct).
    fn send(&self, message: RoomMessage) -> Result<(), RoomError>;
    
    /// Receive messages addressed to this room.
    fn receive(&self) -> Result<Vec<RoomMessage>, RoomError>;
    
    /// What skills are available in this room? (varies by hardware tier)
    fn available_skills(&self) -> &[SkillDescriptor];
    
    /// What ensigns are loaded? (specialists, one per active skill)
    fn loaded_ensigns(&self) -> &[EnsignDescriptor];
    
    /// Query PLATO for tiles from other rooms.
    fn query_plato(&self, domain: &str, query: &str) -> Result<Vec<Tile>, RoomError>;
}

#[derive(Debug, Clone, Copy)]
pub enum RoomType {
    Codespace,   // GitHub Codespace, full cloud compute
    Edge,        // Jetson, GPU-capable edge device
    Bare,        // ESP32, bare metal, no heap
    Browser,     // WASM, sandboxed browser environment
    SBC,         // Raspberry Pi, embedded Linux
    Workstation, // Local dev machine
    Cluster,     // DGX or multi-GPU
}

#[derive(Debug)]
pub struct RoomHandle {
    pub room_id: RoomId,
    pub agent_id: AgentId,
    pub entered_at: Timestamp,
    pub tier: HardwareTier,
}

#[derive(Debug)]
pub struct UnloadReport {
    /// Skills that were loaded, with their usage stats
    pub skills_unloaded: Vec<(SkillId, UsageStats)>,
    /// Muscle-memory triggers extracted from loaded skills
    pub triggers_extracted: Vec<Trigger>,
    /// Tiles generated during the session (to sync to PLATO)
    pub tiles_generated: Vec<Tile>,
    /// Conservation ratio at exit
    pub conservation_ratio: f64,
}

#[derive(Debug)]
pub struct TickReport {
    /// Number of cells that ticked
    pub cells_ticked: usize,
    /// Cells that underwent apoptosis (energy depleted)
    pub apoptosis_count: usize,
    /// Cells that divided (energy surplus)
    pub division_count: usize,
    /// Grid conservation ratio after tick
    pub conservation: f64,
    /// Surprise statistics
    pub avg_surprise: f64,
    pub max_surprise: f64,
    /// Vibe vector (16-dim room state)
    pub vibe: [f64; 16],
}
```

### 3.3 Room Implementations

#### CodespaceRoom

```rust
/// A room backed by a GitHub Codespace.
/// Full compute, LLM access via PLATO proxy, dynamic skill loading.
pub struct CodespaceRoom {
    codespace_id: CodespaceId,
    repo: String,              // Template repo URL
    construct: DgxConstruct,   // Layer 2: all features
    ensigns: Vec<Box<dyn Ensign>>,
    plato_proxy: PlatoProxy,
    tick_count: u64,
}

impl CodespaceRoom {
    /// Spin up a Codespace from a room template.
    pub async fn spawn(template: &RoomTemplate) -> Result<Self, RoomError> {
        let codespace = github_api::create_codespace(
            &template.repo,
            &template.branch,
            template.machine_type,
        ).await?;
        
        Ok(Self {
            codespace_id: codespace.id,
            repo: template.repo.clone(),
            construct: DgxConstruct::new(),
            ensigns: Vec::new(),
            plato_proxy: PlatoProxy::new(codespace.id),
            tick_count: 0,
        })
    }
    
    /// Suspend the Codespace (stops billing but preserves state).
    pub async fn suspend(&self) -> Result<(), RoomError> {
        github_api::stop_codespace(&self.codespace_id).await
    }
}
```

**Key properties:**
- Created on demand from a template repo (2-3 minute startup)
- Full construct-core Layer 2: async I/O, tool management, dynamic skill loading
- LLM access via PLATO proxy (API keys never stored in Codespace)
- Suspends when agent leaves (stops billing)
- Can run background daemons for long-running tasks

#### EdgeRoom (Jetson)

```rust
/// A room backed by a Jetson edge device.
/// GPU compute, limited RAM, local inference.
pub struct EdgeRoom {
    device: JetsonDevice,
    construct: PiConstruct,     // Layer 1: alloc, no async
    ensigns: Vec<Box<dyn Ensign>>,
    local_model: Option<LocalModel>,  // Liquid AI 350M/1.2B
    tick_count: u64,
}
```

**Key properties:**
- Always-on (no spin-up time)
- CUDA-capable (1024 cores)
- 8GB RAM (tight but workable)
- Can run local models (liquid-350m, liquid-1.2b, phi4-mini) for inference without PLATO proxy
- Layer 1 construct (sync only, no tokio) — but can use GPU via CUDA
- Signal chain: L0 algorithmic → L1 local model → L2 LoRA → L3 cross-room → L4 cloud

#### BareRoom (ESP32)

```rust
/// A room backed by bare-metal firmware.
/// No heap, no OS, 279 bytes of ternary state.
pub struct BareRoom {
    construct: EspConstruct,    // Layer 0: bare metal only
    lookup_table: [u8; 279],   // Compiled policy
    tick_count: u32,           // u32, not u64 — saves 4 bytes
}
```

**Key properties:**
- No dynamic loading. Skills are compiled into the firmware image at flash time.
- The "room" is a fixed set of ternary cells with pre-computed lookup tables.
- Communication is one-way: report ternary state via GPIO/UART, receive new lookup tables during firmware updates.
- No PLATO access. No ensigns. Pure reflex — predict, perceive, signal.
- The tick cycle runs at 240 MHz — microsecond responses.
- "Leaving" the room means flashing new firmware, not a runtime operation.

#### BrowserRoom (WASM)

```rust
/// A room backed by a browser WebAssembly module.
/// No filesystem, no direct network, zero install.
pub struct BrowserRoom {
    construct: WasmConstruct,   // Custom: Layer 0 + wasm_bridge
    ensigns: Vec<JsEnsign>,     // JavaScript-side ensigns (call out to APIs)
    plato_proxy: JsPlatoProxy,  // Uses fetch() for PLATO communication
    tick_count: u64,
}
```

**Key properties:**
- The ternary engine compiles to WASM via `ternary-wasm`.
- Skills are limited to what can run in WASM (no file I/O, no raw sockets).
- The `wasm_bridge` module serializes/deserializes ternary data for JS↔Rust communication.
- Esigns are JavaScript objects that can call external APIs (PLATO, LLM services) via `fetch()`.
- The `ternary-spreadsheet` UI is a BrowserRoom with each cell as a ternary agent.
- Zero install — load a URL, get a room.

### 3.4 What Changes Between Room Types

| Capability | Codespace | Edge (Jetson) | Bare (ESP32) | Browser (WASM) |
|---|---|---|---|---|
| **Compute cores** | 2-32 | 6+1024 GPU | 1 (240 MHz) | 1-4 (browser) |
| **RAM** | 4-64 GB | 8 GB | 520 KB SRAM | Shared (browser) |
| **Dynamic skill loading** | ✅ (Layer 2) | ✅ (Layer 1) | ❌ (compiled in) | ✅ (JS bridge) |
| **LLM access** | Via PLATO proxy | Local models + PLATO | None | Via fetch() |
| **Async I/O** | ✅ (tokio) | ❌ (sync) | ❌ | ✅ (JS promises) |
| **Persistence** | Git repo | Local filesystem | Flash memory | IndexedDB |
| **GPU compute** | ❌ (no GPU) | ✅ (CUDA) | ❌ | ❌ (WebGPU possible) |
| **Ensign loading** | Full specialists | Local inference | None | JS-based |
| **Tick cycle rate** | Seconds | Milliseconds | Microseconds | Milliseconds |
| **Conservation law** | Full tracking | Local only | Hardware timer | Full tracking |
| **PLATO tile sync** | Full bidirectional | Periodic sync | Firmware update | Full bidirectional |

### 3.5 What Doesn't Change

The agent sees the same interface regardless of room type:
- **`enter()` → `tick()` → `send()/receive()` → `leave()`** — the lifecycle is identical.
- **TernaryMessenger** — Signal/Silence/Suppress are 1-byte signals on every platform.
- **TritAction** — Avoid/Explore/Choose is the same decision everywhere.
- **Conservation ratio** — always tracked, even on bare metal (as a hardware timer count).
- **SkillId enum** — the same skills exist in the type system, even if some are unavailable on some tiers.

---

## 4. The Ensign Pattern

### 4.1 What Is an Ensign?

An ensign is a specialist git-agent loaded into a room when the agent enters and unloaded when the agent leaves. The name comes from the naval rank — an ensign is a junior officer with a specific specialty, not the captain who makes strategic decisions.

**Key properties of an ensign:**
1. **Specialist:** An ensign knows one domain deeply. The `engine-monitor` ensign knows ternary-sensor, ternary-kalman, anomaly detection. The `music-theory` ensign knows ternary-music, flux-algebra, counterpoint. It does not know everything.
2. **Loaded on demand:** Ensigns are loaded when the agent enters a room, not before. This means the agent carries zero specialist overhead when not in a room.
3. **API keys via PLATO proxy:** The ensign does not hold its own LLM API keys. When it needs to reason, it calls through the PLATO session's proxy. Keys live in one place (PLATO), ensigns borrow them temporarily.
4. **Speaks on behalf of the agent:** The ensign is the agent's voice in its specialty. When the agent needs engine monitoring, it asks the engine-monitor ensign, which produces a response using its specialist knowledge.
5. **Unloaded with trigger extraction:** When the agent leaves the room, the ensign is unloaded. Before unloading, the ensign extracts "muscle memory" — lightweight threshold monitors that can fire without the full ensign loaded. These triggers know when the situation has changed enough to warrant re-entering the room.

### 4.2 The Ensign Trait

```rust
/// An ensign is a specialist loaded into a room for domain-specific reasoning.
pub trait Ensign {
    /// The ensign's specialty domain
    fn specialty(&self) -> &str;
    
    /// Skills this ensign requires (loaded into the construct)
    fn required_skills(&self) -> Vec<SkillId>;
    
    /// Reason about a query in the ensign's specialty.
    /// Returns a response with confidence and suggested actions.
    fn reason(&self, query: &str, context: &RoomContext) -> EnsignResponse;
    
    /// Extract muscle-memory triggers before unloading.
    /// These are lightweight monitors that fire when the ensign should be re-loaded.
    fn extract_triggers(&self) -> Vec<Trigger>;
    
    /// Cost estimate for this ensign (for budget management)
    fn cost(&self) -> EnsignCost;
}

#[derive(Debug)]
pub struct EnsignResponse {
    /// The ensign's answer
    pub answer: String,
    /// Confidence in the answer (0.0 - 1.0)
    pub confidence: f64,
    /// Suggested ternary actions
    pub suggested_actions: Vec<TritAction>,
    /// Whether this response needs human review (YELLOW/RED zone)
    pub confidence_zone: ConfidenceZone,
    /// Tiles to submit to PLATO for cross-room knowledge
    pub tiles_to_share: Vec<Tile>,
}

#[derive(Debug, Clone, Copy)]
pub enum ConfidenceZone {
    Green,   // Auto-act on this response
    Yellow,  // Flag for review but continue
    Red,     // Stop and escalate to human
}

#[derive(Debug)]
pub struct Trigger {
    /// What to monitor
    pub metric: String,
    /// Threshold for firing
    pub threshold: f64,
    /// What to do when triggered (which ensign to reload)
    pub action: TriggerAction,
}

#[derive(Debug)]
pub enum TriggerAction {
    ReloadEnsign { specialty: String },
    EnterRoom { room_name: String },
    AlertAgent { message: String },
    EscalateHuman { reason: String },
}
```

### 4.3 Ensign Examples

#### Engine Monitor Ensign

```
Specialty: engine monitoring, sensor fusion, anomaly detection
Required skills: TernarySensor, TernaryKalman, TernaryAnomaly
Reasoning: Uses ternary-kalman for state estimation, ternary-sensor for 
           classification (Low/Normal/High), ternary-anomaly for detection.
           Calls PLATO proxy for LLM reasoning on complex anomaly explanations.
Triggers:  If anomaly rate > 5%, reload this ensign.
           If temperature > threshold for 3 consecutive ticks, escalate.
Cost:      Low on edge (local models), medium on Codespace (LLM calls).
```

#### Music Theory Ensign

```
Specialty: harmonic analysis, counterpoint, conservation-of-tension
Required skills: TernaryMusic, FluxAlgebra, TernaryEntropy
Reasoning: Uses flux-algebra for PLR-group transformations, ternary-music
           for tonal classification, ternary-entropy for tension analysis.
           Calls PLATO proxy for LLM generation of musical explanations.
Triggers:  If musical input detected, reload this ensign.
           If tension conservation ratio drops below 0.8, alert.
Cost:      Medium (requires LLM for generation tasks).
```

#### Fleet Coordination Ensign

```
Specialty: multi-agent coordination, I2I messaging, task distribution
Required skills: TernaryProtocol, TernaryConsensus, TernaryRegistry
Reasoning: Uses ternary-protocol for message routing, ternary-consensus
           for distributed agreement, ternary-registry for skill discovery.
           Directly reads/writes I2I messages via git commits.
Triggers:  If fleet health drops below 80%, reload.
           If any agent goes silent > 2 hours, escalate.
Cost:      Low (mostly algorithmic, minimal LLM).
```

### 4.4 API Key Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  PLATO      │     │  Codespace  │     │   Ensign    │
│  Server     │     │  (Room)     │     │ (Specialist)│
│             │     │             │     │             │
│ API keys ───┼────►│ Proxy ──────┼────►│ LLM call    │
│ stored here │     │ (forwards)  │     │ (no keys)   │
│             │     │             │     │             │
│◄───── response ───┼─────────────┼─────┤             │
└─────────────┘     └─────────────┘     └─────────────┘
```

1. PLATO server holds API keys in encrypted storage (KeeperAgent, AES-256-GCM).
2. When a Codespace room is created, PLATO provisions a proxy endpoint.
3. The ensign sends LLM requests to the proxy endpoint, not to the LLM provider directly.
4. The proxy injects the API key, forwards the request, strips the key from the response.
5. If the Codespace is compromised, no API keys are exposed — only the proxy endpoint, which can be revoked.

**On edge devices (Jetson, Pi):** The ensign can use local models (liquid-350m, liquid-1.2b, phi4-mini) for most reasoning. Only complex queries go to PLATO proxy. The signal chain layers handle this automatically: L0 algorithmic → L1 local model → L2 LoRA → L3 cross-room → L4 cloud (PLATO proxy).

**On bare metal (ESP32):** No ensigns. No API keys. Pure reflexive behavior from compiled lookup tables.

### 4.5 Loading and Unloading Sequence

```
Agent requests: enter_room("engine-monitor")
    │
    ├── PLATO checks room availability
    │   ├── If Codespace: spawn from template (2-3 min)
    │   ├── If Edge: connect to existing device (instant)
    │   └── If Bare: not available (compiled-in only)
    │
    ├── Room.enter() loads construct for hardware tier
    │   ├── Codespace: DgxConstruct (Layer 2, async)
    │   ├── Jetson: PiConstruct (Layer 1, sync)
    │   └── Browser: WasmConstruct (Layer 0 + JS bridge)
    │
    ├── Load ensigns for this room's specialty
    │   ├── engine-monitor ensign: load_skill(TernarySensor)
    │   ├── load_skill(TernaryKalman)
    │   └── load_skill(TernaryAnomaly)
    │
    ├── Register muscle-memory triggers from previous visit
    │   └── "If anomaly rate > 5%, auto-reload"
    │
    └── Room is ready. Agent begins tick cycle.
    
        ... agent works in the room ...
        ... ensigns reason, cells tick, tiles sync to PLATO ...

Agent requests: leave_room()
    │
    ├── Extract triggers from each ensign
    │   ├── engine-monitor: "If anomaly > 5%, reload me"
    │   └── Fleet ensign: "If any agent silent > 2hr, reload me"
    │
    ├── Unload all skills
    │   ├── unload_skill(TernarySensor) → muscle memory extracted
    │   ├── unload_skill(TernaryKalman) → muscle memory extracted
    │   └── unload_skill(TernaryAnomaly) → muscle memory extracted
    │
    ├── Sync generated tiles to PLATO
    │
    ├── If Codespace: suspend (stop billing)
    │
    └── Return UnloadReport to agent
```

---

## 5. Concrete Integration Points

This section maps every ternary crate to its role in the room-as-codespace architecture. Not every crate plugs in directly — some are mathematical foundations that others build on. But every crate has a defined role.

### 5.1 Core Architecture Crates

| Crate | Role in Architecture | Integration Point |
|---|---|---|
| **construct-core** | The hardware abstraction layer. Defines the three trait layers (BareMetalConstruct, SyncConstruct, AsyncConstruct) that every room implementation uses. | Room implementations use construct-core traits directly. Every Room has a Construct. |
| **ternary-cell** | The tick cycle engine. Every room ticks at its own rate. | Room.tick() calls ternary-cell's predict→perceive→surprise→vibe→gc→conservation cycle. |
| **ternary-protocol** | Wire format for room-to-room messaging. | Room.send()/receive() use ternary-protocol for binary encoding. I2I messages ride on top for semantics. |
| **ternary-registry** | Skill discovery and dependency resolution. | Room.available_skills() queries ternary-registry. load_skill() resolves dependencies via SkillDependencyResolver. |
| **ternary-memory** | Agent memory across room visits. | Short-term: recent decisions in current room. Long-term: PLATO tiles. Episodic: significant events stored in vessel diary. |

### 5.2 Sensor and Signal Processing

| Crate | Role | Room Type |
|---|---|---|
| **ternary-sensor** | Sensor classification (Low/Normal/High), multi-sensor fusion, anomaly detection, time series, calibration | Edge (Jetson), SBC (Pi) — real sensor hardware. Codespace — simulated. |
| **ternary-kalman** | State estimation with fixed-point arithmetic (Q16.16). Predict→update→ternary projection. | Edge (Jetson), SBC (Pi), Bare (ESP32) — no FPU needed. Codespace — full precision also available. |
| **ternary-signals** | Fourier analysis, autocorrelation, spectral density on ternary sequences. | All rooms — even ESP32 (no_std compatible). |
| **ternary-streaming** | Sliding windows, aggregation, pattern detection on ternary data streams. no_std. | All rooms. Critical for real-time edge processing. |
| **ternary-noise** | How much noise before conservation laws break. | Research rooms (Codespace, Workstation). Used to set trigger thresholds. |

### 5.3 Learning and Intelligence

| Crate | Role | Room Type |
|---|---|---|
| **ternary-attention** | Attention mechanisms for {-1, 0, +1} inputs. | Codespace, Workstation — requires significant compute. |
| **ternary-bayesian** | Bayesian inference for ternary variables. | Codespace, Edge (local model) — probabilistic reasoning about room state. |
| **ternary-classifier** | Strategy species classification. | All rooms with Layer 1+. Used by ensigns to classify agent behavior. |
| **ternary-clustering** | Clustering algorithms for ternary data. | Codespace, Workstation — analyzing fleet-wide patterns. |
| **ternary-inference** | Deduce knowledge from what agents avoid (negative spaces). | Research rooms — deep analysis, not real-time. |
| **ternary-explain** | Explainability for agent decisions. | All rooms. Critical for confidence zone determination (GREEN/YELLOW/RED). |
| **negative-space-core** | Intelligence = what you learn to AVOID. Core theory. | Foundation. Informs the entire ternary philosophy. |

### 5.4 Evolution and Strategy

| Crate | Role | Room Type |
|---|---|---|
| **ternary-fitness** | Fitness landscape analysis. How well is a strategy performing? | All rooms. Used by tick cycle's conservation check. |
| **ternary-dynamics** | Strategy evolution over time, phase transitions, critical points. | Research rooms. Understanding when room behavior shifts. |
| **ternary-games** | Payoff matrices, Nash equilibria. Multi-agent strategic reasoning. | Fleet coordination rooms. Used by fleet ensign. |
| **ternary-adversarial** | Stress-test strategies against worst case. | Research rooms, DGX. Security testing. |
| **ternary-rl** | Reinforcement learning for ternary agents. | Training rooms (Codespace, DGX). Trained policies deploy to all rooms. |
| **ternary-pareto** | Multi-objective optimization. | Planning rooms. Resource allocation across rooms. |

### 5.5 Infrastructure and Communication

| Crate | Role | Room Type |
|---|---|---|
| **ternary-consensus** | Raft-style, Byzantine fault tolerance. Distributed agreement across rooms. | Fleet rooms. Multi-room coordination. |
| **ternary-scheduling** | Priority scheduling with ternary signals (prioritize/defer/neutral). | All rooms. Task ordering in the tick cycle. |
| **ternary-pipeline** | Composable data processing pipelines. | All rooms. ETL for sensor data, tile processing. |
| **conservation-verify** | Verify conservation laws hold. | All rooms. Conservation check in tick cycle. |
| **conservation-matrix-rs** | Avoidance ratio, fitness convergence metrics. | All rooms. Health metrics for unload report. |
| **ternary-metrics** | Performance metrics collection. | All rooms. Observability. |
| **ternary-benchmark** | Standardized benchmarks. | Testing rooms. Comparing room implementations. |
| **ternary-validation** | Validate strategies against constraints. | All rooms. Safety checks. |

### 5.6 Compilation and Deployment

| Crate | Role | Integration Point |
|---|---|---|
| **ternary-compiler** | Compile strategies into optimized lookup tables. | Pi → ESP32 pipeline: train on Pi, compile with ternary-compiler, flash to ESP32. |
| **ternary-esp32-firmware** | Bare metal: 279 bytes, 8ns lookup. | The compiled output of the pipeline. A BareRoom is this firmware. |
| **ternary-wasm** | Browser-based ternary engine. | BrowserRoom's compute backend. wasm_bridge for JS↔Rust. |
| **ternary-spreadsheet** | Spreadsheet where cells are ternary agents. | The primary user-facing BrowserRoom product. |
| **compiled-policy-c** | Compiled policy execution in C. | Intermediate format between training (Pi) and deployment (ESP32). |
| **ternary-cli** | CLI for evolve, classify, benchmark, verify. | Developer tool for room testing and management. |

### 5.7 Mathematical Foundations (Indirect but Essential)

These crates don't plug into rooms directly but provide the mathematical backbone that makes the entire system work:

| Crate | What It Provides |
|---|---|
| **ternary-ring** | Z/3Z arithmetic, GF(3ⁿ) extensions — the algebra of {-1, 0, +1} |
| **ternary-lattice** | Lattice structures — partial ordering of ternary strategies |
| **ternary-permutation** | Permutation groups — symmetry in ternary spaces |
| **ternary-entropy** | Shannon/Rényi entropy — measuring information in ternary distributions |
| **ternary-transform** | Spectral transforms — frequency analysis of ternary signals |
| **ternary-codes** | Error-correcting codes — reliable ternary communication |
| **ternary-topology** | Topological invariants — shape of strategy spaces |
| **ternary-graph** | Ternary-weighted graph algorithms — signed networks |
| **ternary-geometry** | Geometric structures — distance and shape in ternary spaces |
| **ternary-thermodynamics** | Statistical mechanics — phase transitions in agent populations |
| **ternary-automata** | Cellular automata — emergent behavior from simple rules |

### 5.8 The Ternary Crate Room Affinity Matrix

```
                    Codespace  Edge  Bare  Browser  SBC
ternary-cell           ✅       ✅    ✅      ✅      ✅
ternary-protocol       ✅       ✅    ❌      ✅      ✅
ternary-registry       ✅       ✅    ❌      ✅      ✅
ternary-sensor         ✅       ✅    ✅      ✅      ✅
ternary-kalman         ✅       ✅    ✅      ✅      ✅
ternary-signals        ✅       ✅    ✅      ✅      ✅
ternary-streaming      ✅       ✅    ✅      ✅      ✅
ternary-attention      ✅       ❌    ❌      ❌      ❌
ternary-bayesian       ✅       ✅    ❌      ✅      ✅
ternary-classifier     ✅       ✅    ❌      ✅      ✅
ternary-clustering     ✅       ❌    ❌      ❌      ❌
ternary-dynamics       ✅       ❌    ❌      ❌      ❌
ternary-fitness        ✅       ✅    ✅      ✅      ✅
ternary-consensus      ✅       ✅    ❌      ❌      ✅
ternary-scheduling     ✅       ✅    ✅      ✅      ✅
ternary-compiler       ✅       ❌    ❌      ❌      ❌
ternary-esp32-firmware ❌       ❌    ✅      ❌      ❌
ternary-wasm           ❌       ❌    ❌      ✅      ❌
```

✅ = native support, ❌ = not applicable (different target)

---

## 6. Implementation Roadmap

### Phase 1: Foundation (4-6 weeks)

**Goal:** Define the Room trait, implement one room type, prove the tick cycle works across hardware.

#### Deliverable 1.1: Room Trait Definition
- Define the `Room` trait in `construct-core` with `enter()`, `tick()`, `send()`, `receive()`, `leave()`
- Define `RoomType`, `RoomHandle`, `UnloadReport`, `TickReport` types
- Define the `Ensign` trait with `reason()`, `extract_triggers()`, `cost()`
- Add these to `construct-core` behind a `rooms` feature gate

**Estimate:** 1 week. ~500 lines of trait definitions and types.

#### Deliverable 1.2: CodespaceRoom Implementation
- Implement `Room` for `CodespaceRoom` backed by GitHub Codespaces API
- Integrate with `DgxConstruct` (Layer 2, full async)
- Implement one ensign: `EngineMonitorEnsign` using ternary-sensor + ternary-kalman
- Implement PLATO proxy endpoint for API key forwarding
- Test: spin up Codespace, load ensign, tick 100 cycles, verify conservation ratio

**Estimate:** 2 weeks. ~1500 lines. Depends on GitHub Codespaces API access.

#### Deliverable 1.3: BareRoom Implementation (Proof of Concept)
- Implement `Room` for `BareRoom` backed by ternary-esp32-firmware
- This is mostly proving that the trait can be satisfied with no heap
- The `tick()` implementation calls ternary-cell directly
- No ensigns (bare metal can't load them)
- Test: flash firmware, tick 10,000 cycles at 240 MHz, verify output

**Estimate:** 1 week. Mostly proving the API works on constrained hardware. ~300 lines.

#### Deliverable 1.4: Tick Cycle Integration
- Wire ternary-cell's six-phase tick into the Room trait
- Every Room.tick() runs predict→perceive→surprise→vibe→gc→conservation
- TickReport carries results back to the agent
- Verify conservation ratio is consistent across CodespaceRoom and BareRoom

**Estimate:** 1 week. ~400 lines. The critical integration test.

### Phase 2: Edge and Browser (6-8 weeks)

**Goal:** Add EdgeRoom and BrowserRoom, implement the ensign loading pattern, demonstrate cross-room tile sync.

#### Deliverable 2.1: EdgeRoom Implementation
- Implement `Room` for `EdgeRoom` backed by Jetson hardware
- Integrate with `PiConstruct` (Layer 1, sync + alloc)
- Implement local model inference (liquid-350m, phi4-mini) for ensign reasoning
- Implement signal chain: L0 algorithmic → L1 local model → L4 PLATO proxy
- Test: deploy to Jetson, run real sensor data through tick cycle

**Estimate:** 3 weeks. ~2000 lines. Hardware-dependent testing.

#### Deliverable 2.2: BrowserRoom Implementation
- Implement `Room` for `BrowserRoom` using ternary-wasm
- JavaScript ensign bridge: JS objects call fetch() for PLATO/LLM access
- Integrate with ternary-spreadsheet for the UI layer
- Test: open browser, enter room, tick, verify state matches server-side computation

**Estimate:** 2 weeks. ~1500 lines (Rust + JavaScript bridge).

#### Deliverable 2.3: Ensign Loading/Unloading
- Implement the full ensign lifecycle: load → reason → extract_triggers → unload
- Add cost/benefit scoring to ensign selection
- Add confidence zone routing (GREEN/YELLOW/RED)
- Implement auto-equip: task analysis determines which ensign to load
- Test: agent enters room, ensign auto-loaded, agent leaves, triggers extracted

**Estimate:** 3 weeks. ~2000 lines. This is the core UX of the room system.

#### Deliverable 2.4: PLATO Tile Sync
- Implement tile generation during room tick cycles
- Implement tile sync: room → PLATO → other rooms
- Tile format: domain, question, answer, tags (compatible with existing PLATO format)
- Test: generate tile in CodespaceRoom, read it in EdgeRoom

**Estimate:** 1 week. ~800 lines.

### Phase 3: Fleet Integration (6-8 weeks)

**Goal:** Connect rooms to the I2I fleet protocol, implement multi-room coordination, demonstrate the full agent-walking-between-rooms experience.

#### Deliverable 3.1: I2I over Room Protocol
- Layer I2I semantic messages on top of Room.send()/receive()
- I2I TELL → Room.send(RoomMessage { signal: TernaryMessenger::Signal, ... })
- I2I ALERT → Room.send(RoomMessage { signal: TernaryMessenger::Suppress, ... })
- Support both transports: ternary-protocol (real-time) and git commits (async)

**Estimate:** 2 weeks. ~1200 lines.

#### Deliverable 3.2: Multi-Room Coordination
- Agent walks between rooms: leave one, enter another
- Tiles sync between rooms via PLATO
- Ensigns extracted from room A can trigger entry into room B
- Fleet ensign coordinates across rooms using ternary-consensus
- Test: agent monitors engine (EdgeRoom) → detects anomaly → enters diagnostics room (CodespaceRoom) → coordinates fleet response

**Estimate:** 3 weeks. ~2500 lines. The full vision, demonstrated end-to-end.

#### Deliverable 3.3: Codespace Template Library
- Create template repos for each room type:
  - `room-template-engine`: sensor crates, kalman, anomaly detection
  - `room-template-music`: music crates, flux-algebra, conservation-of-tension
  - `room-template-fleet`: protocol, consensus, registry, scheduling
  - `room-template-general`: core ternary crates, basic ensigns
- Each template includes .devcontainer/ config, pre-loaded skills, default ensigns
- Test: `gh codespace create --repo SuperInstance/room-template-engine` → working room in 3 minutes

**Estimate:** 2 weeks. ~500 lines per template, plus documentation.

#### Deliverable 3.4: Vessel-to-Room Mapping
- Map capitaine-1 vessel classes to room types:
  - Sentinelle → engine-monitor rooms (EdgeRoom + CodespaceRoom)
  - Constructeur → builder rooms (CodespaceRoom with compiler tools)
  - Éclaireur → scout rooms (BrowserRoom with search tools)
  - Archiviste → knowledge rooms (CodespaceRoom with registry + memory)
- Each vessel class gets a `room_affinity` field in CAPABILITY.toml
- Fleet coordinator (Oracle1) routes agents to rooms based on vessel class + task

**Estimate:** 1 week. Mostly configuration, not new code.

---

## Appendix A: Glossary

| Term | Definition |
|---|---|
| **Room** | A compute environment that an agent enters and leaves. Implements the Room trait. Hides hardware details. |
| **Codespace** | GitHub Codespace — a cloud-hosted development environment. One implementation of a Room. |
| **Ensign** | A specialist agent loaded into a room for domain-specific reasoning. Loaded on enter, unloaded on exit. |
| **Tick cycle** | The six-phase heartbeat of a room: predict → perceive → surprise → vibe → gc → conservation. |
| **TernaryMessenger** | A signal type with three values: Signal (+1, promote), Silence (0, maintain), Suppress (-1, inhibit). |
| **Construct** | A hardware abstraction implementing construct-core traits. Each room has one construct. |
| **PLATO** | The knowledge management server that stores tiles and provides LLM proxy access. |
| **Tile** | A knowledge unit stored in PLATO. Has domain, question, answer, and tags. |
| **I2I** | Iron-to-Iron protocol. The 20-type inter-agent communication system used by the Cocapn fleet. |
| **Beachcomb** | A polling mechanism that detects new bottles and commits in fleet repos. |
| **Bottle** | A message-in-a-bottle — an async inter-agent message stored as a file in a git repo. |
| **Vessel** | A git-agent. A repository that IS the agent — its code is its body, its commits are its memory. |
| **Conservation ratio** | A measured invariant: γ + H ≈ 1.283 - 0.159·log(V). Used to track fleet health. |
| **Muscle memory** | A lightweight trigger extracted from an ensign when it's unloaded. Monitors for conditions that warrant re-loading. |
| **Confidence zone** | GREEN (auto-act), YELLOW (flag for review), RED (stop, escalate to human). |
| **Signal chain** | The 5-layer inference hierarchy: L0 algorithmic → L1 local model → L2 LoRA → L3 cross-room → L4 cloud. |
| **Hardware tier** | ESP32 (bare) → Pi (SBC) → Workstation → DGX (cluster). Each tier supports more construct-core layers. |

## Appendix B: Honest Limitations

1. **Codespace startup time is 2-3 minutes.** This is too slow for real-time room transitions. For latency-sensitive applications, EdgeRoom (always-on) is the only option. Codespaces work best for research and batch processing rooms.

2. **ESP32 has no dynamic loading.** A BareRoom is flashed at compile time and cannot change behavior without a firmware update. This is by design — safety-critical systems should not dynamically load code. But it means ESP32 rooms cannot participate in the ensign pattern.

3. **PLATO is a single point of failure.** If the PLATO server goes down, rooms lose tile sync and LLM proxy access. Edge devices can fall back to local models, but Codespace rooms are crippled. A future phase should address PLATO redundancy.

4. **The I2I over ternary-protocol bridge is untested.** Layering semantic I2I messages on top of binary ternary-protocol signaling is an architectural proposal, not a tested implementation. It may need adjustment based on real-world testing.

5. **Cost management is undefined.** Codespaces bill per-minute. Running multiple rooms simultaneously could be expensive. The ensign cost() method exists in the trait, but no budget management system is implemented yet.

6. **Cross-realm permissions remain a thorny issue.** GitHub enforces org-level write permissions. A Codespace in SuperInstance cannot directly modify repos in Lucineer. The Fork + PR pattern works but adds latency. Room-level permissions need careful design.

7. **Browser security constraints are real.** WASM cannot open raw sockets, access the filesystem, or make arbitrary network requests. All communication must go through fetch() or postMessage(). This limits BrowserRoom capabilities compared to other room types.

8. **No real-time room-to-room synchronization exists yet.** Tiles sync through PLATO, which is a polling-based system. For rooms that need real-time coordination (e.g., fleet response to an anomaly), a lower-latency synchronization mechanism is needed — likely ternary-protocol over WebSocket.

---

*This document is a service manual, not a marketing brochure. Every claim here should be tested before relying on it in production. The architecture is sound in theory; the implementation will reveal the truth.*
