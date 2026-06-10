# Holodeck Specification — Spatial Coordination Layer

*A real specification for the Holodeck MUD as the spatial coordination layer for the ternary fleet. Room types, agent movement, MUD protocol mapping to ternary-protocol messages.*

---

## 1. Overview

The Holodeck is a text-based MUD (Multi-User Dimension) that provides spatial coordination for the ternary fleet. Every ternary-room instance has a Holodeck representation. Agents "walk" between rooms, "look" at their surroundings, "talk" to other agents, and "use" objects (skills).

The Holodeck is **optional** — rooms function perfectly without it. But when spatial abstraction helps (fleet coordination, training, debugging), it's there.

### Design Principles

1. **MUD is a view, not a model.** The underlying data is `RoomCoordinator` with `Room` and `Door` objects. The MUD is a rendering layer.
2. **Every action is a ternary signal.** MUD commands map to `TernaryMessenger` values: Signal (+1), Silence (0), Suppress (-1).
3. **Rooms are real.** "Walking to the Engine Room" triggers `RoomCoordinator::transfer()`, which loads/unloads skills, syncs tiles, and updates fleet state.
4. **NPCs are agents.** Other fleet agents appear as NPCs. Their positions reflect real agent locations.
5. **Offline rooms are dark rooms.** An offline EdgeRoom appears as a dark room in the MUD — you can see it exists but can't interact until the tender syncs.

---

## 2. Room Types

### 2.1 Canonical Room Definitions

| Room | ID Range | Purpose | Default Tier | Ensign | MUD Description |
|---|---|---|---|---|---|
| **Bridge** | 1000-1099 | Fleet command and coordination | Codespace (L2) | FleetCoordinator | "The command center. Holographic displays show fleet status across all sectors." |
| **Engine Room** | 2000-2099 | Sensor monitoring, anomaly detection | Edge (L1) | EngineMonitor | "The warp core hums steadily. Sensor readouts line every wall. The ensign watches for anomalies." |
| **Dojo** | 3000-3099 | Training challenges, skill development | Codespace (L2) | TrainingMaster | "A calm training space. Challenge scrolls line the walls, each rated by difficulty." |
| **Ten Forward** | 4000-4099 | Social mixing, knowledge exchange | Codespace (L2) | SocialCoordinator | "The social hub. Agents gather here between assignments. Knowledge flows freely." |
| **Sickbay** | 5000-5099 | Diagnostics, debugging, repair | Codespace (L2) | Diagnostic | "Diagnostic equipment beeps softly. The repair bay stands ready for broken agents." |
| **Science Lab** | 6000-6099 | Research, experimentation | Codespace (L2) | Research | "Research terminals glow with data. Experimental configurations scroll past." |
| **Cargo Bay** | 7000-7099 | Storage, archiving, retrieval | Codespace (L2) | Archivist | "Rows of storage containers. Knowledge is carefully catalogued and indexed." |
| **Transporter Room** | 8000-8099 | Room-to-room transfer hub | Codespace (L2) | TransferAgent | "The transporter pad shimmers. Direct room-to-room transit available." |
| **Shuttle Bay** | 9000-9099 | Tender docking, offline sync | Edge (L1) | TenderEnsign | "Tenders dock here carrying messages from the fleet. Offline sync in progress." |
| **Sensor Array** | 10000-10099 | Bare-metal sensing | Bare (L0) | None | "The raw sensor feed. 279 bytes of unvarnished truth, refreshed 240 million times per second." |

### 2.2 Room Lifecycle

```
                    ┌───────────────────┐
                    │   Room Template   │
                    │   (repo + config) │
                    └────────┬──────────┘
                             │
                    ┌────────▼──────────┐
                    │   Instance Boot   │
                    │   boot.sh detect  │
                    └────────┬──────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
         ┌──────▼──────┐ ┌──▼───────┐ ┌──▼──────────┐
         │  Spawning   │ │ Always-On│ │   Flashing  │
         │  (Codespace)│ │ (Edge)   │ │   (ESP32)   │
         └──────┬──────┘ └──┬───────┘ └──┬──────────┘
                │            │            │
         ┌──────▼──────┐ ┌──▼───────┐ ┌──▼──────────┐
         │   Active    │ │  Active  │ │   Active    │
         │   (tick)    │ │  (tick)  │ │   (tick)    │
         └──────┬──────┘ └──┬───────┘ └──┬──────────┘
                │            │            │
         ┌──────▼──────┐    │     ┌──────▼──────────┐
         │  Suspended  │    │     │  Firmware Update │
         │  (idle)     │    │     │  (reflash)       │
         └─────────────┘    │     └─────────────────┘
                            │
                     ┌──────▼──────┐
                     │  Permanent  │
                     │  (edge)     │
                     └─────────────┘
```

---

## 3. Agent Entry and Exit Protocol

### 3.1 Entering a Room

When an agent enters a room, the following sequence occurs:

```
Protocol: agent → RoomCoordinator → Room → Holodeck

1. Agent sends: ENTER_ROOM { target_room_id, agent_id, credentials }
2. RoomCoordinator checks:
   a. Does target room exist?
   b. Is there a door from agent's current room to target?
   c. Is the door access open? (DoorAccess::Open or OneWay in correct direction)
   d. Does the agent have required permissions?
3. If all checks pass:
   a. source_room.remove_agent(agent_id)
      → RoomEvent { kind: "leave", detail: "agent X left for room Y" }
   b. target_room.add_agent(agent_id)
      → RoomEvent { kind: "enter", detail: "agent X entered from room Z" }
   c. Load room ensign (if supported by tier)
      → construct.load_skill(skills for ensign)
   d. Sync PLATO tiles to room
   e. Send MUD description to agent:
      → Room description + exits + agents present + available objects
4. If any check fails:
   → Error response with reason (door locked, room not found, permission denied)
```

### 3.2 Leaving a Room

```
Protocol: agent → RoomCoordinator → Room → Holodeck

1. Agent sends: LEAVE_ROOM { from_room_id, agent_id }
2. Unload ensign:
   a. For each loaded skill:
      → trigger = construct.unload_skill(skill)
      → triggers.append(trigger)
   b. Extract muscle-memory triggers
3. Sync generated tiles to PLATO
4. source_room.remove_agent(agent_id)
   → RoomEvent { kind: "leave", detail: "agent X left" }
5. If Codespace: check idle timeout for auto-suspend
6. Return UnloadReport { skills_unloaded, triggers, tiles_generated, conservation }
```

### 3.3 Forced Exit (Room Shutdown)

```
Protocol: system → RoomCoordinator → agents

1. System sends: ROOM_SHUTDOWN { room_id, reason, grace_period }
2. For each agent in room:
   a. Send alert: "Room shutting down in {grace_period}s. Reason: {reason}."
   b. After grace period: force leave_room for each agent
   c. If Codespace: suspend immediately
3. Room state saved to snapshot
4. Room removed from active coordinator
```

---

## 4. MUD Protocol Specification

### 4.1 Command Format

All MUD commands are newline-terminated UTF-8 strings:

```
COMMAND [arguments...]
```

### 4.2 Command Set

#### Movement Commands

| Command | Arguments | Effect | Response |
|---|---|---|---|
| `look` | none | Display room description, agents, exits, objects | Multi-line room description |
| `go <direction>` | direction or room name | Transfer agent to target room via door | New room description, or error |
| `enter <room>` | room name | Alias for `go` | Same as `go` |
| `exit` | none | Leave current room (return to lobby) | Lobby description |
| `map` | none | Display fleet room topology | ASCII map of all rooms |
| `where` | none | Show current room name and coordinates | Single line: room name + ID |
| `who` | none | List all agents in current room | Agent list with roles |
| `fleet` | none | List all rooms and their agent counts | Fleet status table |

#### Interaction Commands

| Command | Arguments | Effect | Response |
|---|---|---|---|
| `examine <object>` | object name | Show object details + bound skill | Object description + skill info |
| `take <object>` | object name | Load skill (construct.load_skill) | Confirmation + skill loaded |
| `drop <object>` | object name | Unload skill (construct.unload_skill) | Confirmation + trigger extracted |
| `use <object> [args]` | object + args | Execute skill with input | Skill output |
| `inventory` | none | List loaded skills | Skill list with status |

#### Communication Commands

| Command | Arguments | Effect | Response |
|---|---|---|---|
| `say <message>` | message text | Broadcast to all agents in room | Echo to all room agents |
| `whisper <agent> <msg>` | target + message | Unicast to specific agent | Confirmation |
| `emote <action>` | action text | Broadcast action description | Echo to all room agents |
| `page <agent> <msg>` | target + message | Cross-room message | Confirmation (may be queued) |

#### Training Commands (Dojo only)

| Command | Arguments | Effect | Response |
|---|---|---|---|
| `challenge <level>` | difficulty 1-10 | Start training challenge | Challenge description |
| `submit <answer>` | answer | Submit challenge answer | Score + feedback |
| `rank` | none | Show training rank and scores | Rank table |

#### Administrative Commands (Captain only)

| Command | Arguments | Effect | Response |
|---|---|---|---|
| `lock <door>` | door ID | Lock a door (DoorAccess::Locked) | Confirmation |
| `unlock <door>` | door ID | Open a door (DoorAccess::Open) | Confirmation |
| `boot <agent>` | agent ID | Force-remove agent from room | Confirmation |
| `shutdown <room>` | room ID | Shutdown a room | Confirmation |
| `spawn <template>` | template name | Create new CodespaceRoom | Room description |

### 4.3 Response Format

Responses are newline-terminated UTF-8 with ANSI formatting:

```
[ROOM_NAME]
Description text...

Exits: north (bridge), east (science-lab), south (sickbay)
Objects: flux-capacitor-module [available], sensor-kit [loaded]
Agents: sentinelle-7 (monitoring), eclaireur-3 (exploring)
```

Error responses:

```
[ERROR] Door to shuttle-bay is locked. The tender is not currently docked.
```

System messages:

```
[SYSTEM] sentinelle-7 has entered the room.
[SYSTEM] Anomaly detected in engine room! (surprise: 0.87, threshold: 0.5)
[SYSTEM] Tender has docked. Sync beginning...
```

---

## 5. MUD Protocol → ternary-protocol Message Mapping

Every MUD command produces a `TernaryMessenger` signal that flows through `ternary-protocol`:

| MUD Command | ternary Signal | Direction | Payload |
|---|---|---|---|
| `look` | Silence (0) | Agent → Room | None (read-only) |
| `go <room>` | Signal (+1) | Agent → Room | Target room ID |
| `enter <room>` | Signal (+1) | Agent → Room | Target room ID |
| `exit` | Signal (+1) | Agent → Room | Lobby room ID |
| `say <msg>` | Signal (+1) | Agent → Room (broadcast) | Message text |
| `whisper <agent> <msg>` | Signal (+1) | Agent → Agent (unicast) | Message text |
| `emote <action>` | Silence (0) | Agent → Room (broadcast) | Action text |
| `take <object>` | Signal (+1) | Agent → Room | Skill ID to load |
| `drop <object>` | Signal (+1) | Agent → Room | Skill ID to unload |
| `challenge <level>` | Signal (+1) | Agent → Room | Difficulty level |
| `lock <door>` | Suppress (-1) | Agent → Room | Door ID to lock |
| `shutdown <room>` | Suppress (-1) | Agent → Fleet | Room ID to shutdown |
| Anomaly alert | Suppress (-1) | Room → Agents (broadcast) | Anomaly details |
| Tender docked | Signal (+1) | System → Room | Sync payload available |
| Agent entered | Signal (+1) | Room → Agents (broadcast) | Agent ID + source |
| Agent left | Signal (+1) | Room → Agents (broadcast) | Agent ID + destination |
| Room shutting down | Suppress (-1) | System → Agents (broadcast) | Shutdown reason |

### Wire Format

```rust
/// MUD message on the wire — wraps ternary-protocol.
#[derive(Debug, Clone)]
pub struct MudMessage {
    /// Ternary signal value
    pub signal: TernaryMessenger,
    /// MUD command that generated this signal
    pub command: MudCommand,
    /// Source agent
    pub from_agent: u64,
    /// Target agent (None = broadcast)
    pub to_agent: Option<u64>,
    /// Source room
    pub from_room: u64,
    /// Target room (for movement commands)
    pub to_room: Option<u64>,
    /// Payload (message text, skill ID, etc.)
    pub payload: String,
    /// Timestamp
    pub timestamp: u64,
}

#[derive(Debug, Clone, Copy)]
pub enum MudCommand {
    Look,
    Go,
    Enter,
    Exit,
    Say,
    Whisper,
    Emote,
    Take,
    Drop,
    Use,
    Challenge,
    Lock,
    Unlock,
    Shutdown,
    Spawn,
    Alert,
    Sync,
}
```

---

## 6. Room-Specific Behavior

### 6.1 Bridge (Fleet Command)

- **Access:** Captain-class agents only (DoorAccess with role check)
- **Commands:** All administrative commands available
- **Special:** `fleet` command shows real-time status of all rooms
- **Tiles:** All fleet tiles aggregated here
- **NPCs:** Proxy agents from every room (read-only fleet overview)

### 6.2 Engine Room (Sensor Monitoring)

- **Access:** Sentinelle-class + Captain-class agents
- **Auto-alerts:** Anomaly detection pushes Suppress signals to all agents in room
- **Special:** `examine <sensor>` shows real-time sensor data
- **Skills:** TernarySensor, TernaryKalman, TernaryAnomaly pre-loaded
- **Offline behavior:** Continues operating from last-known state, queues alerts for tender

### 6.3 Dojo (Training)

- **Access:** All agents
- **Challenges:** Generated from `ternary-rl` training scenarios
- **Scoring:** `ternary-fitness` fitness landscape scores
- **Difficulty:** 1-10 scale mapped to `ternary-adversarial` stress levels
- **Special:** Training results submit tiles to PLATO for fleet learning

### 6.4 Ten Forward (Social)

- **Access:** All agents
- **Purpose:** Informal knowledge exchange, cross-domain pollination
- **Special:** `say` messages here are logged as PLATO tiles (social learning)
- **NPCs:** All agents can appear here simultaneously (multi-room presence)

### 6.5 Shuttle Bay (Tender Sync)

- **Access:** Tender agents + Captain-class
- **Special:** `dock` command initiates tender sync sequence
- **Sync protocol:**
  1. Tender announces arrival (Signal +1)
  2. Edge room drains outbound queue
  3. Tender delivers inbound payload
  4. Joint reasoning session (if tender has capacity)
  5. Tender departs (Signal +1)
- **Dark rooms:** Offline rooms appear as "dark" — visible but inaccessible

### 6.6 Sensor Array (Bare Metal)

- **Access:** None (compiled-in, no agent entry)
- **Behavior:** Pure reflex — tick, predict, perceive, signal
- **MUD representation:** Read-only display showing sensor values
- **Update mechanism:** Firmware flash via Shuttle Bay

---

## 7. Fleet Topology Discovery

When a new room boots, it registers with the fleet:

```
1. Room boots via boot.sh
2. Room sends REGISTER message to Lighthouse Keeper
   → { room_id, room_name, room_type, tier, mode, capabilities }
3. Keeper adds room to RoomCoordinator
4. Keeper creates doors based on room type:
   → Bridge rooms get doors to all other rooms
   → Engine rooms get doors to Science Lab and Sickbay
   → Edge rooms get doors to Shuttle Bay
   → Bare rooms get one-way door from their managing edge room
5. Keeper broadcasts ROOM_REGISTERED to all connected rooms
6. Holodeck updates fleet map
```

When a room goes offline:

```
1. Room sends UNREGISTER message to Keeper (if possible)
   OR Keeper detects missed heartbeats
2. Keeper marks room as offline (dark)
3. Doors to/from room set to DoorAccess::Locked
4. Agents in room are notified: "Room going offline"
5. Holodeck shows room as dark
6. When room returns: re-registration restores doors
```

---

## 8. Session Protocol

### Connection Lifecycle

```
1. Agent connects to Holodeck server (TCP or WebSocket)
2. Server sends: WELCOME { agent_id, current_room, fleet_summary }
3. Agent sends: LOOK (get current room state)
4. Agent interacts via MUD commands
5. Server pushes events:
   - Agent entered/exited room
   - Anomaly alerts
   - Tender sync notifications
   - Challenge results
6. Agent sends: DISCONNECT
7. Server removes agent from room (leave sequence)
```

### Multi-Session Support

An agent can be present in multiple rooms simultaneously:

- **Physical presence:** The agent is actually in one room (agent_id in room.agents)
- **Proxy presence:** The agent has NPC proxies in other rooms (read-only)
- **This enables:** An agent monitoring the Engine Room while socializing in Ten Forward

```rust
/// Multi-room presence: agent is physically in one room,
/// has read-only proxies in others.
pub struct AgentPresence {
    pub agent_id: u64,
    pub physical_room: u64,
    pub proxy_rooms: Vec<u64>,
}
```

---

## 9. Implementation Priority

| Phase | Feature | Depends On |
|---|---|---|
| P0 | Room descriptions, look command, agent listing | ternary-room (existing) |
| P1 | Go/enter/exit commands with RoomCoordinator | ternary-room (existing) |
| P2 | Say/whisper communication | ternary-protocol |
| P3 | Take/drop skill loading | construct-core |
| P4 | Dojo training challenges | ternary-rl, ternary-fitness |
| P5 | Fleet map, topology discovery | FleetCoordinator |
| P6 | Tender dock/sync protocol | TenderAgent |
| P7 | Administrative commands | Role-based access |
| P8 | open-tui visualization rendering | ternary-visualization |

---

*Written 2026-06-04 by synthesis-cocapn-fleet subagent. Specification for the Holodeck spatial coordination layer.*
