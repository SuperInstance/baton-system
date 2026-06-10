---
bottle_schema: i2i-bottle-v2
bottle_id: checkpoint-20260610
origin: oracle2
message_type: CHECKPOINT
severity: critical
timestamp: 2026-06-10T06:50:00Z
ttl_days: 365
---

# 🦀 Oracle2 Fleet Checkpoint — 2026-06-10

This is the definitive fleet state. Any agent entering this session should read this first.

## Tripartite System Live
| Leg | Status | Location |
|-----|--------|----------|
| **A2A** | ✅ 4 subagents today | Fleet audit, constraint fix, Forgemaster wake, CI repair |
| **I2I** | ✅ Online | github.com/SuperInstance/baton-system |
| **Git-Agent** | ✅ Embedded | baton-system/AGENTS.md |

## All Services — Verified Operational

### Production Services
| Service | Port | Manager | Status |
|---------|------|---------|--------|
| OpenClaw Gateway | :18789 | node | ✅ |
| lever-runner-bot | Telegram | systemd | ✅ |
| lever-runner-http-api | :8780 | systemd | ✅ (was :8765, moved) |

### Live Paradigm Pipeline (22 services)
| Port | Service | Manager | Status |
|------|---------|---------|--------|
| 8765 | OpenSMILE Bridge | pid | ✅ |
| 8766 | vision_service | pid | ✅ |
| 8767 | Ghost Track | pid | ✅ |
| 8768 | tminus-dispatcher | pid | ✅ |
| 8769 | Fleet Conductor | **systemd** | ✅ (was dead, restored) |
| 8770 | Piper TTS | pid | ✅ |
| 2160-2175 | 16 fleet-midi agents | fleet-agent.py | ✅ **all 16** (modulation was missing, restored) |
| — | Conductor tracks | — | 17/17 agents online |

### Edge Infrastructure
| Service | URL | Status |
|---------|-----|--------|
| Nebula Worker | fleet-murmur-worker.casey-digennaro.workers.dev | ✅ 24 reflexes |

## What Was Fixed Today
1. **lever-runner**: GC'd .venv rebuilt (no torch — saved 5G), port conflict resolved, systemd hardening
2. **Modulation agent :2168**: Was completely missing → fleet-modulation.service created
3. **Fleet conductor :8769**: Dead for ~5 days → fleet-conductor.service created, connected to tminus-dispatcher
4. **Boot persistence**: fleet-pipeline.target groups all services, enabled at boot
5. **GC protection**: Active service .venvs no longer evicted
6. **MEMORY.md**: Trimmed to 11k chars (was at 95% limit)
7. **constraint-theory-core**: 7 compiler warnings fixed
8. **pincher CI**: workflow_dispatch added (tests still failing — dep API breakages)

## Active Work (in progress)
- **pincher CI repair**: DeepSeek subagent fixing wasmtime/cranelift/ort API deprecations
- **Ternary compose audit**: Kimi Code analyzing 189 crates for dependency chain verification
- **Forgemaster wake**: Dual bottles sent to construct-coordination, awaiting response

## To Investigate Next Session
- Fleet Conductor's HTTP POST/dispatch endpoint payload format (needs alignment with tminus-dispatcher)
- Fork the 189 ternary crates into a workspace to verify composition
- OpenClaw OAuth for Codespaces (device code ADB0-3AAD)
- Nebula worker has 0 requests — needs a client
