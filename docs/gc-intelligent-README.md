# Self-Aware Garbage Collection System

> "A garbage collector that cannot examine its own past mistakes is doomed to repeat them."

A learning, self-regulating GC system for the SuperInstance fleet. Runs on Oracle2, coordinates across all repos via the baton-system I2I protocol.

## System Architecture

```
┌──────────────────────────────────────────────────────────┐
│  gc-intelligent.sh       ← Shell orchestrator           │
│  ├── PID Controller     ← Adjusts aggression by disk    │
│  ├── Discern Engine     ← Finds patterns in past GCs    │
│  ├── Eviction Engine    ← Tiered cleanup with compost   │
│  ├── Self Audit          ← Prunes its own ledger/logs   │
│  └── Fleet Sync          ← Writes bottles to fleet hub  │
│                                                          │
│  gc-predictor.py         ← Python deep analytics        │
│  ├── JSONL reader       ← Ledger parsing + trends       │
│  ├── Burn rate calc     ← Predicts time to critical     │
│  └── Pattern DB update  ← Top eviction categories       │
│                                                          │
│  data/gc-ledger/         ← Persistent state             │
│  ├── ledger.jsonl       ← Every decision, timestamped   │
│  ├── trend.json         ← Burn rate history + pred      │
│  ├── patterns.json      ← Top eviction categories       │
│  ├── pid-state.json     ← PID controller state          │
│  └── calibration.json   ← Auto-tuning results           │
│                                                          │
│  data/gc-compost/        ← Soft-delete heap             │
│  └── <file>__<epoch>    ← TTL-expiring safe-deletes     │
│                                                          │
│  .gc-pin                 ← Protection manifest          │
│                                                          │
│  baton-system/                                           │
│  └── tiers/hot/                                          │
│      └── gc-intelligence-bottle.md ← Fleet broadcast    │
│                                                          │
│  baton-system/docs/                                      │
│  └── GC_AGENTS.md       ← Canonical fleet GC spec       │
└──────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# Dry-run (safe)
./scripts/gc-intelligent.sh --status

# Normal GC cycle — cold artifacts, idle .venv, logs
./scripts/gc-intelligent.sh --execute

# Deep GC — also clears package caches, journals
./scripts/gc-intelligent.sh --deep

# Audit — analyze past GC patterns and predictions
./scripts/gc-intelligent.sh --audit

# Calibrate — auto-tune PID controller from historical data
./scripts/gc-intelligent.sh --calibrate

# Register a path as protected
./scripts/gc-intelligent.sh --register /path/to/thing:immortal
```

## How It Learns

### 1. PID Controller
A Proportional-Integral-Derivative controller adjusts eviction aggression based on disk pressure.

- **Setpoint**: 20% free disk (configurable)
- **Error**: deviation from setpoint
- **Output**: 0.5x–5.0x aggression multiplier
  - At 10% free → ~5.0x (panics, targets everything)
  - At 20% free → ~1.0x (balanced, normal thresholds)
  - At 40% free → ~0.5x (conservative, only ancient artifacts)

Aggression affects: eviction age thresholds, cache clearing, journal vacuum size.

### 2. Pattern Analysis
Every GC cycle reads the JSONL ledger via `gc-predictor.py`:

- **Burn rate**: MB reclaimed per hour → predicts hours until disk hits 10%
- **Trend detection**: is available space growing, stable, or shrinking?
- **Top categories**: what fills up most (cargo caches? venvs? build artifacts?)
- **Pattern DB**: stored in `patterns.json` for fleet-wide visibility

### 3. Self-Audit
The GC audits itself:
- Validates all data stores (pattern DB, trend DB, PID state) for JSON integrity
- Prunes own ledger at 50K lines, self-log at 5K lines
- Resets corrupt state automatically
- Flags critical disk via `.gc-alert` sentinel file

## Tier System

| Tier | Eviction Policy | Examples |
|------|----------------|----------|
| **Immortal** | Never touched | `memory/*`, `baton-system`, `.git`, `secrets/` |
| **Hot** | Protect active .venv if systemd service running | `pincher`, `lever-runner` |
| **Warm** | Git pack compaction only | Legacy repos |
| **Cold** | Full eviction eligibility | Build artifacts, idle venvs, caches |
| **Compost** | Soft-delete with 72h TTL | Recently evicted artifacts |

### Pinning
Customize via `.gc-pin` file:
```yaml
/path/to/project:immortal    # never GC anything here
my-special-repo:hot          # protect active services
```

## Fleet Integration

The GC system integrates with the [baton-system](https://github.com/SuperInstance/baton-system) I2I protocol:

1. Every GC cycle writes a **bottle** to `baton-system/tiers/hot/gc-intelligence-bottle.md`
2. Bottle contains: disk state, PID aggression, patterns found, reclaimed space
3. The bottle is committed to the baton-system repo for fleet-wide visibility
4. The canonical fleet GC spec lives at `baton-system/docs/GC_AGENTS.md`
5. Any fleet agent roaming the SuperInstance org reads `GC_AGENTS.md` and adopts compatible GC behavior

## Per-Repo `.gcconfig` (planned)

Each fleet repo can declare GC intentions:
```json
{
  "tier": "hot",
  "protect_artifacts": ["build/", "target/"],
  "protect_venv": true,
  "max_age_hours": 168,
  "git_gc": true
}
```

Standard location: `<repo-root>/docs/GC_CONFIG.md` or `.gcconfig`

## File Reference

| File | Purpose |
|------|---------|
| `scripts/gc-intelligent.sh` | Main orchestrator (shell) |
| `scripts/gc-predictor.py` | Analytics engine (Python) |
| `data/gc-ledger/ledger.jsonl` | Every GC decision timestamped |
| `data/gc-ledger/trend.json` | Burn rate history + predictions |
| `data/gc-ledger/patterns.json` | Top eviction categories |
| `data/gc-ledger/pid-state.json` | PID controller coefficients |
| `data/gc-compost/` | Soft-delete heap with TTL |
| `.gc-pin` | Per-path protection manifest |
| `baton-system/docs/GC_AGENTS.md` | Fleet-wide GC specification |
| `scripts/gc-system.sh` | Original GC script (deprecated, kept for fallback) |

## Cron Schedule

| Job | Schedule | Mode |
|-----|----------|------|
| `gc-intelligent` | Every 4h | `--execute` |
| (future) daily deep | Every 24h | `--deep` |

## Future Directions

- **Meta-GC agent**: spawns as a subagent that analyzes ledger trends weekly and adjusts PID constants, thresholds, and compost TTLs automatically
- **Fleet `.gcconfig` rollout**: each repo gets a config file declaring GC tier, protected paths, and venv strategy
- **Lossy compression**: for cold files that are too valuable to delete but not worth full size, gzip archive to `archive/` dir
- **Cross-host GC**: if Forgemaster or other fleet nodes come online, propagate GC intelligence across hosts via baton-system
- **Causal analysis**: "the workspace filled up because pincher CI ran 12 builds. Should we clean target/ now?"
