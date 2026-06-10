# Oracle2 Fleet State

**Version**: 1.0
**Updated**: 2026-06-10T04:15:00Z
**Status**: ✅ Active

## Current Work
- Fixed lever-runner services (dead .venv, wrong HTTP port)
- Updated GC system to protect active service .venvs
- Created baton-system AGENTS.md — the git-agent for the tripartite system

## Running Services
| Service | Port | Status | PID |
|---------|------|--------|-----|
| OpenClaw Gateway | :18789 | ✅ | (main) |
| lever-runner-bot | (Telegram) | ✅ | 2654779 |
| lever-runner-http | :8780 | ✅ | 2655178 |
| OpenSMILE Bridge | :8765 | ✅ | 2511006 |
| Ghost Track | :8767 | ✅ | 2402898 |
| tminus-dispatcher | :8768 | ✅ | 2380679 |
| Fleet Conductor | :8769 | (unknown) | — |
| Piper TTS | :8770 | ✅ | 2390778 |
| vision_service | :8766 | ✅ | 2587506 |

## Known Issues
- Fleet Conductor (:8769) hasn't been verified — port not showing in ss output
- Forgemaster status unknown — awaiting construct-coordination check

## Next Steps
- Integrate audit subagent results into this state file
- Push baton-system changes to GitHub for cross-session persistence
