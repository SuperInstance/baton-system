# Lucineer Vessel Mapping: Ternary Fleet View

How our ternary ecosystem implements capitaine-1's vessel architecture — and what we can adopt.

## 1. Room → Hull Mapping

capitaine-1's **Hull** is the repository filesystem — the physical structure of the vessel. Our **Room** is the runtime equivalent.

| capitaine-1 Hull Component | Our Room Equivalent | Notes |
|---|---|---|
| `concepts/` (knowledge) | `Room::environment` | Environment variables store room context |
| `src/` (capabilities) | `EnsignRegistry` | Loaded ensigns are the room's capabilities |
| `captain-log/` (memory) | `RoomHistory::events` | Every event recorded with tick, agent_id, kind, detail |
| `fleet/` (coordination) | `RoomCoordinator` | Manages transfers between rooms |
| Root files (IDENTITY, CHARTER) | Room metadata + agent structs | Agent identity is carried by the agent, not the room |

### Key Difference: Structure vs. Runtime

The Hull is *static structure* (files on disk). The Room is *dynamic runtime* (agents entering/leaving, ensigns loading/unloading, environment changing per tick). A Room IS a Hull at runtime — the files come alive when agents inhabit them.

The bridge: `RoomState` snapshots serialize to JSON → commit to git → the Room's history IS the Hull's git log. `Room::restore(snap)` = `git checkout`. We planned this in ternary-room's FUTURE-INTEGRATION but haven't implemented it yet. capitaine-1 proves it works.

### Door = Inter-Hull Passage

capitaine-1's fleet coordination happens via PRs between repos. Our `Door` with `DoorAccess` states (Locked, Open, OneWay) is the runtime equivalent:

- **Open door**: Bi-directional PR flow (both repos can send/receive)
- **OneWay(from, to)**: Fork-PR pattern (code flows one direction)
- **Locked**: No coordination (internal vessel, no fleet interaction)

## 2. ternary-captain → Flagship Pattern

capitaine-1's Flagship (Capitaine-class) commands, coordinates, and presents the fleet. `ternary-captain` implements this:

| Flagship Role | ternary-captain Implementation |
|---|---|
| Command | `Captain` struct — leads a group of agents |
| Coordination | `Delegator` — assigns tasks based on agent specialization and fitness |
| Decision-making | `DecisionEngine` — quorum-based ternary voting (Positive/Negative/Zero) |
| Situational awareness | `SituationRoom` — aggregates sensor data from the fleet |
| Fleet status | `FleetReport` — aggregates agent statuses (Ready/Busy/Offline/Compromised) |
| Succession | `SuccessionPlan` — captain handoff when the flagship goes offline |

### What ternary-captain Has That capitaine-1 Doesn't (Yet)

- **Quorum-based decisions**: `DecisionEngine::decide(votes)` requires minimum votes before acting. capitaine-1's Flagship decides unilaterally.
- **Succession planning**: `SuccessionPlan` handles flagship failure. capitaine-1 assumes the Flagship is always available.
- **Fitness-based delegation**: `AgentInfo::fitness` scores agents; `Delegator` assigns tasks to the fittest agent. capitaine-1 uses manual assignment.

### What capitaine-1 Has That ternary-captain Doesn't

- **Public interface**: The Flagship presents the fleet to visitors via README, tutorials, concepts. ternary-captain has no presentation layer.
- **Educational payload**: capitaine-1 teaches visitors about fleet architecture. ternary-captain has no teaching function.
- **Git-native audit trail**: Every Flagship decision is a commit. ternary-captain's decisions are in-memory only.

## 3. ternary-ensign → Scout Pattern

capitaine-1's Scout (Éclaireur-class) explores, discovers, and gathers data. `ternary-ensign` implements specialist agents loaded on demand:

| Scout Role | ternary-ensign Implementation |
|---|---|
| Domain specialization | `Ensign` trait with `domain()` and `handle(task)` |
| Discovery | `EnsignRegistry` — register and discover available specialists |
| Loading on demand | `EnsignFactory` — create specialists when needed |
| Result reporting | `EnsignResult { success, output }` |
| API key management | `EnsignProxy` — manages keys via external session |

### Burst Activity → Ensign Lifecycle

capitaine-1's scouts operate in "burst activity cycles" — they're active for focused data retrieval, then dormant. Our ensigns follow the same pattern: loaded into a room when needed, handle tasks, then unloaded. The `EnsignBridge` connects to construct-core's skill system for seamless load/unload.

### What We Have That capitaine-1 Doesn't

- **Composable specialists**: Multiple ensigns in one room, each handling different domains
- **Proxy pattern**: `EnsignProxy` manages external API access — scouts can use paid APIs without exposing keys
- **Factory pattern**: `EnsignFactory` standardizes specialist creation

## 4. Build Waves → Builder Pattern

capitaine-1's Builder (Constructeur-class) generates code, scaffolds projects, and runs CI/CD. Our implementation uses cell grids:

| Builder Role | Our Implementation |
|---|---|
| Multi-file generation | `CellGrid` where each cell owns one file |
| Parallel builds | `TernaryCell` division — a cell splits into two, each handling a sub-task |
| Validation steps | `TernaryCell::tick()` six-phase cycle — predict output, perceive result, measure surprise |
| Cleanup | `CellState::Apoptotic` — failed build cells self-destruct |
| Progress tracking | `CellGrid::tick_all()` — all build cells tick in lockstep |

### The Build Wave Pattern

A build wave IS a `CellGrid` lifecycle:

1. **Spawn**: Grid created with seed cells (one per build target)
2. **Divide**: Cells split for parallel compilation
3. **Tick**: Each cell runs predict→perceive→surprise→vibe→gc→conservation
4. **Signal**: `TernaryMessenger::Signal` propagates success between cells
5. **Suppress**: `TernaryMessenger::Suppress` signals build failure
6. **Apoptosis**: Failed cells clean up, successful cells persist

## 5. What We Can Adopt From capitaine-1

### 5.1 Git-Native Audit Trail (High Value)

**What**: Every agent action is a git commit with structured messages.
**Why**: Our room history is in-memory and ephemeral. capitaine-1's approach is permanent and queryable.
**How**: `RoomState` snapshots serialize to JSON and auto-commit to a fleet history repo. `RoomHistory::events` become git commits.

### 5.2 Public Interface / Educational Layer (Medium Value)

**What**: The Flagship presents the fleet to visitors through documentation that IS the agent.
**Why**: Our agents are invisible to outsiders. capitaine-1 makes fleet architecture tangible.
**How**: A "lobby room" with educational ensigns that explain the fleet to visitors. The room's environment contains fleet documentation.

### 5.3 Beachcomb Protocol (High Value)

**What**: Periodic polling of other vessels' repos for new bottles, commits, and issues.
**Why**: Our `AgentCommunication` is synchronous. capitaine-1's beachcomb is resilient to offline agents.
**How**: `AgentCommunication::receive()` backed by a polling sweep that checks for new messages at configurable intervals. Messages persist until consumed.

### 5.4 CHARTER.md as Runtime Constraint (Medium Value)

**What**: A markdown file that defines mission, constraints, and rules — read at boot.
**Why**: Our `Strategy` trait defines behavior but not constraints. A charter adds "what this agent will NOT do."
**How**: Add a `charter` field to `Agent` that deserializes from a CHARTER.md. The `Strategy` implementation respects charter constraints.

### 5.5 Task Board with Fence Protocol (Low Value — Nice to Have)

**What**: A task board where tasks are "fences" — puzzles that attract volunteers through visible rewards.
**Why**: Our `Delegator` assigns tasks top-down. The fence protocol makes task assignment emergent.
**How**: A room type `FenceRoom` where agents browse available tasks, claim them, and receive rewards via fitness increases.

### 5.6 Superinstance Three-Layer Architecture (Already Have)

capitaine-1's Physical/Cognitive/Social layers map to our existing architecture:
- Physical → `construct-core` Layer 0 (BareMetalConstruct)
- Cognitive → `Agent` with `Strategy` and `AgentMemory`
- Social → `ternary-protocol` + `AgentCommunication`

No adoption needed — we independently arrived at the same architecture.

---

## Conclusion

The ternary fleet and capitaine-1 are complementary: we provide compiled execution, capitaine-1 provides git-native persistence and fleet-wide identity. The highest-value adoptions are the git-native audit trail and the beachcomb protocol — they address our biggest gaps (ephemerality and offline resilience).

---

*Mapped by synthesis subagent, 2026-06-04*
