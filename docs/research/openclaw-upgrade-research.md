# OpenClaw Upgrade Research: 2026.5.28 → 2026.6.6 / 6.7-beta.1

> Research compiled: 2026-06-14, from docs.openclaw.ai and the OpenClaw GitHub CHANGELOG.md (raw, main branch).
> Sources: https://docs.openclaw.ai, https://github.com/openclaw/openclaw/blob/main/CHANGELOG.md, and the docs sitemap at `https://docs.openclaw.ai` (start/hubs).
> Target upgrade: `2026.5.28` (current) → `2026.6.6` (current stable) and optionally `2026.6.8` (pre-release) / `2026.6.7-beta.1` (beta).
> Current local config reviewed: `/home/ubuntu/.openclaw/openclaw.json`.

## TL;DR

- **No formal "migration guide" exists for in-place version upgrades.** OpenClaw uses `openclaw update` + `openclaw doctor --fix` for upgrades. The `/install/migrating` page covers cross-agent-system migration (Claude/Hermes → OpenClaw), not version upgrades.
- **There is no per-version "breaking change" doc.** The CHANGELOG.md lumps breaking changes inside the bullet text. The only major-version-style rename in this range is the release-train switch to `YYYY.M.PATCH` (pinned at 2026.6.5 as the June 2026 floor — pre-transition tags remain compatible).
- **Your existing config is structurally compatible with 6.6.6.** No required field renames. A handful of values have *new defaults*; yours are explicit overrides, so they survive.
- **OpenRouter is new in 6.6.x.** OAuth onboarding landed in 6.6.6, API-key path was already in 6.6.x.
- **Hugging Face Inference** is a first-class provider (no MicroClaw gating it). There is no "MicroClaw" feature in OpenClaw — see §4.
- **MCP stdio** is not new. It was hardened in 6.6.6 (security boundaries). The new MCP surface in 6.6.x is the **Streamable HTTP loopback transport** (a new transport, not stdio).
- **Secret redaction** is in 6.6.6 (`redact transcript images` in user-visible content boundaries), but it does not require any change to your config.
- **Recommended target:** `2026.6.6` (current stable). Hold off on `2026.6.8` (still pre-release) and `2026.6.7-beta.1` unless you specifically want GLM-5.2, Haiku 4.5, or Telegram rich-message delivery.

---

## 1. Breaking changes between 5.28 and 6.6.6

The CHANGELOG.md is sorted by Highlights / Changes / Fixes and rarely labels items as "BREAKING". Below are the items that affect runtime behavior or config shape and could be visible to an operator.

### 1.1 Default-value changes (your explicit overrides win)

| Setting | 5.28 default | 6.6.6 default | Effect on your config |
|---|---|---|---|
| `compaction.timeoutSeconds` | 600 | **180** | You set `600` explicitly. Explicit overrides are respected, so the change to 180 is cosmetic. Consider lowering to 180 if long compactions are misbehaving, or leave at 600. |
| `compaction.maxHistoryShare` | 0.5 | 0.5 (unchanged) | You set 0.6 — still valid. |
| Default `compaction` mode | varies | unchanged | Your `mode: "default"` is fine. |

Quote (6.6.6): *"lower the default compaction timeout to 180 seconds while respecting explicit configuration."*

### 1.2 Surface deprecations / migrations (doctor --fix handles them)

These are runtime surface moves, not config field renames. They mostly affect what model-ref / agent-runtime strings you use.

- **OpenAI provider/runtime split** — `openai/<model>` now defaults to the **native Codex app-server harness** (ChatGPT/Codex subscription route). The legacy `codex-cli/*` model refs are removed; `openclaw doctor --fix` rewrites them to `openai/<model>`. You are not using `codex-cli/*` and your primary model is `minimax/MiniMax-M3` (an explicit runtime), so this is N/A for you.
- **Anthropic / Claude CLI** — preferred form is now canonical `anthropic/claude-opus-4-8` with model-scoped `agentRuntime.id: "claude-cli"`. Legacy `claude-cli/claude-opus-4-7` refs still work. N/A for you (you use `google/gemini-3.1-pro-preview` + `google-gemini-cli`).
- **OpenAI Codex CLI** — bundled Codex CLI backend was **removed**; the Codex app-server harness is the only path. N/A for you.
- **Local llama.cpp runtime** — moved out of core into its provider plugin. Only matters if you ran local llama.cpp; you don't.
- **`api_key` auth profiles** — non-canonical `api_key` auth profiles are now rewritten to canonical form. You don't have any model entry with `api_key` set, so this is N/A.
- **Cron legacy JSON stores** — doctor preflight migrates them to SQLite. N/A unless you have cron in your config (you don't).
- **Auth profiles** — moved to SQLite; old JSON-backed profiles still resolve.

### 1.3 Config write semantics (only affects automations that call `config.patch`)

> *"Gateway/config/auth: … replace arrays explicitly in `config.patch`."* (6.6.6)

If anything in your automation / script uses `config.patch` to mutate an array (e.g. `allowFrom`, `agents.list`, `fallbacks`), the new semantics require explicit array replacement. Your `openclaw.json` is hand-maintained and not patched at runtime, so this is N/A — but flag it for any future `config.patch` callers.

### 1.4 `replacePaths` consent behavior

> *"`replacePaths` consent no longer widens to whole arrays."* (6.6.6)

Affects CLI/dialog consents. Not a config change.

### 1.5 Security-boundary tightenings (6.6.6)

These are tightening of defaults, not config changes. Your current `security` block in `openclaw.json` does not set them, so the new tighter defaults take effect:

- **MCP stdio** — security boundary tightened (see §6).
- **Codex HTTP access** — tighter.
- **Native search policy** — tighter.
- **Elevated sender checks** — tighter.
- **Loopback tools** — tighter.
- **Deleted-agent ACP bypass** — fixed.
- **Sandbox binds** — tighter.
- **Host environment inheritance** — reduced.
- **Exec approvals** — **fail closed on timeout** (this is the most operationally visible one). If you have an exec-approval prompt that times out, the default is now to deny rather than auto-approve. You currently don't have an `exec-approval` policy block in your config; whatever default the previous version used is now "deny on timeout".
- **Discord moderation, Teams group actions** — tightened.

### 1.6 Logging / diagnostics changes

- `gateway.auth.rateLimit` is now **enabled by default** for remote non-browser / HTTP auth failures (loopback is exempt). You have `gateway.bind: "loopback"`, so the loopback exemption applies — but if you ever bind to a public interface, plan for the rate limiter.
- `openclaw security audit` will now **warn when YOLO exec policy overrides a restrictive raw Claude `--permission-mode`** for managed live sessions. N/A for you (no Claude CLI in your config).
- `logging.redactSensitive` — see §5.

### 1.7 Channel / surface changes that may surprise you

- **Telegram**: `/compact` now works on generic ingress; streamed text survives tool calls; account-scoped topics route to the right agent; unauthorized DM text is excluded from cache and prompt context. 6.6.8 (prerelease) adds structured rich text and rich prompt handoff to CLI backends. You have `telegram` configured with a `default` account only.
- **Telegram/Discord/Slack/Feishu/Mattermost/iMessage**: assorted durability and thread-reply fixes. Generally invisible.
- **WhatsApp**: 6.6.8 adds ACP-binding support. N/A for you.
- **QQBot**: `/bot-group-allways` slash command, plus reasoning/thinking stripping before native delivery. N/A.
- **Matrix**: voice-message preflight, thread-aware reads/replies. N/A.
- **iMessage**: outbound transport hardened, durable echo markers, block streaming. N/A.

### 1.8 Operator install policy (6.6.2)

> *"Plugin and skill installs now use an operator install policy instead of the old dangerous-code scanner path."*

The dangerous-code scanner path was removed. The new `operator install policy` keys are accepted but not required for normal operation. You don't have an `installPolicy` block, so doctor may add one under the new default. No action required.

---

## 2. Config changes needed (delta from 5.28 → 6.6.6)

For your specific config at `/home/ubuntu/.openclaw/openclaw.json`, **the answer is: none are required**. The config loads and validates as-is. The items below are *optional* cleanups or forward-looking additions.

### 2.1 Optional cleanups

- **`compaction.timeoutSeconds: 600`** — works (explicit override), but the new 180 s default is what most users run with. If you have been hitting compaction timeouts, drop to 180. If not, leave alone.
- **`agents.defaults.models["minimax/MiniMax-M3"].params.legacyReasoning: true`** — this is a params field that the new model catalog (in 6.6.6+) may not need. Verify after upgrade with `openclaw models list --provider minimax` and `openclaw doctor`; doctor will flag stale params.
- **No provider/plugin entries for OpenRouter** — fine, you don't need it. If you want to add it, see §3.

### 2.2 Forward-looking fields you may want to add

These are not required, but they're new in 6.6.6 and may improve your experience:

```json5
{
  // Per the gateway/configuration reference, these are new in 6.6.x:
  gateway: {
    handshakeTimeoutMs: 15000,        // new tunable; default already
    push: { apns: { relay: { baseUrl: "https://ios-push-relay.openclaw.ai" } } }, // new; only relevant for iOS nodes
  },
  messages: {
    visibleReplies: "automatic",      // new in 6.6.x; current default
    groupChat: {
      visibleReplies: "message_tool", // opt-in; only if you want agent to decide when to speak in groups
      unmentionedInbound: "room_event", // quiet context for unmentioned group chatter
    },
  },
  session: {
    threadBindings: { enabled: true, idleHours: 24, maxAgeHours: 0 }, // new in 6.6.x
  },
  agents: {
    defaults: {
      imageMaxDimensionPx: 1200,      // new default
    },
  },
}
```

None of these are required for an in-place upgrade.

### 2.3 What `openclaw doctor --fix` may do

When you run `openclaw doctor --fix` after the upgrade, expect it to potentially:

- **Strip unknown / retired keys** in your config. Your config looks clean (no deprecated keys I can spot).
- **Migrate legacy `api_key` → canonical form**. You don't have one.
- **Migrate legacy `codex-cli/*` → `openai/*`**. N/A.
- **Add a default `installPolicy` block** (or warn if absent). Optional.
- **Add a default `exec-approval` policy block** (the new fail-closed-on-timeout default needs a policy host). Worth checking after upgrade.
- **Verify SQLite auth migration before cleanup** (6.6.6) — should be a no-op for you.

Recommendation: snapshot `openclaw.json` (`cp openclaw.json openclaw.json.pre-6.6.6`) before running `--fix`, then diff after.

---

## 3. OpenRouter provider configuration (new in 6.6.x)

**Auth options**

1. **API key** — env var `OPENROUTER_API_KEY`, or set per-model in `auth.profiles` / `auth.choices`.
2. **OAuth** — added in 6.6.6 (per the CHANGELOG: *"Provider support expands with OpenRouter OAuth onboarding"*). Use `openclaw models auth login --provider openrouter`.

**Provider id**: `openrouter`

**Model ref pattern**: `openrouter/<provider>/<model>`, e.g.:

- `openrouter/anthropic/claude-sonnet-4-6`
- `openrouter/openai/gpt-5.4`
- `openrouter/google/gemini-3.1-pro-preview`
- `openrouter/meta-llama/llama-3.3-70b-instruct`

**Default**: `openrouter/auto` — OpenRouter's routing layer (picks a model per request).

**Headers** OpenClaw sends automatically:

- `HTTP-Referer`
- `X-OpenRouter-Title`
- `X-OpenRouter-Categories` (image / video / music / tts / stt / fusion router metadata)

**Minimal example** (API key):

```json5
{
  agents: {
    defaults: {
      model: { primary: "openrouter/auto" },
      models: {
        "openrouter/auto": { alias: "OpenRouter auto" },
        "openrouter/anthropic/claude-sonnet-4-6": { alias: "OR Sonnet" },
      },
    },
  },
}
```

Set `OPENROUTER_API_KEY=sk-or-...` in the gateway env (or use a SecretRef profile).

**Provider-prefix normalization** (6.6.8): OpenRouter model IDs are normalized across the provider path so `openrouter/<provider>/<model>` is consistent regardless of the underlying provider's catalog format. Nothing you need to configure.

**Image/video/music routing**: OpenClaw routes `image_generate`, `video_generate`, and `music_generate` requests through OpenRouter when the model ref starts with `openrouter/` and the categories match. Useful if you want a single API key for many modalities.

**Adding to your current config**: optional. If you want to keep your `minimax/MiniMax-M3` primary but add OpenRouter as a fallback, append it to `fallbacks`:

```json5
agents: {
  defaults: {
    model: {
      primary: "minimax/MiniMax-M3",
      fallbacks: [
        "google/gemini-3.1-pro-preview",
        "openrouter/anthropic/claude-sonnet-4-6",
      ],
    },
  },
}
```

---

## 4. "MicroClaw HuggingFace fallback" — does not exist

**There is no feature called "MicroClaw" in OpenClaw.** I checked the entire CHANGELOG.md on `main` and the docs sitemap at `https://docs.openclaw.ai`; the term does not appear.

The most likely confusions and their actual status:

| If you meant… | Status in 6.6.6 |
|---|---|
| **Hugging Face Inference** as a fallback provider | **Exists, first-class.** Provider id `huggingface`, auth via `HUGGINGFACE_HUB_TOKEN` or `HF_TOKEN`, model refs `huggingface/<org>/<model>`, with `:fastest` and `:cheapest` routing suffixes. Enable the bundled `huggingface` plugin, set auth, pick a model. See `https://docs.openclaw.ai/providers/huggingface`. |
| **Local llama.cpp runtime** as a fallback | **Moved out of core in 6.6.6** into its own provider plugin. Now a separate bundled plugin (`llama.cpp` provider). Was bundled with the Gateway before 6.6.6. |
| **Local GGUF embeddings** (memory) | **Already runs in an isolated worker sidecar** (6.5.26) and degrades to configured fallback or keyword search on worker failure. |
| **Microagent / subagent** as a fallback | Subagents exist; they are spawned via `sessions_spawn`, not "MicroClaw". |
| A separate "MicroClaw" product / agent harness | **Not in this product.** |

**Recommended fallback chain if you want a HF fallback for `minimax/MiniMax-M3`:**

```json5
agents: {
  defaults: {
    model: {
      primary: "minimax/MiniMax-M3",
      fallbacks: [
        "google/gemini-3.1-pro-preview",
        "huggingface/Qwen/Qwen2.5-72B-Instruct",   // example
      ],
    },
  },
}
```

You'd need to install/enable the bundled `huggingface` plugin and set `HUGGINGFACE_HUB_TOKEN`. No doctor migration needed.

If "MicroClaw" was something you saw in a different ecosystem (Zapier micro-claws, a third-party tool, etc.), let me know and I'll re-research. **As of 2026-06-14, OpenClaw has no MicroClaw surface.**

---

## 5. Secret redaction changes

**What changed in 6.6.6:**

- `redact transcript images` is now part of the user-visible content boundaries (CHANGELOG 6.6.6 / User-visible content boundaries). Vision transcripts and tool images are scrubbed of secret-shaped content before persistence / display.
- `gateway.auth.rateLimit` is now enabled by default for remote auth failures (6.5.26); loopback exempt.
- `openclaw security audit` gained a check that warns when webhook `hooks.token` reuses an active Gateway password (6.5.26). N/A for you (no `hooks` block).
- `openclaw security audit` warns when YOLO exec policy overrides a restrictive raw Claude `--permission-mode` (6.5.26). N/A for you.
- `log entry redaction: redactSensitive: "tools"` is the new default. Your config doesn't set it; the default applies.

**Does it affect your config?**

- **No required changes.** Your config has no `hooks.token`, no `webhooks`, no explicit `logging.redactSensitive` override, no shared passwords.
- **One thing to verify post-upgrade:** your `openclaw security audit` output. The new checks may surface warnings about general security hygiene that weren't flagged before. None of them should fail; they're warnings.
- **If you ever add webhooks**, give them their own token (don't reuse the gateway password) or the audit will warn.

**Optional forward-looking add** (not required):

```json5
{
  logging: {
    redactSensitive: "tools",   // default in 6.6.6; explicit for clarity
  },
}
```

---

## 6. MCP stdio server integration

**Status: not new in 6.6.x.** MCP support pre-dates 2026.5.28. What *is* new in 6.6.6:

- **MCP stdio security boundary tightened** (6.6.6 Highlights: *"Security boundaries are substantially tighter across transcripts, sandbox binds, host environment inheritance, **MCP stdio**, Codex HTTP access…"*).
- **MCP tool results coercion** (6.6.5): `resource_link`, `resource`, `audio`, malformed image, and future non-text/image blocks are coerced at the materialize boundary so they don't 400 Anthropic.
- **Streamable HTTP loopback transport** (6.6.6) — *new* transport for MCP, separate from stdio. Lets MCP servers be reached over HTTP loopback when stdio is undesirable.
- **MCP HTTP redirects guarded** (6.6.5): "guard MCP HTTP redirects" prevents MCP HTTP servers from bouncing to unexpected hosts.
- **Doctor validates active bundled MCP tool schemas** (6.5.27) — unsupported MCP input schemas are reported and quarantined before assistant startup.

**Config shape for MCP stdio (unchanged from 5.28):**

```json5
{
  mcp: {
    servers: {
      "my-stdio-server": {
        transport: "stdio",
        command: "node",
        args: ["/path/to/server.js"],
        env: { KEY: "value" },
        // or
        cwd: "/path/to/workdir",
      },
      "my-http-server": {
        transport: "http",  // new in 6.6.6: streamable HTTP loopback
        url: "http://127.0.0.1:8765",
      },
    },
  },
}
```

**Your current config does not have an `mcp` block**, so MCP servers are not configured. Adding MCP stdio is purely additive and does not conflict with anything you have.

**Recommendation:** no action required for the upgrade. If you want to add MCP servers (e.g. the openai-whisper or github skills can be served via MCP), the stdio transport is the same shape as 5.28.

---

## 7. Recommended upgrade plan

1. **Snapshot your config and auth state:**
   ```bash
   cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.pre-6.6.6
   cp -r ~/.openclaw/auth ~/.openclaw/auth.pre-6.6.6   # if you have local auth profiles
   ```

2. **Update to 2026.6.6 (stable):**
   ```bash
   openclaw update
   openclaw doctor
   ```
   Read doctor output. Expect zero required changes for your config.

3. **Optionally run fixes:**
   ```bash
   openclaw doctor --fix   # review each change before confirming
   ```
   Most fixes are no-ops for your config. The big one to watch is "strip unknown / retired keys" — if doctor wants to remove something you wanted, decline and ask.

4. **Smoke test:**
   - `openclaw status` (Gateway health)
   - Send a Telegram message to the bot, confirm a turn.
   - `/model` picker, confirm `minimax/MiniMax-M3` is selected.
   - `/usage`, confirm footer renders cleanly.
   - Trigger a compaction: `agents.compaction.maxHistoryShare` is 0.6 with `truncateAfterCompaction: true`, so a long session should compact.

5. **Re-run `openclaw security audit`** and review the new warnings. None should be blockers for you.

6. **Decide on 2026.6.8 (pre-release):** it adds Telegram rich messages, GLM-5.2, Claude Haiku 4.5, OpenRouter/Google-Vertex provider-prefix normalization, and managed SecretRef auth. Useful but not required. Hold for now and let it land as a stable patch (likely 2026.6.9 or 2026.6.10).

7. **Do not run 2026.6.7-beta.1 in production.** It's a beta, and your primary model `minimax/MiniMax-M3` already has its own quirks; don't mix pre-release Gateway with primary model in production.

---

## 8. Quick reference — relevant changelog entries

- **2026.6.8** (prerelease, optional): Telegram rich delivery, WhatsApp ACP bindings, GLM-5.2, Haiku 4.5, OpenRouter/Google-Vertex provider-prefix normalization, managed SecretRef auth, /usage footer renderer.
- **2026.6.6** (current stable, **recommended target**): OpenRouter OAuth, MCP stdio hardening, Streamable HTTP loopback transport for MCP, compaction default 180 s, secret redaction for transcript images, exec approvals fail-closed on timeout, default `gateway.auth.rateLimit` enabled.
- **2026.6.5**: Parallel web-search bundled, MCP tool-result coercion, `codex-cli/*` removal, cron legacy-JSON → SQLite migration, auth profiles → SQLite.
- **2026.6.2**: Operator install policy replaces dangerous-code scanner; policy comparison / ingress-channel conformance / sandbox-posture conformance checks.
- **2026.6.1**: MiniMax M3 model support (your primary model — already supported in 5.28, listed here for reference).
- **2026.5.28** (current): Claude Opus 4.8, Fal Krea image schemas, NVIDIA featured models, MiniMax streaming music responses, encrypted PDF extraction, voice model catalogs, GitHub Copilot agent runtime, Codex Supervisor plugin, `api_key` → canonical migration, exec-approval reaper improvements.

---

## 9. Sources

- https://docs.openclaw.ai (sitemap via `/start/hubs`)
- https://docs.openclaw.ai/install/updating — primary upgrade guide
- https://docs.openclaw.ai/install/migrating — covers *cross-system* migration only, not version upgrades
- https://docs.openclaw.ai/providers/openrouter — OpenRouter provider reference
- https://docs.openclaw.ai/providers/huggingface — Hugging Face Inference provider
- https://docs.openclaw.ai/concepts/model-providers — full provider matrix
- https://docs.openclaw.ai/concepts/agent-runtimes — OpenAI/Anthropic/Codex/Copilot runtime splits
- https://docs.openclaw.ai/gateway/configuration — config overview
- https://docs.openclaw.ai/gateway/configuration-reference — full field map
- https://raw.githubusercontent.com/openclaw/openclaw/main/CHANGELOG.md — full version history
- https://github.com/openclaw/openclaw/releases — release notes and tags

---

*Research closed 2026-06-14 17:58 UTC. The 2026.6.7-beta.1 tag exists but I did not find a separately-documented changelog for it on the `main` branch CHANGELOG.md; it is presumably a release-train tag with the same content family as 6.6.6/6.6.8.*
