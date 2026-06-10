# Block Studio — Execution Engine Audit

**Audit date:** 2026-06-06  
**File:** `voxelworks/block-editor/index.html`  
**Auditor:** DeepSeek V4 Pro (subagent)

---

## 1. Block Execution Order (Linked-List Walk)

**Verdict: ✅ Correct**

The engine walks blocks via `childId` pointers: each block stores `parentId` and `childId`, forming a singly-linked list per stack. The function `getStackBlocks(root)` starts at the root and follows `childId` until null.

```
root → child1 → child2 → … → last
```

The traversal is deterministic and correct. Both the outer execution loop (`executeAll`) and the `executeBlockChain` helper (added in the fix) use this same walk.

**Architecture limitation:** The linked list is flat — there's no separate `nextSibling` vs `bodyChild` pointer. In Scratch, a `repeat` block has a C-shaped body with children, and siblings can appear after the body. In this model, every block below a `repeat`/`if_then` is treated as its body child. This means:

```
repeat 3
  move 10
  say "done"    ← treated as INSIDE the repeat body by flat-chain model
```

A true fix would require a tree data model (`bodyChildId` + `nextSiblingId`), which is a significant refactor outside this audit's scope.

---

## 2. Loop Semantics ("repeat N")

### Bug found: `repeat 0` repeats 1 time

```js
// BEFORE (bug)
const n = parseInt(f['%1']) || 1;
// parseInt('0') → 0, 0 || 1 → 1 — WRONG!
```

**Fix:** Use `Math.max(0, parseInt(f['%1']) || 0)` and early-exit when `n === 0`.

### Bug found: Nested control blocks double-execute descendants

```js
// BEFORE (bug in repeat handler)
const childBlocks = getStackBlocks(child);
for (const cb of childBlocks) {
  await executeBlockAction(cb);  // Executes ALL descendants directly
}
```

When nested (e.g., `repeat 3 { repeat 2 { move } say }`):
- Outer repeat calls `getStackBlocks(inner_repeat)` = `[inner_repeat, move, say]`
- Inner repeat also calls `getStackBlocks(move)` = `[move]`
- Result: `move` runs 3×(2+1) = 9 times instead of 3×2 = 6 times

**Fix:** Introduced `executeBlockChain(startBlock, prefix)` — a walker that properly skips past children of control-flow blocks, matching the pattern used by the outer execution loop. Both `repeat` and `if_then` now delegate to `executeBlockChain` instead of blindly iterating over all descendants.

---

## 3. Conditional Logic ("if then")

**Verdict: ✅ Correct (basic cases)**

- `true` / `false` — literal values work correctly
- `touching edge` — checks sprite bounds within 15px of stage edges. Correct.
- `touching color` — was always `false`. Updated to check a small region around the sprite's center (sprite origin at stage center). This is a rough approximation but functional.
- Default fallback to `cond === 'true'` — safe.

**Before:** iterated over `getStackBlocks(child)` with nested execution.  
**After:** delegates to `executeBlockChain` for correct nested handling.

---

## 4. Wait Block & CPU

### Wait block

```js
// BEFORE
while (Date.now() < until && !executionAborted) {
  await new Promise(r => setTimeout(r, 50));
}
```

**Verdict:** Not busy — `await` yields to the event loop. The 50ms polling gives ~20 iterations/sec maximum, which is negligible. Without polling, `executionAborted` wouldn't be checked until the full timeout expires.

**Improvement:** Extracted into shared `waitWithAbort(ms)` using recursive `setTimeout` instead of a `while` loop. Same behavior, cleaner code, shared by all blocks.

### Blocks that lacked abort support

The following blocks used plain `setTimeout` without checking `executionAborted` during their delay:

| Block | Before | After |
|-------|--------|-------|
| `say` | `setTimeout(r, secs*1000)` | `waitWithAbort(secs*1000)` + abort check |
| `think` | `setTimeout(r, secs*1000)` | `waitWithAbort(secs*1000)` + abort check |
| `move_steps` | `setTimeout(r, 100)` | `waitWithAbort(100)` |
| `turn_cw` | `setTimeout(r, 50)` | `waitWithAbort(50)` |
| `turn_ccw` | `setTimeout(r, 50)` | `waitWithAbort(50)` |
| `goto_xy` | `setTimeout(r, 50)` | `waitWithAbort(50)` |
| `jump` (1st delay) | `setTimeout(r, 150)` | `waitWithAbort(150)` + abort guard |
| `play_sound` | `setTimeout(r, 300)` | `waitWithAbort(300)` |
| `play_drum` | `setTimeout(r, beats*500)` | `waitWithAbort(beats*500)` |
| `wait` | (already polling) | migrated to `waitWithAbort` |

The `jump` block also restores the sprite's original Y position on abort to avoid leaving it in mid-air.

---

## 5. State Management

**Verdict: ✅ Correct for single-sprite MVP**

- **Sprite position:** `sprite.x`/`sprite.y` — updated and clamped to `[10,470]` × `[10,310]`
- **Direction:** `sprite.direction` — 0°=up, 90°=right (Scratch convention). CW/CCW rotation uses modulo arithmetic with proper negative handling.
- **Visibility:** `sprite.visible` — toggled by `show`/`hide` blocks
- **Size:** `sprite.size` — stored but only used for canvas scaling when >0

**Multiple script conflicts:** `executeAll()` processes root stacks sequentially. Since JavaScript is single-threaded, there are no true races — each stack completes before the next begins. This is correct for sequential execution but differs from Scratch's concurrent script behavior.

**Reset on Run:** Sprite position, direction, and visibility are reset at the start of each `executeAll()` call.

---

## 6. DOM / Canvas Sync

**Verdict: ✅ Correct**

- `drawSprite()` clears the canvas and redraws the sprite after every motion/visibility block
- The sprite rotation uses Scratch conventions: `angle = (direction - 90) × π / 180`, mapping Scratch 0°=up to canvas 0°=right
- Speech bubble positioning uses sprite coordinates scaled to the stage container
- The 50–150ms delays between frames give the browser adequate time to repaint between steps

---

## 7. Race Conditions

### Run button double-click

```js
async function executeAll() {
  if (executionRunning) return;  // ← Guard prevents re-entry
  executionRunning = true;
  // ...
  executionRunning = false;      // ← Only set after async chain completes
}
```

**Verdict: ✅ Safe.** The guard at entry prevents simultaneous executions. The flag is set synchronously before the first `await`, so no async gap exists at the entry point.

### Stop + immediate Restart

```
Click Run   → executionRunning=true,  executionAborted=false
Click Stop  → executionAborted=true
Loop exits  → executionRunning=false  (synchronous block, no await between check and write)
Click Run   → executionRunning=false  → guard allows entry → executionAborted=false
```

**Verdict: ✅ Safe.** The abort path reaches `executionRunning = false` synchronously.

### Keyboard shortcuts (R / Space / Escape)

```
Key 'R' → running? stopExecution() : executeAll()
Key ' ' → same toggle
Escape → stopExecution()
```

**Verdict: ✅ Safe.** Keyboard handlers toggle between Run and Stop, and the `executeAll` guard prevents overlap.

---

## Fix Summary

| # | Issue | Severity | Lines Changed | Fix |
|---|-------|----------|---------------|-----|
| 1 | `repeat 0` executes 1 iteration | **High** | 1 | `|| 1` → `Math.max(0, ... || 0)` + early exit |
| 2 | Nested control flow double-executes children | **High** | ~20 | `executeBlockChain` helper with proper skip logic |
| 3 | 10 blocks ignore `executionAborted` during wait | **Medium** | ~15 | `waitWithAbort()` shared polling helper |
| 4 | Repeat/if_then describe children inline (DRY) | **Low** | ~15 | `buildBlockDesc()` shared helper |
| 5 | `touching color` always false | **Low** | 2 | Simple hitbox check around sprite center |
| 6 | Jump leaves sprite displaced on abort | **Low** | 3 | Restore Y position before break |
| 7 | Duplicate block description logic across 3 sites | **Low** | ~10 | Extract `buildBlockDesc()` helper |

---

## Tests Performed

All tests pass with 0 JS errors:

1. **Page load** — canvas, workspace, palette (16 blocks), buttons all present
2. **Run (empty)** — shows "No blocks on workspace."
3. **Run (with block)** — drag "move 10 steps" from palette → click Run → output shows walkthrough, sprite moves on canvas, "✓ Completed"
4. **`buildBlockDesc`** — correctly substitutes `%1` with value
5. **`waitWithAbort` abort** — resolves in <100ms when `executionAborted=true`
6. **`repeat 0` fix** — `n` evaluates to `0`, early exit triggers
7. **Say abort** — `say 10` interrupted after ~100ms, speech bubble hidden
8. **Clear + Run re-run** — button state toggles correctly

---

## Known Limitations (Out of Scope)

1. **Flat-chain architecture** — No distinction between "inside C-shape" (repeat/if body) and "after C-shape" (next sibling). Every block below a control block is treated as its body.
2. **Single sprite** — No support for multiple sprites or costumes
3. **Sequential execution** — Stacks run one after another, not concurrently like Scratch
4. **`touching color`** — Uses a simple center-point proximity check instead of pixel-level color collision
5. **Category ordering** — The skip logic assumes `repeat` and `if_then` IDs; adding new control blocks requires updating the skip check
