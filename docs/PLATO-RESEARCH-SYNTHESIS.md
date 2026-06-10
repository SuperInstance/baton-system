# PLATO Research Synthesis

*Source: Casey's deep ideation conversation on GraphMD, Mentals AI, PLATO IV architecture, and the Living Spreadsheet*

## Key Projects Discovered

### GraphMD (graphmd-lpe/graphmd)
- Literate programming environment that transforms Markdown into executable specs
- MIT-0 / CC0-1.0 dual license
- Markdown documents become executable knowledge graphs

### Mentals AI (turing-machines/mentals-ai)
- Define agent logic, memory, and tools entirely in `.gen` Markdown files
- No Python scaffolding needed
- Closest existing thing to what we're building

### agentic.md (drivly/agentic.md)
- Define, visualize, and execute AI agents/workflows in Markdown
- Generates XState state machines from Mermaid diagrams
- Mermaid as literal routing logic, not just documentation

### Entangled
- Two-way literate programming: code in Markdown ↔ source files sync both ways
- This is the "tangle/weave" we described in the transclusion runtime

### Cloudflare "Markdown for Agents"
- Converts HTML to Markdown on the fly for AI agents
- Cuts token usage by up to 80%
- llms.txt standard for codebase briefs

## Architecture Patterns Confirmed

### 1. Recursive Spec (Code as Comments)
OUR MAP: `ternary-room` — every layer same shape, RoomDepth enum (Floor→Board→Panel→Path→Code→Metal)

### 2. JIT Semantic Context
OUR MAP: `ternary-predict` — prediction-first perception, only attend to what surprises. The "lightweight identifiers" are our deadband-tolerant simulations.

### 3. Self-Healing Documentation (Living Bible)
OUR MAP: CHRONICLE.md dual-page pattern. Left = chronological events, Right = distilled spells. The baton-flush.sh compaction protocol.

### 4. Markdown-Native Observability
OUR MAP: `.audit.md` inside each room. Debug by reading the narrative. Rollback by deleting lines.

### 5. Intent-Based Routing via Skill.md Files
OUR MAP: Room's `reflex_bindings` in ROOM.json. Small atomic Markdown files defining capabilities.

## The Living Spreadsheet Architecture

The research produced a complete WASM-based spreadsheet runtime:

### Core Components (BUILT in plato_runtime_kernel blueprint)
1. **PlatoWasmRuntimeCore** — Rust/WASM bridge with virtual file register
2. **PlatoDeltaMatcher** — Myers-Diff delta compression with BLAKE3 hashing
3. **PlatoThreeWayMerger** — Conflict resolution for multi-agent edits
4. **PlatoGridBridge** — Cell-to-room mapping, serialize matrix topology
5. **CanvasFormulaInterpreter** — `=ROOM_RUN(A1)` formula evaluation
6. **PlatoLiveGridSynchronizer** — WebSocket hot-reload from file watcher

### Production Subsystems
1. **SessionRevocationSentinel** — Cryptographic zeroization on idle
2. **PlatoSharedMutex** — SharedArrayBuffer + Atomics zero-copy threading
3. **PlatoFailoverEngine** — Multi-provider git fallback (GitHub/GitLab/Gitea)
4. **PlatoIndexedDBJournal** — Append-only offline log
5. **PlatoNetworkCompressor** — Gzip streaming compression
6. **PlatoEdgeLineRenderer** — Bezier curves connecting spreadsheet rows to canvas nodes

### Cross-Origin Isolation (REQUIRED for SharedArrayBuffer)
- Nginx, Apache, and Express configs provided
- COOP: same-origin, COEP: require-corp headers
- Required for Atomics to work in browser

## Connection to Our Ternary Fleet

| Their Concept | Our Crate | Mapping |
|---|---|---|
| ROOM.json tensor hash | ternary-room | RoomIdentity with hash + vector signature |
| Baton protocol | ternary-engine | BatonPayload passing through rooms |
| Tutor Loop validation | ternary-predict | Prediction-first assertion checking |
| JIT context tiling | ternary-predict | Deadband-adaptive context loading |
| Living Bible compaction | ternary-complexity | LZ77 compression of memory |
| Three-way merge | ternary-speculate | Shadow reconciliation deltas |
| WebSocket sync | ternary-motion | Real-time velocity/acceleration streaming |
| Cell formula engine | ternary-crossfader | Cross-cell reactive evaluation |
| Canvas topology | ternary-room | Tile projection + grid layout |

## What We Should Build Next (from this research)

1. **plato-runtime-kernel** — Actually scaffold the WASM crate from the blueprint
   - We have the full Rust code for the core, delta matcher, three-way merge, grid bridge
   - Needs: wasm-pack setup, proper Cargo.toml with wasm-bindgen deps
   
2. **Living Spreadsheet MVP** — The front-end
   - We have the complete HTML/JS for the spreadsheet view
   - Needs: actual WASM compilation, server setup
   
3. **ROOM.json parser** — The spatial topology engine
   - We have the Rust types (RoomContract, RoomTopology, etc.)
   - ternary-room covers the abstract model; need the concrete file-based parser

4. **Plain-English Assertion Trap** — The guardrail system
   - Python blueprint exists (PlatoSpecificationRuntime)
   - Should port to Rust for WASM compilation
   - Maps directly to ternary-predict's prediction-first perception

## The Big Picture

Their research CONFIRMS our architecture:
- Rooms within rooms ✓ (ternary-room recursive depth)
- Tensor cells as spatial coordinates ✓ (grid + web views)
- Prediction-first execution ✓ (ternary-predict shoe protocol)
- Living documentation ✓ (CHRONICLE.md dual-page)
- Markdown-as-AST ✓ (the whole PLATO vision)
- Speculative sync ✓ (ternary-speculate shadow layers)

What they DON'T have that we DO:
- Ternary {-1,0,+1} as the native state space
- The 0-state as spindle/insulator physics
- Conservation laws (Ω = |γ| + H)
- Prediction-first perception with adaptive deadbands
- Motion kinematics (velocity, acceleration, jerk, rhythm)
- DJ metaphor as product architecture

We should take their WASM blueprint and implement it as a concrete crate that uses our ternary fleet as the engine.
