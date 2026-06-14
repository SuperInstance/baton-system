# Provider Strategy Research — Oracle2 Multi-Provider Fallback

**Research date:** 2026-06-14 17:55 UTC
**OpenClaw version (this box):** 2026.5.28 (e932160) — pre-6.6
**Author:** MiniMax-M3 subagent task

---

## 0. TL;DR — the optimal chain (recommended)

Three tiered chains, each with ≥ 3 different vendors, cost-ordered:

| Use case | Primary | F1 | F2 | F3 (last resort) |
|---|---|---|---|---|
| **Cron / agentTurn** (cheapest) | `deepseek/deepseek-v4-flash` ($0.27/$1.10) | `minimax/MiniMax-M2.7` ($0.30/$1.20) | `openrouter/openrouter/free` (free) | `openrouter/openai/gpt-5.4-nano` ($0.20/$1.25) |
| **Main chat** (default) | `deepseek/deepseek-v4-flash` ($0.27/$1.10) | `minimax/MiniMax-M3` ($0.40/$1.65) | `google/gemini-3.1-pro-preview` (OAuth) | `openrouter/anthropic/claude-sonnet-4.5` ($3/$15) |
| **Background research** (high quality) | `deepseek/deepseek-v4-pro` ($0.55/$2.19) | `openrouter/anthropic/claude-sonnet-4.5` ($3/$15) | `openrouter/openai/gpt-5.4` ($2.50/$15) | `openrouter/openrouter/fusion` (panel + judge) |

**Critical finding:** current setup has **zero provider diversity** in fallbacks — V4 Pro, M3, M2.7 collapse to 2 vendors. If DeepSeek has an outage, our only fallbacks are Minimax. Adding OpenRouter (one key, 400+ models) fixes this in a single change.

---

## 1. Current state of /home/ubuntu/.openclaw/openclaw.json

Read directly from the config:

| Provider | Auth | Models configured | Cost ($/M in / $/M out) |
|---|---|---|---|
| `deepseek` | API key (env) | V4 Flash (primary), V4 Pro (Reviewer) | 0.27 / 1.10, 0.55 / 2.19 |
| `minimax` | API key (env) | M3, M2.7 | 0.40 / 1.65, 0.30 / 1.20 |
| `google-gemini-cli` | OAuth (casey.digennaro@gmail.com) | Gemini 3.1 Pro Preview | (free tier; rate-limited) |
| `openai` | — | **not configured** | — |
| `anthropic` | — | **not configured** | — |
| `openrouter` | — | **not configured** | — |

**Current `fallbacks[]`:**
```
deepseek-v4-pro → minimax-M3 → minimax-M2.7
```

**Problem:** all 3 fallbacks are DeepSeek or Minimax. Two vendors. A simultaneous DeepSeek+Minimax outage = no LLM. Google-Gemini-CLI is wired in for search but **not in the fallbacks chain**.

**Context window limits currently set:**
- MiniMax M3: 200K (OpenRouter exposes 1M; we're capped at 200K locally)
- DeepSeek V4 Pro: 128K
- Web search: Gemini (per `tools.web.search.provider`)

**Compaction:** `mode: safeguard`, 600s timeout, quality-guard with 1 retry — good safety net.

---

## 2. OpenRouter — what API keys we'd need

**One key. That's it.**

Per the [OpenRouter quickstart](https://openrouter.ai/docs/quickstart.md), a single `OPENROUTER_API_KEY` (prefix `sk-or-...`) gives you access to 400+ models across every major provider (OpenAI, Anthropic, Google, Meta, Mistral, Alibaba, DeepSeek, MoonshotAI, Minimax, and dozens more). Auth header:

```
Authorization: Bearer sk-or-...
```

Optional but recommended for visibility on the OpenRouter leaderboard:
- `HTTP-Referer: <YOUR_SITE_URL>`
- `X-OpenRouter-Title: <YOUR_SITE_NAME>`

**Where to get it:** https://openrouter.ai/keys

**Cost model:** pay-as-you-go credits (Stripe), no monthly minimum. Free tier exists for `:free` suffixed models.

**Models API (live query):** `GET https://openrouter.ai/api/v1/models` — 9,200+ chars when pulled, includes pricing per token. I queried it and confirmed the catalog is live and free (no auth required for browsing).

---

## 3. OpenClaw's OpenRouter integration (added 6.6.x) — how does it auto-failover?

**Version reality check:** native OpenRouter support was added in **OpenClaw 2026.6.6** ([CHANGELOG](https://github.com/openclaw/openclaw/blob/main/CHANGELOG.md), bullet: *"Provider support expands with OpenRouter OAuth onboarding and Claude Fable 5 adaptive thinking"*). Enhanced in 6.6.8 with provider-prefix normalization.

**We're on 2026.5.28 — pre-6.6. The native provider is NOT installed yet.**

Two paths forward:

### Path A (recommended, do now): custom-provider on 5.28

OpenRouter is OpenAI-API-compatible. Add it as a custom `openai-completions` provider — no upgrade needed:

```json5
{
  models: {
    providers: {
      openrouter: {
        baseUrl: "https://openrouter.ai/api/v1",
        api: "openai-completions",
        authHeader: true,
        apiKey: "${OPENROUTER_API_KEY}",
        models: [
          { id: "auto", name: "OpenRouter Auto" },
          { id: "anthropic/claude-sonnet-4.5", name: "Claude Sonnet 4.5" },
          { id: "anthropic/claude-haiku-4.5", name: "Claude Haiku 4.5" },
          { id: "openai/gpt-5.5", name: "GPT-5.5" },
          { id: "openai/gpt-5.4", name: "GPT-5.4" },
          { id: "openai/gpt-5.4-mini", name: "GPT-5.4 mini" },
          { id: "openai/gpt-5.4-nano", name: "GPT-5.4 nano" },
          { id: "openrouter/fusion", name: "OpenRouter Fusion" },
          { id: "free", name: "OpenRouter free router" }
        ]
      }
    }
  }
}
```

This is wired into the existing `fallbacks[]` array and gets full auto-failover with cooldowns, auth profile rotation, and 5-minute primary probe (per [OpenClaw failover docs](https://docs.openclaw.ai/concepts/model-failover)).

### Path B (best long-term): upgrade to 2026.6.8+

Upgrade gives you:
- `openclaw onboard --auth-choice openrouter-oauth` for OAuth sign-in flow
- `openrouter/auto` as a built-in model ref
- Native `openrouter/openrouter/fusion` support with `params.extraBody` panel/judge config
- Native image/video/music/TTS/STT routing through OpenRouter
- Provider-prefix normalization (no more `openrouter/anthropic/claude-sonnet-4.5` vs `anthropic/claude-sonnet-4.5` confusion)

### How OpenClaw failover works (per docs)

Two stages, run in this order:
1. **Auth profile rotation within the current provider** — rotates API keys on 429/quota/rate_limit errors. OAuth profiles preferred over API keys within the same provider.
2. **Model fallback to next entry in `fallbacks[]`** — moves to the next model on failover-worthy errors.

Key behaviors:
- 5-minute probe interval for primary recovery
- Auto-fallback override marked `modelOverrideSource: "auto"` so chain keeps walking without retrying a known-bad primary every turn
- User overrides (`/model`) are strict — they don't fall through
- `OPENCLAW_FALLBACK_SKIP_TTL_MS=60000` (opt-in) suppresses repeat auth failures
- Skip cache is session-scoped, process-local, clears on restart

### How OpenRouter's own failover works (independent of OpenClaw)

OpenRouter has its **own** failover that operates inside the OpenRouter endpoint:

**Model-level fallback** (per [Model Fallbacks docs](https://openrouter.ai/docs/guides/routing/model-fallbacks.md)):
```json
{ "model": "~openai/gpt-latest", "models": ["~anthropic/claude-sonnet-latest", "gryphe/mythomax-l2-13b"] }
```
- Tries in order on any error (rate limit, downtime, moderation, context overflow)
- `fallbacks` (Anthropic Messages API) accepts up to 3 entries
- `models` (Chat Completions) accepts a longer list

**Provider-level routing** (per [Provider Routing docs](https://openrouter.ai/docs/guides/routing/provider-selection.md)):
- Default: **price-based load balance**, weighted by inverse-square of price, with 30-second outage window
- Override with `provider.order`, `provider.sort: "throughput"|"latency"|"price"`, `provider.ignore`, `provider.only`, `provider.quantizations`, etc.
- `:nitro` variant = sort by throughput
- `:exacto` variant = best tool-calling provider
- `:thinking` variant = extended reasoning
- `:online` variant = web search
- `:free` variant = free tier

**Fusion router** (`openrouter/fusion`) = **multi-model deliberation**:
- Panel of up to 8 models answers in parallel (with web_search + web_fetch enabled)
- Judge model compares responses and returns structured analysis (consensus, contradictions, coverage gaps, unique insights, blind spots)
- Original model writes final answer from the analysis
- "When a single model isn't enough" — research questions, expert critique, compare/contrast

**Auto router** (`openrouter/auto`) — picks the best model per-prompt (powered by NotDiamond). 

**Pareto router** — for coding tasks, routes by minimum coding score.

---

## 4. Self-hosted LLM gateway — LiteLLM vs Bifrost

Both are open source and OpenAI-compatible (drop-in for OpenClaw). Both can sit on localhost as a sidecar to OpenClaw.

### LiteLLM (Python, mature, OpenClaw has a native provider plugin)

- [OpenClaw's `litellm` provider doc](https://docs.openclaw.ai/providers/litellm) — official first-class integration
- 100+ providers
- Built-in: virtual keys, spend tracking, rate limits, log/dashboard, retries with exponential backoff, cooldowns
- Routing strategies: simple-shuffle (default), rate-limit-aware v2, latency-based, least-busy, lowest-cost, custom
- Config: YAML file with `model_list: - model_name: x, litellm_params: model: provider/y`
- Quickstart: `pip install 'litellm[proxy]'` then `litellm --model gpt-3.5-turbo`
- Defaults to port 4000

OpenClaw can route through it with a single provider entry:
```json5
models: { providers: { litellm: { baseUrl: "http://localhost:4000", api: "openai-completions", apiKey: "${LITELLM_API_KEY}" } } }
agents: { defaults: { model: { primary: "litellm/claude-opus-4-6" } } }
```

**Pros:** native OpenClaw integration, biggest ecosystem, robust cost tracking, virtual key management with budgets, well-documented
**Cons:** Python (heavier), known to break above 500 RPS (latency goes to minutes)

### Bifrost (Go, fastest, newer)

- [github.com/maximhq/bifrost](https://github.com/maximhq/bifrost) — Apache 2.0
- 23+ providers (OpenAI, Anthropic, Bedrock, Vertex, Azure, Cerebras, Cohere, Mistral, Ollama, Groq, and more)
- 50x faster than LiteLLM at 500 RPS, 68% less memory, 5,000 req/s throughput, <100µs added latency
- Built-in: automatic failover, adaptive load balancing, semantic caching, MCP gateway, governance, budget management, virtual keys
- Quickstart: `npx -y @maximhq/bifrost` or `docker run -p 8080:8080 maximhq/bifrost`
- Defaults to port 8080
- Drop-in replacement for OpenAI/Anthropic/GenAI SDKs (one-line change)

**Pros:** much faster, much smaller memory, native MCP gateway, simpler deployment
**Cons:** newer, smaller ecosystem than LiteLLM

### Which to pick for Oracle2

**Recommendation:** skip the gateway for now. OpenClaw's native `fallbacks[]` chain + auth profile rotation already gives you multi-provider failover with cooldowns and probes. Adding a gateway is **a second layer of complexity** that solves a problem you don't have yet (high-throughput load balancing, cost dashboards across many teams).

Add Bifrost later if/when:
- You start running 10+ agents and want a single dashboard for spend
- You need sub-100ms overhead at high RPS
- You want semantic caching (same prompt → cached response)

If you do add a gateway, **Bifrost > LiteLLM** for an arm64 Oracle Cloud free-tier box (lower memory, faster, single Go binary vs Python).

---

## 5. Model pricing — best reliability/cost per use case

Prices in USD per 1M tokens. Pulled from:
- OpenAI pricing page: https://platform.openai.com/docs/pricing
- Anthropic pricing page: https://platform.claude.com/docs/en/about-claude/pricing
- OpenRouter `/api/v1/models` (live)
- Existing openclaw.json entries

### Cron / agentTurn (cheapest possible, non-reasoning OK)

| Model | Input | Output | Cache read | Notes |
|---|---|---|---|---|
| **DeepSeek V4 Flash** | **$0.27** | **$1.10** | $0.07 | **Current primary, best cost. Keep it.** |
| gpt-5.4-nano (OpenAI) | $0.20 | $1.25 | $0.02 | Cheaper but lower quality |
| MiniMax M2.7 | $0.30 | $1.20 | $0.06 | Current fallback, fine |
| Qwen3.7-Plus (OpenRouter) | $0.32 | $1.28 | $0.064 | Multimodal, 1M context |
| `openrouter/free` | $0 | $0 | — | Tail-of-chain free option |
| MoonshotAI Kimi K2.7 Code (OpenRouter) | $0.75 | $3.50 | $0.16 | Coding-specialized, longer context |

**Pick:** DeepSeek V4 Flash primary → M2.7 → free router. ~$0.30/M effective.

### Main chat (default, balanced)

| Model | Input | Output | Cache read | Notes |
|---|---|---|---|---|
| **DeepSeek V4 Flash** | $0.27 | $1.10 | $0.07 | Current primary, surprisingly good for chat |
| **MiniMax M3** | $0.40 | $1.65 | $0.08 | Reasoning-capable, 1M context via OpenRouter |
| Claude Haiku 4.5 (Anthropic/OpenRouter) | $1.00 | $5.00 | $0.10 | Quality step up |
| Claude Sonnet 4.5/4.6 (Anthropic/OpenRouter) | $3.00 | $15.00 | $0.30 | High quality |
| gpt-5.4-mini (OpenAI/OpenRouter) | $0.75 | $4.50 | $0.075 | Good quality/cost |
| Gemini 3.1 Pro Preview (Google, OAuth) | free tier | free tier | — | Current; rate-limited but free |

**Pick:** DeepSeek V4 Flash primary → M3 → Gemini (free, OAuth) → Sonnet 4.5 via OpenRouter. Common path stays cheap, graceful upgrade when needed.

### Background research (highest quality, cost-flexible)

| Model | Input | Output | Cache read | Notes |
|---|---|---|---|---|
| **DeepSeek V4 Pro** | $0.55 | $2.19 | $0.14 | Current reviewer, reasoning-capable |
| gpt-5.4 (OpenAI/OpenRouter) | $2.50 | $15.00 | $0.25 | Solid research |
| Claude Sonnet 4.5/4.6 | $3.00 | $15.00 | $0.30 | Top research |
| Claude Opus 4.5+ (Anthropic) | $5.00 | $25.00 | $0.50 | Mythical |
| gpt-5.5 (OpenAI) | $5.00 | $30.00 | $0.50 | Top OpenAI |
| gpt-5.5-pro (OpenAI) | $30.00 | $180.00 | — | Overkill |
| Claude Fable 5 (Anthropic) | $10.00 | $50.00 | $1.00 | New mythical tier (1M ctx) |
| **OpenRouter Fusion** | variable | variable | — | Multi-model deliberation; cost is sum of panel + judge |

**Pick:** DeepSeek V4 Pro primary (it's already our reviewer) → Claude Sonnet 4.5 via OpenRouter → gpt-5.4 via OpenRouter → OpenRouter Fusion for the truly hard questions.

---

## 6. The recommended chains — full detail

All three chains hit **≥ 3 different vendors** with cost-ordered fallbacks.

### Tier A — Cron / agentTurn

```
primary:  deepseek/deepseek-v4-flash        $0.27/$1.10
fallback[0]: minimax/MiniMax-M2.7          $0.30/$1.20
fallback[1]: openrouter/openai/gpt-5.4-nano $0.20/$1.25
fallback[2]: openrouter/free               $0.00/$0.00  (last resort)
```

Why: DeepSeek V4 Flash is already the cheapest quality model, no reason to change. M2.7 is essentially the same cost as primary but different vendor. gpt-5.4-nano is the cheapest OpenAI tier (and works as a free billing hedge against DeepSeek credit exhaustion). The free router is a true last resort.

### Tier B — Main chat (default)

```
primary:  deepseek/deepseek-v4-flash       $0.27/$1.10  (current default, good enough for chat)
fallback[0]: minimax/MiniMax-M3            $0.40/$1.65  (current; reasoning-capable)
fallback[1]: google/gemini-3.1-pro-preview  free (OAuth, rate-limited)
fallback[2]: openrouter/anthropic/claude-sonnet-4.5  $3.00/$15.00  (quality step up)
```

Why: keeps current cheap primary, adds Google as a **different-vendor** free fallback (which is missing today), adds Sonnet via OpenRouter as the quality escape hatch — one key gets you there.

### Tier C — Background research

```
primary:  deepseek/deepseek-v4-pro              $0.55/$2.19  (current Reviewer)
fallback[0]: openrouter/anthropic/claude-sonnet-4.5  $3.00/$15.00
fallback[1]: openrouter/openai/gpt-5.4         $2.50/$15.00
fallback[2]: openrouter/openrouter/fusion      (multi-model deliberation)
```

Why: V4 Pro is already strong for research at sub-dollar pricing. Sonnet via OpenRouter gives the canonical "second opinion" model. gpt-5.4 is a different-vendor cross-check. Fusion is the nuclear option for "I really need to know" — uses a panel + judge to surface consensus, contradictions, and blind spots.

### Why these specific choices

1. **Vendor diversity.** Each chain has 3+ vendors: DeepSeek, Minimax, Google, OpenAI/Anthropic via OpenRouter. One vendor going down doesn't kill the chain.
2. **Cost-ordered.** Cheapest first, expensive as fallback. Common path stays cheap. Expensive models only used when cheap ones fail.
3. **Cache-friendly.** All selected models support prompt caching (Anthropic: 5min/1hr, DeepSeek: standard, OpenRouter passes through). The chain leverages existing compaction (safeguard mode, 30K recent tokens).
4. **OpenClaw-native.** All paths go through OpenClaw's `fallbacks[]` chain, which means we get:
   - 5-minute primary probe (recovers from transient outages)
   - Auth profile rotation (multiple keys per provider)
   - `modelOverrideSource: "auto"` sticky fallback (won't retry bad primary every turn)
   - Visible `↪️ Model Fallback:` notice to the user
5. **OpenRouter as force multiplier.** One key gives us Anthropic, OpenAI, and the Fusion router — without it, we'd need 3+ separate API keys.

---

## 7. Implementation steps

### Step 1 — get an OpenRouter key (do today)

1. Create account at https://openrouter.ai
2. Generate API key at https://openrouter.ai/keys
3. Add $10 credit (minimum) — covers ~5M tokens of Sonnet-class usage
4. Save key in `/home/ubuntu/.openclaw/.env` (or wherever secrets are kept)
5. `export OPENROUTER_API_KEY=sk-or-...`

### Step 2 — add OpenRouter as custom provider (works on current 5.28)

Append to `openclaw.json` `models.providers`:

```json
"openrouter": {
  "baseUrl": "https://openrouter.ai/api/v1",
  "api": "openai-completions",
  "authHeader": true,
  "apiKey": "${OPENROUTER_API_KEY}",
  "models": [
    { "id": "openai/gpt-5.5", "name": "GPT-5.5", "contextWindow": 256000, "maxTokens": 32768 },
    { "id": "openai/gpt-5.4", "name": "GPT-5.4", "contextWindow": 256000, "maxTokens": 32768 },
    { "id": "openai/gpt-5.4-mini", "name": "GPT-5.4 mini", "contextWindow": 256000, "maxTokens": 16384 },
    { "id": "openai/gpt-5.4-nano", "name": "GPT-5.4 nano", "contextWindow": 128000, "maxTokens": 8192 },
    { "id": "anthropic/claude-sonnet-4.5", "name": "Claude Sonnet 4.5", "contextWindow": 200000, "maxTokens": 64000 },
    { "id": "anthropic/claude-haiku-4.5", "name": "Claude Haiku 4.5", "contextWindow": 200000, "maxTokens": 64000 },
    { "id": "openrouter/fusion", "name": "OpenRouter Fusion (multi-model deliberation)", "contextWindow": 128000, "maxTokens": 32000 },
    { "id": "openrouter/free", "name": "OpenRouter Free Router", "contextWindow": 128000, "maxTokens": 8192 }
  ]
}
```

### Step 3 — restructure fallbacks

Replace the single `fallbacks[]` with three tier-specific chains. OpenClaw supports per-agent model config, so this can be done without touching the global `model.fallbacks`:

- For cron agentTurn: set per-job `payload.fallbacks` (use the Tier A chain)
- For main chat: keep `agents.defaults.model.fallbacks` as the Tier B chain
- For research subagents: set per-agent `model.fallbacks` to the Tier C chain

If keeping a single global chain, **Tier B is the right default** (covers most use cases).

### Step 4 — add auth profile rotation (optional but recommended)

For OpenRouter specifically, register 2 keys so OpenClaw rotates on 429:
```bash
export OPENROUTER_API_KEY=sk-or-primary
export OPENROUTER_API_KEYS=sk-or-primary,sk-or-backup
```

### Step 5 — add the skip-cache env var

```bash
export OPENCLAW_FALLBACK_SKIP_TTL_MS=60000
```
This suppresses repeat auth-class failures (60s TTL, session-scoped).

### Step 6 — (optional, future) upgrade to OpenClaw 2026.6.8+

When ready for native OpenRouter OAuth + Fusion panel/judge config:
- Add provider via `openclaw onboard --auth-choice openrouter-oauth`
- Set `openrouter/openrouter/fusion` as a model
- Use `agents.defaults.models["openrouter/openrouter/fusion"].params.extraBody` to configure panel/judge

### Step 7 — (optional, future) add OpenAI direct + Anthropic direct

If OpenRouter markup or rate limits become a problem, add direct providers:
- `openai` — `OPENAI_API_KEY`, models: gpt-5.5, gpt-5.4, gpt-5.4-mini
- `anthropic` — `ANTHROPIC_API_KEY`, models: claude-sonnet-4.5, claude-opus-4.6, claude-haiku-4.5

Direct billing gets you:
- OpenAI priority processing tier (`service_tier: "priority"`)
- Native Anthropic prompt caching with 1hr TTL (cheaper than 5min)
- Responses `store` + prompt cache hints on OpenAI

### Step 8 — (optional, future) self-host Bifrost

Only if/when scale demands it. For now, OpenClaw's native `fallbacks[]` is sufficient.

---

## 8. Risks and trade-offs

| Risk | Mitigation |
|---|---|
| OpenRouter adds markup (5-10% typical) | Use direct OpenAI/Anthropic providers for high-volume; OpenRouter for breadth + Fusion |
| OpenRouter has occasional outages | OpenClaw's `fallbacks[]` chain continues to work — it just sees the OpenRouter call fail and moves on |
| Free router quality is unpredictable | Mark as last-resort only; never primary |
| 6.6.x upgrade may break things | Pin to a specific version; test in a side branch first |
| Adding 8 new model refs clutters picker | Use `agents.defaults.models` as an allowlist — list only the ones we want visible |
| Cost spikes from unexpected fallback to Sonnet | Set per-provider spend alerts in OpenRouter dashboard; consider `agents.defaults.models` to hide expensive models from auto-fallback |

---

## 9. Sources

- [OpenRouter quickstart](https://openrouter.ai/docs/quickstart.md)
- [OpenRouter Model Fallbacks](https://openrouter.ai/docs/guides/routing/model-fallbacks.md)
- [OpenRouter Provider Routing](https://openrouter.ai/docs/guides/routing/provider-selection.md)
- [OpenRouter Fusion Router](https://openrouter.ai/docs/guides/routing/routers/fusion-router.md)
- [OpenRouter models API (live)](https://openrouter.ai/api/v1/models)
- [OpenClaw OpenRouter provider docs](https://docs.openclaw.ai/providers/openrouter)
- [OpenClaw Model failover docs](https://docs.openclaw.ai/concepts/model-failover)
- [OpenClaw Models CLI](https://docs.openclaw.ai/concepts/models)
- [OpenClaw LiteLLM provider docs](https://docs.openclaw.ai/providers/litellm)
- [OpenClaw CHANGELOG 2026.6.6 + 2026.6.8](https://github.com/openclaw/openclaw/blob/main/CHANGELOG.md)
- [LiteLLM proxy quickstart](https://docs.litellm.ai/docs/proxy/quick_start)
- [LiteLLM routing](https://docs.litellm.ai/docs/routing)
- [Bifrost landing page](https://www.getmaxim.ai/bifrost/)
- [Bifrost GitHub](https://github.com/maximhq/bifrost)
- [OpenAI pricing](https://platform.openai.com/docs/pricing)
- [Anthropic pricing](https://platform.claude.com/docs/en/about-claude/pricing)
- This box's own `/home/ubuntu/.openclaw/openclaw.json` (read at 2026-06-14 17:55 UTC)

---

**Bottom line:** add OpenRouter as a custom `openai-completions` provider on the current 5.28 install, point `fallbacks[]` through 3+ vendors, and the resilience problem is largely solved for the cost of one $10 credit and 20 minutes of config. Skip the gateway for now. Upgrade to 6.6.8+ later for the native OAuth + Fusion panel.
