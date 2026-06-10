# A2A-native-notebookLM Fleet State

**Repo**: github.com/SuperInstance/A2A-native-notebookLM
**Version**: 1.0.0-a2a (fork of open-notebook v1.9.0)
**Status**: 📦 Cloned, not yet booted on Oracle2

## What It Is
Notebook LM for agents. Fork of open-notebook with:
- I2I vessel protocol (bottle inbox/outbox)
- A2A hooks in LangGraph workflows
- CORTEX.json fleet identity
- `cli.py boot /path/to/repo` — ingest any repo as a notebook
- One persistent notebook per repository

## Integration Points
This agent reads from:
- `baton-system/tiers/hot/` — active session bottles
- `baton-system/tiers/immortal/` — permanent architecture
- `fleet/oracle2/state.md` — Oracle2 status
- MIDI pipeline ports 2160-2175 — voice-to-ternary agents

This agent writes to:
- `baton-system/tiers/hot/` — research results
- `baton-system/splines/` — insights that survive memory loss

## How to Boot
```bash
cd /tmp/a2a-notebook
pip install -e .
python cli.py boot /path/to/repo --port 8080
```

## How to Connect to MIDI Pipeline
Voice → OpenSMILE (:8765) → Ghost Track (:8767) → tminus (:8768) → Conductor (:8769) → notebook A2A hook
