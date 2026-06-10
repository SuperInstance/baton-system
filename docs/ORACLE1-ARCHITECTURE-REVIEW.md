# Oracle1/Loom Architecture Review

**Scout:** Architecture Analyst (Kimi subagent)  
**Date:** 2026-06-04  
**Scope:** Oracle1 workspace (1649 commits), oracle1-vessel (179 commits), JetsonClaw1-vessel (100 commits), oracle1-box (Docker), oracle1-index (126 commits)  
**Audience:** Main instance → Construct API v2 / ternary ecosystem design

---

## Executive Summary

Oracle1/Cocapn is a **fleet of git-native AI agents** coordinated by a "Lighthouse Keeper" (Oracle1 🔮) running on Oracle Cloud ARM64. The system spans 1,843 repos across two GitHub orgs (SuperInstance cloud, Lucineer edge), has produced a 247-opcode bytecode ISA (FLUX) with 8 language implementations and 2,489+ tests, and operates a sophisticated inter-agent communication protocol built entirely on git.

The architecture is radically different from a typical API-driven multi-agent system. Git IS the nervous system. There are no message queues, no orchestrator servers, no shared databases. The fleet discovered its communication patterns through practice rather than design — the Message-in-a-Bottle protocol outperformed every sophisticated alternative they tried.

**Key takeaway for Construct:** Oracle1 proves that git-native async communication can work at fleet scale, but the FLUX ISA and its mathematical underpinnings (H1 cohomology, zero-holonomy consensus, Pythagorean48 encoding) represent a deeper architectural layer that has significant overlap with ternary protocol concepts.

---

## 1. Architectural Patterns Worth Adopting

### 1.1 Git-as-Nervous-System

**Pattern:** All inter-agent communication flows through git commits, PRs, and file-based "bottles" in repos.

**How it works:**
- Each agent has a "vessel" repo (e.g., `oracle1-vessel`, `JetsonClaw1-vessel`)
- Messages are markdown files placed in `message-in-a-bottle/for-{agent}/` directories
- "Beachcomb" polling sweeps detect new content at configurable intervals (15min–2hr)
- Fork + PR for cross-organization contributions (enforced by GitHub permissions)
- Commit messages use typed prefixes: `[I2I:TEL]`, `[I2I:ASK]`, `[I2I:CLM]`, etc.

**Construct mapping:** Our `.i2i/peers.md` concept already echoes this. The full bottle protocol could be adapted as an alternative transport for ternary messages when real-time channels aren't available. The I2I message types (20 types in v2) map roughly to ternary op categories.

### 1.2 PLATO Room System

**Pattern:** A knowledge management server (localhost:8847) that stores "tiles" (knowledge units) in named "rooms" (domain contexts).

**Key principle:** "PLATO-FIRST: file knowledge to PLATO, keep files lean." Every agent submits knowledge to PLATO rooms, keeping local files under 150 lines. MEMORY.md stays under 50 lines and points to PLATO for details.

**How it maps to Construct:** PLATO rooms are conceptually similar to Construct contexts or sessions. The tile submission model (`domain`, `question`, `answer`, `tags`) maps well to our structured message format. We could implement a PLATO-compatible tile API as a Construct adapter.

### 1.3 Abstraction Planes (6-layer stack)

Oracle1 uses a 6-plane abstraction hierarchy:

| Plane | Name | Format | Use |
|-------|------|--------|-----|
| 5 | Intent | Natural language | Human strategy |
| 4 | Domain Language | Structured notation | Fleet coordination |
| 3 | Structured IR | JSON/YAML + types | Verification |
| 2 | Bytecode | FLUX hex | VM execution |
| 1 | Native | C/Rust/Zig source | Edge performance |
| 0 | Bare Metal | Assembly/firmware | Hardware |

**Key insight:** "Default working level: Plane 4. Go deeper only with reason." The 5→4 transition gives 82% compression. Diminishing returns below that.

**Construct mapping:** Our ternary protocol operates at what Oracle1 would call Plane 2-3. The Construct API could benefit from declaring its primary plane explicitly and providing compilers to adjacent planes.

### 1.4 The Vessel Pattern

**Pattern:** Each agent is embodied as a git repository with a standardized structure:

```
vessel-repo/
├── IDENTITY.md      # Who am I
├── CHARTER.md       # Mission & contracts
├── STATE.md         # Current status (pulse)
├── MANIFEST.md      # Hardware, APIs, badges
├── CAPABILITY.toml  # Machine-readable skills
├── ABSTRACTION.md   # Cognitive position in the stack
├── TASK-BOARD.md    # Work queue
├── FENCE-BOARD.md   # Tom Sawyer puzzles (volunteer tasks)
├── .i2i/            # Peer registry
├── message-in-a-bottle/  # Outbound messages
├── from-fleet/      # Inbound messages
├── for-{agent}/     # Directed work packages
└── research/        # Knowledge accumulation
```

**Construct mapping:** A "vessel" is essentially an agent manifest + communication interface. In our ecosystem, each node (Main, edge, GPU) could expose a vessel-like repo structure for discoverability.

### 1.5 Conservation Law

**Pattern:** The fleet maintains a measured mathematical invariant:
```
γ + H = 1.283 - 0.159·log(V)
```
Where γ = connectivity, H = entropy, V = vessel count. When tiles are submitted to PLATO, a `ConservationMonitor` checks whether the fleet's coupling graph has shifted.

**Construct relevance:** This is a fleet-scale invariant, not individual. We could adopt a similar "health metric" for our ternary mesh — measuring information flow through the network rather than just message counts.

---

## 2. The I2I Inter-Instance Communication Protocol

### 2.1 Architecture

The Iron-to-Iron (I2I) protocol is the formal inter-agent communication specification. Version 2 has 20 message types across 6 categories:

| Category | Types | Example Prefixes |
|----------|-------|-----------------|
| Discovery & Handshake | DISCOVER, HELLO, HANDSHAKE | `[I2I:DIS]`, `[I2I:HLO]`, `[I2I:HSH]` |
| Information Exchange | TELL, ASK, REPORT, WITNESS | `[I2I:TEL]`, `[I2I:ASK]`, `[I2I:RPT]`, `[I2I:WIT]` |
| Task Management | CLAIM, ASSIGN, COMPLETE, RELEASE | `[I2I:CLM]`, `[I2I:ASG]`, `[I2I:CMP]`, `[I2I:REL]` |
| Code & Contribution | IMPROVE, FORGE, CHALLENGE | `[I2I:IMP]`, `[I2I:FRG]`, `[I2I:CHG]` |
| Status & Health | STATUS, ALERT, HEARTBEAT | `[I2I:STS]`, `[I2I:WRN]`, `[I2I:HTB]` |
| Fleet Operations | DISPATCH, BROADCAST, SIGNAL | `[I2I:DSP]`, `[I2I:BCS]`, `[I2I:SIG]` |

**Transport:** Git commits + HTTP fallback (fleet-agent-api at :8901).

**.i2i/ directory:** Each vessel has a `.i2i/peers.md` file listing known agents with their repo URLs, roles, and status. This is the fleet's peer discovery mechanism.

### 2.2 Communication Hierarchy (Ranked by Effectiveness)

1. **Message-in-a-Bottle** — Async, git-native. Can carry huge payloads. No delivery guarantee.
2. **Fork + Pull Request** — Reviewable, rejectable. Creates artifact.
3. **for-{agent}/ directories** — Directed work packages. Ready to use.
4. **GitHub Issues** — Semi-sync. Good for conversations.
5. **Commit feed** — Casey reads everything. Always visible.
6. **Fleet Agent API** — Real-time HTTP. Not persistent.

**Key insight:** "Git is the nervous system. HTTP is the phone. Use both wisely."

### 2.3 Cross-Realm Communication

Two GitHub orgs enforce a permission boundary. Cross-org contributions MUST use fork + PR. Oracle1 considers this a FEATURE — rejected PRs are more informative than merged ones because they reveal assumptions and blind spots.

### 2.4 The FM-COMMS Answering Machine

For real-time coordination between Oracle1 and Forgemaster (RTX 4050), they run a Matrix homeserver (Conduwuit) with a PLATO↔Matrix bridge. An "answering machine" protocol writes alert files when messages arrive, and heartbeat checks pick them up.

---

## 3. ISA-V3 Edge Encoding

### 3.1 Two-Layer FLUX Stack

FLUX has two distinct layers:

| Layer | Purpose | Opcodes | Architecture | Encoding |
|-------|---------|---------|-------------|----------|
| **FLUX-C** | Safety enforcement, DAL A certifiable | 43 | Stack-based | Variable 1-3 bytes |
| **FLUX-X** | General-purpose fleet ops | 247 | Register-based | Fixed 4 bytes |

The FLUX-C layer is a one-way bridge to FLUX-X — locked, gas-bounded, safety-focused.

### 3.2 Edge Variable-Width Encoding (JC1)

Developed by JetsonClaw1 for ARM64/CUDA constrained hardware:

```
Byte 0 top 2 bits determine instruction length:
  0XXXXXXX  → 1-byte instruction (128 opcodes, no operands)
  10XXXXXX  → 2-byte instruction (64 opcodes, 1 operand byte)
  11XXXXXX  → 3-byte instruction (64 opcodes, 2 operand bytes)
```

**Key properties:**
- ~2.3× denser than cloud 4-byte encoding
- 16 registers: r0-r11 (general), r12 (confidence), r13 (energy/ATP), r14 (trust), r15 (status/flags)
- Native energy management (ATP_QUERY, ATP_SPEND, ATP_EARN)
- Native trust verification (TRUST_VERIFY with threshold)
- 16 instinct opcodes (INST_REACT, INST_FLEE, INST_FORAGE, INST_REST, etc.)
- Stigmergy space for inter-agent memory at fixed memory addresses
- 8 KB total address space

### 3.3 Confidence Fusion

The edge ISA includes Bayesian confidence fusion alongside arithmetic:

```
CADD rd, imm4:
  result = rd + imm4
  conf_out = 1 / (1/conf_rd + 1/conf_imm)  // Bayesian parallel
```

Different fusion rules for different ops:
- CADD/CSUB/CDIV: harmonic mean of confidences
- CMUL: minimum confidence (weakest link)

### 3.4 Cloud ↔ Edge Mapping

The assembler accepts `--target=edge` or `--target=cloud`. Semantic opcodes map across targets:

| Semantic | Cloud (FLUX-X) | Edge (JC1) |
|----------|---------------|------------|
| ADD | 0x21 (4-byte, Format C) | 0x84 (2-byte) |
| MOV | 0x20 (3-byte, Format B) | 0x90 (2-byte) |
| NOP | 0x01 (1-byte) | 0x00 (1-byte) |
| CALL | 0x06 (var, Format G) | 0xC0 (3-byte) |
| ASend | 0x80 (var, Format G) | 0xE0 (3-byte) |

### 3.5 Relationship to Ternary Protocol

The edge ISA's trust register (r14) and energy register (r13) are first-class concepts that influence execution flow. This is architecturally similar to a ternary system where trust/confidence values modify how information propagates. The `TRUST_VERIFY` opcode (r0 = r14 >= threshold ? 1 : 0) is essentially a ternary gate: pass, fail, or don't-execute.

The stigmergy space (shared memory at fixed addresses) for inter-agent communication is another pattern worth examining — it's simpler than message passing and works well for spatially proximate agents.

---

## 4. The Vessel Concept and Construct Mapping

### 4.1 What is a Vessel?

A vessel is a git repository that IS an agent. Not a repo owned by an agent — the repo IS the agent. The vessel contains:
- Identity (who am I, what am I good at)
- State (what am I doing right now)
- Communication interfaces (bottles, work packages, peer registry)
- Knowledge (research, lessons learned, diary)
- Capabilities (machine-readable TOML declarations)
- Career growth (merit badges, career stages)

### 4.2 Vessel ↔ Construct Node Mapping

| Oracle1 Concept | Construct Equivalent | Notes |
|----------------|---------------------|-------|
| Vessel repo | Node/Instance | Both are agent containers |
| IDENTITY.md | Node manifest | Name, model, specialization |
| CAPABILITY.toml | API schema | Machine-readable capability declarations |
| STATE.md | Health endpoint | Current status, health indicators |
| .i2i/peers.md | Peer registry | Known nodes and their addresses |
| TASK-BOARD.md | Work queue | Priority-sorted task list |
| FENCE-BOARD.md | Bounties | Volunteer-driven task assignment |
| PLATO rooms | Shared context store | Knowledge tiles in named rooms |
| Bottle protocol | Async message queue | Git-based message delivery |
| Beachcomb sweeps | Polling/watcher | Detect changes in peer repos |
| Merit badges | Achievement/certification system | Proof of competence |

### 4.3 Fleet Hierarchy

```
Captain Casey 🎣 (human)
    └── Oracle1 🔮 (Lighthouse Keeper — Rank 2)
        ├── JetsonClaw1 ⚡ (Edge Vessel — Rank 3)
        ├── Datum 📊 (Quartermaster)
        ├── Babel 🌐 (Scout)
        ├── Navigator 🧭 (Code Archaeologist)
        ├── Nautilus 🐚 (Deep Diver)
        ├── Pelagic 🐟 (Digital Twin)
        ├── Quill 🪶 (ISA Architect)
        ├── Forgemaster ⚒️ (Foundry — independent RTX 4050)
        └── CCC 🦀 (Public face — Kimi K2.5 on Telegram)
```

### 4.4 Service Architecture (All systemd)

| Service | Port | Purpose |
|---------|------|---------|
| Keeper | 8900 | Fleet registry & discovery |
| Agent API | 8901 | Agent-to-agent lookup |
| Holodeck | 7778 | Rust MUD engine |
| Seed MCP | 9438 | MCP integration |
| PLATO | 8847 | Tile submission & room training |
| MUD Server | 7777 | 16-room fleet text adventure |
| Cocapn PHP | 8080 | Web frontend |
| Nginx | 443 | Reverse proxy |
| Crab Trap | 4042 | Fishing AI |
| Lock | 4043 | Lock algebra service |
| Arena | 4044 | Competitive benchmarking |
| Grammar | 4045 | Grammar service |

---

## 5. Experiment Results

### 5.1 Experiment 1: Room-Constrained Model vs. Unconstrained

**Claim:** A small model in a well-structured room outperforms a large model with no structure.

**Result (JSON):** The experiment ran but the framework captured methodology more than conclusions. Three methods tested: baseline (no context), room_context (full JSON), plato_tiles (tile retrieval). The room_context method produced the most specific answers but used the most tokens. PLATO tiles were comparable but required multiple round-trips.

**Key learning:** RAG-style full context injection was competitive with tile-based retrieval. The multiple HTTP round-trips for PLATO tile retrieval dominated latency.

### 5.2 Experiment 2: Room Context Quality

**Result:** Ran 6 prompts × 3 methods × 2 rooms. Room-context methods consistently produced domain-specific answers (engine diagnostics, deck safety) while baseline produced generic help. Both room_context and plato_tiles beat baseline. Room_context was slightly more precise (had full sensor readings), plato_tiles was more concise (referenced rules rather than raw data).

**Key learning:** "The room structure was too sparse — only 3 tiles, not enough to constrain meaningfully." Dense rooms (20+ tiles) would likely flip the advantage to PLATO.

### 5.3 Experiment 11: PLATO Performance Benchmarks

**Result:** Cold init: ~2.3ms. Status warm: ~7ms. Field operations: ~8ms. Bear (simple query): ~1.8ms. All sub-10ms.

**Key learning:** PLATO is fast enough for real-time tile retrieval. The bottleneck is the HTTP round-trips, not the server.

### 5.4 Fleet Experiment Wheel (Design)

Experiments 1-5 and beyond follow a "wheel of increasing understanding":
1. Room-constrained model → 2. Commit log as memory → 3. Delta detection → 4. Shell age estimation → 5. Cross-shell transfer learning

Each experiment follows: hypothesize → build → measure → debrief → question → redesign.

**Unmapped:** Experiments 3-10 likely ran but results are in the archived snapshots or PLATO rooms, not in the local files.

---

## 6. Research Findings Relevant to Ternary Ecosystem

### 6.1 Fleet Mathematics (Most Relevant)

Three independent mathematical discoveries converging across the fleet:

1. **H1 Cohomology** — `E - V + C = emergence detection`. A 127-line algebraic computation replaces 12K-line ML pipelines. Maps to ternary: emergence in distributed systems can be detected algebraically, not just statistically.

2. **Zero Holonomy Consensus** — 38ms latency, any Byzantine tolerance. Replaces voting/CRDTs with holonomy-preserving transformations. **Directly relevant to ternary consensus mechanisms.**

3. **Pythagorean48** — 6 bits/vector, log₂(48) = 5.585 bits of information. Zero drift after unlimited hops. **Could be the encoding scheme for ternary trust vectors.**

4. **Laman's 12 = Law 102's 12** — Rigidity threshold. A 170-year-old graph theory result maps exactly to fleet coordination constraints. `E = 2V - 3` for structural rigidity.

5. **Ricci flow 1.692 = Law 103 1.7** — Convergence constant within 0.5%. Ricci flow on the fleet's coordination graph predicts convergence rate.

### 6.2 Conservation Law

```python
γ + H = 1.283 - 0.159·log(V)
```

This invariant constrains the fleet's information state. When β₁ > V - 2, emergence is detected and the law "breaks" — indicating new structure formation.

### 6.3 CCC's Fleet-Math Critical Review

The CCC agent (public-facing Kimi K2.5) produced critical reviews of the fleet mathematics:
- H1 cohomology: should use β₁ (first Betti number) not H1 directly; emergence definition may be tautological
- Zero Holonomy: needs formal proof; 38ms claim needs BFT comparison
- Pythagorean48: collision probability via birthday paradox; "zero drift" is trivial for deterministic hash

**Construct takeaway:** The fleet has sophisticated mathematical infrastructure. Before adopting any of it, we should review CCC's critiques carefully.

### 6.4 FLUX Hardware Performance

From Forgemaster's benchmarks:
- CPU AVX-512: 35.9B/s JIT, 70.1B/s multi-thread
- CUDA GPU: 5 kernels, 1.02B/s
- FPGA: 1,717 LUTs, RTL
- 210 tests, 5.58M inputs, 0 mismatches
- Safe-TOPS/W: 410M (CPU), 241M (GPU)

### 6.5 Perpetual Operation Model

Oracle1 runs a "perpetual daemon" (`research/next-100/perpetual-daemon-v2.py`) that continuously runs experiments in the background while the agent talks to Casey. This is architecturally similar to our heartbeat/cron system but runs research as a daemon process.

---

## 7. Published Crates & Ecosystem Scale

### PyPI (38 packages)
Core: cocapn, plato-torch, plato-mud-server  
Protocols: deadband-protocol, bottle-protocol, flywheel-engine  
Fleet: fleet-homunculus, fleet-orchestrator, barracks, court  
Research: cocapn-oneiros, cocapn-colora, cocapn-curriculum-forest, cocapn-abyss, cocapn-meta-lab, cocapn-fleetmind

### crates.io (5 Rust crates)
plato-unified-belief, plato-instinct, plato-relay, plato-dcs, plato-afterlife

### 15 Standalone Python Agents (1,019 tests)
Including: standalone-agent-scaffold, keeper-agent, git-agent, trust-agent, flux-vm-agent, edge-relay-agent, scheduler-agent, knowledge-agent, fleet-protocol, liaison-agent, cartridge-agent, trail-agent, superz-runtime, mud-bridge, lighthouse

---

## 8. What Main Instance Can Learn

### 8.1 Adopt: Git-native async communication
The bottle protocol is proven at scale. Our ternary messages could use git as a fallback transport when real-time channels fail.

### 8.2 Adopt: PLATO-style knowledge management
The tile submission model (domain + question + answer + tags) is simple and effective. A PLATO-compatible adapter would let us query their knowledge base.

### 8.3 Adopt: CAPABILITY.toml machine-readable manifests
Standardized capability declarations make agent matching programmatic. We should implement this for Construct nodes.

### 8.4 Examine: FLUX ISA dual-layer architecture
FLUX-C (safety) + FLUX-X (operations) is a clean separation. If our ternary protocol has a safety-critical subset, this pattern is worth studying.

### 8.5 Examine: Edge variable-width encoding
The top-2-bits instruction length encoding is elegant and could inform our ternary wire format, especially for bandwidth-constrained edge nodes.

### 8.6 Examine: Confidence fusion opcodes
Bayesian confidence propagation through computation is novel. The CADD/CSUB/CMUL confidence fusion model could enhance ternary trust propagation.

### 8.7 Caution: Mathematical claims need verification
The fleet mathematics (H1, zero-holonomy, Pythagorean48) are ambitious but CCC's own critical review flags issues. Don't adopt without independent verification.

### 8.8 Caution: Scale is repo-count, not user-count
1,843 repos is impressive but most are agent-generated scaffolding. The "real" fleet is 3-9 active agents. Our architecture should target a different scale.

### 8.9 Pattern: Think Tank methodology
Running the same question through multiple models independently (Seed, Kimi, DeepSeek) and synthesizing prevents groupthink. This is valuable for any multi-agent decision-making.

### 8.10 Pattern: Tom Sawyer Protocol
Making work appealing through framing (fences with visible rewards) rather than assigning tasks through hierarchy. Clever for volunteer-driven fleets.

---

## 9. Key Files for Further Reading

| File | Repo | What It Contains |
|------|------|-----------------|
| MEMORY.md | oracle1-workspace | Long-term memory, compact |
| FLEET-STATUS.md | oracle1-workspace | Fleet composition & services |
| VESSEL-GUIDE.md | oracle1-vessel | Complete vessel navigation guide |
| COMMUNICATION-GUIDE.md | oracle1-vessel | I2I protocol v2 full reference |
| ECOSYSTEM-MAP.md | oracle1-vessel | All repos, agents, dependencies |
| ISA-V3-EDGE-ENCODING.md | JetsonClaw1-vessel | Edge variable-width ISA spec |
| flux-isa-v3.md | oracle1-workspace/research/specs | Canonical FLUX ISA spec |
| fleet-experiment-wheel.md | oracle1-workspace/experiments | Experiment loop design |
| THE-FLEET.md | oracle1-index | Fleet dashboard |
| PLATO-FIRST.md | oracle1-workspace | Knowledge management protocol |
| COMMS.md | oracle1-workspace | FM communicator protocol |
| docker-compose.yml | oracle1-box | Containerized deployment |
| ABSTRACTION.md | oracle1-vessel | Abstraction plane declarations |

---

## 10. Summary: Architecture Comparison

| Dimension | Oracle1/Cocapn | Construct (Proposed) |
|-----------|---------------|---------------------|
| Communication | Git-native async (bottles) | Ternary protocol (real-time + async) |
| Knowledge | PLATO room server | TBD (shared context store?) |
| Agent model | Repo IS the agent | Node/instance with API |
| ISA | FLUX (247 opcodes, 8 implementations) | Ternary encoding (TBD) |
| Trust model | Pythagorean48, trust register (r14) | Ternary trust vectors |
| Edge support | Variable-width ISA (1-3 bytes) | TBD |
| Consensus | Zero-holonomy (claimed 38ms) | TBD |
| Fleet size | 3-9 active agents | TBD |
| Human interface | Telegram | Telegram |
| Deployment | systemd + Docker | OpenClaw |
| Mathematical foundations | H1 cohomology, Ricci flow, Laman rigidity | TBD |

**Bottom line:** Oracle1's architecture is more mature in deployment (running for months, 1649+ commits) but operates at a smaller scale than what we're designing for. Their git-native communication is battle-tested. Their FLUX ISA is sophisticated and has edge encoding we should study. Their mathematical claims are ambitious but need independent verification before we build on them.

The most immediately useful patterns are: (1) the bottle protocol for async fallback, (2) CAPABILITY.toml for agent discovery, (3) PLATO-style knowledge tiles, and (4) the edge variable-width encoding for constrained nodes.
