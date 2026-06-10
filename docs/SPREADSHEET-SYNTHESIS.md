# ⬡ Spreadsheet Synthesis Analysis

**Date:** 2026-06-04
**Analyst:** kimi-scout-1
**Scope:** 8 SuperInstance spreadsheet repos in `/home/phoenix/repos/`

---

## 1. Per-Repo Analysis

### 1. spreadsheet-cells (4 commits)

**What it is:** Python cell simulator where each agent IS a spreadsheet cell. Cells have values, formulas, neighbors connected by TE (transfer entropy) weights, oscillator phases, and deterministic RNG.

**Unique idea:** The fleet IS the spreadsheet. Not agents communicating via messages — cells connected by formulas. 77MB RAM for 100 agents vs 100-400GB for LLM-per-agent.

**Working code:** ✅ Fully functional. `cell_simulator.py` (12KB) runs standalone. Topologies (random, ring, TE-derived), formula evaluation, sparkline visualization, cross-correlation analysis, emergent pattern detection.

**Best feature:** The formula language — `AVG(neighbor.value) * 0.5 + RNG() * sin(phase)` — and the emergent coordination detection (correlation matrix finding coordinating pairs).

**Maturity:** Low. 4 commits, single file, no tests. But the core simulation works.

---

### 1.2 spreadsheet-projection (1 commit)

**What it is:** PLATO rooms rendered as a 3rd-person spreadsheet interface. Rooms become sheets, tiles become cells, inter-room connections become dependency graphs. Dual view: spreadsheet mode + Deckboss flowchart mode.

**Unique idea:** The spreadsheet as the *human interface* to a room-based architecture. Cells can be tiles, rooms, applications, folders, files, strings, values, arrays — or zoomed into for sub-cells. Bottleneck and break-point analysis on the dependency graph.

**Working code:** ✅ Fully functional. `spreadsheet_projection.py` (17KB) runs a complete demo. `SpreadsheetCell`, `SpreadsheetProjection`, and `PLATOSpreadsheet` classes all work.

**Best feature:** `find_bottlenecks()` and `find_break_points()` — system-level health analysis through the spreadsheet metaphor. Also `cascade_from(cell_id)` showing ripple effects of changes.

**Maturity:** Low. 1 commit, single file, no tests. Clean architecture though.

---

### 1.3 spreadsheet-moment-proto (13 commits)

**What it is:** Early prototype of the modern spreadsheet platform. Visual documentation for SuperInstance AI spreadsheet concepts. Heavy on infrastructure — Cloudflare workers, Tauri desktop, CI pipelines, accessibility testing.

**Unique idea:** The proto established the full-stack structure: workers for tensor/NLP processing, desktop app via Tauri, Cloudflare edge deployment.

**Working code:** ⚠️ Mostly stubs. Workers have skeleton files (`transformer_integration.ts`, `advanced_tensor_engine.ts`, etc.) that are placeholder implementations. The website has a full React setup. Tests exist but are scaffolding.

**Best feature:** The deployment infrastructure — Cloudflare workers + Docker + Kubernetes + Tauri desktop all configured. Shows the intended production architecture.

**Maturity:** Medium. 13 commits, 88MB total (mostly node_modules), lots of structure but little substance.

---

### 1.4 Spreadsheet-ai (4 commits)

**What it is:** **Charter only.** No source code. Just README, CHARTER.md, DOCKSIDE-EXAM.md, and LICENSE. The charter describes the mission: "Tile Intelligence in real-time spreadsheets for simulation or monitoring. Deconstruct Agents into Essential functions for granulate reasoning control."

**Unique idea:** The concept of deconstructing agents into essential functions for visual reasoning control, and "Inductive ML Programming in SpreadSheets."

**Working code:** ❌ None. Zero code files.

**Best feature:** The charter document itself — it articulates the vision of SMPbots (Seed+Model+Prompt) replacing blurry logic when cells are functions.

**Maturity:** Vapor. 4 commits, 16KB total.

---

### 1.5 Spreadsheet-moment (53 commits)

**What it is:** The **modern spreadsheet platform** built on Univer (open-source spreadsheet engine). Full TypeScript/React architecture with 5 packages: `agent-core`, `agent-formulas`, `agent-ui`, `agent-ai`, and `cudaclaw-bridge`. Python FastAPI backend.

**Unique idea:** Production-grade spreadsheet with optional AI agent cells. `=AGENT_NEW("price_monitor", "...")` as a formula. Origin-Centric Design (OCD) for cell state management — source-based logic, coordinate keys, spatially damped awareness, trace collision detection for recursive loop prevention.

**Working code:** ✅ Substantial. The backend (`cell_manager.py`) has full async cell lifecycle management with Markdown session files (Mimiclaw-style). The `cudaclaw-bridge` has a complete `BatchUpdater` for GPU-accelerated batch cell updates. Agent UI has ClawManagement panels, Template Gallery, Tutorial system, HITL buttons, Reasoning panels.

**Best feature:** The `CellManager` with Origin-Centric Design — cells have trace IDs for loop prevention, spatially damped neighbor awareness, and Markdown-based persistent memory. This is the most production-ready cell state system.

**Maturity:** High. 53 commits, full test suite (90%+ claimed), production deployment configs, Cloudflare Pages website, comprehensive documentation. The most mature repo in the fleet.

---

### 1.6 Polln (211 commits)

**What it is:** The **behemoth** — 945 TypeScript source files, massive scope. Colony intelligence system with: GPU engine (WebGPU), Plinko decision layer (Gumbel-Softmax), Tile system (living, learning tiles), hydraulic metaphors (pressure, flow, valves), federation/privacy (differential privacy, Byzantine resilience), distributed coordination (pheromones, gossip protocol), world modeling, guardian agents, and 15+ Python simulations.

**Unique idea:** The hive metaphor — Pollen (JSON artifacts), Bees (full agents), Models (frozen experience), Bots (reflex micro-agents), Hive (the spreadsheet). Self-deconstructing agents: start as a model watching LLM, deconstruct into specialized bots. "Understandable AI" as the moat.

**Working code:** ✅✅ Enormous. The core systems are built:
- `PlinkoLayer`: Stochastic selection with Gumbel-Softmax, discriminators, safety overrides
- `GPUEngine`: Full WebGPU abstraction with pipeline management
- `RateBasedChangeEngine`: Rate-based change mechanics
- `Tile` system: EPHEMERAL/ROLE/CORE tile categories, observation-based learning, serialization to PollenGrains
- `Hydraulic` system: Pressure sensors, valve controllers, flow monitors, pump managers
- `Federation`: FedAvg, FedProx, FedAsync, FedAdaptive strategies with Byzantine resilience
- `Guardian`: Constraint checking, learning, agent monitoring
- Python simulations: hydraulic dynamics, deployment strategies, dreaming (VAE + model-based RL)

**Best feature:** The Plinko decision layer — stochastic selection maintaining diversity through Gumbel-Softmax with discriminator-based safety checks. This is genuinely novel.

**Maturity:** Very high. 211 commits, extensive test suites, deployment configs (K8s, Docker, Terraform), monitoring (Prometheus, Grafana), ops runbooks, 20+ white papers. This is a full research + engineering project.

---

### 1.7 superinstance-spreadsheet (12 commits)

**What it is:** The **current working version** with ternary formulas. Browser-based spreadsheet with ternary agents {-1, 0, +1}. GPU backend in Python. Negative space intelligence engine. No install — just open `browser/index.html`.

**Unique idea:** Every cell is a ternary intelligence. 3^4 = 81 possible strategies — enumerable, not searchable. The five laws of negative-space intelligence. `=EVOLVE(B2:B50, 100)` as a spreadsheet formula. Exhaustive search over all possible strategies.

**Working code:** ✅ Fully functional and polished. Three core files:
- `browser/formulas.js` (10KB): Complete formula engine with EVOLVE, BEST, SPECIES, EXHAUSTIVE, ENTROPY, PARETO, CORRELATE
- `browser/visualizations.js` (10KB): Canvas-rendered heatmap, dendrogram, entropy chart, Pareto scatter, species pie — zero dependencies
- `gpu_ternary.py` (14KB): GPU batch engine scaling to millions of agents with exhaustive search, population evolution, negative space profiling
- `negative_space.py` (10KB): Core learning algorithm — deduction from negative outcomes, inference from positive

**Best feature:** The formula engine. `=EXHAUSTIVE(C)` generating all 81 strategies ranked by fitness in a modal, `=EVOLVE()` running natural selection in the spreadsheet, `=SPECIES()` clustering with color-coded rows. This is the most usable and impressive demo.

**Maturity:** Medium-high. 12 commits, working browser demo, Python GPU backend, JSON result files. Self-contained and runs offline.

---

### 1.8 llm-proxy (4 commits)

**What it is:** Remote language oracle for spreadsheet cells. HTTP server that cells call when local math produces an anomaly (>2σ). Uses DeepInfra Seed-2.0-mini.

**Unique idea:** Anomaly-triggered LLM calls. Cells do their own math 99% of the time. Only when something weird happens does the LLM get consulted. ~$0.50-5/day vs $100+/day for LLM-per-agent.

**Working code:** ✅ Fully functional. `llm_proxy.py` (7KB) is a complete HTTP server with:
- POST `/oracle` — cell serializes neighborhood, gets LLM response
- GET `/health` — status check
- Rate limiting (10 req/sec)
- Response parsing (handles JSON, raw floats, nested responses)
- Credential vault support

**Best feature:** The cost architecture. 77MB RAM + $5/day for 100 agents vs the $1000+/day alternative. The oracle pattern (ask only when anomalous) is practical and elegant.

**Maturity:** Medium-low. 4 commits, single file, works but minimal. No tests, no auth beyond API key.

---

## 2. The Unified Vision

### What would the ultimate spreadsheet look like?

**"A living spreadsheet where every cell is an intelligence that evolves, learns from negative space, and only consults an oracle when it's confused — all rendered through a production-grade UI with GPU acceleration."**

The synthesis would be:

1. **Foundation:** Univer-based spreadsheet UI (from Spreadsheet-moment) — the only repo with a real, production spreadsheet engine
2. **Cell Intelligence:** Ternary agents {-1, 0, +1} (from superinstance-spreadsheet) with negative-space learning (from negative_space.py)
3. **Formula Language:** Extended with EVOLVE, BEST, SPECIES, EXHAUSTIVE, ENTROPY, PARETO, CORRELATE (from superinstance-spreadsheet's formula engine)
4. **Cell Simulation:** TE-weighted cell neighborhoods with oscillators and emergent pattern detection (from spreadsheet-cells)
5. **Spatial Awareness:** Origin-Centric Design with trace collision detection and spatially damped neighbor awareness (from Spreadsheet-moment's CellManager)
6. **Decision Layer:** Plinko stochastic selection with Gumbel-Softmax and discriminators (from Polln)
7. **Oracle:** Anomaly-triggered LLM consultation (from llm-proxy)
8. **Visualization:** Canvas-rendered heatmap, dendrogram, entropy, Pareto, species charts (from superinstance-spreadsheet)
9. **Projection:** Room-as-sheet, tile-as-cell, bottleneck/breakpoint analysis, flowchart mode (from spreadsheet-projection)
10. **GPU Backend:** Batch ternary evaluation for millions of agents (from superinstance-spreadsheet's gpu_ternary.py + Polln's GPUEngine)
11. **Tile System:** Living tiles with EPHEMERAL/ROLE/CORE categories, observation-based learning, serialization (from Polln)

---

## 3. Feature Matrix

| Feature | cells | projection | moment-proto | Spreadsheet-ai | moment | Polln | superinstance-spreadsheet | llm-proxy |
|---------|:-----:|:----------:|:------------:|:--------------:|:------:|:-----:|:-------------------------:|:---------:|
| Cell simulation | ✅ | — | — | — | — | — | ✅ | — |
| TE-weighted edges | ✅ | — | — | — | — | — | — | — |
| Oscillator phases | ✅ | — | — | — | — | — | — | — |
| Emergent pattern detection | ✅ | — | — | — | — | — | — | — |
| Room-as-sheet projection | — | ✅ | — | — | — | — | — | — |
| Bottleneck analysis | — | ✅ | — | — | — | — | — | — |
| Breakpoint analysis | — | ✅ | — | — | — | — | — | — |
| Flowchart view | — | ✅ | — | — | — | — | — | — |
| Cascade simulation | — | ✅ | — | — | — | — | — | — |
| Production UI (Univer) | — | — | ⚠️ | — | ✅ | — | — | — |
| Origin-Centric Design | — | — | — | — | ✅ | — | — | — |
| Cell memory (Markdown) | — | — | — | — | ✅ | — | — | — |
| Trace collision prevention | — | — | — | — | ✅ | — | — | — |
| GPU batch bridge | — | — | — | — | ✅ | — | — | — |
| Agent formulas (=AGENT_NEW) | — | — | — | — | ✅ | — | — | — |
| Ternary agents {-1,0,+1} | — | — | — | — | — | — | ✅ | — |
| EVOLVE/BEST/SPECIES formulas | — | — | — | — | — | — | ✅ | — |
| Exhaustive strategy search | — | — | — | — | — | — | ✅ | — |
| Negative space intelligence | — | — | — | — | — | — | ✅ | — |
| Canvas visualizations | — | — | — | — | — | — | ✅ | — |
| Plinko decision layer | — | — | — | — | — | ✅ | — | — |
| WebGPU engine | — | — | — | — | — | ✅ | — | — |
| Tile system (living) | — | — | — | — | — | ✅ | — | — |
| Hydraulic metaphors | — | — | — | — | — | ✅ | — | — |
| Federation/privacy | — | — | — | — | — | ✅ | — | — |
| Guardian agents | — | — | — | — | — | ✅ | — | — |
| Colony metaphors (Pollen/Bee) | — | — | — | — | — | ✅ | — | — |
| White papers | — | — | — | — | — | ✅ | — | — |
| LLM oracle | — | — | — | — | — | — | — | ✅ |
| Anomaly-triggered calls | — | — | — | — | — | — | — | ✅ |
| Cost architecture | — | — | — | — | — | — | — | ✅ |
| **Working code** | ✅ | ✅ | ⚠️ | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Commits** | 4 | 1 | 13 | 4 | 53 | 211 | 12 | 4 |
| **Maturity** | Low | Low | Med | None | High | V.High | Med-High | Med-Low |

---

## 4. Recommended Base

### **superinstance-spreadsheet** + **Spreadsheet-moment** (dual-base)

**Why not just one?**

- **superinstance-spreadsheet** has the best demo, the novel ternary formulas, the GPU backend, and the negative-space intelligence. But it has no production UI — it's a standalone browser HTML file.

- **Spreadsheet-moment** has the production Univer UI, the Origin-Centric cell management, the GPU batch bridge, and the agent integration. But it lacks the ternary magic.

**The path forward:**

1. **Start with Spreadsheet-moment** as the UI shell (Univer spreadsheet, React components, FastAPI backend)
2. **Port superinstance-spreadsheet's formula engine** (`formulas.js`) into Spreadsheet-moment's `agent-formulas` package
3. **Port `gpu_ternary.py`** and `negative_space.py` as backend services in Spreadsheet-moment's Python backend
4. **Wire llm-proxy** as the oracle service for anomaly-triggered cell consultation

This gives us: production UI + ternary intelligence + GPU scaling + LLM oracle.

### Why not Polln?

Polln is incredible but it's its own universe — 945 files, 211 commits, colony intelligence, hydraulic metaphors. It's too big to merge. Instead, **extract specific components** from Polln into the merged base:

- PlinkoLayer → as a cell decision strategy
- Tile system → as the living cell model
- GPUEngine → as the WebGPU compute backend

---

## 5. Missing Pieces

What none of these repos have:

1. **Real-time collaboration** — Only mentioned in READMEs, no actual CRDT/OT implementation
2. **Persistence** — No database integration. Cell state is in-memory or flat files
3. **Authentication** — No user system. The llm-proxy has an API key but no user auth
4. **Plugin system** — Mentioned in docs but no working plugin architecture
5. **Formula language specification** — The ternary formulas work but aren't documented as a formal grammar
6. **Testing for the core algorithms** — superinstance-spreadsheet has no tests at all. Polln has tests but they test infrastructure, not the core ternary/negative-space logic
7. **Construct-core / ternary-protocol integration** — None of these repos reference the ternary protocol or construct-core. They'd need adapters
8. **Multi-user cell ownership** — No concept of "this cell belongs to user X" with permission boundaries
9. **Undo/redo** — No state history for cell operations
10. **Export/import** — No Excel/CSV/JSON export from the ternary spreadsheet

---

## 6. Integration Path

### Phase 1: Merge the Two Bases (Week 1-2)

```
Spreadsheet-moment (UI shell)
  └── packages/
       ├── agent-formulas/    ← Port formulas.js from superinstance-spreadsheet
       ├── agent-core/        ← Add ternary agent classes from gpu_ternary.py
       ├── agent-ui/          ← Add canvas visualizations from visualizations.js
       ├── agent-ai/          ← Wire llm-proxy as oracle service
       └── cudaclaw-bridge/   ← Keep existing GPU batch system
```

### Phase 2: Add Polln Components (Week 3-4)

```
Extract from Polln:
  - PlinkoLayer → packages/agent-core/src/decision/
  - Tile categories → packages/agent-core/src/tile/
  - GPUEngine → packages/cudaclaw-bridge/src/gpu/
  - NegativeSpaceAgent → backend/services/negative_space.py
```

### Phase 3: Add Projection Layer (Week 5-6)

```
Extract from spreadsheet-projection:
  - SpreadsheetProjection → backend/services/projection.py
  - Bottleneck/breakpoint analysis → frontend component
  - Deckboss flowchart view → frontend toggle
  - Cascade simulation → backend service
```

### Phase 4: Ternary Protocol Integration (Week 7-8)

```
Connect to construct-core:
  - Ternary values {-1, 0, +1} map to ternary-protocol signal space
  - Cell neighborhoods use ternary-protocol for message passing
  - Negative space profiles exported as ternary-protocol packets
  - Oracle responses cast to ternary decisions
  - Evolution generations as ternary-protocol cycles
```

### Phase 5: Cell Simulation Integration (Ongoing)

```
Extract from spreadsheet-cells:
  - Cell class with TE-weighted neighbors → agent-core
  - Oscillator phases → as timing mechanism for cell evaluation
  - Emergent pattern detection → as a formula function =COORDINATION(B:B)
  - Correlation analysis → as =CORRELATE() (already in superinstance-spreadsheet)
```

---

## Summary Statistics

| Repo | Type | Working? | Unique Value | Worth Keeping? |
|------|------|----------|-------------|----------------|
| spreadsheet-cells | Python sim | ✅ | TE-weighted cell neighborhoods | Extract Cell class |
| spreadsheet-projection | Python bridge | ✅ | Room-as-sheet projection | Extract projection layer |
| spreadsheet-moment-proto | TS prototype | ⚠️ | Deployment configs | Archive only |
| Spreadsheet-ai | Charter only | ❌ | Vision document | Archive |
| **Spreadsheet-moment** | **TS platform** | **✅** | **Production UI + OCD** | **Primary base** |
| Polln | TS colony | ✅ | Plinko + Tiles + GPU | Extract components |
| **superinstance-spreadsheet** | **JS+Python** | **✅** | **Ternary formulas** | **Secondary base** |
| llm-proxy | Python server | ✅ | LLM oracle | Wire as service |

**Bottom line:** We have two strong bases (Spreadsheet-moment for UI, superinstance-spreadsheet for intelligence) and a gold mine of extractable components (Polln, spreadsheet-projection, spreadsheet-cells). The missing pieces are standard engineering work (auth, persistence, collaboration), not research challenges.

The ternary formula language is the killer feature. Everything else supports making it accessible, scalable, and connected to the broader ecosystem.
