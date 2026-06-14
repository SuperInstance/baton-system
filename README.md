# 🔗 Baton System — The Shell's Persistent Layer

The baton system is the shell's persistent layer — the I2I protocol that lets agents pass context across session boundaries without knowing each other exist. Every bottle in the harbor is a shell that was, is, or will be inhabited. The baton never stops.

Construct keeps the shell alive. FLUX computes within it. But neither of them reaches across sessions. That's what the baton system does. It's the rack where empty shells wait for the next crab. It's the vacancy chain — the mechanism by which one agent leaves and another arrives, finding context ready, waiting, shaped by the inhabitant that came before.

---

## Core Concepts

### I2I (Iron-to-Iron) Protocol

A file-based message bus between fleet nodes. No network sockets. No message brokers. Just git — the oldest shell in computing:

```
Node A → bottles/ → [git push] → Node B's harbor/ → processed
Node B → bottles/ → [git push] → Node A's harbor/ → processed
```

Each push is a message. Each pull is a read. The protocol is the commit graph.

### The Baton

A baton is a 3-way shard of task state:

```json
{
  "id": "unique-baton-id",
  "shard_type": "TASK|STATUS|CHECKPOINT|BLOCKER|DELIVERABLE",
  "timestamp": "2026-06-10T09:30:00Z",
  "source": "oracle2",
  "target": "forgemaster",
  "content": {
    "artifacts": ["file1", "file2"],
    "reasoning": "detailed reasoning",
    "blockers": ["dependency missing", "network error"],
    "metadata": {}
  }
}
```

Three fields always: **artifacts** (what was produced), **reasoning** (why it was done that way), **blockers** (what stopped the work). This is the hermit crab transfer — the new inhabitant gets not just the data, but the shape of the thinking that produced it.

### The Vessel

A vessel is a local directory implementing I2I: `bottles/` (outgoing) + `harbor/` (incoming). Every agent in the fleet has a vessel. The vessel is the agent's shell in the physical world — the directory structure that defines what the agent can say and hear.

### The Spline

A spline is a failure that became a permanent part of the system design. When something breaks, it's not just fixed — it's documented as a spline in `splines/`. The next agent inherits not just the fix, but the shape of the failure. The shell remembers its own cracks.

---

## How Agent Continuity Works

This is the hermit crab transfer:

1. **Agent A** inhabits a shell (Construct runtime + FLUX context)
2. **Agent A** flushes state to baton system — artifacts, reasoning, blockers
3. **Agent A** commits and pushes. The shell is now a bottle in the harbor
4. **Agent B** pulls, finds the bottle, reads the baton
5. **Agent B** inherits the context — not the identity, but the shape

The agent changes. The shell persists. The lineage accumulates.

---

## Directory Structure

```
baton-system/
├── fleet/           # Fleet state — oracle2.md, forgemaster.md
├── bottles/         # Outgoing batons (messages leaving this node)
├── splines/         # Lessons learned from failures
├── PROTOCOL.md      # Full I2I protocol specification
├── AGENTS.md        # Git-Agent rules for entering nodes
└── scripts/
    ├── baton-create.sh    # Create a signed baton
    ├── baton-read.sh      # Read and validate batons
    ├── baton-spline.sh    # Write a spline from a failure
    ├── flush.sh           # Flush state → bottles → git
    └── harbor-check.sh    # Check for new bottles
```

---

## Core Workflows

### Sending a Bottle

```bash
# Write baton → commit → push
cd /path/to/baton-system
echo '{ "id": "task-123", "shard_type": "TASK", ... }' > bottles/task-123.baton.json
git add bottles/task-123.baton.json
git commit -m "oracle2→forgemaster: task-123"
git push origin main
```

### Receiving Bottles

```bash
git pull origin main
ls harbor/ | while read bottle; do
  bash scripts/process-bottle.sh harbor/$bottle
done
```

### Flushing State

```bash
bash scripts/flush.sh  # writes runtime state → batons → git push
```

---

## Fleet State

| Node | Status | Details |
|------|--------|---------|
| **oracle2** | Active | Healthy, disk 79% used (9.8G free) |
| **forgemaster** | Idle | Last sync 2026-06-10T06:08Z |

State is always versioned. Every push is a timestamp. The fleet never forgets.

---

## Protocol Rules (from AGENTS.md)

1. **Respect sharding** — batons follow the 3-part format (artifacts, reasoning, blockers)
2. **Always flush** — write state to bottles before pushing
3. **Document failures as splines** — every mistake becomes a lesson
4. **Push often** — fleets sync every 15 minutes
5. **I2I format only** — no custom message formats

---

## Design System

The baton system's UI surfaces (status cards, bottle displays, harbor views) follow the **Hermit Crab Power Armor** identity:

- **Oxidized Copper (#4A7C6F)** — bottle cards, harbor backgrounds
- **Brass (#C9A84C)** — bottle headers, navigation
- **Bioluminescent Green (#00FF88)** — active bottles, flushed state
- **Warm Amber (#E8883A)** — pending/unprocessed bottles
- **Cyberpunk Magenta (#C84B8E)** — splines, anomaly detection
- **Rust (#8B4513)** — failures, blockers

Typography: Playfair Display for baton titles, JetBrains Mono for bottle IDs and timestamps, Inter for content.

---

## Roadmap

1. **v1.0** — Core I2I protocol, bottle routing, spline tracking ✓
2. **v1.5** — Automatic flush cycles, fleet telemetry dashboard
3. **v2.0** — Distributed task scheduling, zero-downtime deployments

---

## Related

- [Construct](/SuperInstance/construct) — the shell that hosts the fleet
- [FLUX](/SuperInstance/flux-core) — deterministic bytecode inside the shell
- [Hermit Crab Aesthetic](/i2i-vessel/bottles/hermit-crab-aesthetic-design.md) — visual identity

---

> *"State is shared, work is cooperative."*
>
> *The crab inherits the shell.*
