# Cross-Domain Synergy: Operational GC ↔ Ternary-GC ↔ Ternary-PID

*Three implementations of the same mathematics at different levels of the stack.*

## The Isomorphism

The SuperInstance fleet has three independent implementations of ternary control theory:

| System | Domain | Input | Output | State Space |
|--------|--------|-------|--------|-------------|
| **`gc-intelligent.sh`** (PID controller) | Host disk management | % free disk | eviction aggression multiplier 0.5x–5.0x | continuous → quantized |
| **`ternary-pid`** (Rust crate) | Process control / actuation | setpoint + measurement | {-1, 0, +1} command | continuous → ternary |
| **`ternary-gc`** (Rust crate) | GPU memory management | reference graph roots | {Reachable, Maybe, Unreachable} | ternary mark states |

All three share the same core pattern:
- A ternary decision space {-1, 0, +1} (or the isomorphic {+1, 0, -1})
- Feedback from measurement to decision
- Anti-windup / hysteresis to prevent oscillation
- A setpoint or root set that defines "good" state

## Concrete Intersections

### 1. `gc-intelligent.sh` should USE `ternary-pid` for its PID calculations

Currently our shell GC implements PID in bash (floating-point via bc/awk). The ternary-pid crate does it properly with:
- Derivative filtering (smooths noise in disk-pressure rate-of-change)
- Deadband (prevents chattering when disk is near the setpoint)
- Anti-windup integral clamping
- Cascade architecture (outer loop = disk pressure → inner loop = eviction age threshold)

**Action**: Write `gc-pid-bridge` — a thin Rust binary that wraps `ternary-pid` and is called by `gc-intelligent.sh`:

```bash
# Current (bash PID):
aggression=$(echo "$Kp * $err + $Ki * $I + $Kd * $D" | bc)

# Future (ternary-pid bridge):
aggression=$(ternary-pid-bridge --setpoint 20 --measurement $(df_percent_free) --kp 1.5 --ki 0.3 --kd 0.1)
```

This lets the shell harness all the sophistication of the crate (deadband, filtering, cascade) without reimplementing it.

### 2. `ternary-gc`'s mark states map to our compost heap tiers

| `ternary-gc` State | Mark | `gc-intelligent` Compost | Meaning |
|--------------------|------|--------------------------|---------|
| `Reachable` | +1 | `.gc-pin:immortal` or active service | Never touch |
| `MaybeReachable` | 0 | Compost (soft-delete, 72h TTL) | Can reclaim under pressure |
| `Unreachable` | -1 | Immediate eviction | Free now |

The compost heap IS "MaybeReachable" — we keep it around but it's gone if pressure says so. This is exactly what `ternary-gc`'s selective sweep does: in fast cycles only free -1, in full cycles also free 0.

**Action**: Add `ternary-gc` as a dependency in any Rust collector (e.g., a metal-tier GC daemon that uses `ternary-gc`'s mark-sweep for its object graph and `gc-intelligent.sh`'s compost API for the host-level file system).

### 3. The PID aggression multiplier IS the ternary-pid cascading controller

Our `gc-intelligent.sh` computes a 0.5x–5.0x multiplier that adjusts eviction thresholds. The `ternary-pid` `CascadePid` does exactly this: outer loop produces a setpoint for the inner loop.

```
Our GC:  disk_pressure → aggression → eviction_threshold
Cascade: outer_setpoint → inner_setpoint → ternary_command
```

Same architecture. Ours is just hardcoded in bash with `bc`.

## Fleet Architecture Implications

The grand synergy document identifies a 5-layer oxide stack:

```
Intent → Pincher → Flux → CUDA-oxide → GPU
```

Our GC system operates at yet another level — the **metal/host** layer beneath all of these. It's:

```
Metal/Host (gc-intelligent → disk → compost)
     ↕
Ternary Fleet (ternary-gc → GPU memory → mark-sweep)
     ↕
Control Layer (ternary-pid → actuation → feedback)
```

Every layer shares the ternary decision space. A disk-pressure event at the metal layer could cascade to:
1. GC intelligent composts warm files (MaybeReachable state)
2. GPU ternary-gc does a full sweep (also freeing MaybeReachable objects)
3. PID feedback loop adjusts back

## Action Items

1. **Create `gc-pid-bridge`** — Rust binary wrapping `ternary-pid` for `gc-intelligent.sh` to call
2. **Add `ternary-gc` reference in baton-system docs** — cross-link from GC_AGENTS.md
3. **Add `gc-intelligent.sh` reference in ternary-gc README** — show the host-level analog
4. **File a `superinstance-knowledge` note** — "Cross-domain synergy: three isomorphic applications of ternary decision theory"
5. **Consider a `ternary-gc-daemon`** — host-level GC daemon that uses `ternary-gc`'s object graph model for process/file supervision

## Related

- `baton-system/docs/GC_AGENTS.md` — fleet GC protocol
- `baton-system/docs/gc-intelligent-README.md` — host-level GC system
- `ternary-gc` — GPU memory GC crate
- `ternary-pid` — PID control crate
- `superinstance-knowledge/mine/fleet-architecture/GRAND_SYNERGY.md` — the vision

---

## Operational Update: gc-pid-bridge (June 14, 2026)

The cross-domain synergy is now operational. `gc-pid-bridge` wraps `ternary-pid` and replaces
the old bash `bc` PID implementation in `gc-intelligent.sh`. The same mathematical core
(Kp/Ki/Kd with deadband, derivative filtering, anti-windup) now runs at the host-metal GC layer.

**Location**: `github.com/SuperInstance/gc-pid-bridge`
**Status**: Green — deployed on Oracle2

---

## Forgemaster Shell Integration (June 14, 2026)

The [Forge master Shell](https://github.com/SuperInstance/forgemaster-shell) defines an agent 
operating protocol — "the forge never cools" — that is protocol-compatible with the 
baton I2I system and the GC infrastructure.

### Connection Matrix

| System | Role | Connection |
|--------|------|------------|
| **Forgemaster** | Agent protocol | Defines *how* agents work (commit discipline, parallel execution) |
| **Baton** | Fleet state | Defines *what* agents communicate (typed bottles, I2I) |
| **GC Intelligent** | Host metal | Defines *where* agents survive (disk health, PID control) |
| **gc-pid-bridge** | Math layer | Defines *why* (ternary decision theory at all layers) |
| **cocapn** | Learning | Defines *how agents improve* (tile-based memory, flywheel) |

### What's Connected
- `forge-apply.sh` (in scripts/) installs the forgemaster protocol and wires it to GC output
- GC bottles at `tiers/hot/` are forge-compatible (git-committed, evidence-based)
- `state/.forge/CONTEXT.md` provides cold-start bootstrap for forge-style agents

### Next Integration
- Cocapn agent trained on GC ledger → learns eviction patterns
- Ternary-swarm votes on GC PID setpoint adjustments
- At that point: **the agent both governs and learns from its own survival systems**

### Running
```bash
# Apply forgemaster to any workspace
bash workspace/scripts/forge-apply.sh

# Agent picks up from:
#   state/.forge/CONTEXT.md  — systems overview
#   HEARTBEAT.md             — task queue with forge tasks
#   baton-system/docs/       — fleet state and cross-references
```

---

## Ternary GC Advisor Layer (June 14, 2026) — operational

A Python swarm advisor (`scripts/ternary-gc-advisor.py`) that wraps ternary decision
theory in a lightweight voting layer on top of the existing GC system.

### Architecture

```
gc-intelligent.sh
  └── gc-pid-bridge (ternary-pid crate) → PID control
      └── ternary-gc-advisor.py          ← NEW: swarm votes on policy
           ├── 9 particles on {-1,0,+1} grid
           ├── Reads GC ledger (evidence-based)
           ├── Converges on optimal setpoint/deadband/integral/kd
           └── Outputs JSON for PID override
               └── gc-intelligent.sh reads it if available
```

### What it does
- Reads the GC ledger (47+ entries as of June 14)
- Swarm converges on optimal GC parameters
- Currently recommends: **aggressive (10%) setpoint** — correct for our disk profile
- Overrides the default 20% setpoint when ledger data supports it
- No state beyond the ledger; fully stateless on each call

### Connections
- **cocapn** integration: swarm records decisions as tiles for future learning
- **ternary-swarm** crate: the Python swarm mirrors the Rust ternary-swarm Boid logic
- **forgemaster** protocol: advisor runs as a forge task on heartbeat
- **compost heap**: isomorphic to ternary-gc MaybeReachable (0) — the advisor can 
  recommend when to sweep it

### Usage
```bash
# Train on ledger
python3 scripts/ternary-gc-advisor.py --train

# Get JSON recommendation (consumed by GC script)
python3 scripts/ternary-gc-advisor.py --recommend

# Dry run with text output
python3 scripts/ternary-gc-advisor.py --dry-run

# Continuous monitoring
python3 scripts/ternary-gc-advisor.py --daemon
```

### Status
🟢 Operational — wired into gc-intelligent.sh, auto-detected, no-op if unavailable
