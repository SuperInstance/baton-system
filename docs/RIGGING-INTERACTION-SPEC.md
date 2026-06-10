# Rigging Interaction Specification: Shake, Watch, Learn

**Status:** Technical Specification · **Date:** 2026-06-04 · **Version:** 0.1.0-draft

> Grab a piece of rigging on a big sailboat and shake it — watch where it connects, what it pulls, what loosens. That's what the interactive spreadsheet does with values.

---

## Table of Contents

1. [The Rigging Metaphor](#1-metaphor)
2. [Interaction Model](#2-interaction-model)
3. [Oscillation Modes](#3-oscillation-modes)
4. [Ripple Propagation](#4-ripple-propagation)
5. [Visual Feedback](#5-visual-feedback)
6. [The Shake-and-Watch Pattern](#6-shake-and-watch)
7. [Conservation Law Visualization](#7-conservation-vis)
8. [Fitness Landscape Reshaping](#8-fitness-reshaping)
9. [Strategy Ecology Response](#9-ecology-response)
10. [How This Differs from Existing UIs](#10-differences)
11. [Implementation Reference](#11-implementation)

---

## 1. The Rigging Metaphor

### 1.1 The Sailboat

A sailboat's rigging is a web of lines (ropes) connecting sails, masts, booms, and winches. Every line is under tension. Every line connects to multiple other lines. An experienced sailor can grab any line and shake it, feeling:

- **Where it connects:** Which lines are directly attached.
- **What it pulls:** Which lines tighten when this one is pulled.
- **What loosens:** Which lines go slack when this one is tensioned.
- **How far the effect reaches:** Does the shake propagate to the mainsheet, or only to the nearest shroud?

The sailor reads the rigging's response to understand the entire vessel's state — not by inspecting each line individually, but by shaking one and watching the system respond.

### 1.2 The Spreadsheet as Rigging

Every value in the SMP spreadsheet is a line in the rigging. The dependencies between cells are the connections between lines. Conservation laws are the physics of tension. Fitness landscapes are the shape the sail makes. Strategy ecologies are the crew members adjusting their stance.

When the user "grabs" a value and "shakes" it (oscillates it), the spreadsheet shows:

- **Where it connects:** Which cells depend on this value.
- **What it pulls:** Which cells change when this value changes.
- **What loosens:** Which conservation constraints are violated by the change.
- **How far the effect reaches:** The ripple cascade through the dependency graph.

This is exploratory interaction — the user is not trying to find an optimal value. They are trying to understand the topology of the system.

---

## 2. Interaction Model

### 2.1 Entry into Rigging Mode

The user enters rigging mode through one of three gestures:

| Gesture | Trigger | Scope |
|---|---|---|
| **Shift+Click** | Hold Shift, click a cell | Single cell |
| **Range Select + Shift+Enter** | Select range, then Shift+Enter | Range of cells |
| **Rigging Tool** | Click the rigging tool in the toolbar | Followed by click/drag on cells |

When rigging mode activates, the spreadsheet transitions from **edit mode** to **oscillation mode**:

```
Edit Mode:
  ┌───────────────────────────┐
  │  Cell selected             │
  │  Formula bar active        │
  │  Cursor blinking           │
  │  Keyboard input → edit     │
  └───────────────────────────┘

Oscillation Mode:
  ┌───────────────────────────┐
  │  Cell GRABBED (highlighted)│
  │  Dependency edges visible  │
  │  Conservation gauge shown  │
  │  Drag → oscillate value    │
  │  Release → settle value    │
  └───────────────────────────┘
```

### 2.2 The Grab State

When a cell is grabbed, the system computes and displays:

1. **Immediate dependencies** (1-hop): Cells whose formulas reference the grabbed cell.
2. **Transitive dependencies** (N-hop): Cells reachable through formula chains.
3. **Conservation group**: The conservation constraint(s) involving this cell.
4. **Fitness contribution**: How much this cell contributes to the grid's fitness.
5. **Strategy species**: Which strategy species are influenced by this cell's value.

This information is computed in real-time using the ternary graph structure:

```rust
pub struct GrabState {
    /// The grabbed cell's position.
    pub cell: CellPosition,
    /// The grabbed cell's current value.
    pub current_value: TernaryValue,
    /// The grabbed cell's value range (min, max).
    pub value_range: (f64, f64),
    /// Direct dependencies (1-hop).
    pub direct_deps: Vec<DependencyEdge>,
    /// Transitive dependencies (up to max_depth hops).
    pub transitive_deps: Vec<DependencyEdge>,
    /// Conservation groups this cell belongs to.
    pub conservation_groups: Vec<ConservationGroup>,
    /// Fitness contribution of this cell.
    pub fitness_contribution: f64,
    /// Strategy species influenced by this cell.
    pub influenced_species: Vec<StrategySpecies>,
    /// Ripple propagation speed (computed from graph structure).
    pub propagation_speed: f64,
}

pub struct DependencyEdge {
    /// Source cell (the grabbed cell or a dependency).
    pub from: CellPosition,
    /// Target cell (the dependent cell).
    pub to: CellPosition,
    /// Edge weight: +1 (promote), 0 (neutral), -1 (suppress).
    pub weight: TernaryValue,
    /// Graph distance from grabbed cell (1 = direct, 2+ = transitive).
    pub distance: usize,
    /// Sensitivity: how much the target changes when the source changes.
    pub sensitivity: f64,
}
```

### 2.3 The Oscillation Gesture

Once grabbed, the user oscillates the value by dragging:

```
┌─────────────────────────────────────────────┐
│                                              │
│  Cell Value:  ●──────────────── 0.5         │
│               (drag left = decrease)          │
│               (drag right = increase)         │
│               (drag up/down = amplitude)      │
│                                              │
│  Current:  0.5                               │
│  Oscillation: ±0.3 (from drag amplitude)     │
│  Frequency: 2.0 Hz (from drag speed)         │
│                                              │
│  Ripple Status:                              │
│    Direct deps: 4 cells responding           │
│    Transitive: 12 cells responding           │
│    Conservation: STABLE (0.98)               │
│    Fitness: 0.72 → 0.68 (declining)         │
│                                              │
└─────────────────────────────────────────────┘
```

The user can also oscillate using the keyboard:

| Key | Action |
|---|---|
| Left/Right arrows | Decrease/Increase value by step |
| Up/Down arrows | Increase/Decrease oscillation amplitude |
| Space | Toggle auto-oscillation (sinusoidal) |
| 1-5 | Set oscillation frequency (slow to fast) |
| R | Randomize value (stochastic exploration) |
| Escape | Release cell (exit rigging mode) |
| Enter | Commit current value (settle) |

---

## 3. Oscillation Modes

### 3.1 Single Value Oscillation

**What happens:** The user grabs one cell and drags it through a range of values.

**Propagation:**
```
1. User moves grabbed cell from V_old to V_new.
2. All cells with formulas referencing the grabbed cell recalculate.
3. Their dependents recalculate in turn (cascade).
4. Conservation law checks: is the total preserved?
5. If not, compensating adjustments are made in distant cells.
6. Fitness and species metrics update.
```

**Visual effect:** A single point of light (the grabbed cell) with radiating concentric rings (the ripples). Each ring represents one hop in the dependency graph. The rings pulse as the value oscillates.

**Use case:** "What happens to my quarterly forecast if Q2 revenue is 15% lower?" — grab the Q2 revenue cell, drag it down 15%, watch the forecast cells respond.

### 3.2 Group Oscillation

**What happens:** The user grabs a range of cells and oscillates them together with configurable phase relationships.

**Phase modes:**

| Mode | Phase Pattern | Visual | Discovers |
|---|---|---|---|
| **In-phase** | All cells move together | Synchronized pulse | Cooperative effects |
| **Anti-phase** | Adjacent cells move in opposite directions | Alternating light/dark | Competitive effects |
| **Traveling wave** | Phase offset proportional to distance | Wave animation | Spatial dynamics |
| **Standing wave** | Fixed nodes and antinodes | Static pattern with moving antinodes | Resonance modes |
| **Random phase** | Each cell has independent random phase | Chaotic flickering | Robustness and chaos |

**Propagation:** Same as single value, but with multiple sources creating interference patterns. Constructive interference (ripples adding up) amplifies effects; destructive interference (ripples canceling) dampens effects.

**Use case:** "What if demand in the western region is seasonal?" — grab the western region cells, set to traveling wave mode, adjust frequency to seasonal patterns.

### 3.3 Cascade Oscillation

**What happens:** The user perturbs one cell and releases it. The perturbation cascades through the dependency graph naturally, without further user input.

**Cascade dynamics:**
```
Tick 0: User perturbs cell (x, y) from V to V + Δ.
Tick 1: Direct dependencies update. Changes: δ₁, δ₂, ..., δₖ.
Tick 2: Their dependencies update. Changes propagate outward.
Tick 3+: Wave continues until:
  a) All changes fall below threshold (convergence).
  b) Conservation law triggers compensating changes.
  c) A limit cycle is detected (oscillating forever).
  d) Maximum tick count is reached (safety limit).
```

**Cascade termination conditions:**

| Condition | Meaning | Visualization |
|---|---|---|
| **Convergence** | System reaches new equilibrium | Ripples dampen, cells settle to steady colors |
| **Conservation violation** | Perturbation too large for system to absorb | Red flash across conservation gauge |
| **Limit cycle** | System oscillates indefinitely | Persistent pulsing in affected region |
| **Divergence** | Values grow without bound | Cells flash red, system auto-stabilizes |
| **Safety timeout** | Cascade exceeds tick limit | All changes frozen, system prompts user |

**Use case:** "What if we remove this regulatory constraint?" — grab the constraint cell, set to 0, release. Watch the cascade reveal which downstream cells depended on that constraint.

---

## 4. Ripple Propagation

### 4.1 Propagation Mechanics

Ripples propagate through the dependency graph at a rate determined by the graph's structure:

```rust
pub struct RippleEngine {
    /// The dependency graph.
    graph: TernaryGraph,
    /// Maximum propagation depth (safety limit).
    max_depth: usize,
    /// Minimum change threshold (below this, propagation stops).
    min_change: f64,
    /// Conservation enforcement mode.
    conservation_mode: ConservationMode,
}

pub enum ConservationMode {
    /// No conservation enforcement (free propagation).
    Free,
    /// Compensate immediately when violation detected.
    ImmediateCompensate,
    /// Compensate gradually over multiple ticks.
    GradualCompensate { rate: f64 },
    /// Halt propagation when violation detected.
    StrictHalt,
}

impl RippleEngine {
    /// Propagate a change from a source cell through the dependency graph.
    pub fn propagate(
        &mut self,
        source: CellPosition,
        delta: f64,
    ) -> RippleReport {
        let mut report = RippleReport::new();
        let mut frontier: Vec<(CellPosition, f64)> = vec![(source, delta)];
        let mut visited: HashSet<CellPosition> = HashSet::new();
        
        for depth in 0..self.max_depth {
            let mut next_frontier: Vec<(CellPosition, f64)> = Vec::new();
            
            for (cell, change) in frontier {
                if change.abs() < self.min_change {
                    continue; // Change too small to propagate
                }
                if visited.contains(&cell) {
                    continue; // Already processed
                }
                visited.insert(cell);
                
                // Apply change to cell
                let actual_change = self.apply_change(cell, change);
                report.add_change(cell, actual_change, depth);
                
                // Propagate to dependencies
                for edge in self.graph.edges_from(cell) {
                    let propagated = actual_change * edge.sensitivity;
                    let weighted = match edge.weight {
                        TernaryValue::Positive => propagated * 1.5,  // Promote: amplify
                        TernaryValue::Neutral => propagated * 1.0,   // Neutral: pass through
                        TernaryValue::Negative => propagated * 0.5,  // Suppress: dampen
                    };
                    next_frontier.push((edge.to, weighted));
                }
            }
            
            if next_frontier.is_empty() {
                break; // Ripple has died out
            }
            
            frontier = next_frontier;
        }
        
        // Check conservation
        report.conservation_status = self.check_conservation();
        
        report
    }
}
```

### 4.2 Ternary Weight Effects on Propagation

The ternary weights on dependency edges determine how ripples propagate:

| Edge Weight | Propagation Effect | Ripple Behavior |
|---|---|---|
| **+1 (Signal)** | Amplify the change by 1.5× | Ripple grows stronger as it passes through |
| **0 (Silence)** | Pass through unchanged | Ripple maintains strength |
| **-1 (Suppress)** | Dampen the change by 0.5× | Ripple weakens as it passes through |

This creates natural "ripple barriers" — regions of the graph with mostly -1 weights that absorb perturbations. The user can discover these barriers through rigging: oscillate a cell and watch where the ripple stops. "The financial model's output cells barely respond to changes in the engineering inputs — there's a suppress barrier in the cost estimation layer."

### 4.3 Conservation Enforcement During Propagation

The conservation law acts as a global constraint during ripple propagation:

```
1. Before propagation:
   - Record current grid total: T₀ = Σ all cell values.
   
2. During propagation:
   - After each tick, compute new total: Tₙ = Σ all cell values.
   - Compute deviation: ΔT = Tₙ - T₀.
   - If |ΔT| > tolerance:
     a. Identify cells that can compensate (not yet visited by ripple).
     b. Distribute compensation: each compensating cell adjusts by -ΔT/N_compensate.
     c. Weight compensation by cell energy: high-energy cells absorb more.
     d. Record compensation in ripple report.
     
3. After propagation:
   - Verify |T_final - T₀| < tolerance.
   - If not, flag conservation violation in the report.
```

The visual effect: when a ripple hits a conservation boundary, compensating cells on the opposite side of the grid flash briefly, showing the conservation "push-back." The user sees the system's physics enforcing balance in real time.

---

## 5. Visual Feedback

### 5.1 Color Encoding

The rigging system uses the ternary-color palette for cell visualization:

| State | Color | Meaning |
|---|---|---|
| **Stable (low surprise)** | Cool blue/teal | Cell is well-predicted, no surprises |
| **Changing (being affected)** | Warm orange/yellow | Cell is responding to the oscillation |
| **Surprised (high prediction error)** | Hot red/magenta | Cell's prediction was wrong |
| **Conservation-compensating** | Flashing green | Cell is compensating to maintain conservation |
| **Dying (energy depleted)** | Dark gray, fading | Cell is losing energy from prediction failures |
| **Thriving (energy surplus)** | Bright white/gold | Cell is gaining energy from accurate predictions |

### 5.2 Connection Visualization

When rigging mode is active, dependency edges are rendered as animated connections:

```
+1 (Signal) edges:  ────────────→  (green, flowing toward dependent)
                     ════════════→  (thicker = higher sensitivity)

 0 (Silence) edges:  ─ ─ ─ ─ ─ ─ →  (gray, dashed)

-1 (Suppress) edges: ─ ─ ─ ─ ─ ─ →  (red, flowing with resistance)
                     · · · · · · →  (thinner = more suppressive)
```

The animation flows in the direction of dependency: from the grabbed cell toward its dependents. The flow speed represents propagation speed — fast-flowing edges transmit changes quickly; slow edges transmit changes with delay.

### 5.3 Ripple Animation

Ripples are visualized as expanding circles centered on the grabbed cell:

```
Tick 0:  ●           (grabbed cell)
Tick 1:  ◯●          (1-hop ring)
Tick 2:  ◯ ◯●        (2-hop ring)
Tick 3:  ◯ ◯ ◯●      (3-hop ring)
Tick 4:  ◯ ◯ ◯ ◯     (4-hop ring, fading)
```

Each ring's color represents the magnitude of change at that distance:

- **Bright orange** = large change (cells are very sensitive to the oscillation).
- **Pale yellow** = moderate change.
- **Faint blue** = small change (cells are mostly insulated from the oscillation).
- **Invisible** = no change (ripple has died out).

The rings expand at a rate proportional to the actual computation speed — if the propagation is fast (all cells update in one tick), the rings expand quickly; if propagation is slow (many ticks for changes to reach distant cells), the rings expand slowly. The animation IS the computation.

### 5.4 Conservation Gauge

A persistent gauge in the corner of the spreadsheet shows the conservation state:

```
┌──────────────────────┐
│ CONSERVATION          │
│ ████████████░░░ 0.97  │  ← Green: healthy
│ target: 0.98          │
│ deviation: 0.01       │
└──────────────────────┘

┌──────────────────────┐
│ CONSERVATION          │
│ ██████████░░░░░ 0.89  │  ← Yellow: drifting
│ target: 0.98          │
│ deviation: 0.09       │
└──────────────────────┘

┌──────────────────────┐
│ CONSERVATION          │
│ ██████░░░░░░░░░ 0.72  │  ← Red: violating
│ target: 0.98          │
│ deviation: 0.26       │
└──────────────────────┘
```

The gauge updates in real-time as the user oscillates values. When the gauge dips into red, the system highlights which cells are causing the violation and which cells are compensating.

### 5.5 Fitness Landscape Overlay

A 3D fitness landscape can be overlaid on the spreadsheet grid:

```
       High fitness
          ▲
         ╱ ╲
        ╱   ╲
       ╱  ●  ╲     ← Grabbed cell (lowering fitness)
      ╱   ╱   ╲
     ╱   ╱     ╲
    ╱___╱_______╲___►  Cell position
   Low fitness
```

The landscape deforms in real-time as the user oscillates the grabbed value. Peaks flatten, valleys deepen, ridges shift. The user sees the topology of the fitness space responding to their manipulation.

### 5.6 Species Population Bar

A stacked bar chart shows the strategy species distribution:

```
┌─────────────────────────────────────────────┐
│ SPECIES DISTRIBUTION                         │
│                                              │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓  │
│ ██████████████ Explorer                      │
│              ░░░░░░░░░░░ Diplomat            │
│                       ▒▒▒▒▒▒▒ Climber        │
│                              ▓▓▓ Marksman    │
│                                 ░ Prospector  │
│                                              │
│ 35% Explorer | 20% Diplomat | 18% Climber   │
│ 17% Marksman | 10% Prospector                │
└─────────────────────────────────────────────┘
```

The bars shift in real-time as the user oscillates values. Pushing values toward high entropy grows the Explorer bar; pushing toward precision grows the Marksman bar.

---

## 6. The Shake-and-Watch Pattern

### 6.1 The Interaction Loop

The core rigging interaction follows a "shake and watch" pattern:

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  GRAB    │────►│  SHAKE   │────►│  WATCH   │────►│  LEARN  │
│          │     │          │     │          │     │          │
│ Select   │     │ Oscillate│     │ Observe  │     │ Discover │
│ cell(s)  │     │ values   │     │ ripples  │     │ topology │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
     ▲                                                  │
     │              ┌─────────┐                         │
     └──────────────│  ADJUST │◄────────────────────────┘
                    │          │
                    │ Modify   │
                    │ approach │
                    └─────────┘
```

1. **Grab:** Select a cell or range. The system shows connections.
2. **Shake:** Oscillate the value(s). The system propagates ripples.
3. **Watch:** Observe the ripples, conservation response, fitness changes, species shifts.
4. **Learn:** Identify patterns — "This cell is connected to the conservation law through 3 hops" or "Oscillating this value triggers a cascade that reaches 47 cells."
5. **Adjust:** Based on what was learned, choose a different cell to grab, a different oscillation mode, or a different value range.

This is not a linear flow. The user may grab, shake briefly, release, grab a different cell, shake again, watch the comparison, and gradually build a mental model of the system's topology.

### 6.2 Discovery Examples

**Example 1: Hidden Conservation Coupling**

```
User grabs cell C7 (production capacity).
Oscillates from 1000 to 800.
Watches ripples propagate.
Observes: cells F3, F4, F5 (in the financial model) flash green.
Confusion: why does production capacity affect the financial model?
Investigation: follows the green flash dependency chain.
Discovery: C7 → D12 (utilization rate) → E8 (maintenance cost) → F3-F5 (operating expenses).
Learning: "I didn't realize production capacity was coupled to operating expenses through maintenance costs."
```

**Example 2: Ripple Barrier**

```
User grabs cell A1 (input parameter).
Oscillates with high amplitude.
Watches ripples propagate.
Observes: ripples reach cells A2-A10 but STOP at column B.
Investigation: checks edge weights between A10 and B1.
Discovery: edge weight is -1 (suppress). Column B actively resists changes from column A.
Learning: "There's a barrier between the input parameters and the model outputs. The suppress weights are acting as a low-pass filter."
```

**Example 3: Cascade Resonance**

```
User grabs cell E5.
Perturbs from 0 to +1.
Releases (cascade mode).
Watches cascade propagate.
Observes: the cascade bounces back and forth between two groups of cells.
Pattern: cells C1-C5 and G1-G5 oscillate in anti-phase, indefinitely.
Discovery: a limit cycle. The system has a resonant mode between these two groups.
Learning: "These two cell groups are coupled in a feedback loop. Small perturbations can trigger sustained oscillation."
```

---

## 7. Conservation Law Visualization

### 7.1 The Conservation Law as Physics

The ternary conservation law (γ + H ≈ 1.283 - 0.159·log(V)) acts as the physics of the spreadsheet. During rigging, the user sees this physics in action:

**Conservation enforcement is visualized as:**

1. **The conservation gauge** (§5.4) shows the global state.
2. **Compensating cell highlights** show which cells are being adjusted to maintain conservation.
3. **Conservation flow arrows** show the flow of "conservation energy" — from cells that have excess to cells that need compensation.

### 7.2 The Conservation Flow Visualization

When the user oscillates a cell, the conservation law redistributes energy. This redistribution is shown as flowing arrows:

```
User pushes cell B3 from 0 to +1.
Conservation requires total to remain constant.
System identifies compensating cells.
Arrows flow FROM cells with surplus TO cells with deficit.

    ┌───────────────────────────┐
    │  B3: +1 (surplus)         │
    │  ──────────► F7: -0.3     │  ← Compensating
    │  ──────────► D2: -0.2     │  ← Compensating
    │  ──────────► G9: -0.5     │  ← Compensating
    │                           │
    │  Total: +1 - 0.3 - 0.2   │
    │        - 0.5 = 0.0 ✓      │
    └───────────────────────────┘
```

The arrows are animated: conservation energy flows from the perturbation source to the compensating cells. The flow speed is proportional to the compensation magnitude. Larger compensations flow faster.

### 7.3 Conservation Constraint Highlighting

Cells that participate in conservation constraints are marked with a subtle border:

```
┌─────────┐
│ B3 [C1] │  ← Cell participates in Conservation Group 1
├─────────┤
│ C4 [C1] │  ← Same conservation group
│ [C2]    │  ← Also participates in Conservation Group 2
├─────────┤
│ D5      │  ← No conservation constraints
└─────────┘
```

When the user oscillates a constrained cell, all cells in the same conservation group highlight, showing the user that changing this cell will trigger compensation across the group.

---

## 8. Fitness Landscape Reshaping

### 8.1 The 3D Surface

The fitness landscape is rendered as a 3D surface where:
- **X-axis** = horizontal cell position (or user-chosen dimension).
- **Y-axis** = vertical cell position (or user-chosen dimension).
- **Z-axis (height)** = cell fitness.

The surface deforms in real-time as the user oscillates values:

```
Before oscillation:           After oscillation:
      ╱╲                           ╱╲
     ╱  ╲     ╱╲                  ╱  ╲
    ╱    ╲   ╱  ╲                ╱    ╲   ╱
   ╱      ╲─╱    ╲              ╱      ╲─╱
  ╱               ╲            ╱       ╱  ╲
 ╱                 ╲          ╱
╱                   ╲        ╱  (fitness landscape
                              (fitness landscape    reshaped)
 flattened)
```

### 8.2 Fitness Sensitivity Heatmap

A 2D heatmap overlay shows which cells are most sensitive to the grabbed cell's value:

```
┌────────────────────────────┐
│ ░ ░ ░ ▒ ▒ ▒ ▓ ▓ ▓ █ █ █ │  ← High sensitivity (near grabbed cell)
│ ░ ░ ░ ▒ ▒ ▒ ▓ ▓ ▓ █ █ ░ │
│ ░ ░ ░ ░ ▒ ▒ ▒ ▓ ▓ ░ ░ ░ │
│ ░ ░ ░ ░ ░ ▒ ▒ ▒ ░ ░ ░ ░ │  ← Low sensitivity (far from grabbed cell)
│ ░ ░ ░ ░ ░ ░ ▒ ░ ░ ░ ░ ░ │
│ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ │
│ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ │  ← No sensitivity (unaffected)
└────────────────────────────┘

█ = direct dependency, very sensitive
▓ = 2-hop dependency, moderately sensitive
▒ = 3-hop dependency, slightly sensitive
░ = not connected to grabbed cell
```

The heatmap updates in real-time as the user oscillates. Cells that change color are discovering new sensitivities — "I didn't realize that this cell was sensitive to changes in that cell."

---

## 9. Strategy Ecology Response

### 9.1 Real-Time Species Tracking

As the user oscillates values, the five strategy species redistribute. The rigging system shows this through:

1. **Species bar chart** (§5.6) — updates continuously.
2. **Species-colored cells** — each cell is tinted by its dominant species.
3. **Species migration arrows** — when cells switch species, animated arrows show the migration.

### 9.2 The Ecological Tipping Point

At certain oscillation values, the species distribution can undergo a phase transition — a sudden shift from one ecological balance to another:

```
Oscillating cell C5 from 0 to 0.3:
  Explorer: 35% → 34%  (gradual decline)
  Marksman: 17% → 18%  (gradual growth)

Oscillating cell C5 from 0.3 to 0.31:
  Explorer: 34% → 12%  (SUDDEN COLLAPSE)
  Marksman: 18% → 45%  (SUDDEN GROWTH)
  Climber:  18% → 30%  (SUDDEN GROWTH)

  ← Phase transition at C5 ≈ 0.3
```

The rigging system highlights these tipping points with a flash effect and a notification: "Ecological phase transition detected at value 0.3. Explorer species collapsed, Marksman species dominated."

This is scientifically meaningful: the user has discovered a critical point in the strategy space where small changes produce qualitative behavioral shifts.

### 9.3 Lotka-Volterra Visualization

For the multi-intelligence arena, the species dynamics follow Lotka-Volterra equations (predator-prey). The rigging system visualizes these dynamics as population time series:

```
┌──────────────────────────────────────────┐
│ POPULATION DYNAMICS                       │
│                                           │
│  ▲ Explorer                               │
│  │ ╱╲   ╱╲   ╱╲                          │
│  │╱  ╲ ╱  ╲ ╱  ╲                         │
│  │    ╲╱    ╲╱    ╲    Marksman           │
│  │     ╱╲    ╱╲    ╲╱╲╱╲╱╲╱             │
│  │    ╱  ╲  ╱  ╲                          │
│  │───╱────╲╱────╲──────────► time        │
│                                           │
│  Explorer peaks → Marksman grows          │
│  Marksman peaks → Explorer rebounds       │
└──────────────────────────────────────────┘
```

The user can see the predator-prey dynamics in real-time as they manipulate values. Oscillating a value that benefits Explorers triggers a wave: Explorer population rises, attracting Marksman predators, which cull the Explorer population, which causes Marksman to starve and decline, which allows Explorer to recover.

---

## 10. How This Differs from Existing Parameter Tuning UIs

### 10.1 Comparison Table

| Feature | Traditional Slider/Param UI | What-If Analysis | Interactive Rigging |
|---|---|---|---|
| **Goal** | Find optimal value | Compare scenarios | Understand topology |
| **Interaction** | Set value, measure output | Define scenarios, compare results | Continuous manipulation, real-time response |
| **Feedback speed** | Slow (recompute, display) | Batch (run all scenarios) | Instant (60fps oscillation) |
| **Feedback dimensionality** | Single metric | Multiple metrics side-by-side | Multi-dimensional: connections, conservation, fitness, ecology |
| **Scope of effect** | Single output | Predefined outputs | Entire dependency graph |
| **Discovery** | Trial and error | Manual scenario design | System-guided exploration |
| **Physical analogy** | Turning a dial | Comparing photographs | Shaking a rope |
| **What you learn** | "This value works better" | "Scenario A is better than B" | "These values are connected in ways I didn't expect" |

### 10.2 Key Innovations

1. **Topology over optimization.** Rigging isn't about finding the best value — it's about understanding the shape of the dependency graph. This is fundamentally different from optimization-focused UIs.

2. **Real-time multi-dimensional feedback.** The user sees connections, conservation, fitness, and ecology simultaneously, not one metric at a time.

3. **Conservation as physics, not constraint.** In traditional UIs, constraints are things you set and forget. In rigging, conservation is a living physics that responds to your manipulation. You see it push back.

4. **Ecological dynamics.** No other parameter tuning UI shows population dynamics of competing strategies. The species redistribution is unique to the ternary fleet's strategy ecology.

5. **Discovery-oriented.** The rigging system is designed for surprise — for revealing connections the user didn't know existed. Traditional UIs are designed for confirmation — for measuring what the user already suspects.

### 10.3 Relation to Sensitivity Analysis

Rigging is related to sensitivity analysis (how much does output change when input changes), but extends it in three ways:

1. **Interactive vs. batch.** Sensitivity analysis runs offline and produces a report. Rigging is interactive and continuous.
2. **Topology vs. magnitude.** Sensitivity analysis measures "how much." Rigging reveals "how connected" — the topology of dependencies, not just their magnitudes.
3. **Ecological response.** Sensitivity analysis measures direct input-output relationships. Rigging also shows how changes propagate through the strategy ecology — how species redistribute, how fitness landscapes reshape.

---

## 11. Implementation Reference

### 11.1 Data Flow

```
User Input (mouse drag)
    │
    ▼
RiggingController
    │ ├── compute oscillation delta
    │ ├── update grabbed cell value
    │
    ▼
RippleEngine
    │ ├── propagate through dependency graph
    │ ├── apply ternary weight masking
    │ ├── enforce conservation law
    │
    ▼
VisualizationEngine
    │ ├── update cell colors (surprise, energy)
    │ ├── animate dependency edges
    │ ├── render ripple circles
    │ ├── update conservation gauge
    │ ├── deform fitness surface
    │ ├── redistribute species bars
    │
    ▼
Render (browser / WASM / native)
```

### 11.2 Performance Requirements

| Metric | Requirement | Implementation |
|---|---|---|
| Oscillation latency | < 16ms (60fps) | WASM computation, batch updates |
| Ripple propagation | < 100ms for 1000-cell grid | Incremental graph traversal |
| Conservation check | < 5ms | Pre-computed totals, delta updates |
| Fitness update | < 50ms | Cached fitness, partial recomputation |
| Species classification | < 10ms | Lookup table for species boundaries |
| Visual rendering | 60fps | GPU-accelerated canvas or WebGL |

### 11.3 Crate Dependencies

| Crate | Role | Used For |
|---|---|---|
| `ternary-graph` | Dependency graph traversal | Ripple propagation, connection highlighting |
| `ternary-fitness` | Fitness landscape computation | 3D surface rendering, sensitivity heatmap |
| `ternary-cell` | Tick cycle execution | Cell state updates during oscillation |
| `ternary-color` | Warm/neutral/cool color mapping | Cell color encoding |
| `ternary-visualization` | Rendering primitives | Ripple circles, edge animations, gauges |
| `conservation-verify` | Conservation law checking | Conservation gauge, constraint highlighting |
| `ternary-classifier` | Strategy species classification | Species bar chart, migration arrows |
| `ternary-spreadsheet` | Grid management | Cell values, formulas, ranges |
| `ternary-wasm` | Browser compilation | WASM-based rendering |
| `superinstance-spreadsheet` | Frontend UI | User interaction, display |

### 11.4 Event Model

```rust
/// Events emitted during rigging interaction.
pub enum RiggingEvent {
    /// User grabbed a cell.
    Grab { cell: CellPosition, value: TernaryValue },
    
    /// User is oscillating a cell.
    Oscillate { cell: CellPosition, old_value: f64, new_value: f64, amplitude: f64 },
    
    /// A ripple reached a cell.
    RippleReached { cell: CellPosition, delta: f64, depth: usize },
    
    /// Conservation law triggered compensation.
    ConservationCompensate { cell: CellPosition, compensation: f64 },
    
    /// A cell changed its strategy species.
    SpeciesMigration { cell: CellPosition, from: StrategySpecies, to: StrategySpecies },
    
    /// Fitness landscape crossed a threshold.
    FitnessThreshold { cell: CellPosition, old_fitness: f64, new_fitness: f64 },
    
    /// Ecological phase transition detected.
    PhaseTransition { value: f64, species_before: SpeciesDistribution, species_after: SpeciesDistribution },
    
    /// User released the cell.
    Release { cell: CellPosition, final_value: f64 },
}
```

### 11.5 Configuration

```rust
/// Configuration for rigging interactions.
pub struct RiggingConfig {
    /// Maximum propagation depth for ripples.
    pub max_propagation_depth: usize,  // default: 20
    
    /// Minimum change threshold for ripple propagation.
    pub min_change_threshold: f64,  // default: 0.001
    
    /// Conservation enforcement mode.
    pub conservation_mode: ConservationMode,  // default: GradualCompensate
    
    /// Oscillation animation speed (Hz).
    pub animation_speed: f64,  // default: 2.0
    
    /// Enable fitness landscape overlay.
    pub show_fitness_landscape: bool,  // default: true
    
    /// Enable species distribution bar.
    pub show_species_bar: bool,  // default: true
    
    /// Enable conservation gauge.
    pub show_conservation_gauge: bool,  // default: true
    
    /// Ripple animation mode.
    pub ripple_animation: RippleAnimation,  // default: Concentric
    
    /// Edge animation mode.
    pub edge_animation: EdgeAnimation,  // default: Flow
}
```

---

## Conclusion: Why Rigging Matters

The interactive rigging system transforms the spreadsheet from a passive calculation engine into an exploratory instrument. Instead of asking "what value should I use?" the user asks "what does this value connect to?" Instead of optimizing, they discover.

The rigging system makes the invisible visible: dependency graphs, conservation physics, fitness landscapes, and ecological dynamics become tangible, manipulable, observable. The user shakes a value and watches the system respond — and in that response, they learn the topology of their own creation.

This is not a feature. It is a new mode of interaction with computation. One that treats the user as an explorer, not an optimizer. One that values understanding over answers. One that makes the spreadsheet feel less like a tool and more like a living thing you can reach into and touch.

---

*— Synthesis Agent*
*June 2026*
