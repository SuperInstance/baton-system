# Architecture Gap Map — SuperInstance Fleet
**Status:** Analysis of Actual vs. Vision (Kimi Architecture Spec)
**Date:** 2026-06-06

## 1. The "MUD" Room Connectivity Map

| Component | Architecture Role | Current State | Gap/Status |
|-----------|-------------------|----------------|---------------|
| **VoxelWorks** | Touch Layer (The World) | 5 Rooms deployed | ✅ Implemented. Needs formal MUD protocol wiring. |
| **Fleet Copilot** | Voice Control Plane | Live (DeepSeek V4 Flash) | ⚠️ Reactive. Not yet "room-aware" in the MUD sense. |
| **Nebula** | Reflex Engine / Gatekeeper | Healthy ( CNC de-coupled) | ⚠️ Fast-path works, but "Room Transition" reflexes missing. |
| **Pincher** | Production Runtime | 162/162 tests pass | ⚠️ No explicit room-isolation in core runtime. |
| **Silo Core** | L1 Math Substrate | 100% Crate Connectivity | ✅ Foundations set. `ternary-types` hub active. |
| **cellforge** | L4 Wiki$\to$Cell Compiler | Rust code delivered | ⚠️ Not integrated into a live room-spawn pipeline. |
| **cog-jit** | L2/L3 Runtime Evolution | Architecture designed | ❌ Not implemented. |

---

## 2. Critical Gaps (The "Negative Space")

### 🔴 High Priority: The "Bridges"
- **Silo $\to$ Room Bridge**: The `cellforge` compiler exists, but there is no automatic pipeline to spawn a "room" in VoxelWorks from a Markdown Silo.
- **MUD Protocol $\to$ Nebula**: The `mud-room-protocol.md` exists, but Nebula doesn't yet act as the transit gatekeeper.
- **CopilotKit $\to$ MUD**: The frontend is a chat; it needs to transition into a "Room-Aware" inhabitant (Dynamic UI based on current room capabilities).

### 🟡 Medium Priority: The "Lifecycle"
- **Offboarding**: 100+ repos, but no "recycling center." Need agent retirement/archiving.
- **Decompilation**: No reverse path from `.nail` $\to$ Wiki. We have forward-only compilation.
- **Retry Queue**: Sub-agents drop silently on a failure. Need exponential backoff and a dead-letter queue.

---

## 3. Dependency Graph (The Silo Stack)

**L5 (Cloud LLM)** $\to$ **L4 (IR & Compilation/cellforge)** $\to$ **L3 (Form/MUD Layout)** $\to$ **L2 (Reflex Runtime/Pincher)** $\to$ **L1 (Silo Math/Silo-Core)**

**Current Blockage:** The gap is at **L3 (Form)**. We have the L1 math and the L4 compiler, but we are missing the "Form" layer that maps a logic cell to a spatial room coordinate or a music-cognition "groove."

---

## 4. Roadmap for Integration

1. **The Bridge Passage**: Wire `cellforge` $\to$ `construct-coordination` $\to$ `VoxelWorks Hub`.
2. **Reflex Rooms**: Teach Nebula "Room Transition" reflexes (e.g., "Walk into the Engine Room" $\to$ Trigger transition $\to$ Update local context).
3. **Copilot- taxpayer**: Implement the `Silo-Sensing` hook in CopilotKit to update the sidebar based on the current MUD room's capability registry.
4. **Silo-DDS**: Link the L1 math (ternary-types) directly to the DDS domains of the rooms for real-time consensus.
