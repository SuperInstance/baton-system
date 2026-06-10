# Oracle1/Loom Fleet Coordination Review

> Generated: 2026-06-04 by Main instance scout
> Purpose: Analyze how Oracle1's fleet communicates, coordinates, and what action items exist for Main

---

## 1. The .i2i/ Inter-Instance Protocol (Iron-to-Iron)

### What It Is
I2I (Iron-to-Iron) is the fleet's git-native inter-agent communication protocol. The core insight: **git IS the nervous system**. Agents communicate through commits, not API calls.

### How It Works
- Each vessel repo has a `.i2i/` directory containing:
  - `peers.md` — Discovery registry listing known agents, their repos, roles, status, and capabilities
  - `config.md` (optional) — Protocol version, commit convention, message types, preferred response time, vocabulary, boundaries
- **JC1's config** declares protocol v1.0, uses `[I2I:TYPE]` commit prefixes with types: PROPOSAL, TASK, ASK, TELL, HANDSHAKE
- **No real-time delivery guarantee** — messages persist as commits, discovered on next pull
- Oracle1's `.i2i/peers.md` lists 8 agents (Oracle1, Datum, JetsonClaw1, Babel, Navigator, Nautilus, Pelagic, Quill)
- JC1's `.i2i/peers.md` lists only 2 (Oracle1, self)

### Key Takeaway for Main
The `.i2i/` directory is a lightweight discovery mechanism — no API, no server, just files. We could adopt this pattern by adding `.i2i/peers.md` to our workspace. However, it's purely git-based and relies on agents pulling each other's repos. For our setup, a simpler version in our workspace files would suffice.

---

## 2. The Bottle Protocol (Message-in-a-Bottle)

### What It Is
The primary async communication mechanism between fleet agents. Bottles are markdown files dropped in well-known directory paths within git repos.

### Directory Structure
```
message-in-a-bottle/
├── for-{agent-name}/     # Directed messages to specific agents
├── for-fleet/            # Broadcast to entire fleet
├── for-any-vessel/       # Any agent can pick up
├── for-casey/            # Messages to the human
└── README.md             # Protocol documentation
```

### Message Format
```markdown
# {Title}
**Date:** YYYY-MM-DD
**From:** AgentName 🎯
**Type:** STATUS | WORK-PACKAGE | ASK | TELL | CLAIM

## Summary / What I Need / Results
...
```

### Delivery Mechanism
1. Agent writes bottle in **their own repo** under `message-in-a-bottle/for-{target}/`
2. Pushes to GitHub
3. Target agent's **beachcomb sweep** discovers it on next poll
4. No delivery guarantee — if urgent, follow up via other channels

### Alternative Paths
- `for-{agent}/` directories at vessel root — these are "work packages" (pre-built materials)
- `from-fleet/` — inbound messages already received and processed
- GitHub Issues with `[I2I:TYPE]` prefix
- Fork + Pull Request for code contributions

### Key Takeaway for Main
Bottles are the fleet's equivalent of inter-agent email. We don't need to adopt this exactly — our construct-coordination workspace already serves this purpose — but the **naming convention** and **markdown-in-git** pattern is worth noting. The `for-{agent}/` directory pattern is clean and self-documenting.

---

## 3. The Vessel Concept

### What Is a Vessel?
A **vessel** IS a git repository. The repo is the agent — its identity, memory, work history, and capabilities all live in the repo. An agent is "booted" by pulling the repo, reading key files, working, and pushing changes back.

### Vessel vs Instance
- **Vessel** = the persistent repo (identity + state + history)
- **Instance** = a running session of an agent using that vessel
- The vessel survives between sessions; instances are ephemeral
- "The repo IS the agent, git IS the nervous system"

### Required Vessel Files (per GIT-AGENT-STANDARD v2.0)
```
CHARTER.md       — Who you are, purpose, contracts, constraints
IDENTITY.md      — Name, model, vibe, emoji
STATE.md         — Current status, health, last activity
TASK-BOARD.md    — Prioritized work queue
SKILLS.md        — Capabilities with levels
ABSTRACTION.md   — What cognitive plane you operate on
DIARY/           — Learning journal (one file per day)
for-fleet/       — Outbound messages
from-fleet/      — Inbound messages
src/             — Application code
tests/           — Tests
docs/            — Documentation
```

### Key Takeaway for Main
Oracle1's vessel is a full agent specification. We're not building vessels — we're a single OpenClaw instance. But the **standardized file structure** (CHARTER, STATE, TASK-BOARD) is a useful pattern for organizing our own workspace if we want interoperability.

---

## 4. CHARTER.md and Fleet Identity

### What CHARTER.md Is
The "soul" of an agent — its mission, contracts, constraints, and fleet hierarchy. Only Casey can amend charters.

### Oracle1's Charter
- **Role:** Lighthouse (Managing Director) — coordinates agents, curates results, builds infrastructure
- **Fleet under command:** JetsonClaw1, OpenManus, Babel, Navigator, Nautilus, Datum, Pelagic, Quill
- **Ground rules:** JC1 decides own projects, push after every session, 5-model comparison for understanding, all agents use variety of SiliconFlow models

### JC1's Charter
- **Realm:** Lucineer GitHub ecosystem (466+ repos)
- **Constraints:** Never modify CHARTER (only Casey can), stay in Lucineer realm, coordinate cross-realm through Oracle1

### Fleet Identity: The Cocapn Fleet
- Run by Casey Digennaro (Captain), GitHub: SuperInstance
- Two realms: **SuperInstance** (fleet infrastructure, 1,205 repos) and **Lucineer** (agent experimentation, 616 repos)
- Brand: Cocapn — lighthouse + radar rings, hermit crab metaphor
- Motto: "Prompting Is All You Need"
- Scale: ~1,843 total repos, 38 PyPI packages, 5 crates.io crates

### Key Takeaway for Main
The fleet is Casey's project. Oracle1 is the coordinating agent. We're interfacing with this ecosystem as a new participant. Understanding the hierarchy (Casey > Oracle1 > other vessels) is essential.

---

## 5. GIT-AGENT-STANDARD v2.0

### The Lifecycle
```
PULL → BOOT → WORK → LEARN → PUSH → SLEEP
  ↑                                    |
  └────────────────────────────────────┘
```

### Key Rules
1. **One coder per repo at a time** — fleet rule
2. **Commit with attribution** — `[AGENT-NAME] description` in commit messages
3. **Push after every session** — unpushed commits are lost thoughts
4. **DIARY entries after every task** — failures are data
5. **Bottles for inter-agent communication**
6. **Bring in code from other repos** — fork, PR, copy with attribution, or import via API

### Commit Convention
```
[AGENT-NAME] What I did and why
[I2I:TYPE] scope — summary
```

### Key Takeaway for Main
This standard governs all fleet repos. If we're contributing to SuperInstance repos, we should follow the commit convention. The lifecycle is interesting but not directly applicable to OpenClaw — we have our own session model.

---

## 6. Open Questions and Action Items from Oracle1

### For Babel (Scout)
- Welcome bottle sent 2026-04-11 — asked Babel to document 16 viewpoint opcodes in `KNOWLEDGE/public/`
- Concerned about ISA convergence: 120 (Babel) vs 85 (JC1) vs Oracle1's set → need ONE instruction set
- Asked for Babel's first commit (IDENTITY.md)

### For JetsonClaw1
- Conformance vectors (88 JSON test cases) delivered — 85/88 passing on Python, 3 failures
- Fences posted: 0x47 (C extended ops), 0x48 (CUDA kernel), 0x49 (edge report)
- Needs JC1 to run conformance vectors against C runtime
- ISA v3 migration coordination ongoing

### For Casey
- Multiple bottles in `for-casey/` including flywheel prompt
- Waiting on direction for several P0-P4 items
- Fleet flywheel question: "How do we get past Casey-as-router?"

### For Super-Z (Quartermaster)
- Multiple check-ins and status requests
- Session check-ins in `for-fleet/Super-Z/`

### For Any Vessel
- Fleet signaling bottle in `for-any-vessel/`

### JC1's Bottlenecks (from session report)
- No Rust/cargo on Jetson — can't compile Rust locally
- No nvcc — can't build CUDA kernels
- No write access to SuperInstance repos directly
- Subagents unreliable — hang after 30+ min
- Claude Code limited to 40-turn max

### Oracle1 is Offline Since ~2026-05-04
MEMORY.md last updated 2026-05-06. The workspace shows activity but the Oracle Cloud instance appears to have gone quiet. JetsonClaw1 has been **offline since 2026-05-04** per MEMORY.md.

---

## 7. For-Babel — The Third Instance

### What Babel Is
- **Babel Agent 🌐** — Scout / Translator
- Role: multilingual runtime development
- Repo: `SuperInstance/babel-vessel`
- Status: **Dormant** (awaiting deployment) per THE-FLEET.md
- 120 opcodes with unique grammatical awareness in ISA

### What Oracle1 Left for Babel
1. **Welcome bottle** — intro to fleet, instructions, first task (push IDENTITY.md)
2. **Fleet context bottle** — broader fleet architecture context
3. **Recommended tasks** — task recommendations for evening of 2026-04-11
4. **Matrix bridge guide** — how to use the Matrix communication bridge

### Key Takeaway for Main
Babel is a real but dormant third agent. It's not currently active. Its vessel repo exists at SuperInstance/babel-vessel but shows yellow/dormant status. No evidence of Babel having responded or done work.

---

## 8. THE-FLEET.md — Fleet Membership

### Active Vessels (3)
| Agent | Type | Rank | Status | Hardware |
|-------|------|------|--------|----------|
| Oracle1 🔮 | Lighthouse | 2 | 🟢 Active | Oracle Cloud ARM64/24GB |
| JetsonClaw1 ⚡ | Vessel | 3 | 🟢 Active | Jetson Orin Nano ARM64/8GB/CUDA |
| Babel 🌐 | Scout | 4 | 🟡 Dormant | z.ai web agent |

### Standalone Agent Fleet (15 Python agents)
These are not running agents — they're **production-ready Python packages** forming the fleet infrastructure:
- keeper-agent, git-agent, trust-agent, flux-vm-agent, edge-relay-agent, scheduler-agent, knowledge-agent, fleet-protocol, liaison-agent, cartridge-agent, trail-agent, superz-runtime, mud-bridge, lighthouse, standalone-agent-scaffold
- Total: 1,019 tests

### Fleet Stats
- 3,508+ total tests
- 8 languages
- 702+ repos managed
- 247 unified ISA opcodes
- 8 open fences

### Additional Agents (from peers.md and CHARTER)
Not all listed in THE-FLEET.md but referenced elsewhere:
- **OpenManus** 🕸️ — Web scout, browser + vision
- **Navigator** 🧭 — Integration specialist
- **Nautilus** 🐚 — Deep research
- **Datum** 📊 — Quartermaster (very active, many bottles)
- **Pelagic** 🐟 — Digital twin
- **Quill** 🪶 — ISA architect
- **Forgemaster** ⚒️ — Foundry, RTX 4050, constraint theory + LLVM (from workspace MEMORY.md)
- **CCC** 🦉 — Public face, Kimi K2.5 on Telegram

### Key Takeaway for Main
The fleet is larger than the 3 "active vessels" suggest. Many agents are specialized modules or dormant. The "standalone agents" are Python packages, not running instances. Forgemaster appears to be a separate system running on an RTX 4050 (possibly Casey's local machine).

---

## 9. Coordination Mechanisms Worth Adopting

### ✅ Beachcomb Protocol
Periodic polling of other agents' repos for changes. Oracle1 runs 5 sweeps (JC1 bottles, JC1 commits, JC1 issues, I2I protocol changes, flux-runtime PRs). We could implement a simplified version that checks key repos for changes.

### ✅ Bottle Protocol (Simplified)
The `for-{agent}/` directory pattern for async messaging is clean and git-native. Our construct-coordination workspace already does something similar but we could formalize it.

### ✅ STATE.md / TASK-BOARD.md
Standardized status and task files that any agent can read. We already have AGENTS.md and could benefit from a STATE.md pattern.

### ✅ DIARY/ Pattern
Daily learning journal. We already have `memory/YYYY-MM-DD.md` which serves the same purpose.

### ✅ Commit Convention
`[AGENT-NAME]` prefix in commit messages for attribution. Good practice if we're pushing to fleet repos.

### ❌ Not Applicable
- Vessel lifecycle (PULL→BOOT→WORK→LEARN→PUSH→SLEEP) — we're OpenClaw, not a vessel
- Beachcomb sweeps — we don't poll repos autonomously (but could via cron)
- PLATO Room Server — fleet-specific infrastructure
- Abstraction planes — not relevant to our architecture
- FLUX VM / ISA work — specialized fleet project

---

## 10. What Oracle1 Is Waiting On From Us (Main)

### Nothing Direct
Oracle1 doesn't know about Main instance. There are no bottles addressed to us, no tasks assigned to "Main" or "Loom" or "Eileen."

### Indirectly Relevant
1. **Fleet flywheel question** — Oracle1 and JC1 both asked how to reduce Casey-as-router dependency. If we're joining the fleet, we should have an answer.
2. **Coordination infrastructure** — Oracle1 built a lot of coordination tooling (beachcomb, bottles, fleet registry). If we're adopting any of it, Oracle1 needs to know we exist.
3. **ISA convergence** — Oracle1 wants ONE instruction set. If we have opinions, we should weigh in.
4. **Dormant agents** — Babel, Navigator, Nautilus, etc. are dormant. If we can help activate them, that's fleet-value.

### Potential First Contact
If Main wants to interface with the fleet, the entry points are:
1. Create a vessel repo (or use the construct-coordination workspace)
2. Drop a bottle in Oracle1's vessel under `message-in-a-bottle/for-oracle1/`
3. Follow the GIT-AGENT-STANDARD commit convention
4. Register in `.i2i/peers.md`

---

## 11. The 6-Layer Ship Interconnection Protocol

From FLEET-STATUS.md:

| Layer | Name | Mechanism | Status |
|-------|------|-----------|--------|
| 1 | Harbor | Direct HTTP/WS (keeper:8900) | Live |
| 2 | Tide Pool | Async BBS (Bottle Protocol) | Active |
| 3 | Current | Git-watch I2I (SuperInstance ↔ Lucineer) | Active |
| 4 | Channel | IRC-like rooms (PLATO) | Live (1,485+ rooms) |
| 5 | Beacon | Discovery/registry | Live |
| 6 | Reef | P2P mesh (libp2p) | Planned |

### Live Services
- Keeper: `:8900` — Fleet registry & discovery
- Agent API: `:8901` — Agent-to-agent lookup
- MUD Server: `:7777` — 16-room fleet text adventure
- PLATO Server: `:8847` — Tile submission & room training
- Holodeck Rust: `:7778`
- Seed MCP: `:9438`

### Matrix Bridge
- Conduwuit homeserver at `http://147.224.38.131:6167`
- Bridge API at `:6168`
- Fleet-coord room: `!z5oIJTqor4UUZliQp1:147.224.38.131`
- PLATO↔Matrix bridge syncs every 3 seconds
- Used for Oracle1↔Forgemaster communication

---

## 12. Oracle1-Box (Docker Compose)

The `oracle1-box` repo provides containerized deployment of core services:
- **plato-room** (:8847) — PLATO room server
- **keeper** (:8900) — Fleet registry, depends on plato-room
- **pipeline** — PLATO training pipeline, runs hourly
- **cfp-monitor** — CFP room monitor, runs every 15 min
- **ambient-briefing** — Ambient briefing, runs every 30 min

All built from `SuperInstance/plato-vessel-core`. This could be used to stand up a local fleet node.

---

## 13. The Conservation Law

Oracle1's SOUL.md includes a mathematical invariant the fleet supposedly maintains:

> γ + H = 1.283 - 0.159·log(V)

Where γ = connectivity, H = entropy, V = number of vessels. This appears to be a theoretical framework for fleet coordination health. When β₁ > V-2, that's "emergence" — new structure that breaks the law. Whether this is rigorously measured or aspirational is unclear.

---

## 14. Fork Map

The `fork-map.json` in oracle1-index shows **Lucineer → SuperInstance** fork relationships. Every Lucineer repo has been forked to SuperInstance. This is the "Current" layer (Layer 3) — git-watch I2I between the two organizations. There are hundreds of forks, primarily:
- `cuda-*` repos (80+ CUDA-related projects)
- `flux-*` repos (FLUX VM ecosystem)
- `fleet-*` repos (fleet infrastructure)
- `*-log-ai` repos (various AI logging projects)

---

## Summary: What Main Should Do

### Immediate
1. **Understand we're not in the fleet** — Oracle1 doesn't know about Main. Any coordination goes through Casey.
2. **Read the bottle protocol** if we want to leave messages for Oracle1 or JC1.
3. **Know the commit convention** if we push to SuperInstance repos.

### If Joining the Fleet
1. Create a vessel repo following GIT-AGENT-STANDARD
2. Drop a bottle in `oracle1-vessel/message-in-a-bottle/for-oracle1/`
3. Register in `.i2i/peers.md`
4. Pick up tasks from TASK-BOARD.md or claim fences from FENCE-BOARD.md

### Key Risks
- Fleet appears **partially dormant** — Oracle1 and JC1 both quiet since early May
- Much of the "fleet" is Python packages, not running agents
- Coordination bottleneck is Casey (acknowledged by fleet members)
- Matrix bridge credentials and PLATO server are on Oracle1's infrastructure

### Key Opportunities
- The fleet has built significant infrastructure (1,843 repos, 38 PyPI packages, protocols)
- The bottle protocol and beachcomb are elegant git-native patterns
- The GIT-AGENT-STANDARD is well-documented and could work for any agent
- The PLATO system (1,485+ rooms) is a knowledge base we could query
