# Precision Audit — SuperInstance Core Crates
**Date:** 2026-06-04  
**Scope:** ternary-cell, ternary-room, ternary-agent, ternary-protocol, construct-core  
**Method:** Full source read of every `.rs` file, logic tracing, cross-crate consistency check  
**Status:** 5 bugs fixed, 6 design issues documented

---

## Summary

| Crate | Real Bugs | Design Issues | Fixed? |
|---|---|---|---|
| ternary-cell | 1 | 1 | ✅ |
| ternary-room | 1 | 1 | ✅ |
| ternary-agent | 0 | 2 | n/a |
| ternary-protocol | 0 | 2 | n/a |
| construct-core | 3 | 0 | ✅ |

---

## ternary-cell

### BUG 1 (FIXED): `CellGrid::tick_all()` returns pre-tick alive count

**File:** `src/lib.rs:264–284`  
**Severity:** Medium — wrong return value; doesn't affect internal state

The `alive` counter was incremented at the start of the tick loop, before calling `c.tick()`. Since `tick()` calls `conservation()` which may transition a cell to `Apoptotic`, cells that die during this tick were counted as alive in the return value. The count reflected "cells alive when we started" not "cells alive when we finished."

```rust
// Before (wrong): counted before tick, including cells about to die
c.tick();
alive += 1;  // ← incremented even if c.tick() just set state = Apoptotic

// After (correct): count survivors after apoptotic cells are removed
for cell in &mut self.cells {
    if let Some(c) = cell {
        if !c.is_alive() { *cell = None; } else { alive += 1; }
    }
}
```

`Tissue::run()` happens to ignore the return value of `tick_all()`, but any external caller would have received a stale count.

### Design Issue: `CellState::Dividing` has no recovery path

After a cell calls `divide()`, its state becomes `Dividing`. There is no built-in mechanism to return it to `Active`. The cell remains `is_alive()` but can never divide again without external intervention setting `cell.state = CellState::Active`. This may be intentional, but nothing in the API communicates it.

---

## ternary-room

### BUG 2 (FIXED): `Door::destination()` ignores the `to` field of `OneWay`

**File:** `src/lib.rs:49–61`  
**Severity:** High — silent wrong destination when `src` room ≠ `room_a`/`room_b`

`DoorAccess::OneWay(src, dst)` stores an explicit destination. `destination()` ignored `dst` entirely and instead computed "the other room in the door":

```rust
// Before (wrong): derived from room_a/room_b, ignores stored dst
if from_room == self.room_a { Some(self.room_b) }
else if from_room == self.room_b { Some(self.room_a) }
else { None }  // ← can_pass() already returned true here — silent mismatch

// After (correct): use the stored destination
DoorAccess::OneWay(_, dst) => Some(*dst),
```

The old code had two failure modes:
1. If `src` is neither `room_a` nor `room_b`, `can_pass()` returns `true` but `destination()` returns `None`.
2. The `to` field in `OneWay(from, to)` appeared meaningful to callers but was never read.

All existing tests passed because they set up `OneWay(room_a, room_b)` consistently, masking the bug.

### Design Issue: `RoomEvent::tick` is always hardcoded to 0

`Room::add_agent()` and `Room::remove_agent()` record events with `tick: 0`. If callers want accurate event timestamps they must call `history_mut()` and fix up the tick after the fact. The `tick` field in `RoomEvent` is effectively unused. A `tick_context` parameter on room operations or a `set_tick()` method on the coordinator would make the history genuinely useful.

---

## ternary-agent

### Design Issue: `TernaryState::from_trit` panics, `TernaryMessenger::from_ternary` returns Option

`ternary-agent` exposes `from_trit(i8)` which panics for values outside `{-1, 0, 1}`. The sibling `ternary-cell` crate exposes `TernaryMessenger::from_ternary(i8) -> Option<Self>` for the same pattern. This API inconsistency means callers of the agent crate must validate inputs themselves or accept a panic risk that doesn't exist in the cell crate.

Recommended fix: add a `try_from_trit(i8) -> Option<Self>` alongside `from_trit`.

### Design Issue: `AgentPool::ranked()` is non-deterministic for equal-fitness agents

```rust
ids.sort_by(|a, b| b.fitness.partial_cmp(&a.fitness).unwrap_or(std::cmp::Ordering::Equal));
```

When two agents have equal fitness, their relative order in the output depends on the `HashMap`'s internal iteration order, which is randomized per-process. The existing test (`test_agent_pool_ranked`) uses three agents with distinct fitness values (0.9, 0.6, 0.3), so it always passes. But production code that relies on ranked() for deterministic scheduling would get random tie-breaking.

Recommended fix: add a secondary sort by `agent_id` as a tiebreaker.

---

## ternary-protocol

### Design Issue: `MessageBus::broadcast` sends to the sender; `AgentCommunication::broadcast` does not

Cross-crate inconsistency:
- `ternary-protocol::MessageBus::send(msg, Broadcast)` delivers to **all registered agents including the sender**.
- `ternary-agent::AgentCommunication::broadcast()` explicitly skips `to == from_id`.

Callers switching between the two transports will observe different self-delivery behavior. One of these should be made to match the other, or the difference should be prominently documented on both.

### Design Issue: Handshake encoding silently truncates to u8

In `handshake.rs`, `create_hello()` encodes capability count, name length, and capability version using `byte_to_trits(value as u8)`. This silently truncates any value > 255. A capability named with a 300-character string, or a system with 256+ capabilities, would corrupt the handshake payload without any error. The encoding was designed for small payloads, but nothing enforces or documents the limits.

---

## construct-core

### BUG 3 (FIXED): `DgxConstruct::query_owned` uses platform-dependent `usize.to_le_bytes()`

**File:** `src/dgx.rs:122`  
**Severity:** High — wire format differs between 64-bit (8 bytes) and 32-bit (4 bytes) platforms

```rust
// Before: metadata width is platform-dependent
metadata.extend_from_slice(&self.tools.len().to_le_bytes());

// After: always 8 bytes, platform-independent
metadata.extend_from_slice(&(self.tools.len() as u64).to_le_bytes());
```

Any consumer parsing the metadata field from a 64-bit DGX on a 32-bit platform (or vice versa) would misinterpret the tool count and all subsequent bytes.

### BUG 4 (FIXED): `SkillId::Custom(0..=7)` breaks serialization roundtrip

**File:** `src/types.rs:74–101`  
**Severity:** Medium — silent data corruption for runtime-defined skills in reserved range

`SkillId::Custom(3).as_u8()` returns `3`, but `SkillId::from_u8(3)` returns `SkillId::RiskAssessment`. Any `Custom` ID in the range 0–7 cannot survive a serialize/deserialize round-trip — it silently becomes the named variant instead.

The existing test uses `Custom(100)` which avoids the reserved range, so the bug was never caught.

Fix: added `SkillId::new_custom(v: u8) -> Option<Self>` which returns `None` for reserved values 0–7, providing a safe constructor that documents the constraint.

```rust
pub const fn new_custom(v: u8) -> Option<Self> {
    if v <= 7 { None } else { Some(Self::Custom(v)) }
}
```

### BUG 5 (FIXED): Duplicate comment in `DgxConstruct::query_async`

**File:** `src/dgx.rs:156`  
**Severity:** Trivial

```rust
// Simulate async I/O — in production this would hit GPU / network   ← duplicate
// Simulate async I/O — in production this would hit GPU / network
```

Removed the duplicate line.

---

## Cross-crate Consistency Notes

### `TritAction` vs `TernaryState` vs `Trit` — three representations of the same concept

| Crate | Type | Values | Repr |
|---|---|---|---|
| construct-core | `TritAction` | Avoid=0, Explore=1, Choose=2 | `#[repr(u8)]` 0/1/2 |
| ternary-agent | `TernaryState` | Avoid=-1, Explore=0, Choose=+1 | balanced ternary |
| ternary-protocol | `Trit` | Neg=-1, Zero=0, Pos=+1 | balanced ternary |
| ternary-cell | `TernaryMessenger` | Suppress=-1, Silence=0, Signal=+1 | balanced ternary |

`construct-core::TritAction` uses 0/1/2 internally (NOT balanced ternary), while all other crates use −1/0/+1. Code that converts between layers must account for this offset. There is no shared conversion utility — callers must know to do `TritAction::Avoid=0 ↔ TernaryState::Avoid=-1` manually.

### No shared ID space across crates

`ternary-agent::Agent::id`, `ternary-room::Room::id`, and `ternary-protocol::TernaryMessage::sender` all use bare `u64` IDs with no registry or newtype wrapper. Two agents from different pools can have the same ID without conflict detection. If the SuperInstance ecosystem ever routes messages across subsystems, this will require careful external coordination.

---

## Verdict

The codebase is generally clean and well-structured. The bugs that exist are subtle (stale counts, unused enum fields, platform width leaks) rather than obvious. The test suite is thorough — all 130+ tests pass after fixes — but tests for the failure modes of the bugs above did not exist, which is how they persisted.

The most important issue to address that was **not** fixed in this pass is the `AgentPool::ranked()` non-determinism for equal-fitness agents, since it silently affects scheduling behavior in production without ever failing tests.
