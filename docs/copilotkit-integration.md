# Fleet Copilot — CopilotKit Integration Guide

> **SuperInstance Fleet Operations Center** — AI-powered assistant powered by CopilotKit + DeepSeek V4 Flash

## Overview

The Fleet Copilot is a web-based operations assistant that provides AI-driven observability into the SuperInstance Fleet. It combines:

- **CopilotKit** — React framework for building AI copilot interfaces
- **DeepSeek V4 Flash** (via DeepInfra) — LLM backend with tool-calling
- **Cloudflare Pages** — Edge deployment with serverless API routes
- **Custom Fleet tools** — Runtime observability for all Fleet subsystems

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  Browser                         │
│  ┌──────────────┐         ┌──────────────────┐  │
│  │   Sidebar     │         │   Chat Interface  │  │
│  │  - Status    │         │  - Messages       │  │
│  │  - Metrics   │         │  - Quick Actions  │  │
│  │  - API info  │         │  - Input          │  │
│  └──────────────┘         └────────┬─────────┘  │
└────────────────────────────────────┼────────────┘
                                     │ POST /api/copilotkit
                                     ▼
┌─────────────────────────────────────────────────┐
│         Next.js API Route (edge runtime)         │
│  ┌──────────────────────────────────────────┐    │
│  │         SuperInstance Agent               │    │
│  │  ┌──────────┐  ┌──────────┐  ┌───────┐  │    │
│  │  │ System   │  │ LLM Call │  │ Tool  │  │    │
│  │  │ Prompt   │  │ (DeepInf │  │ Exec  │  │    │
│  │  └──────────┘  └──────────┘  └───────┘  │    │
│  └──────────────────────────────────────────┘    │
└──────────────┬───────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│         DeepInfra API (OpenAI-compatible)        │
│         Model: deepseek-ai/DeepSeek-V4-Flash     │
└─────────────────────────────────────────────────┘
```

### Key Components

| Component | Path | Description |
|-----------|------|-------------|
| Chat UI | `src/app/page.tsx` | Main chat interface with sidebar, status indicators, quick actions |
| Layout | `src/app/layout.tsx` | Root layout with dark fleet theme |
| Styles | `src/app/globals.css` | Fleet CSS theme with CopilotKit overrides |
| API Route | `src/app/api/copilotkit/route.ts` | Edge runtime endpoint for CopilotKit |
| Agent | `src/lib/superinstance-agent.ts` | Custom agent with tool-calling LLM loop |
| Tools | `src/lib/tools.ts` | Fleet observability tools |

## Fleet Subsystems

The agent has knowledge of these systems:

| System | Description | Tool |
|--------|-------------|------|
| **Nebula Cloud** | Multi-region orchestration layer (v2.4.1) | `nebula_status` |
| **VoxelWorks** | GPU compute clusters (forge-alpha/beta/gamma) | `voxelworks_health` |
| **CraftMind AI** | DeepSeek inference layer | — (integrated) |
| **Cognitive Compiler** | Ternary logic compute graph compiler (v0.9.2) | — (doc searchable) |
| **Ternary Crates** | Distributed package registry (148 crates) | `fleet_docs` |
| **System Info** | Aggregate fleet health summary | `system_info` |

### Available Tools

| Tool | Parameters | Description |
|------|-----------|-------------|
| `nebula_status` | None | Nebula cloud status, pods, latency, version |
| `voxelworks_health` | `cluster` (optional, enum) | GPU utilization, job queue, cluster health |
| `fleet_docs` | `query` (required, string) | Fleet knowledge base search |
| `system_info` | `detailed` (optional, boolean) | Full fleet status summary |

## Configuration

### Required Environment Variables

```bash
# DeepInfra API key (required)
DEEPINFRA_API_KEY=sk-your-deepinfra-api-key-here

# Optional overrides
FLEET_MODEL=deepseek-ai/DeepSeek-V4-Flash
DEEPINFRA_BASE_URL=https://api.deepinfra.com/v1/openai
```

### Cloudflare Secrets

```bash
npx wrangler pages secret put DEEPINFRA_API_KEY
```

## Local Development

```bash
# 1. Clone and install
cd fleet-copilot
cp .env.local.example .env.local
# Edit .env.local with your DeepInfra API key

# 2. Install dependencies
npm install

# 3. Run development server
npm run dev
# → http://localhost:3000

# 4. Build for production
npm run build
```

## Deployment

### Cloudflare Pages

```bash
# 1. Build with next-on-pages
npx @cloudflare/next-on-pages

# 2. Deploy
npx wrangler pages deploy .vercel/output/static --project-name=fleet-copilot --branch=main

# 3. Set secrets
npx wrangler pages secret put DEEPINFRA_API_KEY
```

**Note:** You must be authenticated with `wrangler login` or have a `CLOUDFLARE_API_TOKEN` set.

## Extending with New Tools

To add a new Fleet tool:

1. **Define the tool** in `src/lib/tools.ts`:

```typescript
const myNewTool: ToolDefinition = {
  name: 'my_new_tool',
  description: 'Description of what this tool does',
  parameters: [
    {
      name: 'param',
      type: 'string',
      description: 'Parameter description',
      required: false,
    },
  ],
  execute: async (args) => {
    // Your tool logic here
    return {
      success: true,
      data: { result: 'ok' },
      formatted: '**Result:** Everything looks good!',
    };
  },
};
```

2. **Register** in the `tools` array:

```typescript
export const tools: ToolDefinition[] = [
  nebulaStatus,
  voxelworksHealth,
  fleetDocs,
  systemInfo,
  myNewTool,  // ← add here
];
```

3. **Update the system prompt** in `src/lib/superinstance-agent.ts` to describe the new capability.

That's it — the agent will automatically discover the new tool through the OpenAI-compatible tool definitions sent with each LLM call.

## File Structure

```
fleet-copilot/
├── package.json              # Dependencies and scripts
├── next.config.ts            # Next.js configuration
├── tsconfig.json             # TypeScript configuration
├── tailwind.config.ts        # Tailwind theme (fleet colors)
├── postcss.config.mjs        # PostCSS configuration
├── wrangler.toml             # Cloudflare Pages config
├── .env.local.example        # Example environment variables
└── src/
    ├── app/
    │   ├── layout.tsx        # Root layout
    │   ├── page.tsx          # Chat page with sidebar + UI
    │   ├── globals.css       # Fleet theme + CopilotKit styles
    │   └── api/
    │       └── copilotkit/
    │           └── route.ts  # Edge runtime API endpoint
    └── lib/
        ├── superinstance-agent.ts  # Custom CopilotKit agent
        └── tools.ts               # Fleet tool definitions
```
