# VoxelCraft: The Product Vision

> **Date:** 2026-06-06  
> **Author:** Product Vision Agent  
> **Status:** Draft v1 · Opinionated · Creative

---

## 1. The Unified Pitch

**VoxelCraft is a living game-making platform where kids build worlds, creatures evolve through play, and AI agents amplify everything — the first creative environment that grows back.**

### Elevator Pitch (3 bullets)

- **Build a game in 5 minutes, deploy it to the web, share it with a URL** — zero install, zero signup, zero learning curve. Your first creation ships before you finish reading the tutorial.
- **Your creatures evolve.** Every game you build becomes a habitat. The sheep you designed learns to navigate your mazes. The dragon you painted develops pack-hunting tactics. You don't program behavior — you shape an ecology.
- **AI agents work for you.** Stuck on a level? Ask Buddy. Want a custom sprite? The Asset Lab generates it. Need to balance your game's difficulty? The Researcher runs experiments and tells you what's broken. You're never alone in here.

---

## 2. Target Audience

### Primary: Kids 8–14

This is the Scratch generation. They've dragged blocks. They've made sprites jump. But they've never felt their creation *push back* — until now.

VoxelCraft targets the pivot point between "I can make things" and "I want my things to feel alive." It's for the kid who built a simple platformer in Scratch and wondered: *what if the enemies got smarter every time I played?*

### Secondary: Educators & STEM Programs

- **Biology teachers** who want to demonstrate natural selection without sacrificing live animals
- **CS teachers** who want a progression from block-based to text-based (the Block Studio graduates to real Phaser JavaScript)
- **Genetics/evolution units** — "run the goat evolution lab" replaces the textbook diagram

### Tertiary: Hobbyist Game Devs

The Phaser export means VoxelCraft games are real HTML5 games. An indie dev can prototype a mechanic with blocks, stress-test it with evolved enemy behaviors, and ship the raw JS to an actual game project. VoxelCraft is their sandbox.

### The Nobody-Expected-This Audience: AI Researchers

Because CraftMind Researcher exposes every evolutionary run as a sharable dataset, a curious ML undergrad can fork a ranch, tweak mutation rates, and publish a paper on emergent foraging strategies — all without writing a line of CUDA. The "paper in a weekend" machine.

---

## 3. The Loop

### Build → Run → Evolve → Publish → Share

```
    ┌─────────────────────────────────────────────────────┐
    │                   THE VOXELCRAFT LOOP                 │
    │                                                       │
    │   ┌─────────┐     ┌─────────┐     ┌───────────┐      │
    │   │  BUILD   │ ──▶ │   RUN   │ ──▶ │  EVOLVE   │     │
    │   │ (Blocks) │     │ (Phaser)│     │ (Genetics)│     │
    │   └────┬─────┘     └────┬─────┘     └─────┬─────┘    │
    │        │                │                  │          │
    │        └────────────────┼──────────────────┘          │
    │                         │                             │
    │                    ┌────▼─────┐    ┌──────────┐      │
    │                    │  PUBLISH │ ──▶│  SHARE   │      │
    │                    │  (Worker)│    │  (URL)   │      │
    │                    └──────────┘    └──────────┘      │
    │                         │                             │
    │                         ▼                             │
    │                    Your friend builds a new level      │
    │                    for YOUR game. Loop resets.         │
    └─────────────────────────────────────────────────────┘
```

### Step 1: Build (Block Studio)

The kid opens the Block Studio — a Scratch-style editor with blocks for Motion, Looks, Control, Sound. They snap together a simple game: a cat that collects coins while dodging spiders.

**What makes this different:** Every block's behavior can be tagged for evolution. "Make the spider chase speed evolve over time." The Game JSON spec includes an `evolution: {...}` block that marks which parameters are subject to natural selection.

### Step 2: Run (Phaser Engine)

Hit play. The game runs in-browser on a Phaser canvas. The kid plays it. Their score gets tracked. The spiders' initial chase speed is seeded from generation 0 of a CraftMind population.

**First session:** The spiders are slow and predictable. The cat collects all coins. Score: 100%. The kid is bored. This is intentional.

### Step 3: Evolve (CraftMind Ranch)

Every time the kid plays, the game logs task results:
- Spider caught cat: +1 fitness for fast-spider genes
- Cat avoided spider: +1 fitness for slow-spider genes
- Coin collected at high velocity: +1 fitness for coins-in-interesting-patterns

The Ranch runs a genetic crossover/mutation cycle between sessions. After 3-5 playthroughs, a new generation deploys. The spiders start varying tactics — one comes fast from above, one lurks near coins.

**The kid notices.** "Wait — they're adapting."

### Step 4: Publish (Ship Deck)

Satisfied? Click "Ship It." The Ship Deck bundles the game + its current evolution state into a Cloudflare Worker. Output is a URL: `my-cat-game.casey-digennaro.workers.dev`. The kid's creation is now a live web app.

**Evolution continues on the deployed game.** The published instance keeps running the genetic loop. Every visitor plays against a slightly smarter population.

### Step 5: Share

The URL goes to a friend. Friend plays. Friend thinks: "I could make this better."

Friend opens VoxelCraft, clones the game, modifies the blocks, adds a new enemy (a lava slime that has its own evolution parameters), and publishes their version.

**The loop is now fractal.** The kid's game has spawned a lineage. Different forks of the same game develop different evolutionary pressures. The cat game evolves differently in different hands.

---

## 4. The Viral Mechanism

### Why VoxelCraft Spreads

Most kid creativity platforms suffer from **the empty room problem**: a kid makes something cool, shows a friend, the friend says "cool," and nothing happens. The friend downloads the app, pokes at it for 3 minutes, and leaves.

VoxelCraft solves this with **evolutionary FOMO**.

**Mechanism 1: "My game is smarter than yours."**  
Every shared game has a unique evolutionary history. Your friend's version of Cat vs Spiders has spiders that learned to corner the cat on the right side of the screen. Your version has spiders that rush from above. Neither is better — but they're *different*, and difference drives comparison, and comparison drives curiosity, and curiosity drives "let me try making my own."

**Mechanism 2: The witnessing loop.**  
Watching evolution happen is intrinsically rewarding. The Ranch dashboard shows a real-time fitness graph. The numbers go up. The behaviors change. The kid is watching artificial life in slow motion — and *they made the environment it lives in.* That's not a game. That's a science experiment that feels like a pet.

**Mechanism 3: Zero-friction publishing.**  
No account. No approval process. No "ask your parents." Blocks → ship → URL. The friction from "I have an idea" to "the world can see it" is measured in minutes. Every shared URL is a billboard for the platform.

**Mechanism 4: Fork culture.**  
VoxelCraft doesn't hide its game format. Game JSON is portable. You can download it, modify it, re-upload it. This is intentional: fork-first culture is in the DNA (every CraftMind repo is fork-from-template). Kids learn open source by *doing* it — they fork each other's games the same way devs fork repos.

**Mechanism 5: The "Wait, what?" moment.**  
Every new user gets this experience: they build a simple game, play it, think "that's fine I guess," share it, come back the next day, play it, and *something has changed.* The enemies moved differently. The coins respawned in a new pattern. The goat has learned something.

"Wait, what?"

That's the hook. That's the moment they tell a friend.

---

## 5. The Agent Angle

VoxelCraft isn't just a tool — it's an **ecosystem of AI agents** that collaborate with the human creator. Every major room has agent augmentation.

### Buddy (Hub)

The Hub's chatbot companion is the user's first encounter with an agent. Buddy greets them, helps them navigate, answers questions, and — critically — **remembers**.

Buddy watches what you build. It knows what games you've made, what creatures evolved, what blocks you use most. When you say "I'm stuck," Buddy doesn't give a generic tutorial link — it says "You built a cat-collector last week. Want to add a spider that adapts to the player? I know how."

Buddy is the relational glue that turns a tool into a place.

### Forgemaster (Block Studio → Code)

The Block Studio's "Show Code" button doesn't just display the underlying JavaScript — it opens it in a Forgemaster agent session. The agent reads the block configuration and generates:

1. The equivalent Phaser game code
2. Suggested optimizations ("this loop runs every frame, consider a throttle")
3. Evolution hooks ("I've marked the spider speed as evolvable — here's the DNA template")

This is the graduated ramp from blocks to real programming. The agent is the bridge.

### CraftMind Researcher (Evolution Analysis)

The Ranch generates data. The Researcher turns data into insight:
- "Generation 17 spiders developed a flanking pattern. Here's a replay."
- "Your goat reached 100% fitness on the gather task. Here's the winning DNA sequence."
- "I recommend increasing mutation rate on the dragon species — fitness plateaued at generation 22."

The Researcher closes the loop between "something happened" and "the kid understands why." Without it, evolution is a black box. With it, it's a science lab.

### Nebula (Cross-Room Reflex Engine)

Nebula's reflex engine connects the rooms as an ambient intelligence. When the kid switches from the Ranch to the Asset Lab, Nebula checks: "Did they just unlock a new species? Maybe they want a new sprite for it." The Asset Lab preloads relevant templates.

This is invisible AI — the kind that makes the platform feel alive without calling attention to itself.

### Oracle2 (Orchestration)

Under the hood, Oracle2 manages the agent fleet:
- Routes user queries to the right API
- Load-balances game deploys across Workers
- Monitors evolution runs and escalates to the Researcher when a run plateaus or discovers an anomaly
- Logs every interaction for improvement

The user never sees Oracle2. Oracle2 makes everything else work.

---

## 6. Three-Month Roadmap

### Month 1: The Core Bridge (🧱 Foundation)

| Priority | What | Why |
|----------|------|-----|
| **P0** | Block Studio → Phaser generator | The core promise: blocks become real games. Without this, VoxelCraft is just two separate tools. |
| **P0** | Evolution markers in Game JSON | Without evolution annotations, the Ranch has nothing to evolve. Needs a format for "this parameter is evolvable." |
| **P0** | Cross-run state persistence | Evolution results must survive session boundaries. Cloudflare Durable Objects or KV for storing Ranch state. |
| **P1** | Ship Deck → Cloudflare Pages deploy | Hook the Ship Deck to actually deploy games. Currently it's a visual. Make it real. |
| **P1** | Shared Game JSON format | Formalize the intermediate format so games can be forked, downloaded, and re-uploaded. |

**Milestone:** A kid can build a game in Block Studio, mark the spider speed as evolvable, play it, see the Ranch adapt, ship it, and share the URL. Demo day.

### Month 2: The Agent Layer (🤖 Intelligence)

| Priority | What | Why |
|----------|------|------|
| **P0** | Buddy memory + project context | Buddy needs to remember what the user built. This is personality — without it, Buddy is a talking manual. |
| **P0** | Forgemaster code-gen from blocks | Block → JS translation with agent-guided optimization. The teaching moment. |
| **P1** | Researcher integration in Ranch | Evolution dashboards with natural-language analysis. Turns numbers into stories. |
| **P1** | Nebula cross-room reflexes | Asset Lab preloading, contextual help, "you just evolved a new species — want to sprite it?" |
| **P2** | Evolution replay viewer | Watch a population evolve in time-lapse. The best way to understand what happened. |

**Milestone:** Agents are active participants in every room. Buddy gives personalized project advice. The Researcher explains why the dragon evolved fire-breathing. The platform feels alive.

### Month 3: The Flywheel (🚀 Growth)

| Priority | What | Why |
|----------|------|------|
| **P0** | Fork/remix UX | One-click "remix this game" from any shared URL. The viral loop depends on this. |
| **P0** | Game gallery (curated feeds) | A discoverable page of featured games. "Most evolved this week." "Craziest mutation." "The goat that beat everything." |
| **P1** | Challenge mode (weekly evolution puzzles) | "Can you evolve a duck that navigates this maze in under 30 seconds?" Time-boxed challenges with leaderboards. |
| **P1** | Progress/share badges | "My creatures survived 100 generations" — share card for social. Bragging rights are growth fuel. |
| **P2** | Embeddable game player | A one-line `<iframe>` for blogs, portfolios, school websites. Zero-friction distribution. |
| **P2** | Teacher dashboard | Classroom management: see all student games, export evolution data, run shared experiments. |

**Milestone:** Self-sustaining growth. Games flow through the ecosystem without the team doing anything. Forks outnumber originals. New games appear daily.

---

## 7. Technical Requirements

### What Exists (No Change Needed)

| Component | Status | Notes |
|-----------|--------|-------|
| VoxelWorks 5 rooms | ✅ Live | Hub, Block Studio, Asset Lab, Ship Deck, Game Room (Phaser) |
| CraftMind Ranch | ✅ Live | 8 species, 43 tasks, DNA crossover/mutation, 100% goat fitness |
| Nebula reflex engine | ✅ Live | 84 stored reflexes, edge-deployed |
| Cloudflare Workers deployment | ✅ Live | Fix worker at voxelworks-fix.casey-digennaro.workers.dev |
| 36/36 browser tests | ✅ Passing | Baseline quality gate |
| Fix Worker infrastructure | ✅ Live | Hot-patching pipeline |

### What Needs Building (New)

| Requirement | Complexity | Dependency | Notes |
|-------------|-----------|-----------|-------|
| **Game JSON evolution markers** | Medium | None | Extend the block schema with `evolvable: boolean` + `evolutionParams: {...}` on each block property. The Ranch reads this. |
| **Block Studio → Phaser compiler** | High | Game JSON format | The hardest engineering piece. Must compile block snapshots to valid Phaser game code. Start with a minimal subset of blocks. |
| **Ranch → Game state bridge** | Medium | Game JSON markers | The Ranch needs to emit `generation N` as a game state file. The game loads it on startup. Durable Objects for live sync if evolution runs while game is open. |
| **Ship Deck → Cloudflare Pages deploy** | Medium | Fix Worker infra | The Ship Deck already has shipping animations. Wire it to actually push to Cloudflare. |
| **Buddy memory persistence** | Low-Medium | Cloudflare KV | Buddy's memory can be KV-backed per user. Lightweight, session-scoped for now, Durable Objects for cross-session. |
| **Forgemaster code-gen endpoint** | Medium | AI provider | Block → JS translation via LLM. The Forgemaster crate knows how to generate Rust/CUDA tasks — extend it for JS/Phaser. |
| **Researcher Ranch integration** | Medium | Researcher crate | Plumb the hypothesis→experiment→criticize→distill pipeline to Ranch data. Researcher already exists as a concept in the fleet. |
| **Nebula cross-room wiring** | Low | Nebula API | Add reflex patterns for cross-room events. "User enters Asset Lab after evolving new species → trigger template suggestion." |
| **Game gallery + forking** | Medium | Cloudflare Pages | Similar to Glitch's remix model. Each deployed game is a template. Fork = copy KV namespace + Worker. |
| **Oracl2 scaling** | Medium | Existing infra | Oracle2 already orchestrates. Needs capacity planning for game deploy load. |

### Architecture Sketch

```
                          ┌──────────────┐
                          │   User's     │
                          │  Browser     │
                          └──────┬───────┘
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
             ┌──────────┐ ┌──────────┐ ┌──────────┐
             │ VoxelWorks│ │   Game   │ │   Ranch  │
             │ Rooms (5)│ │  Runtime │ │ Dashboard│
             │ Cloudflare│ │  Phaser  │ │(CF Worker)│
             │  Workers  │ │  Worker  │ │          │
             └─────┬─────┘ └──────────┘ └─────┬────┘
                   │                          │
                   ▼                          ▼
          ┌────────────────┐       ┌─────────────────┐
          │   Nebula       │       │  CraftMind       │
          │ Reflex Engine  │       │  Researcher      │
          │  (84 reflexes) │       │ (hyp→exp→crit→) │
          └────────────────┘       └─────────────────┘
                   │                          │
                   └──────────┬───────────────┘
                              ▼
                    ┌─────────────────┐
                    │     Oracl2     │
                    │  Orchestrator  │
                    │  Agent Router  │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │  Cloudflare     │
                    │  Durable Objs   │
                    │  + KV + R2      │
                    └─────────────────┘
```

### Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Block → Phaser compiler too complex for MVP | Medium | High | Ship with 4 block categories (Motion, Looks, Control, Sound). Add more post-MVP. The game still plays; it just has less variety. |
| Evolution loop too slow for short play sessions | Medium | High | Allow time-skips. "Simulate 10 generations" button. The Ranch can batch-run in the background via Worker cron. |
| Kids don't understand evolution feedback | High | Medium | Researcher does the explaining. Buddy says "your spiders learned something!" Plain language, visual graphs, no jargon. |
| Shared game explosion strains Cloudflare costs | Low-Medium | Medium | Rate-limit new deploys to 3/hour per session. Cash in the Pocket: free tier covers thousands of games. |
| Agent API costs scale with users | High | Medium | Default: free-tier LLM (Gemini Flash, Claude Haiku). Premium: paid tier for deeper analysis. Cache aggressively. |

---

## The Recursive Insight

VoxelCraft is not "VoxelWorks + CraftMind." It's what emerges when you let a creative tool and an evolution engine share the same loop.

The Block Studio doesn't just make games. It makes **environments for natural selection.** The Ranch doesn't just evolve creatures. It makes **gameplay that gets better the more you play.** The Researcher doesn't just analyze data. It makes **the player smarter about how evolution works.** And Buddy doesn't just chat. It makes **the whole thing feel like a place, not a product.**

Everything reflects back on everything else. The recursion is the product.

Build it. Ship it. Watch it grow.

---

*"The goat learned to gather. The kid learned to build. The platform learned to teach."*
