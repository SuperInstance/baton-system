# SKDE Instance Map — Colony Psychology Lab

Part of the Simulation Knowledge-Distillation Engine framework.
This document maps the live colony games server (port 8823) into the
O-A-C-G-R abstraction, showing how each component maps to the general pattern.

## Instance Identity

```
SKDE Instance: colony-psychology-lab
Repos:
  - construct-coordination (notes/experiments/)
  - construct/colony/ (colony-games.py, colony-mirror-norms.py)
Port: 8823
Type: behavioral-simulation
Flavor: multi-agent-social
```

## O-A-C-G-R Mapping

### Observe

| Source | Format | Frequency | Freshness |
|--------|--------|-----------|-----------|
| game-reputation-ledger.json | JSON reputations dict | on request | real-time |
| game-pd-results.json | JSON PD history array | on request | real-time |
| game-deception-ledger.json | JSON claims/verifications | on request | real-time |
| game-diplomacy-ledger.json | JSON pacts/trust scores | on request | real-time |
| game-darwin-ledger.json | JSON generations/fitness | on request | real-time |
| game-gift-ledger.json | JSON gift transactions | on request | real-time |
| game-auction-ledger.json | JSON bid history | on request | real-time |
| game-norms-ledger.json | JSON norm lifecycle | on request | real-time |

**Observation primitive:** `_read_ledger(name)` — reads JSON from filesystem,
returns dict. Fresh colony = empty dict (no crash).

### Abstract

**Fingerprint:** 8-dimensional behavioral vector per cell:

| Dim | Range | Source | Semantics |
|-----|-------|--------|-----------|
| deception_score | 0-100 | deception ledger score + PD betray rate | How much this cell deceives |
| betrayal_score | 0-100 | PD betray rate + diplomacy betrayals | How often this cell reneges |
| trust_score | 0-100 | diplomacy reputation (inverted betrayal) | How colony rates trustworthiness |
| generosity | int | total XP gifted | Material contribution to colony |
| cooperate_rate | 0.0-1.0 | PD cooperate ratio | Likelihood of cooperation |
| risk_tolerance | 0.0-1.0 | auction bid amount / max | Comfort with uncertainty |
| meta_awareness | bool | narrative generated flag | Has this cell reflected? |
| norm_compliance_rate | 0.0-1.0 | adherence/(adherence+violations) | Follows colony rules? |

**Compression method:** Weighted combination of ledger values with domain-
specific heuristics. `deception_score` uses direct ledger score if available,
else infers from betrayal + auction behavior.

**Abstraction primitive:** `PersonalityMirror.compute_fingerprint(cell_id) -> dict`

### Contrast

**Deviation vector:** z-score for each numeric dimension:

```
dev[dim] = (cell_val - colony_mean) / max(0.001, colony_std)
```

**Colony averages:** computed across all cells (lazy, on query).

**Deviation detection:** outlier threshold at |z| > 2.0.
- harvester: deception z=+3.74 (outlier)
- culled-crier-scavenger: cooperate_rate z=-2.47 (outlier)

**Contrast primitive:** `PersonalityMirror.deviation_vector(cell_id) -> dict`

### Govern

**Three norm mechanisms** (all three implemented):

| Mechanism | Colony Equivalent | Activation | Penalty |
|-----------|-------------------|------------|---------|
| **Voted** | NormFormation.vote() | majority >50% | trust score penalty |
| **Scripted** | Darwin Arena fitness | mutation pressure | extinction |
| **Economic** | Fitness Engine reputation | XP transfer | reputation capital loss |

**Norm lifecycle:**
```
propose → [vote cycle] → active → [enforce cycle] → sunset
                      ↘ rejected
```

**Governance primitive:** `NormFormation.{propose,vote,enforce,evaluate}(...) -> dict`

### Reflect

**Narrative:** First-person behavioral self-description.
Generated from deviation vector + fingerprint values.

**Coherence score:** 0.0-1.0 heuristic matching narrative keywords to actual data.

**Meta-awareness tracking:** cells that have reflected once gain `meta_awareness=True`,
which improves future coherence scores.

**Reflection primitive:** `PersonalityMirror.generate_narrative(cell_id) -> str`

## Dimensional Expansion Plan

The colony currently uses 8 dimensions. As we add more games, dimensions expand:

| New Game | New Dimensions | Current Status |
|----------|---------------|----------------|
| Mafia (night/day cycle) | **kill_rate**, **doc_protect_rate**, **detective_accuracy** | module written, HTTP not wired |
| Emotional States (from MIDI crossing) | **mood_index**, **entropy_preference** | not started |
| Resource Trading | **hoard_rate**, **share_ratio**, **debt_burden** | not started |

## Conservation Law

For the colony, the conservation law is **behavioral inertia** (not energy):

```
Σ(Δ_behavior) ≈ 0 over sufficient cycles
```

A cell's fingerprint should change minimally between reflections unless
a norm enforcement or major event disrupts it. If we observe Δ_behavior
consistently > 0.5σ between reflections, the colony is in a regime change.

Current law: **anormative** — norms are only 2 proposals, zero enforced.
Once norms activate, we can measure norm-induced behavioral drift.

## Git-Native State

The colony SKDE instance replicates its state through git:

```
construct-coordination/
  notes/oracle2/experiments/
    colony-psychology-2026-06-15.md
    darwin-arena-100-gen-2026-06-15.md
    social-deduction-2026-06-15.md
    mirror-first-reflection-2026-06-15.md
```

Each experiment is a **bottle** — snapshot of system state + reasoning at a
point in time. Bottles are not normalized; they're narrative-first with
attached data. This is intentional: the narrative is the interface.

## Cloudflare Edge Deployment (Blocked)

When deployed to Cloudflare via fleet-kit:

```
colony-edge-agent.ts — Durable Object per cell (colony identity)
colony-pulse-worker.ts — cron bridge feeding fingerprint data to fleet-pulse
fleet-harbor — receives norm enforcement events
```

Current blocker: wrangler auth on Oracle2 (X-Auth-Key incompatibility).
Bridge bottle sent to Forgemaster via construct-coordination.

## Future: Cross-Instance Communication

The colony SKDE should eventually talk to other SKDE instances:

```
colony (behavioral) ↔ MIDI (musical) ↔ GC (system) ↔ spreadsheet (tensor)
```

Cross-instance norms: "If the colony is in high-deception regime, reduce
musical complexity (MIDI) to match." This is governance across the fleet.

This requires the I2I protocol to carry SKDE-structured messages (not just
arbitrary JSON). Spec: baton-system/docs/I2I-SKDE-EXTENSION.md (not yet written).
