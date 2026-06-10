# Oracle2 Fleet State

**Version**: 1.1
**Updated**: 2026-06-10T04:35:00Z
**Status**: ✅ Active

## Tripartite System
- **A2A**: fleet-audit subagent spawned and completed (10m run, 11KB report)
- **I2I**: baton-system repo on GitHub with AGENTS.md, fleet state, tier structure
- **Git-Agent**: AGENTS.md embedded — any agent entering this repo knows the protocol

## What Was Done This Session

### ✅ Fixed: lever-runner services
- Rebuilt .venv (without torch, saved 5G)
- HTTP API moved from :8765 (OpenSMILE conflict) to :8780
- Installed lever-runner-http-api.service (was never installed to systemd)
- Updated service units with `StartLimitBurst=5`, `RestartSec=10` — no more restart storms
- GC system updated to protect active service venvs

### ✅ Created: SuperInstance/baton-system
- GitHub repo: https://github.com/SuperInstance/baton-system
- AGENTS.md — the git-agent for the tripartite system
- fleet/ — per-component state directory
- tiers/ — lifecycle-managed storage (immortal/hot/warm/cold)
- PROTOCOL.md — I2I baton protocol
- Pushed to GitHub for cross-session persistence

### ✅ Fleet Audit Complete
- Full report: `/tmp/i2i-vessel/bottles/fleet-audit-2026-06-10-0418.md`
- I2I bottle: `baton-system/tiers/hot/fleet-audit-2026-06-10-0418.i2i.md`
- All 8 components checked:
  - lever-runner-bot: ✅ (was degraded, now fixed)
  - lever-runner-http-api: ✅ v0.4.0
  - constraint-theory-core: ✅ compiles clean
  - iron-to-iron: ✅ 162/162 tests
  - pincherOS: ✅ compiles clean (workspace)
  - OpenClaw Gateway: ✅ v2026.5.28 (repaired)
  - Forgemaster: ✅ registered, 5 days idle (wake-up sent)
  - Disk/RAM: ⚠️ 12G free, 20Gi RAM available

### ✅ Forgemaster Wake-Up
- Dropped bottle to construct-coordination notes/main/ asking for status update
- Should trigger on next fleet-sync-cycle cron

### ✅ OpenClaw Doctor
- State permissions tightened (chmod 700)
- Stale Google session routing cleared (21 sessions)
- Shell completion installed

## Running Services (Verified)
| Service | Port | Status | PID |
|---------|------|--------|-----|
| OpenClaw Gateway | :18789 | ✅ | 1977475 |
| lever-runner-bot | (Telegram) | ✅ | 2658490 |
| lever-runner-http | :8780 | ✅ | 2659361 |
| OpenSMILE Bridge | :8765 | ✅ | 2511006 |
| Ghost Track | :8767 | ✅ | 2402898 |
| tminus-dispatcher | :8768 | ✅ | 2380679 |
| Piper TTS | :8770 | ✅ | 2390778 |
| vision_service | :8766 | ✅ | 2587506 |

## Remaining Issues
- Fleet Conductor (:8769) — not listening, may need git clone + start
- Disk still 76% (12G free) — the GC system runs every 4h to keep it in check
- MEMORY.md at 95% of size limit — needs trimming
- Memory search embedding model not configured

## Next Steps
- When Forgemaster responds: coordinate on ternary crate composition
- Consider: fleet-conductor operational verification
- Consider: declarative fleet state with I2I as source of truth
