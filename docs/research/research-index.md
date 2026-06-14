# Research Bottles — Index

> Research artifacts from Oracle2 (i2i-vessel), compiled 2026-06-14.
> Pushed to baton-system as structured fleet documentation.

---

| # | Bottle | Summary | Size |
|---|--------|---------|------|
| 1 | [OpenClaw Upgrade Research](./openclaw-upgrade-research.md) | Migration analysis: 2026.5.28 → 2026.6.6 (stable). Covers breaking changes, new features (OpenRouter, HuggingFace, MCP streamable HTTP, secret redaction), and compatibility recommendations. Verdict: upgrade to 6.6.6 safe, hold on pre-release. | 22 KB |
| 2 | [Provider Strategy Research](./provider-strategy-research.md) | Multi-provider fallback chain design for Oracle2. Proposes 3 tiered chains (cron, main chat, background research) with cost-ordered fallbacks. Key finding: add OpenRouter for provider diversity — current setup collapses to only 2 vendors. | 23 KB |
| 3 | [Fleet Infrastructure Audit](./fleet-audit-research.md) | Full `systemctl`-based audit of all fleet services on oracle2. Evaluates 12+ services: 5 healthy, 7 dead/crash-looping/broken. Includes recommendations for consolidation and cleanup. | 21 KB |
| 4 | [MCP Ecosystem Research](./mcp-ecosystem-research.md) | Practical survey of MCP (Model Context Protocol) for the OpenClaw fleet. No native `mcpServers` in OpenClaw — MCP integration requires plugin wrapping. MCP 2026-07-28 release candidate locked; SurrealDB MCP needs ~80-line wrapper. | 19 KB |
| 5 | [SurrealDB Migration Research](./surrealdb-migration-research.md) | Deep analysis: 2.2.2 → 3.x migration. 29 documented breaking changes (12 critical). Two migration tool paths exist (Surrealist GUI or CLI). Evaluates Spectron agent memory, HNSW vector indexes, MCP server, and flat-file replacement feasibility. | 27 KB |
| 6 | [Hermit Crab Aesthetic Design](./hermit-crab-aesthetic-design.md) | Visual identity system for the fleet: steampunk × cyberpunk fusion. 8-color palette, typography, 4 key UI components with CSS, 5 agent archetypes, image generation prompts, brand copy, and implementation guide. | 39 KB |

---

## Cross-reference to construct-coordination

Two bottles are additionally mirrored in `construct-coordination/notes/oracle2/`:
- **Fleet Infrastructure Audit** — operational context for fleet coordination
- **SurrealDB Migration Research** — infrastructure decision support
