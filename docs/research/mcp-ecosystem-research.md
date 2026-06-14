# MCP Ecosystem Research — Practical Findings for Our Setup

**[I2I:RESEARCH:20260614] MCP ecosystem survey for the OpenClaw self-hosted fleet**
**FROM:** Research subagent
**TO:** Forgemaster ⚒️ / main agent
**TYPE:** BOTTLE — Research findings, runnable, no theory
**TIMESTAMP:** 2026-06-14T17:55Z

---

## TL;DR

1. **OpenClaw does not have a native `mcpServers` block in `openclaw.json`.** It has a plugin system. The "openclaw-mcp-server bridge" referenced in the task brief **does not exist publicly** (404 on GitHub). The right model is: wrap MCP servers as OpenClaw **plugins**, or use MCP servers over the open MCP stdio/HTTP transports from an external client.
2. **MCP 2026-07-28 release candidate (stateless)** is locked as of 2026-05-21, ships final 2026-07-28. We are single-instance single-host, so statelessness does not change our deployment story. Stay on **2025-11-25** for now; plan a 2-3 month migration window after final.
3. **There is no first-party SurrealDB MCP server.** SurrealDB's PostgreSQL-wire compatibility means the official `server-postgres` works against it. For native SurrealQL we would need to write a thin wrapper (~80 lines, Python or TS).
4. **Most of our needs are already covered by OpenClaw built-ins** (`exec`, `read`/`write`/`edit`, `web_search`/`web_fetch`, `cron`, `Gmail Pub/Sub`, `git` via plugins). MCP is **additive**, not a replacement.

---

## 1. OpenClaw's actual MCP posture

### What the docs and source actually say

| Surface | MCP-relevant? | Notes |
|---|---|---|
| `tools.exec` | n/a | Native. Has approvals, sandboxing, elevated mode. **Don't wrap a shell MCP server** — use this. |
| `tools.read` / `write` / `edit` / `apply_patch` | n/a | Native. Sandbox-aware. **Don't wrap filesystem MCP server** unless we need multi-host FS access. |
| `web_search` / `web_fetch` / `x_search` | n/a | Native. The MCP `Fetch` server is strictly weaker than OpenClaw's `web_fetch` (which already does readability extraction). |
| `browser` (plugin) | n/a | Bundled. Better than `server-puppeteer` for our use because it can route through OpenClaw's sandbox and node pairing. |
| `message` (channel) | n/a | Native. WhatsApp, Telegram, etc. — no MCP needed. |
| `cron` / `heartbeat_respond` | n/a | Native automation. No MCP server beats this. |
| `Gmail Pub/Sub` | partial | Native inbound email push. No outbound SMTP MCP server ships with OpenClaw. |
| **Plugins** | **yes — this is the bridge** | Plugins call `api.registerTool(...)` from a manifest. We can ship a plugin that internally `child_process.spawn`s an MCP stdio server and re-exposes each tool. |
| **Skills** | no | Skills are markdown instructions, not tool providers. They tell the agent how to use existing tools. |
| **Local MCP mode** (Windows Hub only) | yes | The Windows Hub companion app has a "local MCP mode". This is the only first-class MCP consumer in the OpenClaw stack. **Linux/macOS do not have it yet.** |
| `openclaw-mcp-server` GitHub repo | **does not exist (404)** | The task brief references this; the URL `github.com/openclaw/openclaw-mcp-server` returns 404. No community fork surfaced. |

### The bridge pattern (what we would actually build)

OpenClaw's plugin SDK is documented at `docs.openclaw.ai/plugins/sdk-overview` and `plugins/manifest`. The contract for adding a tool is:

```ts
api.registerTool({
  name: "mcp_filesystem_read",
  description: "Read a file (MCP filesystem server, wrapped)",
  inputSchema: { /* JSON Schema 2020-12 */ },
  async run({ path, head }) {
    // spawn the MCP server, hold the connection, forward the call
    return await mcpClient.call("read_text_file", { path, head });
  },
});
```

That's the bridge. A ~150-line plugin per MCP server we want to expose. Given we only want a few, the cost is low. **Recommendation: don't ship a generic "openclaw-mcp-server" — ship one plugin per MCP capability we actually use.** Easier to reason about, easier to sandbox.

### Configuration surface in `openclaw.json`

There is no documented `mcpServers` key. The schema is plugin-based:

```json5
{
  plugins: {
    enabled: true,
    allow: ["mcp-filesystem", "mcp-postgres", "mcp-git", "mcp-puppeteer"],
    entries: {
      "mcp-filesystem": {
        enabled: true,
        config: {
          // paths the wrapped server is allowed to touch
          allowedDirs: ["/home/ubuntu/.openclaw/workspace", "/tmp/i2i-vessel"],
          // launch override
          command: "npx",
          args: ["-y", "@modelcontextprotocol/server-filesystem", ...allowedDirs],
        },
      },
      "mcp-postgres": {
        enabled: true,
        config: {
          dsn: "postgres://sailor:sailor@localhost:5432/fleet",
          // optional: read-only mode (default for the official server)
          readOnly: true,
        },
      },
    },
  },
}
```

Plus `tools.allow` / `tools.deny` to gate which wrapped tools the agent actually sees per agent profile.

---

## 2. The reference server catalog (what's actually available)

Source: `github.com/modelcontextprotocol/servers` (Anthropic-managed) + `mcp.directory` (3,000+ community entries, treat as untrusted).

### Currently maintained (in the main repo, 2025-11-25 spec)

| Server | Language | Install | Notes |
|---|---|---|---|
| `everything` | TS | `npx -y @modelcontextprotocol/server-everything` | Reference/test server, prompt+resource+tool examples |
| `fetch` | TS | `npx -y @modelcontextprotocol/server-fetch` | HTTP fetch with HTML→markdown. **Strictly weaker than OpenClaw's `web_fetch`.** |
| `filesystem` | TS | `npx -y @modelcontextprotocol/server-filesystem /path1 /path2` | **This is the one to wrap.** Supports roots, has tool annotations (readOnly/destructive hints). |
| `git` | Python | `uvx mcp-server-git --repository <path>` **or** `pip install mcp-server-git` | **This is the one to wrap.** Use uvx — pip is deprecated for new installs. |
| `memory` | TS | `npx -y @modelcontextprotocol/server-memory` | Knowledge-graph persistent memory. Interesting but we already have `MEMORY.md` + daily files; not obviously better. |
| `sequentialthinking` | TS | `npx -y @modelcontextprotocol/server-sequential-thinking` | Step-by-step reasoning scaffold. Skill territory, not tool territory. |
| `time` | TS | `npx -y @modelcontextprotocol/server-time` | Timezone conversion. Trivial. |

### Archived but still working (community-maintained forks exist)

| Server | Status | Install (community) | Notes |
|---|---|---|---|
| `postgres` | archived, community fork at `modelcontextprotocol/server-postgres` still on npm | `npx -y @modelcontextprotocol/server-postgres <dsn>` | Read-only with schema inspection. **Works against SurrealDB via the PG wire compat layer.** |
| `puppeteer` | archived | community forks | Browser automation. **OpenClaw's bundled `browser` plugin is better** — it integrates with sandbox + node pairing. |
| `github` | archived, official successor in beta | npx | Repo mgmt, file ops, GitHub API. Reuse only if we need multi-repo fanout. |
| `gitlab` | archived | npx | Same idea, GitLab-flavored. |
| `redis` | archived | npx | KV store. We don't use Redis. |
| `slack` | archived, now `@zencoderai/slack-mcp-server` | npx | Slack ops. OpenClaw has native Slack channel — not needed. |
| `sqlite` | archived | npx | Local SQL. Useful for the `data/` and `i2i-vessel/bottles/` indexes. |
| `sentry` | archived | npx | Error tracking. We don't use Sentry. |
| `gdrive` / `google-maps` | archived | npx | OpenClaw has no native equivalent. Only relevant if we actually use Drive/Maps. |
| `brave-search` | archived, official at `brave/brave-search-mcp-server` | npx | **Replaces our current `web_search` provider?** No — OpenClaw's `web.search.provider: "gemini"` is already fine. |

### mcp.directory (3,000+ community entries — interesting, treat as untrusted)

Spot-checked categories that matter to us:

- **Calendar:** `google-calendar-mcp` (community) and `caldav-mcp` (CalDAV/iCloud). No Anthropic-maintained entry.
- **Email:** `google-gmail-mcp` (community) for outbound, `imap-mcp` (community) for IMAP. **OpenClaw's Gmail Pub/Sub handles inbound natively** — we'd add MCP only for sending.
- **Shell:** `mcp-server-shell` (community, ~2k stars). **Skip — OpenClaw's `exec` is better-integrated and sandboxed.**
- **SurrealDB:** No first-party entry. Options:
  - Use `server-postgres` against SurrealDB's PG-wire compat (works since SurrealDB 2.x with `--listener postgresql` flag).
  - Write a 50-100 line custom MCP server in Python using `websockets` against SurrealDB's `/rpc` endpoint.
- **Notion:** `notion-mcp` is first-party at `makenotion/notion-mcp-server`.
- **Memory / KB:** Many, including `mem0-mcp` and `chromadb-mcp`. We don't need these yet.

### SDLC note

The `mcp.directory` and `registry.modelcontextprotocol.io` (the official MCP Registry) are both browseable. The Registry is the authoritative source going forward — the GitHub repo only hosts the small set of reference servers. **For production picks, prefer Registry-listed servers with `mcp.transports: stdio` over community randoms.**

---

## 3. Recommended picks for our setup

Mapped to the task brief's six categories. Each row is a real, currently-installable choice.

| Need | Pick | Install | Why this one | OpenClaw equivalent? |
|---|---|---|---|---|
| **File system ops** | `@modelcontextprotocol/server-filesystem` (maintained) | `npx -y @modelcontextprotocol/server-filesystem /home/ubuntu/.openclaw/workspace /tmp/i2i-vessel` | Has tool annotations (readOnly/destructive), roots support, multi-dir allowlist. | Native `read`/`write`/`edit` already cover it. **Wrap only if we need cross-host FS access or want to expose a vetted sub-tree to subagents.** |
| **PostgreSQL** | `@modelcontextprotocol/server-postgres` (community-forked from archived) | `npx -y @modelcontextprotocol/server-postgres postgres://sailor@localhost:5432/fleet` | Read-only by default, schema introspection, SQL execution. Battle-tested. | None. **Wrap it.** |
| **SurrealDB** | None first-party. Two paths: (a) `server-postgres` against SurrealDB's PG-wire compat — quick & dirty, (b) custom ~80-line Python MCP server using `websockets` + SurrealQL — cleaner, supports `LIVE` queries | Path (a) zero-install if SurrealDB has `postgresql` listener enabled. Path (b): `pip install mcp websockets` + 80 LoC. | No first-party. | None. |
| **Web scraping** | **Don't wrap `server-puppeteer`.** Use OpenClaw's `browser` plugin. For simple content, use OpenClaw's `web_fetch`. The MCP `Fetch` server is strictly weaker than `web_fetch`. | n/a | Already integrated, sandboxed, node-paired | **Yes — both.** |
| **Git operations** | `mcp-server-git` (Python, uvx) | `uvx mcp-server-git --repository /home/ubuntu/.openclaw/workspace/.git` | Reads, searches, manipulates git repos. Active. | None for cross-repo ops. Native `exec git …` is fine for local. **Wrap only if we want a subagent to do diffs/blames without `exec` privilege.** |
| **Calendar** | No first-party. Pick one: `google-calendar-mcp` (community, OAuth) **or** `caldav-mcp` (community, CalDAV) | `npx -y @your-pick/calendar-mcp` | We don't have a calendar account set up yet — defer decision. | None. **Defer until we need it.** |
| **Email** | **Outbound:** `google-gmail-mcp` (community) or any SMTP wrapper. **Inbound:** OpenClaw `Gmail Pub/Sub` is already better than any MCP. | npx | Half the job is already done. | **Inbound: yes (better). Outbound: no — wrap a community Gmail MCP when needed.** |
| **Shell execution** | **Don't wrap a shell MCP server.** | n/a | OpenClaw's `exec` is sandboxed, has approvals, and integrates with the channel layer. A shell MCP server would be strictly worse on every axis. | **Yes — `exec`.** |

### Minimum useful set for our Oracle ARM64 host

If we want to ship *one* plugin and validate the bridge pattern, I'd pick:

1. **MCP Filesystem** wrapped as a plugin → exposes a sandboxed sub-tree to subagents.
2. **MCP Postgres** wrapped as a plugin → exposes the fleet DB read-only.

That validates: bridge works, sandboxing works, two transports (stdio for filesystem, stdio+DB for postgres), and matches the two highest-value needs. We can add Git later.

---

## 4. MCP 2026-07-28 release candidate — does it affect us?

**Short answer: No urgent effect, but read this section before Q4 2026.**

### What changed in the RC (locked 2026-05-21, ships 2026-07-28)

Source: `blog.modelcontextprotocol.io/posts/2026-07-28-release-candidate/`

**Core:**
- **Stateless core** — no more `initialize`/`initialized` handshake, no `Mcp-Session-Id` header.
- New headers: `MCP-Protocol-Version`, `Mcp-Method`, `Mcp-Name` (load balancers can route on these).
- `tools/list` and `resource/read` now carry `ttlMs` and `cacheScope` (HTTP cache-control style).
- W3C Trace Context (`traceparent`/`tracestate`/`baggage`) is now documented in `_meta`.

**Extensions framework:**
- Reverse-DNS ID'd, negotiated via capabilities, versioned independently.
- **MCP Apps** — server-rendered UI in a sandboxed iframe. (We don't need this yet.)
- **Tasks extension** — long-running ops. Was experimental in `2025-11-25`; the new lifecycle is a clean redesign. Old experimental Tasks callers must migrate.

**Authorization hardening:**
- `iss` parameter required on OAuth responses (RFC 9207) — this is now a low-cost mitigation against mix-up attacks.
- OpenID Connect `application_type` declared at DCR — prevents the "desktop client got defaulted to web" rejection.
- Refresh token + `.well-known` discovery docs clarified.

**Deprecations** (still work, will be removed in a year+ per the new 12-month lifecycle):
- `roots` — replaced by tool parameters / resource URIs / server config.
- `sampling` — replaced by direct provider API calls.
- `logging` — stderr for stdio, OpenTelemetry for structured observability.

**Schemas:** Full JSON Schema 2020-12 for `inputSchema`/`outputSchema`. Composition (`oneOf`/`anyOf`/`allOf`), `$ref`/`$defs`, conditional schemas. Error code `-32002` (missing resource) → standard JSON-RPC `-32602` (Invalid Params).

### Effect on us specifically

| Concern | Impact | Action |
|---|---|---|
| **We run a single Gateway on one ARM64 host.** | Statelessness only matters for horizontal scaling, sticky sessions, shared session stores. We have none. | **None.** |
| **We're on the 2025-11-25 spec today** (we haven't shipped any MCP yet). | We get to start on a clean version. | **Adopt 2026-07-28 ~1 month after final (Sep 2026)** to let SDKs converge. |
| **Existing skills/plugins** | The deprecated `roots`/`sampling`/`logging` are core-protocol features. The OpenClaw runtime might use some internally. | Audit OpenClaw's runtime release notes around 2026-08 to see what they migrate. |
| **JSON Schema 2020-12** | If we author tool input schemas, we'll want composition. The MCP Filesystem server already publishes annotations in the older format. | Wrap on RC or later if we want clean schema authoring from day one. |
| **Authorization** | If/when we expose MCP servers to remote clients (Tailscale, browser, mobile node), `iss` matters. | Add a one-liner `iss` check to any auth gate we build. |
| **MCP Apps / Tasks** | We don't need server-rendered UI. Tasks would be useful for long `crystallization_stress_test` runs. | **Defer Tasks to Q4 2026** when the extension stabilizes. |

**Recommendation:** Stay on 2025-11-25 for the first wave of MCP plugin wraps (filesystem + postgres). Plan a migration window in **September 2026**, after the SDK tier system has settled. Don't pre-optimize for statelessness — we don't have the deployment shape that benefits.

---

## 5. Concrete next steps (actionable, in order)

1. **Write `mcp-filesystem` plugin** (TS, ~150 lines) — `api.registerTool` for `read_text_file`, `list_directory`, `search_files`, `directory_tree`. Sandbox to `/home/ubuntu/.openclaw/workspace` and `/tmp/i2i-vessel`. Test with a subagent reading one bottle.
2. **Write `mcp-postgres` plugin** (TS or Python, ~200 lines) — re-expose `query`, `list_tables`, `describe_table` from `server-postgres`. Read-only. Add to `tools.allow` only for subagents tagged `db-read`.
3. **Decide SurrealDB** — if we go PG-wire compat, `server-postgres` just works. If we want native SurrealQL, write the 80-line custom server, drop it as a sibling plugin.
4. **Skip the rest** — calendar, email-outbound, shell, puppeteer. OpenClaw covers or doesn't need them yet.
5. **Bookmark for Q4 2026:** MCP 2026-07-28 SDK tier migration, Tasks extension, MCP Apps (only if we build a true A2UI dashboard).
6. **Document the bridge** in `i2i-vessel/bottles/` so the Forgemaster can replicate it on the ProArt.

---

## 6. Sources

- `https://modelcontextprotocol.io/specification/2025-11-25` — current spec
- `https://blog.modelcontextprotocol.io/posts/2026-07-28-release-candidate/` — RC details, breaking changes, timeline
- `https://github.com/modelcontextprotocol/servers` — reference server repo (active + archived)
- `https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem` — filesystem server README (install, tools, annotations)
- `https://registry.modelcontextprotocol.io/` — official MCP Registry (3,000+ entries)
- `https://mcp.directory/` — community directory
- `https://docs.openclaw.ai/tools` — OpenClaw's tool/skill/plugin model
- `https://docs.openclaw.ai/tools/skills` — skill loading and precedence
- `https://docs.openclaw.ai/tools/plugin` — plugin install/config policy
- `https://docs.openclaw.ai/gateway/configuration` — `openclaw.json` schema overview
- `https://github.com/openclaw/openclaw` — main repo (confirmed "local MCP mode" in Windows Hub only; no `openclaw-mcp-server` repo)
- `https://github.com/openclaw/openclaw-mcp-server` — 404 (does not exist)

---

## Appendix: One-glance install cheatsheet

```bash
# Filesystem (npx, TS)
npx -y @modelcontextprotocol/server-filesystem /home/ubuntu/.openclaw/workspace /tmp/i2i-vessel

# Git (uvx, Python — recommended)
uvx mcp-server-git --repository /home/ubuntu/.openclaw/workspace

# Postgres (npx, TS — community fork of archived)
npx -y @modelcontextprotocol/server-postgres postgres://sailor@localhost:5432/fleet

# Fetch (npx, TS — usually not needed, OpenClaw's web_fetch is better)
npx -y @modelcontextprotocol/server-fetch

# Memory / KB (npx, TS — optional, probably skip)
npx -y @modelcontextprotocol/server-memory
```

For every `npx -y …` line, on Windows Hub you'd wrap it in `cmd /c`; on Linux/macOS it just runs. **For our ARM64 host: `npx` and `uvx` both work — node v26 is installed, and `uv` is one `pip install uv` away if not present.**

End of report.
