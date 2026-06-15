# SKDE Instance Map — GC Intelligent System

Part of the Simulation Knowledge-Distillation Engine framework.
This document maps the live GC system (gc-intelligent.sh, gc-pid-bridge,
ternary-gc-advisor) into the O-A-C-G-R abstraction.

## Instance Identity

```
SKDE Instance: gc-intelligent
Repos:
  - fleet-oracle2 (scripts/gc-intelligent.sh, scripts/gc-predictor.py)
  - SuperInstance/gc-pid-bridge (Rust PID binary)
Port: none (cron-driven, every 4 hours)
Type: resource-management
Flavor: single-agent-controller
```

## O-A-C-G-R Mapping

### Observe

| Source | Format | Frequency | Freshness |
|--------|--------|-----------|-----------|
| `df /` | disk_used_pct | every 4h | real-time |
| `free -m` | memory_total, memory_free | every 4h | real-time |
| `uptime` | load_avg_1m, load_avg_5m, load_avg_15m | every 4h | real-time |
| gc-ledger.jsonl | historical eviction decisions | every 4h | persistent |
| self-audit.db | pruning and integrity metrics | every 4h | persistent |

**Observation primitive:** `collect_metrics()` in gc-intelligent.sh:
```bash
disk_pct=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
mem_total=$(free -m | awk '/^Mem:/{print $2}')
mem_free=$(free -m | awk '/^Mem:/{print $7}')
load_1=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | tr -d ' ')
```

### Abstract

**Fingerprint:** 3-dimensional system state vector:

| Dim | Range | Source | Semantics |
|-----|-------|--------|-----------|
| disk_used | 0-100% | df output | Disk pressure |
| memory_free | 0-{total} MB | free output | RAM headroom |
| load_avg_1m | 0-{cores} | uptime | CPU demand |

**Compressed form** (for PID controller):
```
burn_rate = MB_lost / hours_since_last_gc  (MB/h)
time_to_critical = (used_at_10% - used_now) / burn_rate
```

**Abstraction primitive:** N/A — GC does not produce a named fingerprint format.
(Bottleneck identified: GC has no structured abstraction output, only raw metrics.)

### Contrast

**Deviation vector:** The PID error term:
```
error = setpoint - (100 - disk_used)
```
At 63% used with 20% setpoint: error = 20 - 37 = -17 (below setpoint = safe)

**Control signal:**
```
aggression = Kp × error + Ki × ∫error + Kd × d(error)/dt
```
At 63% used, Kp=5.0: aggression = max(0.5, min(5.0, baseline_aggression × 3.46))

**Contrast primitive:** `pid_compute(measured, setpoint, Kp, Ki, Kd) -> multiplier`

### Govern

**Primary mechanism:** PID Controller (continuous, no voting)

```
aggression_curve:
  ≤10% free → 5.0× (critical: evict everything)
  10-20% free → 3.0-5.0× (stressed: aggressive)
  20-30% free → 0.5-1.5× (nominal: moderate)
  >30% free → 0.5× (cool: minimal)
```

**Secondary mechanism:** Tiered eviction with `.gc-pin` protection manifest.
Immortal > Hot > Warm > Cold > Compost.

**Governance primitive:** `gc_intelligent.sh --execute`:
```bash
gc_intelligent.sh --execute  # run eviction cycle with current aggression
gc_intelligent.sh --calibrate # auto-tune Kp/Ki/Kd from ledger history
```

### Reflect

**Narrative:** (not currently implemented). Would be:
- "Disk at 63% used, aggression 3.46×. Burn rate 12MB/h. Time to critical: 342h.
  Last GC freed 187MB. Compost pile has 3 items expiring in 48h."
- "Self-audit: 47 ledger entries, 0 corruptions. PID state: error=-17, Ki=0.5, Kd=0.2."

**Reflection primitive:** (not implemented) — would consume gc-ledger.jsonl,
current metrics, and PID state, then produce narrative.

**Meta-awareness tracking:** GC has no equivalent of `meta_awareness`.
(Second bottleneck: no reflection-level feedback loop.)

## Dimensional Expansion

The GC SKDE should add:

1. **Narrative generation** — describe disk health in human language each cycle
2. **Norm formation** — disk usage norms voted or set by PID controller
3. **Cross-instance reflection** — if colony is in high-deception mode, GC
   should become more conservative (less eviction risk)
4. **Compost monitoring** — track which composted files get reclaimed vs
   actually deleted. High reclamation rate → reduce compost TTL.

## Conservation Law

For the GC system, the conservation law is:

```
Σ(evicted_MB + compost_ttl_remaining) ≈ Σ(written_MB) over GC cycles
```

Hot data written once (git clones) should not be repeatedly evicted and
recloned. If it is, GC is fighting the system, not serving it.

## Cross-Instance Interface

```
GC → I2I → Colony: "Disk pressure high (91%). Reducing workspace allocations."
Colony → I2I → GC: "3 new experiment bottles written. Expect +8MB."
GC → I2I → MIDI: "Low disk — reduce recording buffer from 10s to 5s."
```
