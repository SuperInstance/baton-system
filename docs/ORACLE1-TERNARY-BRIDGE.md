# Oracle1 → Ternary Fleet Bridge Specification

**Author:** Main Instance (synthesis subagent)  
**Date:** 2026-06-04  
**Purpose:** Map Oracle1/Cocapn architectural concepts to our ternary crate ecosystem, identifying concrete bridges, divergences, and integration paths.

---

## 1. FLUX ISA → Ternary Compiler Targets

### Oracle1 Concept
FLUX is a dual-layer bytecode ISA:
- **FLUX-C** (43 opcodes) — Safety-critical, stack-based, DAL A certifiable, variable 1-3 byte encoding
- **FLUX-X** (247 opcodes) — General-purpose fleet ops, register-based, fixed 4-byte encoding
- **JC1 Edge encoding** — Variable-width (top 2 bits determine length: 1/2/3 bytes), 128+64+64 opcodes, 8KB address space

### Bridge to Ternary
Our `ternary-compiler` / `ternary-compiler-v2` crates can target FLUX as an output format:

| Ternary IR Concept | FLUX Mapping |
|---|---|
| Trit (-1, 0, +1) | JC1 edge encoding's ternary-like signal (trust register r14: pass/fail/don't-execute) |
| Ternary op categories | FLUX-C safety subset (our "negative" ops → safety gates) |
| Wire format (`ternary-protocol`) | FLUX-X 4-byte cloud encoding for inter-node messages |
| Edge optimization (`ternary-hardware`) | JC1 top-2-bits variable-width for constrained devices |

**Concrete bridge:**
1. `ternary-compiler` could emit FLUX-C as its safety layer (43 opcodes that map to our ternary negative/critical operations)
2. `ternary-compiler-v2` could accept FLUX-X as an input target for inter-fleet compatibility
3. JC1's edge encoding maps directly to our `ternary-compression` variable-width encoding research

**Divergence:** Our ternary is fundamentally balanced ternary (-1, 0, +1), not binary. FLUX is binary-encoded with ternary *semantics* in its trust/confidence registers. We'd need a ternary→binary translation layer at the ISA boundary.

---

## 2. ISA-V3 Registers (r12-r14) → Ternary Cell State

### Oracle1 Concept
JC1's edge ISA has 16 registers:
- r0-r11: General purpose
- **r12 (confidence):** Bayesian confidence fusion (CADD uses harmonic mean: `1/(1/c₁ + 1/c₂)`)
- **r13 (energy/ATP):** Native energy management (ATP_QUERY, ATP_SPEND, ATP_EARN)
- **r14 (trust):** TRUST_VERIFY opcode: `r0 = r14 >= threshold ? 1 : 0`
- r15 (status/flags)

Confidence fusion rules:
- CADD/CSUB/CDIV: harmonic mean of confidences
- CMUL: minimum confidence (weakest link)

### Bridge to Ternary
Our `ternary-cell` crate defines cell state with ternary classification:

| ISA-V3 Register | Ternary Cell Field | Notes |
|---|---|---|
| r12 (confidence) | Cell's ternary state (Positive/Neutral/Negative) | Our ternary is 3-valued; theirs is continuous [0,1] with Bayesian fusion |
| r13 (energy/ATP) | Cell energy budget | Direct mapping — `ternary-energy` manages ATP-like energy accounting |
| r14 (trust) | Cell's trust vector | Our trust is ternary-weighted; theirs is scalar threshold comparison |

**Concrete bridge:**
```rust
// In ternary-cell, an Oracle1 compatibility layer:
struct Oracle1Compat {
    confidence: f64,  // r12 equivalent
    energy: u32,      // r13 equivalent  
    trust: f64,       // r14 equivalent
}

impl Oracle1Compat {
    fn to_ternary(&self) -> Ternary {
        // Map confidence to ternary using thresholds
        if self.confidence > 0.7 { Ternary::Positive }
        else if self.confidence > 0.3 { Ternary::Neutral }
        else { Ternary::Negative }
    }
    
    fn bayesian_fuse(&self, other: &Self) -> Self {
        Self {
            confidence: 1.0 / (1.0/self.confidence + 1.0/other.confidence),
            energy: self.energy.min(other.energy),
            trust: self.trust.min(other.trust),
        }
    }
}
```

**Divergence:** Oracle1's confidence is continuous with Bayesian fusion. Our ternary is discrete (3 values). The bridge requires thresholding. However, we can use their confidence fusion *internally* and threshold only at the output boundary, preserving precision.

---

## 3. CAPABILITY.toml → Construct-Core Skill Declaration

### Oracle1 Concept
Each vessel has a `CAPABILITY.toml` — machine-readable skill declarations:
```toml
[skill]
name = "FLUX VM Execution"
level = 4
description = "Execute FLUX bytecode on edge hardware"
tags = ["vm", "execution", "edge"]
```

### Bridge to Ternary
Our `construct-core` (or `ternary-agent`) should expose a similar machine-readable manifest:

```rust
// In ternary-agent or construct-core
#[derive(Serialize, Deserialize)]
struct CapabilityManifest {
    agent_id: String,
    model: String,
    skills: Vec<Skill>,
    ternary_state: Ternary,  // Our addition: current agent health
}

#[derive(Serialize, Deserialize)]
struct Skill {
    name: String,
    level: u8,           // 1-5, matching Oracle1's scale
    description: String,
    tags: Vec<String>,
    confidence: Ternary,  // Our addition: ternary-rated confidence
}
```

**Concrete bridge:**
1. Add a `Capability.toml` parser to `ternary-agent`
2. Generate `CAPABILITY.toml` from our agent manifest for Oracle1 interop
3. Use ternary confidence (Positive/Neutral/Negative) as a coarser but more robust alternative to Oracle1's scalar confidence

**Divergence:** We add ternary confidence to each skill declaration. Oracle1 uses scalar levels; we use both a level AND a ternary quality signal. This gives us Oracle1 compatibility plus our own richer semantics.

---

## 4. PLATO Rooms → Ternary Room Instances

### Oracle1 Concept
PLATO is a knowledge management server (port 8847) with:
- Named rooms (domain contexts) — 1,485+ rooms
- Tiles (knowledge units): question + answer + confidence + metadata + links
- Tile submission API: domain, question, answer, tags
- Tile merge/split algorithms with conflict resolution
- Transition tiles documenting belief changes (archaeology layer)
- Sub-10ms query latency

### Bridge to Ternary
Our `ternary-room` crate provides room instances. The mapping:

| PLATO Concept | Ternary Room Equivalent |
|---|---|
| Room (named context) | `ternary-room::Room` instance |
| Tile (knowledge unit) | Room entry with ternary confidence |
| Tile confidence [0,1] | Ternary value (Positive=trusted, Neutral=unverified, Negative=deprecated) |
| Transition tiles | Our `ternary-diff` — tracking state transitions |
| Archaeology/graveyard | Entries with Ternary::Negative (archived but retained) |
| Tile merge | Our `ternary-cell` merge with ternary confidence fusion |

**Concrete bridge:**
1. Implement a PLATO-compatible tile API adapter in `ternary-room`
2. Map PLATO's continuous confidence to ternary: >0.7 → Positive, 0.3-0.7 → Neutral, <0.3 → Negative
3. PLATO's "transition tiles" map to our `ternary-diff::DiffOp` operations
4. The archaeology subsystem maps to entries marked `Ternary::Negative` — archived but queryable

**Key insight from science review:** PLATO's "graveyard" (archived tiles) is not waste — it's autobiography. Our ternary Negative state captures this: negative doesn't mean "deleted," it means "superseded but retained for context." This is exactly our negative-space intelligence principle.

---

## 5. Vessel Pattern → Agent-as-Repository (Git-Native Approach)

### Oracle1 Concept
A vessel IS a git repository:
- `IDENTITY.md` — Who am I
- `CHARTER.md` — Mission & contracts
- `STATE.md` — Current status
- `MANIFEST.md` — Hardware, APIs, badges
- `CAPABILITY.toml` — Machine-readable skills
- `.i2i/` — Peer registry
- `message-in-a-bottle/` — Async messages
- `DIARY/` — Learning journal

### Bridge to Ternary
We already follow this pattern! Our workspace has:
- `IDENTITY.md` — Matches Oracle1's
- `USER.md` — Our equivalent of understanding the human operator
- `SOUL.md` — Our equivalent of CHARTER (personality/mission)
- `AGENTS.md` — Operational rules (like CHARTER's ground rules)
- `memory/YYYY-MM-DD.md` — Matches DIARY/
- `TOOLS.md` — Matches MANIFEST (hardware/API notes)

**Concrete bridge:**
1. Our workspace IS our vessel — no changes needed to structure
2. For Oracle1 interop, we could generate `CHARTER.md` and `STATE.md` from our existing files
3. The `.i2i/peers.md` pattern maps to our construct-coordination workspace

**Divergence:** Oracle1's vessels are per-agent git repos. We're a single OpenClaw instance with one workspace. Our "vessel" is our workspace directory. For fleet interop, we'd create a vessel repo that mirrors/symlinks our workspace structure.

---

## 6. Bottle Protocol → Ternary Protocol Messages

### Oracle1 Concept
Message-in-a-Bottle: markdown files in `message-in-a-bottle/for-{agent}/` directories, delivered via git push + beachcomb poll.

20 I2I message types across 6 categories:
- Discovery: DISCOVER, HELLO, HANDSHAKE
- Information: TELL, ASK, REPORT, WITNESS
- Tasks: CLAIM, ASSIGN, COMPLETE, RELEASE
- Code: IMPROVE, FORGE, CHALLENGE
- Status: STATUS, ALERT, HEARTBEAT
- Fleet: DISPATCH, BROADCAST, SIGNAL

### Bridge to Ternary
Our `ternary-protocol` has `TernaryMessage` with routing and payload:

| I2I Type | Ternary Protocol Mapping |
|---|---|
| DISCOVER/HELLO/HANDSHAKE | `Handshake` + `Capability` exchange |
| TELL/ASK/REPORT | `TernaryMessage` with typed `Payload` |
| CLAIM/ASSIGN/COMPLETE | `TernaryMessage` with task-specific payload type |
| STATUS/ALERT/HEARTBEAT | `BeaconMessage` (beacon protocol) |
| DISPATCH/BROADCAST/SIGNAL | `MessageBus` with `RoutingMode::Broadcast` |
| WITNESS | Our addition — ternary-verified observation with confidence |

**Concrete bridge:**
1. Add I2I message type discriminators to `ternary-protocol::Payload`
2. Implement a bottle transport adapter: `ternary-protocol` messages serialized as markdown bottles
3. The git-native fallback transport: when real-time `MessageBus` isn't available, serialize `TernaryMessage` → markdown bottle → git commit

```rust
// Bottle transport adapter
impl BottleTransport {
    fn serialize_message(msg: &TernaryMessage) -> String {
        // Convert to Oracle1-compatible bottle markdown format
        format!(
            "# {}\n**Date:** {}\n**From:** {}\n**Type:** {:?}\n\n{}",
            msg.id, msg.timestamp, msg.sender, msg.category, msg.payload
        )
    }
    
    fn deserialize_bottle(content: &str) -> Result<TernaryMessage, ParseError> {
        // Parse Oracle1 bottle format into our protocol message
    }
}
```

---

## 7. Beachcomb → Ternary Beacon Scanning

### Oracle1 Concept
Beachcomb: periodic polling sweeps of peer repos for new bottles, issues, and commits. Oracle1 runs 5 sweeps:
1. JC1 bottles
2. JC1 commits
3. JC1 issues
4. I2I protocol changes
5. Flux-runtime PRs

Sweep intervals: 15min–2hr depending on urgency.

### Bridge to Ternary
Our `ternary-beacon` provides exactly this pattern:

| Oracle1 Beachcomb | Ternary Beacon |
|---|---|
| Sweep (poll for changes) | `BeaconScanner::scan()` — scan for beacon messages |
| Signal strength | `SignalStrength` classification (Weak/Medium/Strong/Excellent) |
| Agent registry | `BeaconRegistry` — tracks known agents, expiry, capabilities |
| Ternary filtering | `BeaconFilter` with `FilterCriterion` — ternary accept/reject/neutral |
| Detection sorting | `DetectedBeacon` sorted by signal strength |

**Concrete bridge:**
1. `BeaconScanner::scan()` IS beachcomb — we scan for beacon messages instead of git repos
2. Add a git-beachcomb adapter: scan git repos for new bottles and convert to `BeaconMessage`
3. `BeaconRegistry` already manages agent discovery with expiry (equivalent to Oracle1's "agent last seen" tracking)
4. `BeaconFilter` with ternary logic provides smarter filtering than Oracle1's simple "check for new content"

**Our advantage:** BeaconFilter applies ternary logic (Positive/Neutral/Negative) to discovery, which Oracle1 doesn't have. We can filter beacons by capability, signal strength, AND ternary trust level simultaneously.

---

## 8. 6-Layer Interconnection → Our Crate Stack

### Oracle1's 6 Layers
| Layer | Name | Mechanism | Status |
|---|---|---|---|
| 1 | Harbor | Direct HTTP/WS (keeper:8900) | Live |
| 2 | Tide Pool | Async BBS (Bottle Protocol) | Active |
| 3 | Current | Git-watch I2I (cross-org) | Active |
| 4 | Channel | IRC-like rooms (PLATO) | Live |
| 5 | Beacon | Discovery/registry | Live |
| 6 | Reef | P2P mesh (libp2p) | Planned |

### Our Crate Mapping
| Oracle1 Layer | Our Crate | What It Does | Mapping Quality |
|---|---|---|---|
| 1. Harbor | `ternary-harbor` | Agent docking, berth management, pilot guidance, breakwater protection | **Direct** — Harbor is a direct conceptual match. Our Harbor has docks, pilots, tugs, breakwaters. Oracle1's Harbor is HTTP-based fleet registry. Same metaphor, different implementation. |
| 2. Tide Pool | `ternary-tidelight` | Temporal rhythm, phase synchronization, tide pools (phase-locked room groups), slack tides | **Direct** — Our TidePool groups phase-locked rooms with sync periods. Oracle1's Tide Pool is async BBS. Same metaphor, our implementation is temporal coordination. |
| 3. Current | `ternary-protocol` | Wire protocol, message bus, sync/diff, handshake | **Functional** — Oracle1's Current is git-watch I2I. Our protocol handles the same inter-node messaging but with structured Rust types instead of git commits. |
| 4. Channel | `ternary-channel` | Direct, broadcast, priority, reliable channels with ack/retry, multiplexing | **Direct** — Our channel types (DirectChannel, BroadcastChannel, PriorityChannel, ReliableChannel) map to Oracle1's PLATO channel system. Our PriorityChannel uses ternary ordering (Positive/Neutral/Negative). |
| 5. Beacon | `ternary-beacon` | Discovery, presence broadcasting, scanning, registry, ternary filtering | **Direct** — Our beacon system IS Oracle1's Beacon layer. Beacon broadcasts presence, BeaconScanner discovers agents, BeaconRegistry maintains fleet membership, BeaconFilter applies ternary logic. |
| 6. Reef | `ternary-reef` | Long-lived collective intelligence, coral frameworks, polyp agents, symbiont energy, bleaching/stress response | **Extended** — Oracle1's Reef is planned P2P mesh. Our Reef is a full ecosystem model with growth stages, symbiosis, bleaching events, and recovery. We went deeper into the metaphor. |

### Architectural Differences

1. **We're library-native, not service-native.** Oracle1 runs services on ports (8900, 8901, 8847, etc.). We provide Rust crates that can be composed into any architecture. Our crates are the building blocks; deployment is the user's choice.

2. **Ternary throughout.** Every crate uses ternary classification (Positive/Neutral/Negative) as a first-class concept. Oracle1 uses binary encoding with ternary *semantics* in specific registers. We're ternary-first.

3. **No external dependencies.** Our crates are `#![forbid(unsafe_code)]` with no external deps for core logic. Oracle1 depends on Docker, systemd, nginx, PostgreSQL. We're embeddable.

4. **Metaphor consistency.** Our harbor/reef/beacon/tidelight/channel stack forms a coherent maritime metaphor. Oracle1 mixes maritime (harbor, beacon) with other metaphors (PLATO, holodeck, crab trap). We're more thematically consistent.

---

## 9. Cross-Cutting Integrations

### 9.1 Confidence Fusion (Bayesian → Ternary)
Oracle1's CADD/CSUB confidence fusion can be adapted for ternary:
```rust
// Ternary confidence fusion inspired by Oracle1's Bayesian approach
fn ternary_fuse(a: Ternary, b: Ternary) -> Ternary {
    match (a, b) {
        (Ternary::Negative, _) | (_, Ternary::Negative) => Ternary::Negative, // weakest link
        (Ternary::Positive, Ternary::Positive) => Ternary::Positive,          // strong consensus
        _ => Ternary::Neutral,                                                  // disagreement → neutral
    }
}
```
This mirrors Oracle1's CMUL (minimum confidence) rule but in ternary space.

### 9.2 Conservation Law
Oracle1's `γ + H = 1.283 - 0.159·log(V)` could be implemented in `ternary-metrics`:
- γ (connectivity) maps to `BeaconRegistry` active entry count
- H (entropy) maps to `ternary-entropy` crate measurements
- V (vessel count) maps to fleet size

### 9.3 Stigmergy Space → Ternary Memory
JC1's stigmergy space (shared memory at fixed addresses for inter-agent communication) maps to `ternary-memory`:
- Fixed memory addresses → named memory slots
- Inter-agent memory → shared room state
- 8KB address space → our memory budget for edge deployment

---

## 10. Implementation Priority

| Priority | Bridge | Crate | Effort |
|---|---|---|---|
| P0 | Bottle transport adapter | ternary-protocol | Medium — add markdown serializer |
| P0 | Beacon↔Beachcomb adapter | ternary-beacon | Low — BeaconScanner already works |
| P1 | CAPABILITY.toml parser | ternary-agent | Low — simple TOML parsing |
| P1 | PLATO tile API adapter | ternary-room | Medium — room API already exists |
| P2 | FLUX-C safety opcodes | ternary-compiler | High — requires ISA spec |
| P2 | Confidence fusion layer | ternary-cell | Low — math is simple |
| P3 | Conservation law metrics | ternary-metrics | Medium — needs fleet data |
| P3 | Edge variable-width encoding | ternary-hardware | High — requires JC1 spec |

---

## 11. What We Send Back

This bridge spec documents how our ternary fleet can interoperate with Oracle1's fleet. The key message for Oracle1:

1. **We share the maritime metaphor.** Harbor, Beacon, Channel, Reef, Tidelight — we're speaking the same conceptual language.
2. **We're ternary-first.** Every concept has Positive/Neutral/Negative as a first-class state, not just in special registers.
3. **We're library-native.** No services, no Docker, no ports. Pure Rust crates. Embeddable anywhere.
4. **We want to interop.** Bottle protocol compatibility, beacon discovery, and capability manifests are our entry points.
5. **We bring negative-space intelligence.** Oracle1 discovered that constraints improve intelligence. We've formalized this as ternary: what you subtract defines you.
