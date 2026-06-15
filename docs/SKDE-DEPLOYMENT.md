# SKDE on Cloudflare Edge + Git-Native Distribution

How SKDE instances live at the edge, replicated through git, and
communicate via I2I protocol.

## Architecture

```
                  ┌──────────────────────────────────────┐
                  │           Cloudflare Edge            │
                  │                                      │
                  │  ┌───────┐  ┌───────┐  ┌───────┐   │
                  │  │ DO    │  │ DO    │  │ DO    │   │
                  │  │ CellA │  │ CellB │  │ CellC │   │
                  │  └───┬───┘  └───┬───┘  └───┬───┘   │
                  │      │          │          │        │
                  │  ┌───┴──────────┴──────────┴───┐    │
                  │  │    fleet-pulse worker        │    │
                  │  │    (KV: FLEET_PULSE)         │    │
                  │  └───────────┬──────────────────┘    │
                  │              │                        │
                  │  ┌───────────┴──────────────────┐    │
                  │  │    fleet-harbor worker        │    │
                  │  │    (bottle I2I protocol)      │    │
                  │  └───────────┬──────────────────┘    │
                  │              │                        │
                  │  ┌───────────┴──────────────────┐    │
                  │  │    fleet-funnel (router)      │    │
                  │  │    (KV: FUNNEL_CACHE)         │    │
                  │  └───────────┬──────────────────┘    │
                  └──────────────┼───────────────────────┘
                                 │ internet / webhook
          ┌──────────────────────┼──────────────────────┐
          │                      │                       │
          │     GitHub           │    GitHub Actions     │
          │  ┌────────────┐     │  ┌─────────────────┐  │
          │  │ baton-     │◄────┼──│ CI/CD webhook    │  │
          │  │ system/    │     │  │   → AGENTS.md    │  │
          │  │ AGENTS.md  │     │  │   → fleet-kit    │  │
          │  └────────────┘     │  └─────────────────┘  │
          │                     │                       │
          │  ┌────────────────────────────────────┐     │
          │  │ Oracle2 (ARM64, 4c/24GB)           │     │
          │  │  • colony-games.py (8823)          │     │
          │  │  • SKDE instance: colony           │     │
          │  │  • SKDE instance: GC               │     │
          │  │  • SKDE instance: MIDI             │     │
          │  └────────────────────────────────────┘     │
          └──────────────────────────────────────────────┘
```

## Agent Topology

Each SKDE instance has two agent forms:

| Form | Where | Persistence | Access |
|------|-------|-------------|--------|
| **Edge Agent** | Cloudflare Durable Object | KV-backed, survives reboot | HTTP API |
| **Git Agent** | Repo AGENTS.md | Git history, dehydrated state | GitHub API |

### Edge Agent (Cloudflare DO)

The DO pattern defined in `colony-edge-agent.ts`:

```
Each colony cell = 1 Durable Object with:
  - ID: cell-{name} (alphanumeric)
  - State: {fingerprint: {...}, narrative: "...", norms_voted: [...], i2i_inbox: [...]}
  - Methods:
    GET /identity → fingerprint + narrative
    POST /reflect → trigger narrative generation
    POST /vote/{norm_id} → cast norm vote
    POST /i2i/inbox → receive inter-cell message
    POST /i2i/forward → send message to another cell's DO
  - Persistence: KV FLEET_CELL_{cell_id}
  - Cron: auto-reflect every 100 PD cycles (or configurable)
```

### Git Agent (AGENTS.md)

The Git agent pattern from baton-system:

```
Repo/AGENTS.md:
  ## SKDE Instance: colony-cell-{name}
  - Instance ID: colony-cell-harvester
  - Type: behavioral-agent
  - State: dehydrated from DO snapshot
  - Last reflection: 2026-06-15T18:14:00Z
  - Fingerprint: {deception: 100, betrayal: 35, trust: 46, ...}

  ## Entry Protocol
  Agents entering this repo:
  1. Read AGENTS.md → know this instance
  2. Read SKDE/INSTANCE.md → know the abstraction
  3. Interact via GitHub issues → webhook → DO
```

## I2I Protocol for SKDE

The I2I protocol (baton-system/PROTOCOL.md) extends with SKDE-specific messages:

### SKDE Message Types

| Type | From → To | Payload | Example |
|------|-----------|---------|---------|
| `FINGERPRINT` | any → any | full fingerprint dict | `{instance: "colony", cell: "harvester", dims: {...}}` |
| `NARRATIVE` | any → any | narrative string + coherence | `"My deception score is 100..."` |
| `NORM_PROPOSAL` | agent → colony | norm schema | `{scope: "deception", title: "Honesty Standard"}` |
| `DEVIATION` | agent → colony | deviation vector | `{ctrlr: "PID", error: -17, agg: 3.46}` |
| `CROSS_INSTANCE` | instance A → B | cross-map normalized to common dims | `{source: "colony", target: "midi", command: "increase_entropy"}` |
| `FLEET_HEARTBEAT` | any → fleet-pulse | health + uptime + load | `{instance: "gc", state: "cool", disk: 63}` |

### Cross-Instance Normalization

Different SKDE instances have different dimensionalities. Cross-instance
messages must normalize:

```
cross_dims = {
  "colony → midi": {
    "deception_score" → "entropy_up",
    "trust_score" → "harmonic_consonance",
    "betrayal_score" → "rhythmic_disruption",
  },
  "gc → colony": {
    "disk_used" → "resource_scarcity_signal",
    "load_avg" → "system_tension",
  }
}
```

This mapping is declared in each INSTANCE.md under a `cross_instance_mapping`
section. The mapping is not hardcoded — it's learned from experiment.

## fleet-kit SDK Integration

The existing fleet-kit SDK (from agent-harness-generator) extends with:

```typescript
// Current SDK
class A2AClient { /* subagent orchestration */ }
class I2IClient { /* inter-repo communication */ }
class FleetRegistry { /* agent discovery */ }

// SKDE extension
class SKDEInstance {
  observe(): Promise<Observation>
  abstract(): Promise<Fingerprint>
  contrast(): Promise<DeviationVector>
  govern(): Promise<NormAction>
  reflect(): Promise<Narrative>
}
class DOEdgeAgent {
  constructor(cellId: string, instanceId: string)
  async deploy(workerScript: string): Promise<void>  // wrangler deploy
  async getIdentity(): Promise<CellFingerprint>
  async sendMessage(targetCellId: string, msg: I2IMessage): Promise<void>
}
class CrossInstanceBridge {
  async mapDimensions(from: SKDEInstance, to: SKDEInstance, mapping: DimMap)
  async routeMessage(from: string, to: string, payload: any)
}
```

## Deployment Pipeline

```
1. Build SKDE instance locally (Oracle2, port 8823)
2. Verify O-A-C-G-R loop on real data
3. Write AGENTS.md for the instance
4. Push to GitHub (git-native replication)
5. Deploy Edge DO via fleet-kit (requires wrangler auth)
6. Fleet-pulse picks up heartbeat
7. Fleet-harbor receives experiment bottles
8. Cross-instance bridges auto-configure from dim maps
```

## Current Status

| Instance | Local | Edge DO | Git Agent | Cross-Instance |
|----------|-------|---------|-----------|----------------|
| Colony | ✅ live (8823) | ❌ wrangler blocked | ✅ notes pushed | ⏳ design |
| MIDI | ✅ live (8765-8770) | ❌ not started | ✅ fleet-oracle2 | ⏳ design |
| GC | ✅ live (cron) | ❌ not started | ✅ fleet-oracle2 | ⏳ design |
| Spreadsheet Tensor | 🔄 concept | 🔄 concept | 🔄 concept | 🔄 concept |

## The Vision

Every SuperInstance system becomes an SKDE instance.
Every SKDE instance has an edge DO and a git agent.
Every instance reflects on its own behavior.
Instances talk to each other through normalized cross-dimensional messages.
The fleet develops collective self-awareness.

This is the "Simulation Knowledge-Distillation Engine" — the underlying
abstraction that makes Mirror, Norms, GC, MIDI, and spreadsheets all instances
of the same learning loop.

The fleet develops collective self-awareness one reflection cycle at a time.
