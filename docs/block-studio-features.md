# Block Studio (VoxelWorks) — Full Feature Map

> **Source:** `/home/ubuntu/.openclaw/workspace/voxelworks/block-editor/index.html`
> **Total lines:** 1028 (single self-contained HTML file)
> **Framework:** None — vanilla HTML/CSS/JS
> **Architecture:** Single-file SPA with IIFE ("(function(){'use strict'; ... })()")

---

## 1. Block Categories & Blocks

Total **4 categories**, **16 blocks** defined.

### Motion (`#4C97FF`)

| Block ID | Label | Args | Type |
|----------|-------|------|------|
| `move_steps` | move %1 steps | number(10) | regular |
| `turn_cw` | turn ↻ %1 degrees | number(15) | regular |
| `turn_ccw` | turn ↺ %1 degrees | number(15) | regular |
| `goto_xy` | go to x:%1 y:%2 | number(0), number(0) | regular |
| `jump` | jump | none | regular |

### Looks (`#9966FF`)

| Block ID | Label | Args | Type |
|----------|-------|------|------|
| `say` | say %1 for %2 secs | text("Hello!"), number(2) | regular |
| `think` | think %1 for %2 secs | text("Hmm..."), number(2) | regular |
| `show` | show | none | regular |
| `hide` | hide | none | regular |

### Control (`#FFAB19`)

| Block ID | Label | Args | Type |
|----------|-------|------|------|
| `when_clicked` | when clicked | none | **hat** (no notch) |
| `if_then` | if %1 then | dropdown(true/false/touching edge/touching color) | regular |
| `repeat` | repeat %1 | number(10) | regular |
| `wait` | wait %1 secs | number(1) | regular |

### Sound (`#CF63CF`)

| Block ID | Label | Args | Type |
|----------|-------|------|------|
| `play_sound` | play sound %1 | dropdown(meow/chirp/buzz/pop) | regular |
| `stop_sound` | stop all sounds | none | regular |
| `play_drum` | play drum %1 for %2 beats | dropdown(snare/kick/hi-hat/cymbal), number(0.25) | regular |

**Total: 16 blocks.** The `jump`, `show`, `hide`, `stop_sound` blocks are parameterless.

---

## 2. Hidden / Unused Features

### 2a. "Sensing" Category Defined but NOT Populated

The CSS defines a variable `--sensing:#5CB1D6`, and the color value suggests a sensing category was planned. However, the `CATEGORIES` array contains no `sensing` category and no sensing blocks exist.

### 2b. Palette Trash Zone (Undocumented)

If a dragged block is **dropped over the palette area**, the entire stack is deleted from the workspace. This acts as a trash/delete zone. No visual indicator exists — no trash icon, no highlight. Completely hidden.

### 2c. Keyboard Shortcut `R`

Pressing `R` or `r` (without Ctrl/Meta) triggers `executeAll()` — same as clicking the Run button. Undocumented in the UI.

### 2d. Grid Snap System

All blocks snap to a `12px` grid on drop. This is invisible to the user (no grid axis labels, no snap indicators during positioning).

### 2e. Dropdown Blocks with Multi-Option Conditions

The `if_then` block offers two interesting options beyond true/false: "touching edge" and "touching color" — however, NO code evaluates these conditions at runtime.

### 2f. Step-free Number Inputs

Number inputs use `step="any"`, meaning decimals are allowed (e.g., 1.5 steps). This is standard Scratch behavior but not highlighted.

### 2g. Cat.blocks Array Order

All block IDs and their order in the `CATEGORIES` array follow a Scratch-like convention. The array ordering is significant for palette rendering.

---

## 3. Interactive Elements

### Palette (Left Panel)

| Element | Type | Behavior |
|---------|------|----------|
| Category header | Clickable div | Toggles `.open` class on cat-body, rotates arrow |
| Category dot | Visual only | Colored square indicator |
| Palette blocks | `mousedown` handler (left-button) | Clones block into workspace, starts drag |

### Workspace (Center Area)

| Element | Type | Behavior |
|---------|------|----------|
| Workspace background | Drop zone | Shows radial glow on drag (`workspace-drag-over` class) |
| Empty hint | Visual only | Hidden when `instances.length > 0` |
| Block instances | `mousedown` handler | Starts drag on the block (moves entire stack) |
| Block instance inputs | `mousedown` handler + `stopPropagation()` | Prevents drag from starting on input/select clicks |
| Block instance number inputs | `change` handler | Updates `inst.fields[key]` with parsed float |
| Block instance text inputs | `change` handler | Updates `inst.fields[key]` with raw string |
| Block instance dropdowns | `change` handler | Updates `inst.fields[key]` with dropdown value |

### Header Bar

| Element | ID | Behavior |
|---------|----|----------|
| Run button | `btn-run` | Calls `executeAll()` |
| Clear button | `btn-clear` | Calls `clearAll()` + `renderAll()` |

### Output Panel (Bottom)

| Element | Behavior |
|---------|----------|
| Output content | Scrollable div, receives `appendOutput()` calls |
| Status indicator | Shows "ready", "running...", "done ✓", "cleared" |

### Global

| Element | Behavior |
|---------|----------|
| `document` keydown | Triggers `executeAll()` on R/r (no Ctrl/Meta) |
| `document` mousemove (on drag) | Updates block positions, checks snap |
| `document` mouseup (on drag) | Finalizes position, applies snap or grid-snap, clears drag state |

---

## 4. Event Handlers — Complete Inventory

| Event | Target | Phase | Handler | Effect |
|-------|--------|-------|---------|--------|
| `click` | cat-header | bubble | Toggle cat-body open/close | Shows/hides block templates |
| `mousedown` | palette-block | bubble | `startDrag(e, inst)` | Clones block to workspace, begins drag |
| `mousedown` | block-instance | bubble | `startDrag(e, inst)` | Grabs entire stack, begins drag |
| `mousedown` | input/select inside block | bubble | `e.stopPropagation()` | Prevents drag initiation when editing fields |
| `change` | number input inside block | bubble | Update `inst.fields[arg.key]` | Saves numeric value to instance fields |
| `change` | text input inside block | bubble | Update `inst.fields[arg.key]` | Saves text value to instance fields |
| `change` | select inside block | bubble | Update `inst.fields[arg.key]` | Saves dropdown value to instance fields |
| `click` | `#btn-run` | bubble | `executeAll()` | Iterates stacks, logs blocks to output |
| `click` | `#btn-clear` | bubble | `clearAll()` + `renderAll()` | Removes all blocks, clears output |
| `keydown` | `document` | bubble | Check R/r → `executeAll()` | Runs from keyboard |
| `mousemove` | `document` | capture | `onDrag(e)` | Moves blocks, snap detection |
| `mouseup` | `document` | capture | `endDrag(e)` | Finalizes drop, snap/unsnap, cleanup |

---

## 5. State Variables

### Global State

| Variable | Type | Purpose |
|----------|------|---------|
| `instances` | `Array<Instance>` | All block instances on the workspace (flat list) |
| `nextId` | `number` | Auto-incrementing ID generator (starts at 1) |
| `drag` | `Object|null` | Active drag state |

### Drag State Object

| Field | Type | Purpose |
|-------|------|---------|
| `inst` | Instance | Root block of the dragged stack |
| `el` | HTMLElement | Root block's DOM element |
| `startMX` | number | Mouse clientX at drag start |
| `startMY` | number | Mouse clientY at drag start |
| `offsetX` | number | Horizontal offset mouse → element top-left |
| `offsetY` | number | Vertical offset mouse → element top-left |
| `isClone` | boolean | True if from palette (fresh clone) |
| `origStack` | Array|null | Blocks in the stack at drag start (existing blocks only) |
| `snapTarget` | Object|null | Current snap candidate `{block, side, alignX, otherCenterX}` |

### Block Instance Object

| Field | Type | Purpose |
|-------|------|---------|
| `id` | number | Unique auto-increment ID |
| `def` | BlockDef | Reference to block definition from CATEGORIES |
| `fields` | Object | Current field values (keyed by arg key) |
| `x` | number | Grid-snapped X position on workspace |
| `y` | number | Grid-snapped Y position on workspace |
| `parentId` | number|null | ID of parent block in the stack (null = root) |
| `childId` | number|null | ID of child block below in the stack (null = last) |
| `el` | HTMLElement|null | DOM element reference |

### Snap Target Object

| Field | Type | Purpose |
|-------|------|---------|
| `block` | Instance | Root of the target stack |
| `side` | `"top"\|"bottom"` | Which edge of the target to snap to |
| `alignX` | number | Center X of dragged stack |
| `otherCenterX` | number | Center X of target stack |

---

## 6. Rendering Pipeline

### Step-by-step rendering flow

1. **`buildPalette()`** — Called once on init. Iterates `CATEGORIES`, creates category sections with headers and block templates. Each palette block is a `div.palette-block` with shoulders (notch) and bump, plus embedded inputs/selects.

2. **`buildBlockEl(inst, isPalette)`** — Creates a block DOM element.
   - Splits the label by `%1`, `%2` pattern tokens
   - Wraps label text in `<span>` elements
   - For each arg type: creates `<input type="number">`, `<input type="text">`, or `<select>` with multi-option support
   - Wraps everything in a `<span class="block-body">` (inline-flex)
   - Appends a `<div class="bump">` at bottom for interlock
   - Adds `--block-color` CSS variable for dynamic coloring
   - Hat blocks: omit `::before`/`::after` pseudo-elements (shoulders)
   - Attaches `mousedown` event listener

3. **`renderStack(root)`** — Renders a stack recursively.
   - Iterates `getStackBlocks(root)` (linked-list walk)
   - Sets `left`/`top` CSS for each block
   - Appends each `el` to workspace DOM
   - Spacing: `y += getBlockHeight(b) - NOTCH_H` between consecutive blocks

4. **`renderAll()`** — Renders ALL stacks.
   - Finds all root instances (no parent)
   - Removes ALL block elements from DOM (in one loop)
   - Calls `renderStack(root)` for each root

5. **`refreshPositions()`** — Updates CSS positions without re-appending.
   - Same logic as `renderStack` but only sets `style.left`/`style.top`

6. **`getBlockHeight(inst)`** — Computes visual height of one block.
   - Body height (queried from DOM) + NOTCH_H + (NOTCH_H if non-hat)
   - Non-hat: shoulders(8) + body + bump(8)
   - Hat: body + bump(8)

7. **`getStackVisualHeight(root)`** — Computes total visual height of a stack.
   - Manual calculation (NOT using `getBlockHeight`), sums individual block heights minus interlock overlap

### Block Visual Anatomy

```
   ┌─────────────────────┐  ← top (margin-top: var(--notch-h) = 8px)
   │   ╱     ────     ╲  │  ← shoulders (::before + ::after, 8px each)
   │  │  block-body    │  │  ← body with label + inputs
   │  │  e.g. "move  ╰┴╯"│
   │   ╲              ╱  │
   └─────────────────────┘  ← bumper div (.bump, 8px)
                              ← margin-bottom: var(--notch-h) = 8px
```

---

## 7. Drag-and-Drop System (Custom Mouse Events)

### Architecture

Not HTML5 DnD API. Custom implementation using `mousedown`, `mousemove`, `mouseup` on `document`.

### Drag Start (`startDrag`)

1. **Palette source:** Creates a new `createWorkspaceBlock()` at cursor position, appends to workspace, applies `dragging` CSS class, sets `drag.isClone=true`
2. **Workspace source:** Gets `getRoot(inst)`, stores entire stack in `drag.origStack`, no clones
3. Sets `drag.offsetX/Y` for smooth cursor-to-block positioning
4. Attaches `mousemove` + `mouseup` on `document`

### Drag Move (`onDrag`)

1. Computes new position: `clientX/Y - workspaceRect.left/top - offsetX/Y`
2. Snaps to grid: `snapToGrid(newX)`, `snapToGrid(newY)`
3. Repositions ALL blocks in the dragged stack (linked-list walk)
4. Applies `dragging` CSS class to each block (shadow + opacity)
5. Calls `findSnap()` for snap detection
6. Toggles `snap-indicator` class on target blocks
7. Shows workspace radial glow via `workspace-drag-over` class

### Snap Detection (`findSnap`)

- Threshold: `SNAP_DIST = 24px` vertical proximity
- Horizontal alignment tolerance: `SNAP_DIST * 1.5 = 36px` (center-to-center)
- Checks two cases:
  - **Drag bottom to other top:** Dragged stack's bottom edge near another stack's top edge
  - **Other bottom to drag top:** Another stack's bottom edge near dragged stack's top edge
- Returns the closest snap candidate by distance

### Drag End (`endDrag`)

1. Removes event listeners
2. Removes `dragging` and `snap-indicator` classes
3. **Palette zone check:** If dropped over palette, deletes entire stack
4. **Snap commit:** If snap target exists:
   - **`side: 'top'`:** Dragged stack goes ABOVE target. Last block of drag chain-links to target root. Parent of target root chain-links to drag stack.
   - **`side: 'bottom'`:** Dragged stack goes BELOW target. Target's last child chain-links to drag root.
   - Calls `renderAll()` to rebuild DOM positions
5. **No snap:** Grid-snaps position, calls `refreshPositions()`

### Snap Connection Model

Blocks form a **singly-linked list** via `parentId`/`childId`:
- `parentId = null` → root block (top of stack)
- `childId = null` → last block (bottom of stack)
- Each block has exactly one parent and one child (linked list node)

---

## 8. Persistence

**NONE.** No localStorage, no server save, no URL serialization. All state is in-memory only. Refreshing the page loses everything.

---

## 9. Execution System

### `executeAll()` — The Run Button

**Does the Run button actually execute scripts? NO.** It only **prints/describes** the blocks.

### What happens when Run is clicked:

1. Clears output panel
2. Sets status to "running..."
3. Filters `instances` to roots (stacks)
4. For each stack:
   - Prints a header: `── Stack N: "block_label" ──`
   - For each block in the stack:
     - Replaces `%1`, `%2` tokens with actual field values
     - Appends `▶ block_description` to output
5. Sets status to "done ✓"
6. Appends "✓ Completed"

### What DOES NOT happen:

- ❌ No sprite/bot movement (move_steps, turn, goto_xy, jump are purely cosmetic)
- ❌ No speech bubbles (say, think)
- ❌ No show/hide state
- ❌ No sound playback (play_sound, stop_sound, play_drum)
- ❌ No conditional branching (if_then)
- ❌ No loops (repeat)
- ❌ No delays (wait)
- ❌ No "when clicked" event handling

### Output format

```
▸ ── Stack 1: "move [...]" ──
▸ ▶ move 10 steps
▸ ▶ turn ↻ 15 degrees
▸ ▶ jump
▸
▸ ── Stack 2: "say [...]" ──
▸ ▶ say Hello! for 2 secs
▸ ▶ wait 1 secs
▸
✓ Completed
```

Output uses colored CSS classes:
- `.info` → green text (`#8aff8a`)
- `.warn` → orange text (`#ffab19`)
- `.error` → red text (`#ff6b6b`)
- `.done` → accent purple (`#6C6CE0`)
- `.ts` → muted gray timestamp prefix (`▸`)

---

## 10. CSS Architecture

### Layout (Flexbox)

```
#app (flex column, 100vh)
├── header (height: 48px, fixed)
├── .main-area (flex row, flex: 1)
│   ├── .palette (width: 280px, sticky, scrollable)
│   └── .workspace (flex: 1, grid background, overflow: hidden)
└── .output-panel (height: 180px, fixed)
```

### Key CSS Features

- **CSS Variables:** 24 custom properties including category colors, layout constants, and snap/threshold values
- **Block notch/bump:** Pure CSS using `::before`/`::after` pseudo-elements for trapezoidal shoulders and `.bump` div
- **Grid background:** Dual `linear-gradient` to create grid lines
- **Drag overlay:** `radial-gradient` glow that follows mouse during drag
- **Scrollbar styling:** Custom thin scrollbars for palette and output

---

## 11. Bugs, Limitations & Incomplete Features

### Bugs

| # | Bug | Details |
|---|-----|---------|
| B1 | **Inconsistent height calculation** | `getStackVisualHeight(root)` calculates heights manually (body.offsetHeight + NOTCH_H × 2) while `renderStack()` uses `getBlockHeight()` (bodyH + NOTCH_H + optional NOTCH_H). These can produce different values if body heights differ, causing visual misalignment after snap |
| B2 | **DOM thrashes on every drag** | `renderAll()` removes ALL block elements from DOM and re-appends them on every snap commit. Could cause flicker and forces full layout recalc |
| B3 | **Snap "bottom" calculates unused variable** | In `endDrag()`, a `let y=targetRoot.y;` loop iterates target blocks then computes `dragStartY` independently. The variable `y` is set but never actually used for positioning |
| B4 | **Snap positions may jitter** | After snap, `renderAll()` is called which rebuilds ALL stack positions from scratch. But the linked-list model means positions are recalculated from roots only—moving stacks may get reordered |
| B5 | **Dropping on palette deletes entire stack** | The "trash zone" has no visual feedback. A user dragging near the palette to scroll might accidentally lose blocks |
| B6 | **Number inputs accept invalid values** | `parseFloat(inp.value)||0` means a completely empty input becomes 0, and non-numeric input becomes 0 without warning |

### Limitations

| # | Limitation |
|---|-----------|
| L1 | **No undo/redo** — any accidental deletion is permanent |
| L2 | **No block selection** — no way to select a single block within a stack |
| L3 | **Stack is atomic** — dragging any block in a stack drags the entire stack. No way to split or reorder within a stack |
| L4 | **No persistence** — all state lost on page refresh |
| L5 | **No workspace zoom/pan** |
| L6 | **No snapping visual line** — snap is highlighted with a white outline, not a guide line |
| L7 | **Single workspace only** — no multiple script/stack areas |
| L8 | **No drag-scroll** — if blocks are dragged beyond visible workspace area, they disappear |
| L9 | **No collision avoidance** — blocks can overlap if dropped on top of each other without snap |
| L10 | **No context menu** — no delete/duplicate actions except drag-to-palette delete |
| L11 | **Infinite empty-stack rendering** — if a block has `childId` pointing to another root, `renderStack` shows it in both places temporarily |
| L12 | **No CSS transitions on drop** — snap positioning updates are instant, no animation |

### Incomplete Features

| # | Feature | Status |
|---|---------|--------|
| F1 | **Sensing category** | Color defined (`#5CB1D6`) but no blocks created |
| F2 | **if_then conditional logic** | Block exists but no code evaluates the condition at runtime |
| F3 | **repeat loop execution** | Block exists but no looping logic |
| F4 | **wait/delay execution** | Block exists but no `setTimeout`/`async` handling |
| F5 | **Sound playback** | Play/stop blocks exist but no `Audio` API integration |
| F6 | **Sprite/bot movement** | Motion blocks exist but no visual sprite to manipulate |
| F7 | **Speech bubbles (say/think)** | Blocks exist but no bubble rendering |
| F8 | **Show/hide state management** | No visibility state for any on-screen element |
| F9 | **when_clicked event** | Hat block exists but no green-flag or click-to-start mechanism |
| F10 | **Keyboard Delete/Backspace** | Handled in `keydown` listener but logic is `// skip` (commented out) |

---

## 12. Technical Architecture Summary

```
                 ┌─────────────────────┐
                 │    CATEGORIES[]      │  ← Static block definitions
                 │   (4 categories,     │
                 │    16 blocks total)  │
                 └──────┬──────┬────────┘
                        │      │
               ┌────────┘      └────────┐
               ▼                         ▼
        ┌─────────────┐         ┌───────────────┐
        │  Palette     │         │  Workspace     │
        │  (left 280px)│         │  (flex: 1)     │
        │  buildPalette│         │  instances[]   │
        └──────┬───────┘         └───────┬────────┘
               │ mousedown               │
               ▼                         │
        ┌─────────────┐                  │
        │  startDrag()│──────────────────┤
        └──────┬──────┘  creates clone   │
               │ mousemove               │
               ▼                         │
        ┌─────────────┐                  │
        │  onDrag()   │ ◄─────────────── │
        │  +findSnap()│  moves blocks    │
        └──────┬──────┘                  │
               │ mouseup                 │
               ▼                         │
        ┌─────────────┐                  │
        │  endDrag()  │──────────────────│
        │  snap/unsnap│  updates inst[]│
        │  → renderAll│                 │
        └─────────────┘                 │
                                         │
               ▼                         ▼
        ┌─────────────────────────────────────┐
        │         Execute All                  │
        │  executeAll() — logs only, no exec   │
        └─────────────────────────────────────┘
```

### Data Flow

```
CATEGORIES  ──→  buildPalette()
                         │
              palette-block mousedown
                         │
                         ▼
               createWorkspaceBlock()
                         │
                         ▼
               instances.push(inst)
                         │
                  drag state active
                         │
              mousemove → findSnap()
                         │
              mouseup → snap commit
                         │
              update parentId/childId
                         │
              renderAll() → DOM update
                         │
                  btn-run click
                         │
                         ▼
                executeAll() (log only)
```

---

## 13. Constants & Configuration

| Constant | Value | Purpose |
|----------|-------|---------|
| `GRID` | 12 | Grid snap size (px) |
| `NOTCH_H` | 8 | Notch/bump height (px) |
| `SNAP_DIST` | 24 | Snap threshold (px) |
| `--snap-threshold` | 22px | CSS variable (unused in JS — SNAP_DIST has priority) |
| `--palette-w` | 280px | Palette width |
| `--header-h` | 48px | Header height |
| `--output-h` | 180px | Output panel height |
| `--notch-h` | 8px | CSS notch height |
| `--bump-w` | 28px | Bump width |
| `--bump-h` | 8px | Bump height |

---

## 14. Summary Statistics

| Metric | Value |
|--------|-------|
| Total lines of code | 1028 |
| Block categories | 4 (Motion, Looks, Control, Sound) + 1 unused (Sensing) |
| Total blocks defined | 16 |
| Hat blocks | 1 (`when_clicked`) |
| Blocks with inputs | 7 (number/text/dropdown) |
| Parameterless blocks | 5 (jump, show, hide, stop_sound, when_clicked) |
| Number inputs | 7 |
| Text inputs | 2 |
| Dropdown inputs | 3 (if_then, play_sound, play_drum) |
| Interactive elements (total) | ~32 (4 cat headers + 16 palette blocks + variable workspace blocks + 2 buttons + 1 document keydown) |
| Event handlers | 12 distinct handler registrations |
| State variables (top-level) | 4 (instances, nextId, drag, + DOM refs) |
| Helper functions | ~20 |
| CSS classes | ~25 |
| CSS custom properties | 24 |
| Runtime execution | **NONE** — log-only |

### Does the Run button actually execute scripts?

**No.** The Run button (`btn-run`) triggers `executeAll()`, which iterates through all workspace stacks and prints each block's description to the output panel with substituted field values. It performs zero actual execution:
- No sprite movement
- No sound playback
- No conditional branching
- No looping
- No delays/timers
- No show/hide toggling
- No speech bubbles

### What the execution output looks like

A scrolling log panel at the bottom of the screen with:
- Stack separators (`── Stack N: "block_label" ──`)
- Each block listed with values substituted (`▶ move 10 steps`)
- Green `.info` lines for block execution
- Purple `.done` final line: "✓ Completed"
- Status badge changes from "ready" → "running..." → "done ✓"

### Key Limitations

1. **Not a running interpreter** — it's a block editor with output logging only
2. **No actual execution engine** — no runtime, no event loop, no async handling
3. **Singe-file monolith** — easy to extend but tightly coupled
4. **No visual target** — no sprite, no canvas, no 3D scene to act upon
