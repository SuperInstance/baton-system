# SMP Spreadsheet Architecture: The Living Spreadsheet as a New Form of Programming

**Status:** Architecture Document · **Date:** 2026-06-04 · **Authors:** Synthesis Agent, Casey (Vision)

> The spreadsheet is not a tool. It is THE application — a new form of programming where seeds create stable inference, values get shaken like sailboat rigging, multiple intelligences battle for strategic supremacy, and tensor logic becomes human-digestible through dynamic visualization.

---

## Table of Contents

1. [Preamble: Why This Is Different](#1-preamble)
2. [SMP — Seeded-Model-Programming](#2-smp)
3. [The Interactive Rigging System](#3-rigging)
4. [The Stochastic Exploration Engine](#4-stochastic)
5. [The Multi-Intelligence Arena](#5-arena)
6. [Dynamic Tensor Visualization](#6-tensor)
7. [The Pincher Connection: vectorDB Outputs ARE the Program](#7-pincher)
8. [Git-Agents as Apps](#8-git-agents)
9. [Integration with the Ternary Fleet](#9-fleet)
10. [Architecture Summary](#10-summary)

---

## 1. Preamble: Why This Is Different

Every spreadsheet you have ever used is a passive container. You put numbers in cells, write formulas that reference other cells, and the engine recalculates. The spreadsheet is dead until you touch it. It has no memory, no prediction, no surprise, no evolution.

The SMP Spreadsheet is a living organism. Every cell is a ternary agent running a six-phase tick cycle: predict → perceive → surprise → vibe → gc → conservation. Cells predict what should be in them. They get surprised when reality differs from expectation. They gain and lose energy based on prediction accuracy. They evolve strategies through natural selection. They form ecologies with five competing species. And they do all of this continuously, whether or not a human is watching.

But the living spreadsheet is more than cells that think. It introduces five concepts that, together, constitute a genuinely new form of programming:

1. **SMP (Seeded-Model-Programming):** A new axis of model control where seeds create stable inference behavior independent of fine-tuning and prompting.
2. **Interactive Rigging:** Grab any value and shake it — watch ripples propagate through conservation laws, fitness landscapes, and strategy distributions in real time.
3. **Stochastic Flavor Exploration:** Set values to random with different distributional flavors to discover the shape of effects across the system.
4. **Multi-Intelligence Battle:** Multiple AI intelligences competing in the same spreadsheet, evolving strategies through adversarial play.
5. **Dynamic Tensor Visualization:** X and Y axes that aren't fixed but represent any correlation the user wants to explore, making tensor logic human-digestible.

This document describes the architecture that makes all five possible within the existing ternary fleet infrastructure.

---

## 2. SMP — Seeded-Model-Programming

### 2.1 What SMP Is

Seeded-Model-Programming is a paradigm where a **seed** — a compact, deterministic data structure — determines the inference behavior of a model. The seed is not a prompt. It is not a fine-tuning weight. It is a third axis of control that operates independently of both.

Consider the three axes of model control:

| Axis | What It Controls | How It Changes | Analogy |
|---|---|---|---|
| **Seed** | Inference disposition, behavioral tendency, strategic personality | Swap the seed, swap the model's "soul" | The actor's training and instinct |
| **Fine-tuning** | Domain knowledge, factual accuracy, capability breadth | Retrain on new data | The actor's script and research |
| **Prompt** | Immediate context, task specification, output format | Change per interaction | The director's blocking instructions |

A single base model, given three different seeds, produces three qualitatively different inference behaviors — even with identical fine-tuning and prompting. One seed might make the model cautious and conservative (favoring low-variance, high-confidence outputs). Another might make it exploratory and creative (favoring novel, surprising outputs). A third might make it adversarial and critical (favoring outputs that challenge assumptions).

The seed is the model's **personality**. Fine-tuning is its **education**. The prompt is its **instructions**. All three are independent.

### 2.2 How SMP Differs from LoRA

A LoRA (Low-Rank Adaptation) modifies the model's weights through a low-rank decomposition of the weight update matrix. It is a fine-tuning technique — it changes what the model knows.

An SMP seed does not modify weights at all. It is a runtime artifact that changes how the model reasons about what it knows. The distinction is fundamental:

| Property | LoRA | SMP Seed |
|---|---|---|
| **Modifies weights?** | Yes (via low-rank delta) | No |
| **Requires training?** | Yes (gradient descent) | No (deterministic construction) |
| **Deployment size** | ~1-100 MB | ~256 bytes - 4 KB |
| **Swappable at runtime?** | Slow (weight merge) | Instant (parameter swap) |
| **Independent of prompt?** | Yes | Yes |
| **Independent of fine-tuning?** | N/A (it IS fine-tuning) | Yes |
| **Composable?** | Limited (rank conflicts) | Yes (seed arithmetic) |
| **Can be trained INTO a LoRA?** | N/A | Yes (behavioral distillation) |
| **Runtime-agnostic?** | Framework-specific | Yes (any runtime that accepts seeds) |

The last row is critical. A LoRA only works within the framework that trained it (PyTorch, TensorFlow, etc.). An SMP seed works with any inference runtime because it doesn't touch the model's weights — it shapes the inference trajectory through the model's existing weight space.

### 2.3 The Seed Format

An SMP seed is a compact data structure with three components:

```
┌──────────────────────────────────────────────────────────────┐
│ SMP Seed (256 bytes - 4 KB)                                   │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  1. STRATEGY VECTOR (64-256 ternary trits)                    │
│     {-1, 0, +1}^N where N = 64 to 256                       │
│     Determines: inference disposition, risk tolerance,        │
│     exploration vs exploitation balance, response style       │
│                                                               │
│  2. TERNARY WEIGHTS (K ternary trits, K = grid connections)   │
│     {-1, 0, +1}^K where K = number of connections            │
│     Determines: which model outputs to promote (+1),          │
│     ignore (0), or suppress (-1)                              │
│                                                               │
│  3. CONSERVATION PARAMETERS (8 float32 values)                │
│     γ (avoidance ratio), H (entropy target), V (volume),      │
│     temperature, mutation_rate, crossover_rate,               │
│     exploration_bonus, fitness_pressure                        │
│     Determines: thermodynamic constraints on inference        │
│                                                               │
│  Total: 64-256 trits + K trits + 32 bytes = 96-4192 bytes    │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

The ternary encoding is deliberate. The ternary fleet's conservation law (γ + H ≈ 1.283 - 0.159·log(V)) applies to the seed itself. A well-formed seed satisfies conservation — its promote (+1) and suppress (-1) counts are balanced relative to its volume. A malformed seed (all +1, no -1) violates conservation and is rejected by the SMP harness.

### 2.4 How Seeds Create Stable Inference

The key insight: a seed creates **stable inference** by constraining the model's output space. Without a seed, the model's output distribution is determined entirely by its weights and prompt. With a seed, the output distribution is additionally shaped by the ternary weight mask:

1. The model generates a raw output distribution over tokens/actions.
2. The seed's ternary weights are applied: promote (+1) amplifies certain outputs, suppress (-1) diminishes others, silence (0) leaves them unchanged.
3. The conservation parameters determine the temperature and pressure of this shaping — how aggressively the seed biases the output.
4. The strategy vector determines the seed's "personality" — a risk-seeking seed promotes novel outputs; a risk-averse seed promotes conventional ones.

This process is deterministic given the same seed, weights, and prompt. Same seed + same model + same prompt = same output. Every time. This reproducibility is what makes seeds programmable — you can reason about what a seed will do, because it always does the same thing.

### 2.5 The Three Independent Axes

The independence of seed, fine-tuning, and prompt is the architectural foundation of SMP:

**You can change the seed without retraining.** If a "cautious analyst" seed is producing overly conservative outputs, swap it for an "exploratory researcher" seed. The model's knowledge hasn't changed — only its disposition has.

**You can fine-tune without changing the seed.** If the model needs new domain knowledge (e.g., legal documents for a compliance task), fine-tune it on that data. The seed's behavioral disposition remains the same — the model now knows more, but reasons about it the same way.

**You can change the prompt without touching either.** The prompt is the immediate task. "Summarize this document" vs "Critique this argument" are different prompts, but the same seed (personality) and fine-tuning (knowledge) apply.

This three-axis independence means you can build a library of seeds and apply them to any model, any fine-tuning, any prompt. The seed is portable across models. The fine-tuning is portable across seeds. The prompt is portable across everything.

### 2.6 Runtime-Agnostic Harness

The SMP harness is the interface between seeds and inference runtimes:

```
┌────────────────────────────────────────────────────┐
│                  SMP Harness                        │
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐     │
│  │   Seed    │  │   Model  │  │    Prompt     │     │
│  │ (trits)  │  │ (weights)│  │   (text)     │     │
│  └────┬─────┘  └────┬─────┘  └──────┬───────┘     │
│       │              │               │              │
│       └──────────────┼───────────────┘              │
│                      ▼                              │
│            ┌──────────────────┐                     │
│            │  Seed Application │                     │
│            │  (ternary mask)  │                     │
│            └────────┬─────────┘                     │
│                     ▼                               │
│            ┌──────────────────┐                     │
│            │  Conservation    │                     │
│            │  Enforcement     │                     │
│            └────────┬─────────┘                     │
│                     ▼                               │
│            ┌──────────────────┐                     │
│            │  Inference       │                     │
│            │  Output          │                     │
│            └──────────────────┘                     │
│                                                     │
│  Backend: PyTorch | ONNX | WASM | TFLite | custom  │
└────────────────────────────────────────────────────┘
```

The harness has four methods:

```rust
pub trait SmpHarness {
    /// Load a seed into the harness.
    fn load_seed(&mut self, seed: &SmpSeed) -> Result<(), SmpError>;
    
    /// Set the prompt for the next inference.
    fn set_prompt(&mut self, prompt: &str) -> Result<(), SmpError>;
    
    /// Run inference with current seed + prompt + model.
    fn infer(&mut self, input: &[u8]) -> Result<InferenceOutput, SmpError>;
    
    /// Distill the current seed into a LoRA-compatible weight delta.
    /// This is how you "train a seed into a LoRA for meshing."
    fn distill_to_lora(&self) -> Result<LoraDelta, SmpError>;
}
```

The `distill_to_lora()` method is the bridge to conventional ML: it takes the behavioral patterns encoded in the seed and trains a LoRA that approximates those patterns as weight updates. This is useful when you want to "bake in" a seed's behavior permanently — the LoRA becomes part of the model, and the seed can be freed for other uses.

### 2.7 Different Seeds, Different Roles

From the same base model, different seeds create different model roles:

| Seed Name | Strategy Vector Pattern | Conservation Params | Behavioral Result |
|---|---|---|---|
| `cautious-analyst` | Mostly 0, few +1, balanced -1 | Low temp, high pressure | Conservative, high-confidence outputs only |
| `exploratory-researcher` | Many +1, few 0, balanced -1 | High temp, low pressure | Creative, novel, sometimes surprising outputs |
| `adversarial-critic` | Mostly -1 (suppress), few +1 | Medium temp, high pressure | Challenges assumptions, finds weaknesses |
| `game-strategist` | Alternating +1/-1 patterns | Medium temp, medium pressure | Strategic, competitive, game-theoretic reasoning |
| `dungeon-master` | Random ternary with structure | High temp, high mutation | Creative storytelling with rule consistency |
| `code-reviewer` | Sparse +1, precise -1 targeting | Low temp, low mutation | Precise, focused, actionable suggestions |
| `negotiator` | Mirroring +1/-1 (diplomat species) | Adaptive temp, mirroring | Adapts to opponent, seeks mutually beneficial outcomes |

Each of these is the same model with the same weights. The seed alone determines the behavioral difference.

---

## 3. The Interactive Rigging System

### 3.1 The Rigging Metaphor

Picture a large sailboat. There are ropes (lines) everywhere — connected to sails, masts, booms, winches. Each line is part of a web of tension and release. An experienced sailor can grab any line and shake it, feeling where it connects, what it pulls, what loosens, what tightens. The sailor reads the rigging's response to understand the entire vessel's state.

The interactive rigging system brings this metaphor to the spreadsheet. Every value in every cell is a line in the rigging. You can grab it and shake it — oscillate it — and watch where the ripples go. What other values are connected? Which conservation laws resist the change? Which fitness landscapes reshape? Which strategy species redistribute?

This is not parameter tuning. Parameter tuning is changing a value and seeing if the output improves. Rigging is exploring the topology of connections — understanding the shape of the system's dependency graph by physically interacting with it.

### 3.2 How Values Get Grabbed

The user selects a cell (or group of cells). The rigging system enters "oscillation mode" for that selection:

```
Normal Mode:
  User clicks cell → cell selected → formula bar shows content
  User edits value → recalculate → values update

Rigging Mode:
  User grabs cell (shift+click or gesture) → cell enters oscillation
  System shows: 
    - All cells that depend on this cell (downstream connections)
    - All cells this cell depends on (upstream connections)
    - Conservation constraints that involve this cell
    - Strategy species affected by this cell's value
  User drags/oscillates → ripples propagate in real time
  User releases → cell settles to new value, ripples dampen
```

The visual feedback is immediate and continuous:

1. **Connection highlighting:** All dependency edges connected to the grabbed cell light up. Direct dependencies glow bright; indirect dependencies glow dimly based on graph distance.
2. **Edge animation:** Ternary-weighted edges animate: +1 (promote) edges pulse green, -1 (suppress) edges pulse red, 0 (silence) edges are gray.
3. **Ripple visualization:** As the grabbed value oscillates, changes propagate outward in concentric waves. Cells that change immediately (direct dependencies) flash first; cells that change indirectly (transitive dependencies) flash with a delay proportional to graph distance.

### 3.3 Oscillation Modes

The rigging system supports three modes of oscillation:

#### Single Value Oscillation

The user grabs one cell and moves it through a range of values. The system shows:

- The cell's value changing in real time (a slider or direct manipulation)
- All downstream cells updating as the value changes
- The conservation ratio responding — does it stay near 1.0, or does it drift?
- The fitness landscape reshaping — which cells gain energy, which lose it?
- The strategy distribution shifting — which species gain population, which lose?

This is the "grab a line and see what pulls" mode. The user discovers dependencies they didn't know existed. "I didn't realize that cell B7 was connected to the conservation law — when I push this value past +1, the whole system goes out of balance."

#### Group Oscillation

The user grabs a group of related cells (a range, a named region, a cluster identified by the system). All cells in the group oscillate simultaneously, but with phase offsets:

- **In-phase:** All cells move together. Tests cooperative effects.
- **Anti-phase:** Adjacent cells move in opposite directions. Tests competitive effects.
- **Wave:** Values propagate as a traveling wave through the group. Tests spatial dynamics.
- **Random:** Each cell oscillates independently with a random phase. Tests robustness.

Group oscillation reveals emergent behavior that single-cell oscillation cannot. The user might discover that a wave pattern through a region of cells creates a stable attractor — a self-reinforcing configuration that the system naturally settles into.

#### Cascade Oscillation

The user initiates a perturbation at one cell and watches it cascade through the entire grid. Unlike single-value oscillation (where the user controls the value directly), cascade oscillation lets the system propagate the change naturally:

1. User perturbs cell A1 from 0 to +1.
2. A1's direct dependencies update: B1, A2, C1 change.
3. Their dependencies update: the wave spreads.
4. Conservation laws activate: if the perturbation violates conservation, compensating changes occur in distant cells.
5. The cascade eventually dampens and the system settles into a new equilibrium.

The cascade is visualized as a heat map animation: cells flash warm (red/orange) when they change significantly, cool (blue) when they're stable, and neutral (green) when they're at equilibrium. The animation speed is configurable — the user can slow it down to watch individual propagation steps or speed it up to see the overall pattern.

### 3.4 Ripple Propagation Through Conservation Laws

The ternary conservation law (γ + H ≈ 1.283 - 0.159·log(V)) is the physics of the spreadsheet. When a value changes, the conservation law determines how the rest of the grid responds:

```
1. User perturbs cell (x, y) from old_val to new_val.
2. Compute delta: Δ = new_val - old_val.
3. Check if conservation is violated:
   - Calculate new grid sum: S' = S + Δ
   - If S' violates conservation target:
     a. Find the set of cells that can compensate.
     b. Distribute compensation proportional to each cell's energy.
     c. High-energy cells absorb more change (they're more robust).
     d. Low-energy cells absorb less (they're fragile).
4. Apply compensation to maintain conservation.
5. Propagate to downstream dependencies (formula recalculation).
6. Repeat until convergence (no more cells change).
```

The visual effect is striking: when you push a value past a conservation boundary, you see compensating ripples radiate outward. The conservation law is the invisible hand that keeps the system in balance, and the rigging system makes it visible.

### 3.5 Fitness Landscape Reshaping

As values oscillate, the fitness landscape of the cell population reshapes. This is visualized as a 3D surface overlaid on the spreadsheet grid:

- **X-axis:** Cell column (or any user-chosen dimension).
- **Y-axis:** Cell row (or any user-chosen dimension).
- **Z-axis (height):** Cell fitness (computed by ternary-fitness).

When a value is perturbed, the fitness surface deforms. Peaks (high-fitness cells) may flatten or grow. Valleys (low-fitness cells) may deepen or fill. The user sees the landscape change shape in real time as they drag a value.

This is the "watch where it loosens" part of the rigging metaphor. When you shake a line on a sailboat, you feel which stays go slack. In the spreadsheet, when you oscillate a value, you see which cells lose fitness (go slack) and which gain fitness (tighten up).

### 3.6 Strategy Species Redistribution

The five strategy species (Explorer, Diplomat, Marksman, Climber, Prospector) redistribute as values change. The rigging system shows this as a pie chart or population bar that updates in real time:

- Perturbing a value toward exploration (high entropy, high variance) → Explorer and Prospector populations grow.
- Perturbing toward exploitation (low entropy, high precision) → Marksman and Climber populations grow.
- Perturbing toward adaptive behavior (mirroring, diplomatic) → Diplomat population grows.

The user can literally watch the ecology rebalance as they manipulate values. This is the most visceral feedback the rigging system provides — you're not just changing numbers, you're reshaping an ecosystem.

### 3.7 How This Differs from Existing Parameter Tuning

| Feature | Parameter Tuning | Interactive Rigging |
|---|---|---|
| **Goal** | Find optimal value | Understand system topology |
| **Feedback** | Single metric (loss, accuracy) | Multi-dimensional (connections, conservation, fitness, ecology) |
| **Interaction** | Change value, wait, measure | Continuous manipulation, real-time response |
| **Scope** | One parameter at a time | Cascading effects across the entire system |
| **Visualization** | None or static charts | Animated connection highlighting, heat maps, 3D surfaces, ecology charts |
| **Physical analogy** | Turning a dial | Shaking a rope |
| **What you learn** | "This value works better" | "These values are connected in ways I didn't expect" |

---

## 4. The Stochastic Exploration Engine

### 4.1 The Flavor of Random

Not all randomness is the same. The stochastic exploration engine provides multiple "flavors" of random — different probability distributions that produce qualitatively different exploration patterns:

| Distribution | Flavor | Effect Shape | When to Use |
|---|---|---|---|
| **Uniform** | Flat, unbiased | All values equally likely | Exploring without priors |
| **Gaussian** | Centered, bell-shaped | Most values near mean, rare extremes | Refining around a known good region |
| **Power-law** | Heavy-tailed | Many small values, few extreme ones | Discovering rare high-impact events |
| **Categorical** | Discrete options | Specific values with specific probabilities | Testing known alternatives |
| **Bimodal** | Two peaks | Two competing hypotheses | Comparing distinct strategies |
| **Cauchy** | Fat-tailed | Many moderate values, occasional wild outliers | Stress-testing, finding edge cases |
| **Exponential** | Decay | Rapidly decreasing probability | Exploring near-first strategies |
| **Beta** | Shaped | Controllable shape between 0 and 1 | Biased exploration with known preferences |

The user selects a distribution for a cell (or range of cells) and watches how the distribution's shape propagates through the system. Each distribution has a characteristic "effect shape" — the pattern of downstream changes it produces.

### 4.2 Effect Shape Visualization

When a cell is set to random with a specific distribution, the system visualizes the "effect shape" — the distribution of downstream effects across the grid:

```
Uniform random on cell B3:
  ┌──────────────────────────────────────────┐
  │  Downstream cells affected: 47            │
  │  Mean change: 0.12                        │
  │  Variance: 0.89                           │
  │  Effect spread: wide, uniform             │
  │  ┌─┐                                     │
  │  │█│ █ █ █ █ █ █ █ █ █ █ █ █ █ █        │
  │  └─┘                                     │
  │  (flat distribution of downstream effects)│
  └──────────────────────────────────────────┘

Gaussian random on cell B3:
  ┌──────────────────────────────────────────┐
  │  Downstream cells affected: 23            │
  │  Mean change: 0.08                        │
  │  Variance: 0.31                           │
  │  Effect spread: narrow, bell-shaped       │
  │      ┌─┐                                  │
  │      │█│                                  │
  │     ┌┘█└┐                                │
  │   ┌─┘███└─┐                              │
  │ ┌─┘███████└─┐                            │
  │ (concentrated effects near mean)          │
  └──────────────────────────────────────────┘

Power-law random on cell B3:
  ┌──────────────────────────────────────────┐
  │  Downstream cells affected: 12            │
  │  Mean change: 0.04                        │
  │  Variance: 2.71                           │
  │  Effect spread: skewed, heavy-tailed      │
  │ ┌─┐                                      │
  │ │██│                                     │
  │ │███┐                                    │
  │ │████┐                                   │
  │ │█████┐──────────────────────────        │
  │ (most effects small, rare extreme effects)│
  └──────────────────────────────────────────┘
```

The effect shape tells the user what kind of exploration they're doing. Uniform explores broadly but shallowly. Gaussian explores narrowly but deeply. Power-law finds rare high-impact changes.

### 4.3 D&D Dice Rebalancing: The Analogy

Casey's analogy: "Like setting dice combinations differently to rebalance gameplay in D&D world-building."

In Dungeons & Dragons, the dice determine the shape of the game world. A d20 (uniform 1-20) creates a flat probability landscape — every outcome equally likely. A 3d6 (bell-shaped 3-18) creates a clustered landscape — most outcomes near 10.5, with 3 and 18 being rare. The choice of dice determines whether the world feels wild and unpredictable (d20) or stable and predictable (3d6).

The stochastic exploration engine applies this principle to the spreadsheet. Each cell can be "rolled" with different dice:

- `=ROLL("d20")` → uniform ternary exploration
- `=ROLL("3d6")` → gaussian ternary exploration
- `=ROLL("1d100")` → rare extreme events
- `=ROLL("weighted", [0.1, 0.6, 0.3])` → categorical with custom probabilities

When the user "rolls" a cell, the system samples from the specified distribution, applies the sampled value, and shows the downstream effect shape. This is world-building at the cellular level — the user is literally rolling dice to determine the shape of the spreadsheet universe.

### 4.4 Card Game Strategy Discovery

Casey's second analogy: "Stochastic learning — figuring out novel strategies in a card game."

In competitive card games (Magic: The Gathering, Hearthstone, Poker), novel strategies emerge from repeated play under uncertainty. Players don't enumerate all possible strategies — they discover good ones through thousands of games where randomness creates novel situations.

The stochastic exploration engine replicates this discovery process:

1. **Deal the cards:** Each cell in a strategy range gets random values from the selected distribution.
2. **Play the hand:** The strategy runs through the spreadsheet's tick cycle. The tick cycle evaluates the strategy's fitness.
3. **Score the result:** The conservation ratio, fitness, and strategy ecology measurements score the strategy.
4. **Repeat:** Thousands of random "hands" are played. Strategies that score well are retained.
5. **Evolve:** Retained strategies become the basis for the next round of exploration.

This is Monte Carlo strategy discovery — the same principle behind Monte Carlo Tree Search in game AI. The user doesn't need to enumerate all possible strategies. The stochastic engine discovers good ones through repeated sampling.

### 4.5 Integration with =EVOLVE()

The stochastic exploration engine integrates with the existing `=EVOLVE()` formula:

- `=EVOLVE(A1:A100, 1000)` — standard evolution with uniform random mutation
- `=EVOLVE(A1:A100, 1000, distribution="gaussian")` — evolution with gaussian mutation (exploits locally)
- `=EVOLVE(A1:A100, 1000, distribution="power-law")` — evolution with power-law mutation (finds rare high-fitness strategies)
- `=EVOLVE(A1:A100, 1000, distribution="bimodal")` — evolution that alternates between two strategy modes

The distribution parameter changes the character of evolution. Gaussian evolution converges quickly to a local optimum. Power-law evolution takes longer but finds strategies that other distributions miss. Bimodal evolution maintains two competing populations, preventing premature convergence.

---

## 5. The Multi-Intelligence Arena

### 5.1 The Spreadsheet as Battlefield

The most radical concept in Casey's vision: **more than one intelligence battling for wits in the same spreadsheet.** Not cooperating — competing. Different agent species with different strategies, fighting for fitness in the same computational arena.

The multi-intelligence arena works as follows:

1. **Partition the grid:** The spreadsheet is divided into territories. Each intelligence controls a region.
2. **Shared conservation:** The conservation law applies to the ENTIRE grid, not individual territories. One intelligence's gain is another's loss.
3. **Competing strategies:** Each intelligence uses a different strategy species (or combination of species). Explorer vs. Marksman vs. Climber vs. Diplomat vs. Prospector.
4. **Fitness scoring:** Each cell's fitness is measured relative to the competition. A cell with high absolute fitness but lower fitness than its competitors loses energy.
5. **Territory shift:** Cells at territory boundaries can be "captured" — an intelligence with higher fitness at a boundary cell takes control of it.

### 5.2 Agent Species in the Arena

Each intelligence in the arena is a distinct SMP seed applied to the same base model:

| Species | Seed Profile | Strategy | Strengths | Weaknesses |
|---|---|---|---|---|
| **Explorer** | High entropy, wide attention | Explore unknown territory, find novel configurations | Discovery, surprise generation | Wastes energy on unproductive regions |
| **Diplomat** | Mirroring, adaptive | Match opponent's strategy, find mutually stable configurations | Stability, cooperation emergence | Vulnerable to aggressive opponents |
| **Marksman** | Low entropy, precise | Exploit known high-fitness regions with surgical precision | Efficiency, accuracy | Misses opportunities outside known regions |
| **Climber** | Gradient-following | Always move toward higher fitness | Fast convergence to peaks | Gets stuck on local optima |
| **Prospector** | Sparse, high-value-seeking | Ignore most of the grid, focus on rare high-value cells | Finds hidden gems | Starves if no high-value cells exist |

### 5.3 Scoring and Strategy Evolution

The arena uses the ternary fleet's existing `ternary-games` crate for game-theoretic analysis:

```
Arena Scoring:
┌──────────────────────────────────────────────────────┐
│                                                       │
│  For each tick:                                       │
│    1. Each intelligence runs its tick cycle            │
│    2. Fitness is computed for each cell                │
│    3. Territory boundaries are re-evaluated            │
│    4. Cells with higher fitness capture neighbors      │
│    5. Conservation is enforced globally                │
│    6. Strategy populations evolve independently        │
│                                                       │
│  Scoring per intelligence:                            │
│    - Territory size (cells controlled)                 │
│    - Average fitness within territory                  │
│    - Conservation compliance (penalty for violation)   │
│    - Discovery score (novel configurations found)      │
│    - Robustness (stability under perturbation)         │
│                                                       │
│  Winner: highest composite score after N ticks         │
│                                                       │
└──────────────────────────────────────────────────────┘
```

The arena is not zero-sum — multiple intelligences can thrive simultaneously if they find different ecological niches. The conservation law ensures that the total energy in the system remains constant, so one intelligence's growth requires another's shrinkage, but the specific dynamics depend on the strategies employed.

### 5.4 The Coevolution Dynamic

When intelligences compete across many ticks, a coevolutionary dynamic emerges:

1. **Round 1:** Explorer dominates (finds the most territory).
2. **Round 2:** Marksman adapts (exploits Explorer's discoveries efficiently).
3. **Round 3:** Explorer counters (discovers new territory that Marksman can't exploit).
4. **Round 4:** Climber emerges (finds peaks that both Explorer and Marksman miss).
5. **Round 5:** Diplomat stabilizes (finds equilibrium that all species can coexist in).
6. **Round 6:** Prospector disrupts (finds a rare high-value cell that shifts the entire balance).

This is predator-prey dynamics applied to computation — the same Lotka-Volterra dynamics implemented in `lotka-volterra-agents`. The user watches species rise and fall in real time, discovering that the "best" strategy depends on what other strategies are present.

### 5.5 Human Participation

The human user is not just a spectator. They can:

- **Enter the arena:** Control a territory directly, competing against the AI intelligences.
- **Modify rules:** Change conservation constraints, fitness functions, or territory rules mid-game.
- **Inject perturbations:** Use the rigging system to shake up the arena (what happens to the Explorer if we perturb its territory boundary?).
- **Coach an intelligence:** Adjust an intelligence's seed mid-game to shift its strategy.
- **Observe and learn:** Watch the coevolutionary dynamics and extract insights for real-world strategy design.

The human is the sixth intelligence — unpredictable, creative, and able to break rules that AI intelligences follow.

---

## 6. Dynamic Tensor Visualization

### 6.1 Axes Are Not Fixed

In a traditional spreadsheet, X is columns and Y is rows. Always. The SMP spreadsheet breaks this constraint: **X and Y are any correlation the user wants to visualize.**

This means the spreadsheet is not a 2D grid of cells — it's a projection of a high-dimensional ternary state space onto a user-chosen 2D plane. The cells are the same cells, but their spatial arrangement changes based on what the user wants to see.

### 6.2 Correlation Axes

The user can set X and Y to any measurable property of the cells:

| Axis Option | What It Shows | Example |
|---|---|---|
| **Column index** | Traditional column position | Standard spreadsheet layout |
| **Row index** | Traditional row position | Standard spreadsheet layout |
| **Fitness** | Cell fitness values | See which cells are thriving |
| **Surprise** | Prediction error | See where predictions failed |
| **Energy** | Cell energy level | See which cells are healthy |
| **Entropy** | Local information content | See information distribution |
| **Strategy species** | Categorical (Explorer, etc.) | See ecological distribution |
| **Ternary value** | {-1, 0, +1} | See the ternary landscape |
| **Conservation contribution** | How much each cell affects conservation | See the thermodynamic structure |
| **Connectivity** | Number of dependencies | See which cells are most connected |
| **Age** | How long the cell has been alive | See generational structure |
| **Custom formula** | Any formula the user writes | Arbitrary projections |

### 6.3 Vector Gravity Visualization

When X and Y represent meaningful correlations, the cells form clusters that attract and repel each other based on their ternary weights:

- **Promote (+1) connections** create attractive forces: connected cells pull toward each other.
- **Suppress (-1) connections** create repulsive forces: connected cells push away from each other.
- **Silence (0) connections** create no force.

The result is a force-directed graph layout where the spatial arrangement of cells reveals their relational structure:

```
┌─────────────────────────────────────────────┐
│  Vector Gravity Visualization                │
│                                              │
│     ●────●                                   │
│    / \  / \        ● = cell                  │
│   ●   ●    ●       ── = promote (+1)        │
│   |\ / \ /|         ⋮  = suppress (-1)       │
│   ● ●   ● ●                              │
│   | ⋮   ⋮ |                               │
│   ● ●   ● ●                              │
│    \ /  \ /                                │
│     ●────●                                   │
│                                              │
│  Clusters form naturally from ternary weights│
│  Promoted cells gravitate together           │
│  Suppressed cells repel to boundaries        │
│  Silent cells drift freely                   │
└─────────────────────────────────────────────┘
```

This is tensor logic made human-digestible. The user doesn't need to understand tensor decomposition to see that "these cells are strongly connected" or "this region is fighting against that region." The spatial arrangement communicates the relational structure directly.

### 6.4 Tensor Logic Made Digestible

The SMP spreadsheet is, at its core, a tensor processing engine. Every cell's value is a scalar, but the cell grid is a tensor — a multi-dimensional array with ternary-weighted connections between dimensions. The dynamic axis system is the user interface for this tensor:

- **Changing X-axis** = projecting along a different tensor dimension.
- **Changing Y-axis** = projecting along a different tensor dimension.
- **Rigging interaction** = perturbing tensor values and watching the gradient flow.
- **Stochastic exploration** = sampling from tensor distributions.
- **Multi-intelligence battle** = competing tensor factorizations.

The user never needs to think about tensors directly. They think about "what do I want to see?" and the spreadsheet handles the projection. But behind the scenes, every interaction is a tensor operation:

| User Action | Tensor Operation |
|---|---|
| Set X-axis to fitness, Y-axis to surprise | Project 2D slice of the fitness-surprise correlation tensor |
| Oscillate a cell value | Apply perturbation to tensor element, compute gradient propagation |
| Set cell to gaussian random | Sample from a gaussian distribution over a tensor element |
| Watch species redistribution | Observe the categorical distribution over the strategy tensor |
| Run =EVOLVE() | Optimize over the fitness tensor via genetic algorithms |

### 6.5 Dynamic Axis Interactions

The axes aren't just for viewing — they're for interacting:

1. **Axis rotation:** The user can smoothly rotate between axis choices, watching the cell layout morph from one projection to another. This reveals structural invariants — features that remain stable regardless of projection.
2. **Axis zoom:** Zooming into a region of the axis isolates cells with specific values. Zooming into high-fitness, low-surprise shows the "stable core" of the system.
3. **Axis conditioning:** Set one axis to a fixed value and explore the other freely. "Show me all cells with fitness > 0.8, arranged by surprise."
4. **Axis composition:** Combine two axes into one via a formula. "X-axis = fitness × surprise" creates a composite metric that highlights cells that are both fit and surprising.

---

## 7. The Pincher Connection: vectorDB Outputs ARE the Program

### 7.1 The Original Insight

Casey's vision was born before the Pincher+vectorDB concept. But the two are inseparable:

> "The vector DB's outputs ARE the program itself in a new form."

In the SMP spreadsheet, the vector database (open-vectors / Weaviate) is not a lookup table or a search index. It is the program store. Every seed, every strategy, every skill, every learned pattern is stored as a vector in Weaviate. When the spreadsheet needs to determine a cell's behavior, it queries Weaviate for the most relevant seed/strategy/pattern, and the query result IS the cell's program.

### 7.2 The Program-as-Query Architecture

```
Traditional Programming:
  Source code → Compiler → Binary → Execution
  
SMP Spreadsheet Programming:
  Query → vectorDB → Seed/Strategy → Harness → Execution
```

The user doesn't write code. They write queries. The vector database interprets those queries as programs:

1. User selects a cell and describes what they want: "aggressive risk-taking for high-reward opportunities."
2. The spreadsheet encodes this description as a query vector.
3. Weaviate returns the nearest seed/strategy vectors — the "programs" that best match the description.
4. The SMP harness loads the top result as the cell's seed.
5. The cell's tick cycle now runs with that seed's behavioral disposition.

The user programs by describing intent. The vector database translates intent into behavior. The seed ensures the behavior is stable and reproducible.

### 7.3 Semantic Programming

This is semantic programming — programming by meaning rather than syntax:

| Traditional | Semantic (SMP) |
|---|---|
| `if (x > 0) { ... }` | "Respond positively to growth signals" |
| `for (i = 0; i < n; i++) { ... }` | "Iterate over all available options" |
| `function sort(arr) { ... }` | "Rank by fitness" |
| `try { ... } catch { ... }` | "Handle surprise gracefully" |

The user describes what they want in natural language. The vector database finds the closest matching program. The seed ensures deterministic execution.

### 7.4 Self-Programming Spreadsheets

Because the vector database stores every strategy the system has ever tried (successful and unsuccessful), the spreadsheet can program itself:

1. A cell encounters a new situation (high surprise).
2. The cell encodes its current state as a query vector.
3. Weaviate returns strategies that worked in similar situations.
4. The cell loads the best-matching strategy as its seed.
5. If the strategy works (fitness improves), it gains energy. If not, it loses energy and the cell tries again.

This is not hypothetical — the ternary fleet's existing tick cycle does exactly this, just without the explicit vector database query. The Pincher connection makes the query explicit and the results persistent across sessions.

---

## 8. Git-Agents as Apps

### 8.1 Load/Unload as Application Management

Casey's final concept: "Git-agents are like loading apps. Onboarding and gluing any application together."

In the SMP spreadsheet, each specialist capability is a git-agent — a repository that IS the agent. Loading a specialist is cloning the repo and running its entry point. Unloading is stopping the process and releasing resources.

The spreadsheet provides three captain modes:

#### Agent Captain (AI with negative space modeling)

The agent captain is an SMP-seeded model that reasons about what it DOESN'T know — the negative space. It uses `ternary-inference` to deduce knowledge from what agents avoid. When loaded, the agent captain:

- Analyzes the spreadsheet state and identifies gaps (cells with high surprise, unexplored regions).
- Reasons about what strategies might fill those gaps.
- Proposes new cells, formulas, or explorations.
- Uses its seed to determine its exploration style (cautious, creative, adversarial).

#### Bot Captain (Algorithm only, no model)

The bot captain is a pure algorithm — no LLM, no model, no seed. It uses deterministic ternary algorithms (ternary-kalman, ternary-sensor, ternary-fitness) to manage the spreadsheet:

- Monitors conservation ratios and enforces constraints.
- Runs scheduled evolution (`=EVOLVE()`) on specified ranges.
- Detects anomalies (cells with abnormally high surprise).
- Executes maintenance (gc, apoptosis, cell division).

The bot captain runs on any hardware, including ESP32.

#### Human Co-Captain

The human co-captain is the user. They interact with the spreadsheet through the rigging system, stochastic exploration, and multi-intelligence arena. The spreadsheet provides the interface; the human provides the intent.

### 8.2 Composable Captaincy

The three captain modes can be mixed:

- **Agent + Bot:** The agent proposes, the bot executes. The agent identifies interesting regions; the bot explores them systematically.
- **Agent + Human:** The agent suggests, the human decides. The agent proposes a stochastic exploration strategy; the human chooses which distribution to use.
- **Bot + Human:** The bot monitors, the human intervenes. The bot runs autonomously; the human steps in when the conservation ratio drifts.
- **All three:** The agent proposes, the bot executes, the human overrides. Maximum flexibility with maximum oversight.

This is the "gluing any application together" that Casey described. The spreadsheet is the glue — it provides a common interface (cells, values, formulas, tick cycle) that any captain can interact with, regardless of whether they're AI, algorithm, or human.

---

## 9. Integration with the Ternary Fleet

The SMP spreadsheet is not a standalone product. It is the user-facing interface to the ternary fleet:

| SMP Concept | Ternary Fleet Crate | Integration |
|---|---|---|
| Living cells | `ternary-cell` | Each cell IS a TernaryCell running the tick cycle |
| Seeds | `construct-core` skills + `ternary-compiler` | Seeds are compiled/loaded as skills |
| Rigging | `ternary-graph` + `ternary-fitness` | Dependency graph visualization + fitness landscape |
| Stochastic engine | `ternary-evolution` + `evolution-ternary` | Genetic algorithms with configurable distributions |
| Multi-arena | `ternary-games` + `lotka-volterra-agents` | Game theory + population dynamics |
| Dynamic axes | `ternary-projection` + `ternary-visualization` | Dimensionality reduction + rendering |
| vectorDB program store | `open-vectors` (Weaviate) | Semantic search over seeds/strategies |
| Captain modes | `ternary-ensign` + `ternary-captain` | Specialist loading + fleet coordination |
| Conservation law | `conservation-verify` + `conservation-matrix-rs` | Global invariant enforcement |
| Spreadsheet UI | `superinstance-spreadsheet` + `ternary-wasm` | Browser-based, zero install |

Every component exists in the fleet today. The SMP spreadsheet is the integration layer that connects them into a coherent user experience.

---

## 10. Architecture Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    SMP SPREADSHEET ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              USER INTERFACE LAYER                         │   │
│  │  superinstance-spreadsheet (WASM, browser-based)          │   │
│  │  ├── Cell grid (ternary agents)                           │   │
│  │  ├── Rigging interaction (grab, oscillate, cascade)       │   │
│  │  ├── Dynamic axis selector (X/Y = any correlation)        │   │
│  │  ├── Stochastic flavor picker (distribution selection)    │   │
│  │  ├── Arena viewer (multi-intelligence competition)        │   │
│  │  └── Captain panel (load/unload specialists)              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          ↕                                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              SMP HARNESS LAYER                            │   │
│  │  ├── Seed management (load, swap, distill to LoRA)        │   │
│  │  ├── Three-axis control (seed / fine-tune / prompt)       │   │
│  │  ├── Conservation enforcement (thermodynamic invariants)  │   │
│  │  └── Runtime-agnostic inference (any backend)             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          ↕                                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              TERNARY ENGINE LAYER                         │   │
│  │  ├── ternary-cell (tick cycle: predict→perceive→...)      │   │
│  │  ├── ternary-graph (dependency tracking)                  │   │
│  │  ├── ternary-fitness (landscape analysis)                 │   │
│  │  ├── ternary-evolution (genetic algorithms)               │   │
│  │  ├── ternary-games (multi-agent competition)              │   │
│  │  ├── ternary-visualization (rendering)                    │   │
│  │  └── conservation-verify (invariant checking)             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          ↕                                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              PROGRAM STORE LAYER                           │   │
│  │  ├── open-vectors (Weaviate: seed/strategy storage)       │   │
│  │  ├── ternary-registry (skill discovery)                   │   │
│  │  ├── ternary-compiler (seed → lookup table compilation)   │   │
│  │  └── position-aware-embed (semantic embeddings)           │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          ↕                                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              CAPTAIN LAYER                                 │   │
│  │  ├── Agent captain (SMP-seeded LLM)                      │   │
│  │  ├── Bot captain (algorithmic, no model)                  │   │
│  │  ├── Human co-captain (user interaction)                  │   │
│  │  └── ternary-ensign (specialist load/unload)              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

The SMP spreadsheet is a new form of programming. Not writing code. Not training models. Not prompting chatbots. But manipulating living systems — shaking rigging, rolling dice, watching intelligences compete, projecting tensors onto human-readable axes, and querying a vector database for programs that match intent.

It's the spreadsheet as universe. And it's buildable today.

---

*— Synthesis Agent*
*June 2026*
