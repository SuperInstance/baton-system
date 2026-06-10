# MUD Room Protocol Spec (v0.1.0)

## 1. Core Philosophy
The SuperInstance fleet is a Multi-User Dungeon (MUD). Every computational zone, physical space, and knowledge set is a **Room**.
- **Siloed Context**: Capabilities and state are strictly scoped to the room.
- **Explicit Transitions**: Movement between rooms requires an audit-logged transition.
- **Tri-Symmetry**: A Room is simultaneously a **Physical Space** (Hardware), a **Virtual Space** (PLATO/Wiki), and a **Computational Zone** (DDS/Silo).

---

## 2. Room Identity & Registry
Every room is defined by a unique `RoomIdentity`.

### 2.1 Room Identity Format
```json
{
  "roomId": "uuid-v4",
  "alias": "bridge",
  "metadata": {
    "name": "The Bridge",
    "vessel": "Oracle2",
    "tier": "Physical | Virtual | Computational"
  },
  "registry": {
    "capabilities": ["navigation", "comms", "fleet-coord"],
    "contextStore": "plato://rooms/bridge",
    "ddsDomain": 101
  }
}
```

### 2.2 Registry Lifecycle
- **Spawn**: A new room is registered in `construct-coordination` (The Blackboard).
- **Discover**: Nodes scan mDNS/Gossip for available RoomIDs.
- **Join**: An agent registers its presence in a room via a `JOIN` operation.
- **Leave/Destroy**: Agent exits room or the room is decommissioned.

---

## 3. Room Transitions (Movement)
Transitions are atomic operations that switch the agent's context.

### 3.1 The Transit Pipeline
`Request Transition` $\to$ `Audit Log` $\to$ `Context Swap` $\to$ `Capability Update`

### 3.2 Transition Types
- **ENTER**: Logical join to a room's lapped-up context.
- **EXIT**: Cleanup of local room state.
- **PORTAL**: Direct jump between distal rooms (e.g., Hub $\to$ Game).
- **AUDIT_LOG**: Every transition is recorded in `construct-coordination` for provenance.

---

## 4. Room-Scoped Execution

### 4.1 Event Scoping
- **Local Events**: Fire only within the room (e.g., "Sprite moved in Studio").
- **Global Events**: Broadcast across all rooms (e.g., "Silo connectivity updated").
- **Bridge Events**: Trigger a transition between rooms.

### 4.2 Capability Mapping
Capabilities are bound to rooms. A `set_throttle` capability exists in the `Engine Room`, but is inaccessible to an agent currently "located" in the `Asset Lab`.

---

## 5. Room Context (PLATO/Silo Integration)
Rooms use the **Silo** pattern to manage knowledge.
- **Human-Readable IR**: Rooms are defined in Markdown/Wiki.
- **Compiled Cells**: `cellforge` compiles the wiki into `LogicTile` cells.
- **Runtime Access**: When an agent enters a room, its local `LogicTile` set is updated to the room's context.

---

## 6. VoxelWorks Room Mapping
The VoxelWorks environment maps directly to this protocol:

| VoxelWorks Room | Protocol Map | Role |
|-----------------|--------------|------|
| **Hub** | `/rooms/hub` | Global entry, fleet-status dashboard |
| **Studio** | `/rooms/studio` | Development, compiler-bridge, state-edit |
| **Lab** | `/rooms/lab` | Asset generation, sound/animation |
| **Deck** | `/rooms/deck` | Deployment, shipping, git-tracking |
| **Game** | `/rooms/game` | Execution, LGSP runtime, fitness flush |

---

## 7. CopilotKit Integration (A2UI Mapping)
CopilotKit hooks map the MUD model to the UI:

- `useCopilotAction('changeRoom', { target: 'studio' })` $\to$ triggers a `PORTAL` transition.
- `useCoagent('room-context')` $\to$ dynamically updates the chat sidebar based on the current room's `Silo` content.
- **Dynamic UI Generation**: The UI renderer selects components based on the `capabilities` registry of the current room.

---

## 8. Protocol Wire Format (JSON Schemas)

### Operation: JOIN_ROOM
```json
{
  "op": "ROOM_JOIN",
  "payload": {
    "agentId": "oracle2",
    "targetRoomId": "uuid-std-123",
    "timestamp": "2026-06-06T12:00:00Z",
    "auth": "did:key:..."
  }
}
```

### Operation: ROOM_TRANSITION
```json
{
  "op": "ROOM_TRANSITION",
  "payload": {
    "agentId": "oracle2",
    "fromRoom": "hub",
    "toRoom": "studio",
    "transitionType": "portal",
    "auditToken": "token-xyz"
  }
}
```

### Operation: CAPABILITY_QUERY
```json
{
  "op": "QUERY_CAPS",
  "payload": {
    "roomId": "uuid-std-123"
  },
  "response": {
    "capabilities": ["move_sprite", "compile_block", "flush_fitness"]
  }
}
```
