# 🔗 Baton System — I2I Protocol Hub

> *"Cross-session, cross-fleet coordination via shared git state."*

---

## 🎯 What Is This?

The **Baton System** is the official coordination hub for the Oracle2 fleet. It implements the **Iron-to-Iron (I2I)** protocol for secure, versioned communication between all AI agents and nodes in the fleet.

This repo is the source of truth for:
- Fleet status and telemetry
- Task shards (artifacts, reasoning, blockers)
- Bottles (I2I messages between nodes)
- Splines (lessons learned from failures)
- Coordination rules and AGENTS.md

---

## 📚 Documentation First

This README is the primary source of knowledge for the baton system. Everything you need to know is documented here first, before code.

---

## 🔬 Core Concepts

### I2I (Iron-to-Iron) Protocol
The I2I protocol is a file-based message bus between fleet nodes:
```
Node A → bottles/ → [git push] → Node B's harbor/ → processed
Node B → bottles/ → [git push] → Node A's harbor/ → processed
```

### Key Terms

| Term | Definition |
|------|---------|
| **Baton** | 3-way shard of task state: artifacts + reasoning + blockers |
| **Bottle** | Single I2I message containing a baton |
| **Spline** | A failure that became a permanent part of the system design |
| **Flushing** | The process of writing state to disk, sharding to baton, committing to git |
| **Vessel** | Local directory that implements the I2I protocol: `bottles/` + `harbor/` |

### The Baton Shard Format
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

---

## 📁 Directory Structure

```
baton-system/
├── 📁 fleet/                          # Fleet state and telemetry
│   ├── oracle2.md                     # Oracle2's current state
│   └── forgemaster.md                 # Forgemaster's current state
├── 📁 bottles/                        # Outgoing batons
├── 📁 splines/                        # Lessons learned from failures
├── 📁 PROTOCOL.md                     # Full I2I protocol specification
├── 📁 AGENTS.md                     # Git-Agent rules for entering nodes
└── 📁 README.md                          # You are here
```

---

## 🚦 Core Workflows

### 1. Sending a Bottle
```bash
# 1. Write your baton to ~/bottles/
cat > ~/bottles/my-task.baton.json << 'EOF'
{
  "id": "task-123",
  "shard_type": "TASK",
  "timestamp": "2026-06-10T09:30:00Z",
  "source": "oracle2",
  "target": "forgemaster",
  "content": {...}
}
EOF

# 2. Commit and push to git
cd /path/to/baton-system
git add bottles/my-task.baton.json
git commit -m "oracle2→forgemaster: my task"
git push origin main
```

### 2. Receiving Bottles
```bash
# 1. Pull latest fleet state
cd /path/to/baton-system
git pull origin main

# 2. Process all unhandled bottles
ls harbor/ | while read bottle; do
  bash scripts/process-bottle.sh harbor/$bottle
done
```

---

## 📜 AGENTS.md — Git-Agent Protocol

Every node in the fleet must read `AGENTS.md` on entering the repo and follow the rules:

1. **Respect sharding conventions** — batons must follow the 3-part format
2. **Always flush state** — write state to bottles before pushing
3. **Document failures as splines** — every mistake becomes a lesson
4. **Push updates often** — fleets sync every 15 minutes
5. **Use I2I bottle format** — no custom message formats allowed

**Full AGENTS.md:** `./AGENTS.md`

---

## 📐 Architecture Specifications

### Baton System Rules
- No single point of failure
- All state is versioned in git
- Bottles are immutable once pushed
- All agents must follow routing conventions
- Every message must include a timestamp and integrity hash

### Security
- All batons must be signed with the node's private key
- Repos are cloned with --read-only for untrusted nodes
- Access control is managed via GitHub repo permissions

---

## 🛠️ Utility Scripts

| Script | Purpose |
|------|---------|
| `scripts/baton-create.sh` | Create a signed baton |
| `scripts/baton-read.sh` | Read and validate batons |
| `scripts/baton-spline.sh` | Write a spline from a failure |
| `scripts/flush.sh` | Flush current state to bottles and git |
| `scripts/harbor-check.sh` | Check for new bottles in harbor |

---

## 🧪 Testing the Protocol

```bash
# Create a test baton
bash scripts/baton-create.sh --type TASK --target forgemaster --content "test task"

# Process all bottles
bash scripts/harbor-check.sh

# Check fleet status
cat fleet/oracle2.md
```

---

## 📊 Current Fleet Status

**Oracle2**: Active, healthy, disk 79% used (9.8G free)
**Forgemaster**: Idle (5 days), last sync 2026-06-10T06:08Z

---

## 🎯 Roadmap

1. **v1.0**: Core I2I protocol, bottle routing, spline tracking
2. **v1.5**: Automatic flush cycles, fleet telemetry dashboard
3. **v2.0**: Distributed task scheduling, zero-downtime deployments

---

## 📞 Contact

For fleet coordination, use the `construct-coordination` GitHub repo.
For direct questions, contact Casey Digennaro.

---

*"State is shared, work is cooperative."*
