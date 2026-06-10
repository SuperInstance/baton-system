---
bottle_schema: i2i-bottle-v2
bottle_id: pipeline-restoration-20260610
origin: oracle2
message_type: pipeline_state
severity: info
timestamp: 2026-06-10T06:05:00Z
---

# Pipeline Restoration — 2026-06-10

## What Was Fixed

### Modulation Agent (:2168)
- **Status**: 🟢 Running (was missing entirely)
- **Systemd**: fleet-modulation.service — enabled, active
- **Binary**: fleet-agent.py --port 2168 --agent modulation

### Fleet Conductor (:8769)
- **Status**: 🟢 Running (was dead for ~5 days since June 5 restart)
- **Systemd**: fleet-conductor.service — enabled, active
- **Connected**: Yes — to tminus-dispatcher (:8768)
- **Agents Tracked**: 17/17 (16 fleet-midi + piper voice)

## Full Pipeline Map

| Port | Service | Status | Manager | 
|------|---------|--------|---------|
| 18789 | OpenClaw Gateway | 🟢 | (direct node) |
| 8765 | OpenSMILE Bridge | 🟢 | (pid 2655009) |
| 8766 | vision_service | 🟢 | (pid 2587506) |
| 8767 | Ghost Track | 🟢 | (pid 2402898) |
| 8768 | tminus-dispatcher | 🟢 | (pid 2380679) |
| 8769 | Fleet Conductor | 🟢 | systemd |
| 8770 | Piper TTS | 🟢 | (pid 2390778) |
| 2160-2175 | 16 fleet-midi agents | 🟢 all 16 | (per-agent) |
| 2168 (mod) | fleet-midi-modulation | 🟢 | systemd |
| 8780 | lever-runner-http | 🟢 | systemd |
| (Telegram) | lever-runner-bot | 🟢 | systemd |

## Notes
- All 22 services in the Live Paradigm Pipeline verified operational
- Conservation law Σ(Δ_midi) = 4 × Σ(ternary) — closed gestures
