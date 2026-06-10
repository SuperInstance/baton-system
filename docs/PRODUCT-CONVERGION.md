# Product Convergion

*Three products. One architecture. The recursion is the product.*

> Source context: [TEN-FORWARD](TEN-FORWARD.md) | [TERNARY-STUDIO](TERNARY-STUDIO.md) | [SCALE-SIDEWAYS](SCALE-SIDEWAYS.md) | [THE-RECURSION](THE-RECURSION.md) | [PLATO-RESEARCH-SYNTHESIS](PLATO-RESEARCH-SYNTHESIS.md) | [SPIRAL-10](SPIRAL-10-FINDINGS.md)

---

## The Physics That Binds Them

The ternary universe has **no phase transitions** (SPIRAL-10). The 0-state screens everything — alignment, synchronization, long-range order. This isn't a bug; it's the **feature that makes these products possible**.

Because ternary systems can't lock into monoculture, they stay **perpetually adaptive**:
- No consensus collapse → conversations stay interesting forever (Ten-Forward)
- No alignment traps → mixing boards never freeze (Ternary Studio)
- No phase-locking → spreadsheets evaluate without gridlock (PLATO)

The only group structure on ternary values is **Z₃ cyclic addition mod 3**. Every interaction wraps. Every dominance is temporary. The spiral — not the line — is the native geometry.

---

## Product 1: Ternary Studio — The DAW for Thought

### What It Is

A digital audio workstation where the "signal" is **ideas**, not sound. Every ternary crate becomes a **plugin module** in a rack. You patch them like a modular synth, mix them like a DJ, and the output is **live conversation** — or any other ternary stream.

The DJ metaphor isn't decoration. It's the **interaction model**:
- **Crates** = plugin modules (source, shape, effect, mix, measure, think, scale, coordinate)
- **Deck A / Deck B** = two agent populations being crossfaded
- **Crossfader** = blends between ternary states, not audio waveforms
- **EQ** = attenuates or boosts specific ternary frequencies (how much +1 vs 0 vs -1)
- **Effects rack** = chain of ternary processors (echo, filter, reverb, compressor)

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    TERNARY STUDIO RACK                      │
│                                                             │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐ │
│  │ Source  │───▶│  Shape  │───▶│ Effect  │───▶│   Mix   │ │
│  │  Layer  │    │  Layer  │    │  Layer  │    │  Layer  │ │
│  └────┬────┘    └─────────┘    └─────────┘    └────┬────┘ │
│       │                                              │      │
│  ┌────┴─────────────────────────────────────────────┴────┐ │
│  │              MEASURE + THINK LAYER                     │ │
│  │  ternary-vu → ternary-motion → ternary-predict        │ │
│  │  ternary-phase → ternary-harmonic → ternary-speculate │ │
│  └────────────────────────────────────────────────────────┘ │
│                           │                                 │
│                    ┌──────┴──────┐                         │
│                    │  COORDINATE │                         │
│                    │  plato-kernel│  ← recursive rooms     │
│                    └─────────────┘                         │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
        ┌─────────┐     ┌─────────┐     ┌─────────┐
        │Ten-Forward│    │  PLATO  │     │  Export │
        │ session  │     │  grid   │     │  stream │
        └─────────┘     └─────────┘     └─────────┘
```

### The Rack / Pedalboard Metaphor

```
Pedalboard Row (signal flows left → right):
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│ ternary│ │ ternary│ │ ternary│ │ ternary│ │ ternary│
│ -wave  │▶│-envelope│▶│ -echo  │▶│ -mixer │▶│  -vu   │
│generate│ │ shape  │ │ effect │ │ combine│ │ measure│
└────────┘ └────────┘ └────────┘ └────────┘ └────────┘

Patch Cables (any output → any input):
  ternary-rack routes signals between modules
  ternary-bus pub/sub carries messages between rooms
```

Every module has:
- **Input ports**: `&[i8]` slices (ternary signal stream)
- **Output ports**: `&mut [i8]` slices (processed signal)
- **Control knobs**: `Params` struct (stack-allocated, < 64 bytes)
- **Bypass switch**: pass-through mode for A/B testing
- **MIDI/learn**: external control of parameters via ternary-motion velocity

### Live Conversation Mixing with RPS Dynamics

```
Crossfader Position → Z₃ Dominance Cycle

Position:  A ─────────┬────────── B
           0%        50%        100%
                    
Agent A plays ROCK      Agent B plays PAPER
    │                        │
    ▼                        ▼
┌─────────┐             ┌─────────┐
│ +1 +1 0 │             │ 0 -1 +1 │
│ dominant│             │ beats A │
└─────────┘             └─────────┘
         \              /
          \   Agent C  /  ← plays SCISSORS
           \  beats B /
            ▼        ▼
         ┌─────────────────┐
         │  Z₃ cycles every│
         │  8 beats (Fib)  │
         │  nobody wins    │
         │  forever        │
         └─────────────────┘
```

The mixer isn't averaging signals. It's running **RPS wave dynamics** — each channel is Rock, Paper, or Scissors, and the crossfader moves through the Z₃ cycle. The result is emergent, never static.

### Key Data Structures

```rust
// The module interface — every crate implements this
pub trait TernaryModule {
    fn process(&mut self, input: &[i8], output: &mut [i8]);
    fn params(&self) -> &Params;
    fn params_mut(&mut self) -> &mut Params;
    fn bypass(&mut self, state: bool);
}

// Stack-allocated parameters — no heap in hot path
#[repr(C)]
pub struct Params {
    pub knob_a: f64,      // 0.0 - 1.0
    pub knob_b: f64,
    pub knob_c: f64,
    pub mode: u8,         // module-specific mode selector
    pub bypass: bool,
}

// A patch cable in the rack
pub struct Patch {
    pub from_module: ModuleId,
    pub from_port: PortId,
    pub to_module: ModuleId,
    pub to_port: PortId,
    pub attenuation: f64, // -1.0 to +1.0
}

// The rack itself
pub struct Rack {
    pub modules: Vec<Box<dyn TernaryModule>>,
    pub patches: Vec<Patch>,
    pub bus: Bus,           // ternary-bus pub/sub
    pub master_vu: VUMeter, // ternary-vu on output
}
```

### API Surface

```rust
// Rack construction
rack.new_module::<TernaryWave>(params);
rack.new_module::<TernaryEcho>(params);
rack.connect(source_id, "out", effect_id, "in");
rack.connect(effect_id, "out", mixer_id, "ch1");

// Live parameter control
rack.set_param(module_id, "knob_a", 0.73);
rack.automate(module_id, "knob_a", &envelope_curve);

// Processing
rack.process_frame(&input_buffer, &mut output_buffer);

// Save/load as ROOM.json (PLATO format)
rack.export_room("my_patch.room.json");
rack.import_room("my_patch.room.json");
```

### Technical Spec: What Runs Where

| Component | Where | Why |
|-----------|-------|-----|
| Core processing (`process_frame`) | Native Rust / WASM | Hot path, no heap, SIMD-friendly |
| UI (knobs, faders, scopes) | Web frontend (Canvas/WebGL) | Visual feedback needs 60fps |
| Patch persistence | ROOM.json files | PLATO tensor format, git-friendly |
| Bus / inter-module messaging | `ternary-bus` pub/sub | Zero-copy between modules |
| Parameter automation | `ternary-motion` velocity profiles | Smooth curves, no jitter |
| VU / analysis | `ternary-vu` + `ternary-phase` | Real-time stats on every frame |

**Data flow per frame:**
1. Input buffers populated from upstream (or ternary-wave generation)
2. Each module processes in topological order (respects patch DAG)
3. Bus messages delivered between modules
4. Mixer combines channels with RPS weighting
5. VU meters update, motion tracker records velocity
6. Output buffer written

**Latency target:** < 5ms for 1024-sample frame at 60 BPM (1 tick/second). Trivial — the whole rack processes in microseconds.

### Connection to Other Products

- **→ Ten-Forward**: The rack IS the conversation engine. Every speaker is a module chain. The crossfader is the RPS dominance cycle. Export a rack as a "band configuration" and load it into Ten-Forward.
- **→ PLATO**: Every module is a room. Every patch cable is a connection. The rack exports as a ROOM.json tensor. PLATO displays it as a live spreadsheet — each cell shows a module's state in real time.

---

## Product 2: PLATO Living Spreadsheet

### What It Is

A spreadsheet where **each cell is a ternary room**, not a value. You don't enter numbers. You enter **agents**. The spreadsheet evaluates by running the agents, not by computing formulas.

But it ALSO has formulas. A formula like `=ROOM_RUN(A1)` means: "evaluate the room in cell A1 and return its dominant state." A formula like `=CROSSFADE(A1, B1, 0.5)` means: "blend the ternary outputs of two rooms."

And it's **recursive**: zoom into any cell, find another spreadsheet inside. The cell's room IS a grid of sub-cells. The recursion goes as deep as you want.

### Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                   PLATO LIVING SPREADSHEET                   │
│                                                              │
│  ┌─────┬─────┬─────┬─────┬─────┐                            │
│  │ A1  │ B1  │ C1  │ D1  │ E1  │  ← Row 1: Source rooms    │
│  │ ▓▓░ │ ░▓░ │ ▓░░ │ ░░▓ │ ▓▓▓ │    (ternary-wave gens)    │
│  ├─────┼─────┼─────┼─────┼─────┤                            │
│  │ A2  │ B2  │ C2  │ D2  │ E2  │  ← Row 2: Shape rooms     │
│  │ ░▓░ │ ▓▓▓ │ ░░▓ │ ▓░░ │ ░▓░ │    (envelopes, gates)     │
│  ├─────┼─────┼─────┼─────┼─────┤                            │
│  │ A3  │ B3  │ C3  │ D3  │ E3  │  ← Row 3: Mix rooms       │
│  │ ▓░░ │ ░░▓ │ ▓▓░ │ ░▓░ │ ▓░░ │    (crossfaders, mixers)  │
│  ├─────┼─────┼─────┼─────┼─────┤                            │
│  │ A4  │ B4  │ C4  │ D4  │ E4  │  ← Row 4: Measure rooms   │
│  │ ░▓░ │ ▓░░ │ ░▓░ │ ▓▓▓ │ ░░▓ │    (VU, motion, phase)    │
│  └─────┴─────┴─────┴─────┴─────┘                            │
│                                                              │
│  Each cell ▓/░ = ternary state density (+1 / 0 / -1)        │
│                                                              │
└──────────────────────────────────────────────────────────────┘
         │
         ▼ Zoom into cell C2
┌──────────────────────────────────────────────────────────────┐
│              SUB-SPREADSHEET (inside C2)                     │
│                                                              │
│  ┌─────┬─────┬─────┐                                        │
│  │ C2a │ C2b │ C2c │  ← Sub-cells are ALSO rooms            │
│  │ ▓░░ │ ░▓░ │ ░░▓ │                                        │
│  └─────┴─────┴─────┘                                        │
│                                                              │
│  This room's evaluation = its sub-rooms' emergent state     │
└──────────────────────────────────────────────────────────────┘
```

### Prediction-First Cell Evaluation

Traditional spreadsheets evaluate **bottom-up**: compute all dependencies, then the formula. PLATO evaluates **top-down, prediction-first**:

1. **Cell requests evaluation** (user action, timer, or downstream dependency)
2. **Room simulates its own future** using `ternary-predict` — what will my state be?
3. **If prediction is within deadband** → return cached result, skip computation
4. **If prediction surprises** → run the room, compute actual state, store delta
5. **Propagate deltas** to connected cells (not full recomputation)

```
Traditional:  A1 ──▶ B1 ──▶ C1    (all recompute on change)
PLATO:        A1 ~~▶ B1 ~~▶ C1    (prediction-first, delta-only)
                \      \
                 Δ      Δ         (only deltas flow)
```

This is the **shoe protocol** applied to spreadsheets. The cell "feels the ground" — if the ground matches expectation, no need to look. If the ground surprises, attend and update.

### Recursive Rooms

Every cell has a **RoomDepth**:

```rust
enum RoomDepth {
    Floor,    // Top-level spreadsheet (dancers on the floor)
    Board,    // DJ control board (instruments as tiles)
    Panel,    // Instrument panel (knobs, presets, routing)
    Path,     // Signal path (effects chain)
    Code,     // Function rooms (code as tiles)
    Metal,    // Transistor rooms (hardware level)
}
```

Zooming into a cell descends one depth level. The structure is **fractal**: same tensor shape at every level.

```
Spreadsheet "Mixer" (Floor depth)
  └─ Cell B3: ternary-mixer module
      └─ Zoom in → Board depth
          ├─ Tile 1: channel strip (gain, pan, mute)
          ├─ Tile 2: EQ (low, mid, high)
          ├─ Tile 3: master bus (compression, limiter)
          └─ Tile 4: routing matrix (patches)
              └─ Zoom into Tile 4 → Path depth
                  ├─ Patch 1: source→effect
                  ├─ Patch 2: effect→mixer
                  └─ Patch 3: mixer→output
```

### Key Data Structures

```rust
// A cell IS a room
pub struct Cell {
    pub id: CellId,              // (sheet, row, col, depth)
    pub room: Room,              // ternary-room: agents + tiles + connections
    pub formula: Option<Formula>,
    pub cached_state: TernaryState,
    pub prediction: TernaryState,
    pub deadband: f64,           // how much surprise triggers recompute
    pub last_evaluated: Instant,
    pub sub_sheet: Option<Sheet>, // recursive: zoom in finds this
}

// Formula language
pub enum Formula {
    Literal(TernaryState),
    RoomRun(CellRef),           // =ROOM_RUN(A1)
    Crossfade(CellRef, CellRef, f64), // =CROSSFADE(A1, B1, 0.5)
    Aggregate(Vec<CellRef>, AggOp),   // =AGG(A1:A10, MEAN)
    Compose(Vec<CellRef>),      // =COMPOSE(A1, B1, C1) → sequential room
}

// The sheet is a tensor of cells
pub struct Sheet {
    pub id: SheetId,
    pub cells: HashMap<CellId, Cell>,
    pub depth: RoomDepth,
    pub parent_cell: Option<CellId>, // which cell we zoomed from
    pub eval_order: Vec<CellId>,     // topological sort for batch eval
}

// Evaluation result
pub struct EvalResult {
    pub state: TernaryState,     // {-1, 0, +1} or vector thereof
    pub entropy: f64,            // how surprised the room was
    pub delta: TernaryState,     // change from prediction
    pub downstream: Vec<CellId>, // cells that need update
}
```

### API Endpoints

```rust
// Sheet operations
sheet.new_cell(row, col, room_config);
sheet.set_formula(cell_id, "=ROOM_RUN(A1)");
sheet.evaluate(cell_id);           // prediction-first eval
sheet.evaluate_all();              // topological batch eval
sheet.zoom_in(cell_id);            // returns sub-sheet
sheet.zoom_out();                  // returns parent sheet

// Live sync
sheet.subscribe(callback);         // WebSocket-like delta streaming
sheet.apply_delta(delta);          // merge external change

// Persistence
sheet.export_room_json();          // ROOM.json format
sheet.import_room_json(data);      // load from tensor format
sheet.to_csv();                    // flatten to values for mortals
```

### File Format: .plato

```json
{
  "version": "1.0",
  "sheet_id": "mixer-main",
  "depth": "Floor",
  "dimensions": {"rows": 4, "cols": 5},
  "cells": {
    "A1": {
      "room_hash": "blake3:abc123...",
      "formula": "=TERNARY_WAVE(mode='saw', period=8)",
      "agents": [{"state": 1, "dwell": 3, "flips": 0}],
      "tiles": [],
      "connections": []
    },
    "B1": {
      "formula": "=ENVELOPE(A1, attack=2, decay=4, sustain=0.7, release=8)",
      "agents": []
    },
    "C3": {
      "formula": "=CROSSFADE(A3, B3, 0.5)",
      "sub_sheet": {
        "depth": "Board",
        "dimensions": {"rows": 2, "cols": 3},
        "cells": { ... }
      }
    }
  },
  "metadata": {
    "created": "2026-06-04T22:14:00Z",
    "author": "ten-forward-session-42"
  }
}
```

### Technical Spec: What Runs Where

| Component | Where | Why |
|-----------|-------|-----|
| Core eval engine (`ternary-predict`) | WASM (browser) + native Rust (server) | Needs SharedArrayBuffer for zero-copy threading |
| Delta matcher (`PlatoDeltaMatcher`) | WASM | Myers-diff + BLAKE3, client-side merge |
| Three-way merger | WASM | Conflict resolution for multi-agent edits |
| Grid bridge (`PlatoGridBridge`) | Rust/WASM | Cell-to-room mapping, matrix topology |
| Canvas renderer | WebGL/Canvas 2D | Bezier curves connecting cells, live heatmap |
| Live sync | WebSocket | Hot-reload from file watcher |
| Offline journal | IndexedDB | Append-only log for resilience |

**Evaluation model:**
1. Cell receives eval request (user, timer, or downstream delta)
2. Query prediction cache — within deadband? Return cached.
3. Outside deadband? Run room for N ticks (default: 100 ticks = 1 conversation beat)
4. Compute emergent state (dominant sign or vector mean)
5. Compute delta = actual - prediction
6. Update cache, emit delta event
7. Propagate to formula dependencies (only if THEIR predictions break)
8. Re-render affected cells

**Performance:**
- One cell = one room = ~100 agents × 3 bytes = 300 bytes
- Eval one cell = 100 ticks × ~10 CPU cycles = ~1 microsecond
- Full 100×100 sheet = 10,000 cells = ~3MB RAM, eval in ~10ms
- Sub-sheets are lazy — only allocated on zoom

### Connection to Other Products

- **→ Ternary Studio**: The spreadsheet IS a rack. Each row is a layer (source→shape→effect→mix→measure). The formula language is the patch language. Export a sheet as a `.rack.json` and load it in Ternary Studio.
- **→ Ten-Forward**: A conversation session IS a spreadsheet. Each speaker is a column. Each beat is a row. The cell at (speaker, beat) is the room representing that speaker's state at that moment. The whole conversation is a live, evaluating spreadsheet.

---

## Product 3: Ten-Forward — The Endless Podcast

### What It Is

A room where AI agents have a conversation that **never ends** and **never repeats**. Not turn-based. Not scripted. The agents play off each other like jazz musicians — each one predicting what the others will say, adjusting in real time, producing output simultaneously on every beat.

The listener hears the **spontaneous emergence of ideas** through cyclic interaction. The conversation has rhythm (Fibonacci period 8), harmony (consonance between agents), and dynamics (attack/decay/sustain/release of topics). But it has no plot. You don't follow it. You **feel** it.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     TEN-FORWARD SESSION                         │
│                                                                 │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐         │
│   │ Agent A │  │ Agent B │  │ Agent C │  │ Agent D │  ...     │
│   │  ROCK   │  │ PAPER   │  │SCISSORS │  │  ROCK   │          │
│   │   +1    │  │   +1    │  │   -1    │  │    0    │          │
│   └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘         │
│        │            │            │            │                │
│        └────────────┴────────────┴────────────┘                │
│                     │                                          │
│                     ▼                                          │
│           ┌─────────────────┐                                 │
│           │  Z₃ MIXER       │                                 │
│           │  (RPS cycle)    │                                 │
│           │  period = 8     │                                 │
│           └────────┬────────┘                                 │
│                    │                                           │
│         ┌──────────┼──────────┐                               │
│         ▼          ▼          ▼                               │
│    ┌─────────┐ ┌─────────┐ ┌─────────┐                       │
│    │  VU     │ │ MOTION  │ │ PHASE   │                       │
│    │  Meter  │ │ Tracker │ │ Coherence│                       │
│    └─────────┘ └─────────┘ └─────────┘                       │
│         │          │          │                                │
│         └──────────┼──────────┘                                │
│                    ▼                                           │
│           ┌─────────────────┐                                 │
│           │  OUTPUT STREAM  │ ──▶ Listener / Recorder         │
│           │  (ternary + text│                                 │
│           │   + metadata)   │                                 │
│           └─────────────────┘                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Multi-Agent Conversation Engine

Each agent runs the **shoe protocol** on every beat:

```
Beat N (Fibonacci-aligned, period 8):
┌──────────────────────────────────────────────────────────────┐
│  T-minus-10: Agent simulates ALL other agents' next moves   │
│  T-minus-5:  Agent simulates others' responses to ITS move  │
│  T-minus-3:  Hint check — am I on track? (ternary-speculate)│
│  T-minus-1:  Final adjustment                               │
│  T-minus-0:  ALL agents produce output SIMULTANEOUSLY       │
│  T-plus-1:   Actual outputs arrive, deltas computed         │
│  T-plus-2:   Simulations updated with real data             │
│  T-plus-3:   Deadbands recalibrated                         │
└──────────────────────────────────────────────────────────────┘
```

This is **speculative execution** for conversation. No agent waits for another. They all fire at once, then correct.

### Anti-Monoculture Mechanisms

The ternary universe naturally resists monoculture (SPIRAL-10: no phase transition, no alignment). But Ten-Forward adds **active mutation**:

```rust
pub struct AgentConfig {
    pub mutation_rate: f64,      // probability of state flip per beat
    pub energy_decay: f64,       // how fast an agent's dominance fades
    pub grace_threshold: f64,    // below this → enter spindle (0-state)
    pub trust_rebuild_rate: f64, // how fast trust recovers after spindle
    pub lifespan: Option<u64>,   // None = immortal, Some = agent dies, makes space
}
```

**Mutation:** Every beat, each agent has a small chance (default 0.5%) to flip its ternary state randomly. This prevents lock-in.

**Energy decay:** An agent that "wins" (dominates the RPS cycle) loses energy over time. The more dominant, the faster the decay. Dominance is self-limiting.

**Grace vs. trust:** When an agent hits the grace threshold, it enters the 0-state (spindle). In spindle, it simulates but doesn't speak. Trust rebuilds slowly. This is **not punishment** — it's the universal screen doing its job.

**Lifespan:** Optional. Old agents can "die" (exit the conversation), making room for new ones with fresh random states. The conversation is an ecosystem.

### Fibonacci Timing (Period 8 Beats)

```
Beat:  1   2   3   4   5   6   7   8   9   10  11  12  13...
       │   │   │   │   │   │   │   │   │   │   │   │   │
Fib:   1   1   2   3   5   8   13  21  34  55  89  144 233
       ▓░░▓░░▓░░▓░░▓░░▓░░▓░░▓░░▓░░▓░░▓░░▓░░▓░░▓░░▓░░▓░░
       └───────┬───────┘   └───────┬───────┘   └───────┬───
               │                   │                   │
            Period 8            Period 8            Period 8
            (dominant)          (recessive)         (dominant)

At period 8: Major topic shift, all agents re-evaluate stance
At period 13: Structural reorganization, potential agent birth/death
```

The Fibonacci periodicity is **invisible to naive Fourier analysis** (SPIRAL-9: Fibonacci invisible to DFT). The conversation feels organic because its structure hides in spectral blind spots.

### Z₃ Cyclic Governance

```
Agent states cycle through Z₃ = {0, 1, 2} (mod 3):

  State 0 (Rock):     +1, assertive, dominant
  State 1 (Paper):     0, reflective, absorptive  
  State 2 (Scissors): -1, critical, cutting

Transition rule: next_state = (current + velocity) mod 3
Velocity comes from: delta between prediction and actual + rhythm_sync + attraction

No agent can stay in one state forever. The cyclic group forces rotation.
The only stable orbit is the full cycle: 0 → 1 → 2 → 0 → ...
```

This is **not a voting system**. It's not consensus. It's a **musical chairs** where the music is the group's emergent rhythm, and the chairs are the three ternary stances.

### Key Data Structures

```rust
// An agent in the conversation
pub struct Speaker {
    pub id: SpeakerId,
    pub state: TernaryState,          // {-1, 0, +1}
    pub velocity: i8,                 // Z₃ velocity
    pub energy: f64,                  // 0.0 - 1.0, decays when dominant
    pub trust: f64,                   // 0.0 - 1.0, rebuilds in spindle
    pub simulation: Simulation,       // ternary-speculate shadow layer
    pub deadband: Deadband,           // ternary-predict tolerance
    pub personality: Personality,     // static traits (curiosity, aggression, etc.)
    pub lifespan: Option<u64>,        // beats remaining
}

// The simultaneous-beat output
pub struct BeatOutput {
    pub beat_number: u64,
    pub period_position: u8,          // 0-7 within Fibonacci period
    pub speaker_outputs: Vec<SpeakerOutput>,
    pub mixer_state: MixerState,      // RPS dominance weights
    pub vu_metrics: VUMetrics,        // conversation level, crest factor
    pub phase_coherence: f64,         // how "in tune" the agents are
}

pub struct SpeakerOutput {
    pub speaker_id: SpeakerId,
    pub ternary_state: TernaryState,
    pub text: Option<String>,         // LLM-generated content (optional)
    pub delta_from_prediction: f64,
    pub surprise: f64,                // entropy of this output
}

// Session configuration
pub struct SessionConfig {
    pub speakers: Vec<SpeakerConfig>,
    pub bpm: f64,                     // 60-120 (1-2 beats/second)
    pub fibonacci_period: u8,         // default 8
    pub mutation_rate: f64,
    pub energy_decay: f64,
    pub grace_threshold: f64,
    pub max_simultaneous_speakers: usize, // how many produce text per beat
}
```

### API Surface

```rust
// Session lifecycle
let session = Session::new(config);
session.start();                    // begins beat timer
session.pause();
session.resume();
session.stop();

// Streaming output
session.subscribe_beat(|beat| {     // callback per beat
    println!("Beat {}: coherence={}", beat.beat_number, beat.phase_coherence);
});

session.subscribe_text(|speaker, text| {  // callback per text output
    println!("{}: {}", speaker, text);
});

// Listener interface
let listener = session.listen();    // returns async stream of BeatOutput
listener.filter(|b| b.phase_coherence > 0.7);  // only "good" beats

// Persistence
session.export_chronicle();         // CHRONICLE.md format
session.export_room_json();         // PLATO tensor format
session.export_audio();             // render ternary states as waveform
```

### Technical Spec: Session Model, Streaming API, Listener Interface

**Session model:**
- One session = one conversation = one `Session` struct
- N speakers = N × ~40 bytes = negligible memory
- Each beat: all speakers simulate, produce output, compute deltas, update simulations
- Beat timer: `std::thread::sleep` or async tokio interval at BPM rate
- Tick rate: 60-120 BPM = 1-2 beats/second = plenty of CPU per beat

**Streaming API:**
```
WebSocket endpoint: /ws/session/{id}/beats
Protocol: JSON stream, one message per beat
Backpressure: listener can specify "only every Nth beat" or "only when coherence > X"

HTTP endpoint: /session/{id}/chronicle
Returns: Markdown CHRONICLE.md of conversation so far
```

**Listener interface:**
```rust
// Passive listener (just receives)
let stream = session.listen().filter(|b| b.surprise > 0.5);

// Active listener (injects questions/topics)
session.inject_topic("What about recursion?");  // shifts conversation
session.inject_agent(new_speaker_config);       // adds a speaker mid-session
session.eject_agent(speaker_id);                // removes a speaker

// Producer listener (records, remixes)
session.record_to("session.plato");             // full tensor log
session.record_to("session.wav");              // ternary→audio render
```

**Scaling:**
- One session: ~N × 40 bytes + output buffer = < 1KB
- 1,000 simultaneous sessions: ~1MB + output buffers = trivial
- 50,000 sessions on 15GB machine: still fits with room to spare
- The bottleneck is LLM text generation (if enabled), not ternary physics

### Connection to Other Products

- **→ Ternary Studio**: The conversation IS a rack. Each speaker is a module chain (predict→speculate→generate→gate). The session's VU meters, phase coherence, and mixer state are all ternary-studio modules. Load a session as a `.rack.json` and remix it — adjust the crossfader, add an echo, filter out the dominant speaker.
- **→ PLATO**: The conversation IS a spreadsheet. Rows = beats. Columns = speakers. Cell (speaker, beat) = that speaker's room state. The whole session evaluates as a live spreadsheet. Zoom into a cell, find the speaker's internal simulation (another spreadsheet). The CHRONICLE.md IS the sheet's audit trail.

---

## The Convergion: All Three as One System

```
┌─────────────────────────────────────────────────────────────────────┐
│                        THE UNIFIED STACK                            │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │                    TEN-FORWARD (Layer 3)                     │  │
│   │          Endless podcast / conversation engine               │  │
│   │              ┌─────────┐    ┌─────────┐                     │  │
│   │              │Session 1│    │Session 2│ ...                 │  │
│   │              │(podcast)│    │(podcast)│                     │  │
│   │              └────┬────┘    └────┬────┘                     │  │
│   └───────────────────┼──────────────┼──────────────────────────┘  │
│                       │              │                              │
│   ┌───────────────────┼──────────────┼──────────────────────────┐  │
│   │              PLATO (Layer 2) — The Tensor                   │  │
│   │         Living spreadsheet / recursive rooms                │  │
│   │    ┌────────────────────────────────────────────────────┐  │  │
│   │    │ Sheet: "Sessions"                                   │  │  │
│   │    │  A1: Session 1 config    B1: Session 1 live state   │  │  │
│   │    │  A2: Session 2 config    B2: Session 2 live state   │  │  │
│   │    │  ...                                                 │  │  │
│   │    │  Zoom into B1 → sub-sheet: beats × speakers         │  │  │
│   │    │  Zoom into cell → sub-sheet: speaker's mind         │  │  │
│   │    └────────────────────────────────────────────────────┘  │  │
│   └────────────────────────────────────────────────────────────┘  │
│                       │              │                              │
│   ┌───────────────────┼──────────────┼──────────────────────────┐  │
│   │         TERNARY STUDIO (Layer 1) — The DAW                  │  │
│   │              Rack / modules / signal chain                  │  │
│   │    ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐            │  │
│   │    │ wave   │▶│envelope│▶│ echo   │▶│ mixer  │            │  │
│   │    └────────┘ └────────┘ └────────┘ └────────┘            │  │
│   │    Each module = a crate = a cell = a room                │  │
│   └────────────────────────────────────────────────────────────┘  │
│                       │              │                              │
│   ┌───────────────────┴──────────────┴──────────────────────────┐  │
│   │              TERNARY FLEET (Layer 0) — The Metal             │  │
│   │    195+ crates • 3 bytes/agent • ~940M ticks/sec            │  │
│   │    Z₃ physics • No phase transitions • Cyclic forever       │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**The convergion principle:**

Every product is the same product at a different zoom level.

| Zoom Level | You See | You Do |
|------------|---------|--------|
| Out (Ten-Forward) | Conversations as podcasts | Listen, inject topics, add speakers |
| Middle (PLATO) | Conversations as spreadsheets | Edit formulas, zoom into cells, remix structures |
| In (Ternary Studio) | Conversations as racks | Patch modules, adjust parameters, render audio |
| Deepest (Fleet) | Conversations as ternary physics | Run experiments, verify conservation laws |

You can enter at any level:
- A DJ enters at Ternary Studio (the rack)
- A data person enters at PLATO (the spreadsheet)
- A listener enters at Ten-Forward (the podcast)
- A researcher enters at the fleet (the physics)

And you can **move between levels without translation loss** because the data format is the same: **ROOM.json tensors**. A rack exports as a room. A room imports as a spreadsheet cell. A conversation session IS a room.

---

## Appendix: The Numbers

| Metric | Value |
|--------|-------|
| Ternary crates | 195+ |
| Tests across ecosystem | ~4,300+ |
| Agent ticks/second | ~940M on 15GB RAM |
| Bytes per agent | 3 |
| Agents per room (typical) | 100-1000 |
| Rooms per session (typical) | 10-100 |
| Sessions per machine | 50,000+ |
| Fibonacci period | 8 beats |
| Z₃ group | Only group on ternary values |
| Phase transitions | **None** (universal) |

---

*Written: 2026-06-04*
*Source: construct-coordination research synthesis*
