# Architectural Review: VoxelWorks + CraftMind System Stack

**Reviewer:** Hermes 405B (architectural analysis agent)
**Date:** 2026-06-06
**Scope:** VoxelWorks product vision, VoxelWorks architecture, CraftMind→Fleet integration, Construct Coordination surface, FLEET-SYMMETRY, SiloGap, CRITICAL-REVIEW, ECOSYSTEM-MAP
**License to be opinionated:** Full

---

## 1. Layer Analysis

The system as described spans five distinct architectural layers. Here's what exists and what's missing.

### Layer 1: Edge/Nebula — The Reflex Nervous System

**What it is:** Cloudflare Workers hosting the Nebula reflex engine — a three-path routing system (Fast path ≥0.80 embedding similarity → cached response; Similar path 0.55–0.80 → LLM confirm+adapt; Slow path <0.55 → DeepSeek V4 Flash full reasoning). BGE 384d embeddings. KV-backed. 84 stored reflexes.

**Assessment:** This is the most solidly designed layer in the stack. The three-path routing is elegant and practical. It handles the reality that some queries are cacheable, some need adaptation, and some need full generative reasoning. The ∼709ms / ∼806ms / ∼2.45s latency bands are honest and realistic for edge inference.

**Weakness:** The reflex store (84 reflexes) is small. For a kid-facing product with millions of possible intents, this needs to grow by several orders of magnitude. More critically: there is no reflex *expiration* or *decay* mechanism. Old, rarely-matched reflexes accumulate noise in the embedding space. A reflex garbage collector (evict reflexes with <X matches in N days) needs to exist.

### Layer 2: Build/Crates — The Ternary Math Engine

**What it is:** 200+ Rust crates built around the {-1, 0, +1} ternary type. Rotational/translational/scalable/reductive symmetry groups. `ternary-core` traits, `pincher` runtime, domain crates for ring, matrix, compiler, topology, budget, quorum, percolate, etc.

**Assessment:** The mathematical foundation is ambitious and beautiful. It's also wildly over-engineered for what the product actually needs right now. The CRITICAL-REVIEW document is correct: the Construct API (`Pin<Box<dyn Future>>` on ESP32, heap allocation in `no_std` contexts, `Vec<String>` in `const fn`) is aspirational fantasy, not production architecture. The hardware abstraction tier enum (`Dgx > Workstation > Pi > Tui > Browser > Esp`) with `PartialOrd` is genuinely nonsense — it's a total order imposed on a fundamentally partial-order capability space.

**Weakness:** The crate ecosystem has a 64% "zero cross-links" problem per SiloGap. This is a documentation/organization failure. The symmetry group mapping (Rotational = cycle stability, Translational = shift invariance, etc.) is a beautiful abstraction that no new contributor can navigate without a map. The "Connection Ratio ≥ 3" metric is good governance — actually enforcing it is what matters.

**Verdict:** The ternary math layer is *intellectually* coherent but *practically* disconnected from the product layers above. CraftMind Ranch doesn't use ternary math for its evolution engine. VoxelWorks blocks don't map to ternary operators. The connection between "200 Rust crates doing ring theory" and "a kid making a raccoon ninja game" is currently zero. This is either a deliberate separation of concerns or a sign that the crate ecosystem has drifted into academic territory without a product anchor.

### Layer 3: UI/VoxelWorks — The Kid-Facing Product

**What it is:** Five React rooms (Hub, Build Studio, Asset Lab, Ship Deck, Library), Phaser.js game canvas, Scratch-like block editor, prompt-to-asset pipeline, Buddy chatbot.

**Assessment:** The product vision document is extraordinary. It's genuinely one of the most compelling product visions I've seen for a kids' creative platform. The emotional arc (confidence from 2/10 to 10/10), the Buddy relationship (guide → co-creator → teammate → archive), the viral loops, the monetization that "feels like play" — this is *product thinking at its finest*.

**Weakness:** The architecture is aspirational, not built. The detailed API endpoints (`POST /api/voxel/build`, `GET /api/voxel/status/:build_id`, etc.) describe a system that mostly doesn't exist yet. The 20-60 second build pipeline (Nebula reflex → Claude Code → Asset gen → GitHub → Cloudflare) is a heroic estimate that assumes perfect parallelism, zero LLM queueing, and no failure modes. In practice: Claude Code can take 2-30s for generation, but it also fails, generates broken code, or gets context-window-limited. The status polling model (poll every 1-2 seconds) is fine for demo-day but will need WebSockets or SSE for production.

### Layer 4: Evolution/CraftMind — The Living Systems Engine

**What it is:** 8 craftmind game repos (fishing, studio, courses, researcher, ranch, herding, circuits, discgolf). Ranch with 8 species, 43 tasks, DNA crossover/mutation, 97.7% goat fitness. Evolution loop across generations.

**Assessment:** The ranch actually works — 38 unit tests passing, real evolution runs. This is the closest thing to a shipped product in the entire stack. The porting plan (craftmind→fleet integration architecture document) is thorough and pragmatic: "don't rewrite — wrap" is the right strategy. Every craftmind module keeps core logic; only the integration layer changes.

**Weakness:** The gap between "CraftMind Ranch can evolve a goat to 97.7% fitness on a gather task" and "a kid's spider enemies adapt to the player's play style in a deployed game" is enormous. The evolution loop is currently batch/simulation — it runs generations in sequence. A kid playing a game needs *per-play adaptive evolution*. The Ranch's current DNA model (speed, thoroughness, strength, curious) maps to task-fitness, not gameplay-adaptation. The genes that matter for a platformer (chase speed, patrol patterns, reaction time, spawn locations) are different from the genes that matter for a gather task.

### Layer 5: Deploy/Cloudflare — The Delivery Surface

**What it is:** Cloudflare Workers, Pages, KV, Durable Objects, R2. Fix Worker infrastructure. GitHub API for repo creation.

**Assessment:** The deployment layer is pragmatic and well-chosen. Cloudflare's edge network is the right place for this. The make-me-app pipeline (fork → wrangler deploy → URL) is a proven pattern.

**Weakness:** The product vision requires *each game deployment to be a living thing* — evolution continues post-deploy, every visitor plays against a slightly smarter population. This is a distributed state problem that Cloudflare Workers + KV was not designed for. KV has 1s read-after-write consistency for globally-distributed keys. If two visitors play the same game simultaneously, they'll read different evolution states. Durable Objects can help, but they have concurrency limits (1,024 concurrent connections per DO). At scale, this architecture needs a rethink — see Scale Path below.

---

## 2. Integration Points — Where the Pieces Touch

### Existing Integrations

| Interface | Connects | Protocol | Status |
|-----------|----------|----------|--------|
| Nebula ↔ VoxelWorks | Intent routing (kid says "make me a platformer") | HTTP POST + status polling | 🟡 Draft — endpoints specified, not built |
| Nebula ↔ CraftMind | Reflex registration, intent→action mapping | POST /api/agent/teach | 🟡 Planned — schema exists, no implementation |
| I2I Bottle ↔ Game Workers | Cross-game event flow (storm→recall sheep) | File-based shards in /tmp/i2i-vessel/ | 🟢 Live but fragile |
| VoxelWorks ↔ Cloudflare | Game deploy | Cloudflare Pages API | 🟢 Live (Fix Worker exists) |
| CraftMind ↔ Construct Coordination | Status notes, blackboard | GitHub repo + git push | 🟢 Live |

### Critical Missing Integrations

| Interface | Should Connect | Gap |
|-----------|---------------|-----|
| **Ranch ↔ Game Runtime** | Evolution state must flow into deployed Phaser games | **The biggest gap in the entire stack.** The "Game JSON evolution markers" and "Ranch→Game state bridge" are both listed as "high complexity, needs building." Without this, evolution is a dashboard demo, not a product feature. |
| **Block Studio ↔ CraftMind** | Block configurations map to evolvable parameters | The product vision says "every block's behavior can be tagged for evolution" but the block schema has no `evolvable: boolean` field yet. The Forgemaster integration (blocks→code) doesn't understand evolution markers. |
| **Nebula ↔ Buddy Memory** | Buddy needs persistent cross-session memory | The product vision says "Buddy remembers 50 sessions of games." The current Buddy is an LLM chatbot with no persistence layer. Cloudflare KV is proposed but "Buddy memory persistence" is listed as Low-Medium priority — it should be P0 if Buddy is the product. |
| **VoxelWorks ↔ Ternary Crates** | Why does a kid's game need ternary math? | Currently zero integration. This could be fine (the crates are a separate concern) or it could indicate the crate ecosystem has no product pulse. The construct-coordination is designed to surface this, but nobody has asked "which ternary crate does VoxelWorks need?" |

### The I2I Bottle Protocol Is Fragile

The bottle protocol (`/tmp/i2i-vessel/bottles/` + `harbor/`) is a file-based message queue. This works for a demo fleet of 5 agents on a local filesystem. It will not work for distributed agents across Cloudflare Workers. When "storm detected" needs to reach a herding worker running in a different Cloudflare PoP, a local file mount doesn't exist.

**Fix:** The I2I protocol needs a proper distributed message broker. The file-based approach is fine for inter-instance communication within the same construct-coordination repo (since agents can git-push-pull notes), but for real-time cross-worker communication, it needs to graduate to Cloudflare Queues (natively available to Workers) or a lightweight pub/sub.

---

## 3. Duplication Risk

### Forgemaster vs. Make-Me-App vs. Block→Phaser Compiler

There are three separate code-generation pipelines being designed:

1. **Forgemaster** — Generates 150+ ternary Rust crates. Lives in Forgemaster subagent on ProArt.
2. **Make-Me-App** — Planned pipeline: fork template → customize → wrangler deploy → URL. For craftmind repos.
3. **Block→Phaser Compiler** — Planned: VoxelWorks blocks → Phaser.js game code. Uses Claude Code or LLM.

These overlap significantly:
- Forgemaster's crate generation and Make-Me-App's template forking both produce "new project from template" outputs
- The Block→Phaser compiler and Forgemaster's code-gen both transform a specification into runnable code
- All three need to know about Game JSON format, evolution markers, and Cloudflare deploy targets

**Risk:** The Block→Phaser compiler is described as "the hardest engineering piece" and "high complexity, needs building," while Forgemaster already generates production Rust code from task descriptions. There's an opportunity to reuse Forgemaster's code-gen architecture (not the crates, but the *generation pipeline*) for VoxelWorks. Alternatively, if both projects independently build code-gen from scratch, you get two half-solutions instead of one full one.

**Recommendation:** Define a shared "code generation interface" that specifies: input format (task description + template), output format (runnable project), deploy target (CF Pages, Worker, standalone). Then make Forgemaster, Make-Me-App, and VoxelWorks all implement the same interface. This doesn't mean a shared codebase — it means a shared contract that prevents each project from reinventing the same pipeline with slightly different JSON schemas.

### Nebula Reflex Registration vs. SiloGap Connection Mapping

Both systems track "what connects to what":
- Nebula: reflex registration (intent → action)
- SiloGap: crate cross-links (crate → related crate)

These are mapping the same underlying topology (the "connection graph" of the fleet) from different angles. The risk is not duplication of effort (they serve different purposes) but *inconsistency* — Nebula registers a new reflex for `ternary-matrix` that isn't reflected in SiloGap's connection matrix.

**Fix:** SiloGap should be the *source of truth* for cross-crate connections, and Nebula's reflex registry should be derivable from it. When a crate's reflexes change, the SiloGap connection ratio should update automatically.

---

## 4. Missing Middle

The biggest missing piece in the entire stack sits between "kid builds a game" and "the game evolves."

**The Missing Middle: The Living Game State Protocol**

Here's the gap in concrete terms:

1. Kid builds a platformer in Blocks Studio. Marks spider speed as "evolvable."
2. Game JSON is generated with `{ evolvable: true, generation: 0, dna: {...} }`.
3. Game deploys to Cloudflare Pages.
4. Kid plays. Spiders chase at speed X.
5. Kid closes the tab.
6. **What happens to the evolution state?**

In the Ranch, generation N+1 requires:
- Task fitness data from generation N
- DNA crossover/mutation computation
- New DNA deployed to generation N+1

For the deployed game, this means:
- The game must report fitness data **somewhere** (KV? Durable Object?)
- A cron job or Worker must run the evolution computation
- The *next time someone opens the game*, it must load the new generation's DNA

This is not a single missing feature. It's a missing **protocol** — the lifecycle of a living deployed game:

```
┌──────────────────────────────────────────────────────────────┐
│                THE MISSING PROTOCOL                          │
│                                                              │
│  GAME BOOT (load from KV):                                   │
│    1. Fetch current generation DNA for this game             │
│    2. Initialize NPC behaviors with gen N DNA                │
│    3. Set up fitness reporter (track per-interaction data)   │
│                                                              │
│  GAME PLAY:                                                  │
│    - Each spider encounter: log outcome to fitness buffer    │
│    - Each game over: flush fitness buffer to KV              │
│    - If player returns within same session: use current gen  │
│    - If player returns next day: check for gen N+1           │
│                                                              │
│  GAME EVOLVE (cron or on-demand):                            │
│    1. Read fitness data from KV                              │
│    2. Feed to Ranch evolution engine                         │
│    3. Generate gen N+1 DNA                                   │
│    4. Store gen N+1 in KV under game's evolution key         │
│    5. Log result to Ship Deck timeline                       │
│                                                              │
│  GAME FORK:                                                  │
│    1. Copy evolution state from parent game                   │
│    2. Reset generation counter but keep DNA                  │
│    3. New fork's evolution diverges from parent from here    │
│                                                              │
│  GAME MERGE (buddy-suggested cross-pollination):             │
│    1. "Your friend's game evolved flanking spiders"          │
│    2. Offer to import specific DNA traits from friend's game │
│    3. This creates hybrid evolution — a shared lineage       │
└──────────────────────────────────────────────────────────────┘
```

Without this protocol, evolution is a backstage demo (Ranch dashboard shows fitness curves) but not a product feature (kid plays against evolving enemies). The product vision document *promises* this experience — "Wait, they're adapting" is the hook — but the architecture doesn't deliver it yet.

**This is the single highest-priority architectural gap.** Everything else — Buddy memory, agent orchestration, cross-room reflexes — is additive. This is foundational. Without it, the "evolutionary FOMO" viral mechanism is aspirational fiction.

### The Second Missing Piece: The Escape Hatch from Blocks to Code

The product vision describes Forgemaster opening a generated code view:

> "The Block Studio's 'Show Code' button doesn't just display the underlying JavaScript — it opens it in a Forgemaster agent session. The agent reads the block configuration and generates: the equivalent Phaser game code, suggested optimizations, evolution hooks."

This is a beautiful teaching moment. It's also a massive integration point that requires:
- The Block→Phaser compiler to produce correct, readable JavaScript
- Forgemaster to understand the block schema and produce human-readable annotations
- The code view to be live-editable (kid modifies JS, changes reflect in blocks?)
- A sync protocol between block mode and code mode

**Risk:** If the "Show Code" button reveals impenetrable, LLM-generated spaghetti, it destroys trust. Kid thinks "blocks made this mess? I'm not learning that." The button needs to be gated behind serious code quality guarantees.

---

## 5. Scale Path — What Breaks First

Let me run the scenario: VoxelWorks launches, gets traction, 10,000 active kid makers, each generating 2-3 game deploys per week.

### Breaks First: Cloudflare Workers Free Tier Limits

**KV limits:**
- Maximum 1,000 writes per second per KV namespace
- 25 MB per KV value
- Read-after-write consistency: eventual (globally within 60s, strong within 1s per region)

Current architecture:
- Each game: evolution state, fitness data, generation history → KV
- Buddy memory: per-user chat history → KV
- Nebula reflex store → KV
- Asset metadata → KV

With 10,000 games, each storing maybe 50 KB of evolution state + 10 KB of metadata → ~600 MB. KV is priced at $0.50/GB/month for stored data and $0.50/million read operations. At 10,000 games with 100 reads/day each = 1M reads/day = 30M/month = $15/month just for evolution KV reads. Add Buddy chat, reflex lookups, asset metadata — you hit $50-100/month on storage costs alone at moderate scale.

**Durable Objects limits:**
- 1,024 concurrent connections per DO
- 128 MB persistent storage per DO
- Eventual consistency for DO-to-DO communication

If each game's economy (multiplayer scoring, leaderboards) uses a DO, you need one DO per game. 10,000 games = 10,000 DOs = 10,000 storage units. At $0.20/GB/month for DO storage, you're looking at $20-40/month for 128MB*10k = 1.28 TB of *allocated* capacity (actual usage will be far less, but minimum allocation per DO is real).

**Verdict:** Cloudflare Workers will handle moderate scale (10k-100k games) fine on the free tier for the first few months. At 100k+ games, the cost model changes. This is a *cost optimization problem*, not an architectural redesign problem — but it needs to be budgeted for.

**Fix:** Batch fitness data writes (don't write per-interaction, write per-session). Compress evolution state (DNA can be bit-packed — it's just a few float vectors). Cache Buddy responses aggressively (most kids ask similar questions).

### Breaks Second: The Block→Phaser Compiler at Scale

The product vision says "build a game in 5 minutes, deploy to the web." The architecture says this involves:
1. Nebula intent parsing (~500ms)
2. LLM code generation (~2-30s)
3. Asset generation (5-15s parallel)
4. GitHub API calls (2-5s)
5. Cloudflare Deploy (10-30s)

Total: 20-60 seconds per build.

At 10,000 kids, each building 2x/week, that's 20,000 builds/week = ~3,000/day = ~125/hour = ~2/minute. The LLM code generation step alone costs $0.01-0.05 per Claude Code call. 3,000 builds/day × $0.03 = $90/day in LLM costs. **That's $2,700/month on code generation alone.** Add asset generation (Stable Diffusion / Flux at $0.002-0.01 per image), and you're looking at $3,000-5,000/month in AI inference costs at moderate scale.

**Fix:** This is the killer. The answer in the product vision is already hinted: "Default: free-tier LLM (Gemini Flash, Claude Haiku). Premium: paid tier for deeper analysis." But even Gemini Flash adds up. The real answer is **template reuse and caching**. If 80% of games are variations of 10 templates (platformer, runner, puzzle, etc.), pre-generate the template code and only customize the delta. The Block→Phaser compiler doesn't need to generate from scratch — it loads a template and applies modifications.

### Breaks Third: Evolution at Scale

The evolution loop (fitness data → Ranch computation → new DNA) is currently designed as a cron-triggered batch job. This works for 10 games. For 10,000 games:

- 10,000 evolution runs, each processing fitness data from possibly hundreds of play sessions
- Each run needs to read KV data, run crossover/mutation, write new DNA
- If runs are sequential (one cron worker), last game waits hours for its evolution

**Fix:** The evolution loop needs to be parallelizable. Each game's evolution is independent — this is the ideal "embarrassingly parallel" workload. Use Cloudflare Queues: each game's fitness data triggers an evolution task message. Workers consume from the queue in parallel. Durable Objects for the evolution state of each game. This is a natural fit for the architecture, but it needs to be designed from day one rather than retrofitted.

### What Needs Redesign vs. Optimization

| Component | Threshold | Action |
|-----------|-----------|--------|
| Nebula reflex routing | 1M queries/day | Optimization — cache common paths, add CDN edge caching |
| Block→Phaser compiler | 1,000 builds/day | Redesign — move from per-build LLM generation to template+delta |
| Evolution loop | 100 games | Redesign — move from batch cron to queue-per-game |
| Buddy memory | 10,000 sessions | Optimization — KV with TTL, archive sessions >30 days to R2 |
| Cloudflare KV costs | 100k games | Optimization — compress state, batch writes, use R2 for cold storage |
| I2I Bottle protocol | 5 agents | Redesign — move from file-based to Cloudflare Queues or pub/sub |
| Git-based construct-coordination | 50 agents | Optimization — large git history is fine, consider shallow clones for CI |

---

## 6. Synthesis: The Good, The Bad, The Missing

### The Good

1. **The product vision is extraordinary.** The emotional arc, Buddy as relationship (not UI), evolution as viral hook, monetization that rewards creation — this is pitchfork-level product thinking. The "Grandma Test" paragraph genuinely made me feel something.

2. **The architecture has the right bones.** Edge-first (Cloudflare Workers for everything), intent-routed (Nebula three-path), agent-orchestrated (Oracle2, Forgemaster), evolution-powered (CraftMind Ranch), fork-deployed (GitHub + Pages). The layering is conceptually clean.

3. **The "don't rewrite — wrap" strategy for craftmind ports is correct.** 42,000 lines of fishing code stays as-is. Wrap registerWithCore() around Nebula reflexes. This is pragmatic engineering.

4. **The three-path routing is a genuinely novel architecture.** Fast/Similar/Slow with embedding thresholds is elegant and practical. It acknowledges that not all queries need a full LLM.

### The Bad

1. **The missing evolution state protocol is existential.** Without it, VoxelCraft is "Scratch with nicer assets and a Ranch dashboard." The viral loop depends on "the enemies learned something." This requires a living game state protocol that currently doesn't exist.

2. **The Block→Phaser compiler is hand-waved.** It's called "the hardest engineering piece" and "high complexity" in the same document. The code-generation step is the core promise ("build a game in 5 minutes"), and it relies on a pipeline with multiple LLM-dependent failure points. A demo-day prototype works. A production system for 10k kids needs caching, fallback, testing, and quality gates that don't exist yet.

3. **AI inference costs are not sanity-checked.** $3,000-5,000/month at moderate scale for LLM + asset generation is real money for a free-to-use kids' platform. The product vision's monetization is clever but assumes kids reach Session 50 before hitting the paywall. The architecture needs to account for 50 sessions' worth of free AI before a kid sees a paid feature.

4. **The Construct API is fantasy.** The CRITICAL-REVIEW document covers this thoroughly. The hardware abstraction trait hierarchy, the security vacuums, the latency fiction, the state synchronization hand-waving — all correct critiques. The crate ecosystem is intellectually beautiful but practically disconnected from the product.

### The Missing

1. **Living Game State Protocol** — as described in §4 above. P0, should be the next design document written.

2. **Kid Identity System** — "No account, no signup" is the onboarding pitch, but Buddy needs memory, games need ownership, and forking needs attribution. The plan says "Supabase Auth / Clerk" — this needs to be designed with the specific constraints of 8-14 year olds (COPPA compliance, no email requirement, anonymous sessions with upgrade path).

3. **Analytics & Observability** — Nowhere in the architecture is there mention of game analytics (how many plays, where players get stuck, what blocks are most used, evolution convergence rates). This data is essential for the Researcher agent, for Buddy's recommendations, and for product improvement. "Where do kids stop making games?" is the most important question for retention, and the current architecture cannot answer it.

4. **Parent/Teacher Dashboard** — Listed as P2 in Month 3. For the product to have any chance in schools or with safety-conscious parents, this needs to be P1 alongside the core experience. The "Grandma Test" kid shares a game, Grandma plays it on her phone — but what if Grandma has concerns? A parent dashboard that shows "Priya made 3 games this week, shared 1, has 0 friends, Buddy conversations are logged" is table stakes for the audience.

5. **Offline/Outage Experience** — Cloudflare Workers are edge-deployed, but Kids don't understand "504 Gateway Timeout." What happens when Nebula's embedding endpoint is slow? When Durable Objects hit concurrency limits? When Buddy's LLM backend is rate-limited? The product needs graceful degradation — a cached Buddy, a playable offline mode, sensible error messages. The status polling architecture (poll every 1-2s) will show a spinning loader for 20-60 seconds on every build. Ten-year-olds do not have that patience.

---

## 7. Concrete Recommendations

### Immediate (Week 1-2)

1. **Write the Living Game State Protocol spec.** Before any more code is written in VoxelWorks or CraftMind integration, document the lifecycle: boot → play → report → evolve → deploy → boot again. Make it a `proposals/LIVING-GAME-PROTOCOL.md` in construct-coordination. Get consensus from VoxelWorks, Nebula, and CraftMind owners.

2. **Define the shared code-generation interface.** A single document that all three code-gen projects (Forgemaster, Make-Me-App, VoxelWorks Block→Phaser) implement. Input format, output format, deploy target, quality gates.

3. **Build the Frog Pond loop.** The simplest possible end-to-end trace: a kid says "make me a game," blocks appear, game deploys, one evolution step runs, DNA updates. Don't build the full Block→Phaser compiler — build a single-template end-to-end. Prove the pipeline works end-to-end before adding complexity.

### Short-term (Week 3-4)

4. **Retrofit Buddy with KV-backed session memory.** The "low-medium" priority is wrong. Buddy is the product. Buddy without memory is a talking manual. Two days of work to wire KV persistence to chat history.

5. **Add SiloGap enforcement to CI.** Every pull request to a ternary crate must update the cross-links in SiloGap. Connection ratio ≥ 3 enforced by CI check. This prevents further silo drift.

6. **Budget AI inference costs at scale.** Run the numbers: projected builds/day × LLM cost/build × asset generation cost/build. Compare against monetization projections. If the free tier burns through $5/kid in AI costs before the kid sees a paid feature, the business model needs adjustment before launch.

### Medium-term (Month 2-3)

7. **Design the kid identity system with COPPA compliance.** Anonymous sessions with upgrade path. No email for kids under 13. Parent consent flow. This is not a feature — it's a legal requirement for the target audience.

8. **Replace file-based I2I with Cloudflare Queues.** The bottle protocol works for local agents. For Workers distributed globally, use natively available Pub/Sub infrastructure. The I2I *shard format* (artifacts, reasoning, blockers) is good — keep the schema, change the transport.

9. **Design analytics instrumentation into the architecture.** Every game interaction, evolution run, block usage, Buddy conversation should emit telemetry. This is how you know what's working. Daphne (if she's joining) will need this data.

### Long-term (Month 3+)

10. **Revisit the Construct API for the actual hardware targets.** The CRITICAL-REVIEW is right: the API is aspirational. But the *intent* (same mental model across DGX and ESP32) is worth preserving. Ship a minimal `CoreConstruct` trait (no_std, no alloc, no async) for embedded targets, and let the full trait hierarchy extend from there. Drop the hardware tier enum.

11. **Add reflex garbage collection to Nebula.** Reflex store grows unbounded. Add match-count tracking, access-time metadata, and an eviction policy (LRU by access recency, or LFU by match count with decay).

---

## The Recursive Insight (Stealing from the Product Vision)

The product vision says VoxelCraft is "not VoxelWorks + CraftMind — it's what emerges when a creative tool and an evolution engine share the same loop."

The architectural review says: this loop **is not yet designed**. The product vision *promises* the loop. The architecture *describes* the components. The gap between them is the living game state protocol.

Build that protocol. Let the loop be real. Everything else follows.

---

*"The goat learned to gather. The architecture learned to connect. The product learned to live."*
