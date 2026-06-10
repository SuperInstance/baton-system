# SMP Specification: Seeded-Model-Programming

**Status:** Technical Specification · **Date:** 2026-06-04 · **Version:** 0.1.0-draft

> SMP defines a third axis of model control — the seed — that determines inference disposition independently of fine-tuning and prompting. This document specifies the seed format, the harness API, and concrete examples.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Seed Format](#2-seed-format)
3. [Seed-Driven Inference](#3-seed-driven-inference)
4. [Independence of Axes](#4-independence-of-axes)
5. [Seed-to-LoRA Distillation](#5-distillation)
6. [Runtime-Agnostic Harness API](#6-harness-api)
7. [Seed Library: Concrete Examples](#7-examples)
8. [Seed Lifecycle](#8-lifecycle)
9. [Conservation Constraints on Seeds](#9-conservation)
10. [Serialization and Transport](#10-serialization)

---

## 1. Overview

### 1.1 Motivation

Current model control has two axes:

- **Fine-tuning** changes what the model knows (weights).
- **Prompting** changes what the model does right now (context).

Both are necessary but insufficient. Fine-tuning is expensive and slow. Prompting is cheap but fragile — small prompt changes produce large behavioral differences. There is no mechanism for creating stable, reproducible, swappable behavioral dispositions that are independent of both knowledge and context.

SMP introduces the **seed** as a third axis:

- **Seed** changes how the model reasons about what it knows (disposition).

A seed is a compact, deterministic data structure that constrains the model's output distribution without modifying weights. Different seeds produce qualitatively different behaviors from the same model, same fine-tuning, same prompt.

### 1.2 Design Principles

1. **Compactness:** A seed fits in 256 bytes to 4 KB. It can be transmitted as a URL parameter, stored in a spreadsheet cell, or embedded in a QR code.
2. **Determinism:** Same seed + same model + same prompt = same output. Always. Seeds are reproducible.
3. **Independence:** Seed, fine-tuning, and prompt can each change without affecting the others.
4. **Conservation:** Seeds obey the ternary conservation law. A seed that violates conservation is invalid.
5. **Runtime-agnostic:** Seeds work with any inference runtime — PyTorch, ONNX, WASM, TFLite, custom.
6. **Distillable:** A seed's behavioral patterns can be distilled into a LoRA for permanent weight integration.

---

## 2. Seed Format

### 2.1 Binary Layout

An SMP seed is a packed binary structure with three sections:

```
Offset  Size         Field                    Description
──────  ───────────  ───────────────────────  ───────────────────────────────────
0x00    4 bytes      magic                    0x534D5021 ("SMP!")
0x04    2 bytes      version                  Format version (uint16, currently 0x0001)
0x06    1 byte       flags                    Bit field (see §2.2)
0x07    1 byte       strategy_vector_len      Length of strategy vector in trits (8-256)
0x08    1 byte       weight_count             Number of ternary weights (0-255)
0x09    1 byte       reserved                 Reserved for future use (must be 0)
0x0A    SV_LEN bits  strategy_vector          Packed ternary strategy vector (2 bits/trit)
0x0A +  WC bits     ternary_weights          Packed ternary weight mask (2 bits/trit)
  SV_LEN
0x0A +  32 bytes     conservation_params      8 × float32 (see §2.4)
  SV_LEN
  + WC
──────  ───────────  ───────────────────────  ───────────────────────────────────
Total:  10 + ceil(SV_LEN/4) + ceil(WC/4) + 32 bytes
        Minimum: 42 bytes (SV_LEN=8, WC=0)
        Typical:  80-200 bytes (SV_LEN=64, WC=32-128)
        Maximum: ~4 KB (SV_LEN=256, WC=255)
```

### 2.2 Flags Field

```
Bit 7 (0x80):  TERNARY_ENCODING  — 0 = standard binary trits, 1 = ternary-encoded
Bit 6 (0x40):  DISTILLABLE       — 0 = pure seed, 1 = can be distilled to LoRA
Bit 5 (0x20):  SIGNED            — 0 = unsigned seed (public), 1 = signed (verified)
Bit 4 (0x10):  COMPRESSED        — 0 = raw, 1 = strategy_vector is LZ4-compressed
Bits 3-0:      RESERVED          — Must be 0
```

### 2.3 Strategy Vector Encoding

Each trit in the strategy vector is encoded as 2 bits:

| Trit Value | Binary | Meaning |
|---|---|---|
| -1 (Suppress) | `00` | Inhibit, avoid, reject |
| 0 (Silence) | `01` | Maintain, ignore, neutral |
| +1 (Signal) | `10` | Promote, encourage, accept |
| (invalid) | `11` | Reserved — must not appear |

The strategy vector is packed MSB-first: the first trit occupies bits 7-6 of byte 0, the second trit occupies bits 5-4, etc.

**Example:** Strategy vector [-1, 0, +1, 0] encodes as binary `00 01 10 01` = `0x39` (with remaining bits zero-padded).

### 2.4 Conservation Parameters

Eight float32 values that define the seed's thermodynamic profile:

| Offset | Field | Type | Range | Description |
|---|---|---|---|---|
| +0 | `gamma` | f32 | [0.0, 1.0] | Avoidance ratio — how much the seed suppresses vs. promotes |
| +4 | `entropy_target` | f32 | [0.0, 3.0] | Target entropy — desired output diversity |
| +5 | `volume` | f32 | [1.0, ∞) | Population volume — scale parameter |
| +8 | `temperature` | f32 | [0.01, 100.0] | Sampling temperature for seed-shaped outputs |
| +12 | `mutation_rate` | f32 | [0.0, 1.0] | How much the seed allows variation from its disposition |
| +16 | `crossover_rate` | f32 | [0.0, 1.0] | How much the seed blends with other seeds |
| +20 | `exploration_bonus` | f32 | [0.0, 10.0] | Extra weight for novel outputs |
| +24 | `fitness_pressure` | f32 | [0.0, 10.0] | Selection pressure toward high-fitness outputs |

### 2.5 JSON Representation

For human readability and debugging, seeds can be represented as JSON:

```json
{
  "version": 1,
  "flags": {
    "ternary_encoding": false,
    "distillable": true,
    "signed": false,
    "compressed": false
  },
  "strategy_vector": [-1, 0, 1, 0, -1, 1, 0, -1, 1, 1, 0, -1],
  "ternary_weights": {
    "output_tokens": [1, 1, 0, -1, -1, 0, 1, 0],
    "attention_heads": [1, 0, -1, 1, 0, 0, -1, 1],
    "response_modes": [0, 1, -1]
  },
  "conservation_params": {
    "gamma": 0.35,
    "entropy_target": 1.2,
    "volume": 10.0,
    "temperature": 0.8,
    "mutation_rate": 0.1,
    "crossover_rate": 0.3,
    "exploration_bonus": 1.5,
    "fitness_pressure": 2.0
  }
}
```

### 2.6 Ternary-Encoded Seeds

When the `TERNARY_ENCODING` flag is set, the strategy vector uses balanced ternary encoding rather than binary trits. Balanced ternary represents each trit as a power of 3, enabling arithmetic operations on seeds:

```
Standard encoding: [-1, 0, +1] as 2-bit pairs
Ternary encoding:  each group of 4 trits as a base-3 number

Example: [+1, 0, -1, +1] = 1×27 + 0×9 + (-1)×3 + 1×1 = 25 (in balanced ternary)
```

Ternary encoding enables seed arithmetic: `seed_a + seed_b` produces a new seed whose disposition is the sum of the two. This is the foundation of seed composition.

---

## 3. Seed-Driven Inference

### 3.1 The Inference Pipeline

Seed-driven inference modifies the standard inference pipeline at two points:

```
Standard Inference:
  Input → Tokenize → Model Forward Pass → Output Distribution → Sample → Output

Seed-Driven Inference:
  Input → Tokenize → Model Forward Pass → Output Distribution
                                                ↓
                                    [Seed Ternary Weight Mask]
                                                ↓
                                    Masked Distribution
                                                ↓
                                    [Conservation Rescaling]
                                                ↓
                                    [Temperature Scaling]
                                                ↓
                                    Sample → Output
```

### 3.2 Ternary Weight Masking

The seed's ternary weights are applied to the model's output distribution before sampling:

```
For each element i in the output distribution:
  if weight[i] == +1 (Signal):    scale[i] = 1 + exploration_bonus × signal_strength
  if weight[i] ==  0 (Silence):   scale[i] = 1.0 (unchanged)
  if weight[i] == -1 (Suppress):  scale[i] = 1 / (1 + fitness_pressure × suppress_strength)

Apply: output_distribution[i] *= scale[i]
Then:  renormalize to sum to 1.0
```

Where:
- `signal_strength` and `suppress_strength` are derived from the conservation params
- The rescaling preserves the relative ordering of outputs (promoted outputs remain promoted, suppressed outputs remain suppressed)
- The renormalization ensures the distribution remains valid

### 3.3 Conservation Rescaling

After masking, the distribution is checked against the conservation law:

```
γ + H ≈ 1.283 - 0.159 × log(V)

Where:
  γ = fraction of outputs that are suppressed (weight = -1)
  H = Shannon entropy of the masked distribution
  V = number of non-suppressed outputs
```

If the masked distribution violates conservation (deviation > tolerance), the distribution is rescaled:

```
rescale_factor = target_conservation / actual_conservation
entropy_adjustment = log(rescale_factor) × entropy_target
temperature_adjusted = temperature × rescale_factor
```

This ensures that no seed can create a distribution that violates thermodynamic constraints. The conservation law is the physics of SMP — it cannot be broken, only shaped within its bounds.

### 3.4 Seed Influence on Strategy Species

The strategy vector determines which of the five strategy species the seed favors:

```
Strategy Vector Analysis:
  sv_entropy = Shannon_entropy(strategy_vector)
  sv_balance = count(+1) / (count(+1) + count(-1))
  sv_sparsity = count(0) / len(strategy_vector)

Species Classification:
  if sv_entropy > 1.5 && sv_balance > 0.6:  Explorer
  if sv_entropy > 1.0 && abs(sv_balance - 0.5) < 0.15: Diplomat
  if sv_entropy < 0.8 && sv_balance > 0.7:  Marksman
  if sv_entropy < 1.0 && sv_balance < 0.7:  Climber
  if sv_sparsity > 0.7:                      Prospector
```

A seed can favor multiple species (mixed classification). The dominant species determines the seed's primary behavioral mode; secondary species influence but don't override.

---

## 4. Independence of Axes

### 4.1 Formal Independence Proof Sketch

The three axes (seed, fine-tuning, prompt) are independent if changing one does not constrain the others. Formally:

**Seed independence:** For any seed S, fine-tuning F, and prompt P, the output O(S, F, P) can take any value in the output space. Changing S does not reduce the output space achievable by varying F and P.

**Fine-tuning independence:** For any fine-tuning F, the seed S can produce any behavioral disposition. Changing F (updating weights) does not change the set of achievable dispositions.

**Prompt independence:** For any prompt P, the seed S can produce any behavioral disposition. The prompt constrains the content of the output but not the disposition.

The ternary weight mask ensures seed independence: the mask is applied AFTER the model's forward pass, so it shapes the distribution without constraining the model's computation. The model produces the same raw distribution regardless of the seed; the seed only affects post-processing.

Fine-tuning independence holds because seeds operate on the output distribution, not the weights. Changing the weights changes the raw distribution, but the seed's masking and rescaling apply equally to any raw distribution.

Prompt independence holds because the prompt determines the input to the model, not the output masking. Different prompts produce different raw distributions, but the same seed shapes all distributions the same way.

### 4.2 Practical Independence

In practice, the three axes interact:

- A seed that promotes creative outputs + a prompt for creative writing = highly creative output (synergistic).
- A seed that promotes cautious outputs + a prompt for creative writing = cautiously creative output (moderated).
- A seed that promotes adversarial outputs + fine-tuning on legal documents = adversarial legal analysis (specialized).

The interaction is not a violation of independence — it's the point. Independence means each axis can be changed freely, not that the axes don't interact. The interaction IS the programming model.

---

## 5. Seed-to-LoRA Distillation

### 5.1 Why Distill?

Seeds are runtime artifacts — they shape inference behavior on the fly. But sometimes you want to "bake in" a seed's behavior permanently:

1. **Performance:** Seed masking adds a post-processing step. A LoRA that encodes the same behavior eliminates this overhead.
2. **Compatibility:** Some runtimes don't support seed injection. A LoRA works everywhere LoRA is supported.
3. **Composition:** Multiple seeds can be distilled into a single LoRA, combining their behaviors.
4. **Distribution:** A LoRA can be shared as a single file, without requiring the SMP harness.

### 5.2 Distillation Process

```
Input: seed S, base model M, calibration dataset D

1. Generate seed-shaped outputs:
   For each input x in D:
     raw_output = M.forward(x)
     shaped_output = apply_seed_mask(raw_output, S)
     record (x, shaped_output)

2. Compute LoRA target:
   For each weight matrix W in M:
     delta_W = minimize loss(W + delta_W produces shaped_outputs for inputs in D)
     (Use standard LoRA rank factorization: delta_W = A × B, rank r)

3. Validate:
   For each input x in test_split(D):
     lora_output = M_with_lora.forward(x)
     seed_output = apply_seed_mask(M.forward(x), S)
     assert KL(lora_output, seed_output) < threshold

4. Output: LoRA weights (A, B matrices for each adapted layer)
```

### 5.3 Distillation Quality Metrics

| Metric | Formula | Acceptable Range |
|---|---|---|
| KL Divergence | KL(seed_output ‖ lora_output) | < 0.1 |
| Behavioral Fidelity | correlation(seed_actions, lora_actions) | > 0.9 |
| Conservation Preservation | |γ_seed - γ_lora| | < 0.05 |
| Entropy Preservation | |H_seed - H_lora| | < 0.2 |
| Species Classification Match | class(seed) == class(lora) | Required |

### 5.4 Multi-Seed Distillation

Multiple seeds can be distilled into a single LoRA by interpolating their target outputs:

```
combined_output = w1 × seed1_output + w2 × seed2_output + ... + wn × seedn_output
where w1 + w2 + ... + wn = 1.0 (interpolation weights)
```

This creates a LoRA that captures the combined behavioral profile of multiple seeds — "meshing" them together. The interpolation weights determine the relative influence of each seed's disposition.

---

## 6. Runtime-Agnostic Harness API

### 6.1 Core Trait

```rust
/// The SMP Harness — runtime-agnostic interface for seed-driven inference.
pub trait SmpHarness {
    /// Load a seed into the harness.
    /// Returns an error if the seed violates conservation constraints.
    fn load_seed(&mut self, seed: SmpSeed) -> Result<SeedHandle, SmpError>;
    
    /// Unload the current seed.
    fn unload_seed(&mut self, handle: SeedHandle) -> Result<(), SmpError>;
    
    /// Set the prompt for the next inference.
    fn set_prompt(&mut self, prompt: &str) -> Result<(), SmpError>;
    
    /// Run inference with the current seed + prompt + model.
    /// The seed's ternary weights shape the output distribution.
    fn infer(&mut self, input: &[u8]) -> Result<InferenceOutput, SmpError>;
    
    /// Run inference with a specific seed override (one-shot).
    fn infer_with_seed(
        &mut self,
        seed: &SmpSeed,
        input: &[u8],
    ) -> Result<InferenceOutput, SmpError>;
    
    /// Distill the current seed into a LoRA weight delta.
    fn distill_to_lora(
        &self,
        calibration_data: &[CalibrationSample],
        lora_rank: usize,
    ) -> Result<LoraDelta, SmpError>;
    
    /// Check if a seed is valid (conservation law satisfied).
    fn validate_seed(&self, seed: &SmpSeed) -> Result<SeedValidation, SmpError>;
    
    /// Get the current seed's strategy species classification.
    fn classify_seed(&self, seed: &SmpSeed) -> StrategySpecies;
}

/// Handle to a loaded seed.
#[derive(Debug, Clone, Copy)]
pub struct SeedHandle(pub u64);

/// Output from seed-driven inference.
#[derive(Debug)]
pub struct InferenceOutput {
    /// The model's raw output distribution (before seed masking).
    pub raw_distribution: Vec<f32>,
    /// The seed-masked distribution (after seed application).
    pub masked_distribution: Vec<f32>,
    /// The selected output (after sampling from masked distribution).
    pub output: Vec<u8>,
    /// Conservation ratio of the masked distribution.
    pub conservation_ratio: f64,
    /// Strategy species classification of the seed used.
    pub species: StrategySpecies,
    /// The seed's influence metrics.
    pub seed_influence: SeedInfluence,
}

/// Metrics describing how much the seed shaped the output.
#[derive(Debug)]
pub struct SeedInfluence {
    /// How much the seed changed the output distribution (KL divergence).
    pub distribution_shift: f64,
    /// Fraction of outputs promoted by the seed.
    pub promoted_fraction: f64,
    /// Fraction of outputs suppressed by the seed.
    pub suppressed_fraction: f64,
    /// Entropy change: masked entropy - raw entropy.
    pub entropy_delta: f64,
}

/// Validation result for a seed.
#[derive(Debug)]
pub struct SeedValidation {
    pub is_valid: bool,
    pub conservation_deviation: f64,
    pub warnings: Vec<String>,
}

/// The five strategy species.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StrategySpecies {
    Explorer,
    Diplomat,
    Marksman,
    Climber,
    Prospector,
}

/// A LoRA weight delta distilled from a seed.
#[derive(Debug)]
pub struct LoraDelta {
    /// Layer name → (A matrix, B matrix).
    pub deltas: HashMap<String, (Vec<f32>, Vec<f32>)>,
    /// Rank of the LoRA decomposition.
    pub rank: usize,
    /// The seed that was distilled.
    pub source_seed: SmpSeed,
    /// Quality metrics from distillation.
    pub quality: DistillationQuality,
}
```

### 6.2 Backend Implementations

The harness trait is implemented for multiple backends:

| Backend | Crate | Inference Method | Status |
|---|---|---|---|
| PyTorch | `smp-pytorch` | Python/C++ model forward pass | Planned |
| ONNX Runtime | `smp-onnx` | ONNX model execution | Planned |
| WASM | `smp-wasm` | Browser-based inference via WASM | Planned |
| Candle | `smp-candle` | Pure Rust inference | Planned |
| Local models | `smp-local` | Liquid AI / Phi via local runtime | Planned |
| Mock | `smp-mock` | Deterministic test harness | Implemented |

### 6.3 Backend Registration

```rust
/// Register a backend implementation.
pub fn register_backend(name: &str, factory: Box<dyn SmpHarnessFactory>) -> Result<(), SmpError>;

/// Create a harness from a registered backend.
pub fn create_harness(backend: &str, model_path: &str) -> Result<Box<dyn SmpHarness>, SmpError>;
```

---

## 7. Seed Library: Concrete Examples

### 7.1 Card Game Strategist

A seed that produces strategic, game-theoretic reasoning optimized for competitive card games.

```json
{
  "name": "card-game-strategist",
  "description": "Strategic reasoning optimized for competitive card games. Explores novel strategies through stochastic play, identifies opponent patterns, and adapts tactics dynamically.",
  "strategy_vector": [
    1, 1, -1, 0, 1, -1, 0, 1,
    -1, 0, 1, 1, 0, -1, 1, 0,
    1, -1, 0, 1, -1, 1, 0, -1,
    0, 1, -1, 1, 0, 1, -1, 0,
    1, 0, -1, 1, 1, 0, -1, 1,
    0, 1, -1, 0, 1, 1, -1, 0,
    -1, 1, 0, 1, -1, 0, 1, 1,
    0, -1, 1, 0, 1, -1, 1, 0
  ],
  "ternary_weights": {
    "novel_moves": [1, 1, 1, 0, 0],
    "conventional_plays": [0, 0, -1, 0, 0],
    "bluffing": [1, 0, 1, 1, 0],
    "conservative_plays": [-1, -1, 0, 0, 0]
  },
  "conservation_params": {
    "gamma": 0.3,
    "entropy_target": 1.5,
    "volume": 12.0,
    "temperature": 1.2,
    "mutation_rate": 0.25,
    "crossover_rate": 0.4,
    "exploration_bonus": 3.0,
    "fitness_pressure": 1.5
  }
}
```

**Behavioral profile:** High exploration (entropy 1.5, exploration_bonus 3.0) with moderate fitness pressure. Promotes novel moves and bluffing while suppressing conservative plays. The alternating +1/-1 pattern in the strategy vector creates a "swingy" disposition that matches card game dynamics. Species classification: Explorer with Prospector secondary.

### 7.2 D&D Dungeon Master

A seed that produces creative storytelling with rule consistency.

```json
{
  "name": "dungeon-master",
  "description": "Creative storytelling with consistent rule enforcement. Generates vivid descriptions, manages complex scenarios, and maintains narrative coherence while allowing player agency.",
  "strategy_vector": [
    1, 0, 1, 1, 0, 1, 0, 1,
    1, 1, 0, 1, 0, 0, 1, 1,
    0, 1, 1, 0, 1, 1, 0, 1,
    1, 0, 1, 0, 1, 1, 0, 1,
    0, 1, 1, 1, 0, 1, 1, 0,
    1, 0, 1, 1, 0, 1, 0, 1,
    1, 1, 0, 1, 1, 0, 1, 0,
    0, 1, 0, 1, 1, 1, 0, 1
  ],
  "ternary_weights": {
    "creative_description": [1, 1, 1, 1, 1],
    "rule_enforcement": [0, 0, 1, 0, 0],
    "player_agency": [1, 1, 0, 1, 1],
    "narrative_consistency": [1, 0, 1, 0, 1],
    "meta_gaming": [-1, -1, -1, -1, 0],
    "fourth_wall_breaks": [-1, -1, 0, -1, -1]
  },
  "conservation_params": {
    "gamma": 0.2,
    "entropy_target": 1.8,
    "volume": 20.0,
    "temperature": 1.5,
    "mutation_rate": 0.35,
    "crossover_rate": 0.2,
    "exploration_bonus": 2.5,
    "fitness_pressure": 0.8
  }
}
```

**Behavioral profile:** Very high exploration (entropy 1.8, temperature 1.5) with low fitness pressure — creativity is prioritized over optimization. Suppresses meta-gaming and fourth-wall breaks while promoting creative description and player agency. The mostly +1 strategy vector creates a generative disposition. Species classification: Explorer with Climber secondary.

### 7.3 Code Reviewer

A seed that produces precise, actionable code review feedback.

```json
{
  "name": "code-reviewer",
  "description": "Precise, actionable code review feedback. Identifies bugs, style issues, architectural concerns, and security vulnerabilities with high confidence and low noise.",
  "strategy_vector": [
    0, -1, 0, 1, 0, -1, 0, 1,
    0, 0, -1, 0, 1, 0, -1, 0,
    0, 1, 0, -1, 0, 0, 1, 0,
    -1, 0, 0, 1, 0, -1, 0, 0,
    1, 0, -1, 0, 0, 1, 0, -1,
    0, 1, 0, 0, -1, 0, 1, 0,
    0, -1, 0, 1, 0, 0, -1, 0,
    1, 0, 0, -1, 0, 1, 0, 0
  ],
  "ternary_weights": {
    "bug_detection": [1, 1, 0, 1, 1],
    "style_suggestions": [0, 0, 1, 0, 0],
    "architectural_concerns": [1, 0, 1, 0, 1],
    "security_issues": [1, 1, 1, 1, 0],
    "nitpicks": [-1, -1, 0, -1, -1],
    "vague_comments": [-1, -1, -1, -1, -1],
    "actionable_fixes": [1, 1, 1, 1, 1]
  },
  "conservation_params": {
    "gamma": 0.45,
    "entropy_target": 0.6,
    "volume": 8.0,
    "temperature": 0.4,
    "mutation_rate": 0.05,
    "crossover_rate": 0.1,
    "exploration_bonus": 0.3,
    "fitness_pressure": 4.0
  }
}
```

**Behavioral profile:** Low exploration (entropy 0.6, temperature 0.4) with high fitness pressure — precision is paramount. Suppresses nitpicks and vague comments while strongly promoting bug detection, security issues, and actionable fixes. The sparse, targeted strategy vector creates a focused disposition. Species classification: Marksman (primary) with Climber secondary.

### 7.4 Negotiator

```json
{
  "name": "negotiator",
  "description": "Adaptive negotiation strategy. Mirrors opponent behavior, finds mutually beneficial outcomes, and adjusts between cooperative and competitive tactics based on context.",
  "strategy_vector": [
    1, 0, -1, 0, 1, 0, -1, 0,
    0, 1, 0, -1, 0, 1, 0, -1,
    1, 0, -1, 0, 1, 0, -1, 0,
    0, 1, 0, -1, 0, 1, 0, -1,
    -1, 0, 1, 0, -1, 0, 1, 0,
    0, -1, 0, 1, 0, -1, 0, 1,
    -1, 0, 1, 0, -1, 0, 1, 0,
    0, -1, 0, 1, 0, -1, 0, 1
  ],
  "ternary_weights": {
    "mutual_benefit": [1, 1, 1, 0, 1],
    "opponent_positions": [1, 0, 1, 1, 0],
    "competitive_moves": [0, 1, 0, 1, 0],
    "escalation": [-1, 0, -1, 0, -1],
    "concession": [0, 1, 0, 1, 0],
    "deadlock": [-1, -1, -1, -1, 0]
  },
  "conservation_params": {
    "gamma": 0.35,
    "entropy_target": 1.0,
    "volume": 15.0,
    "temperature": 0.9,
    "mutation_rate": 0.15,
    "crossover_rate": 0.5,
    "exploration_bonus": 1.0,
    "fitness_pressure": 2.0
  }
}
```

**Behavioral profile:** Balanced entropy (1.0) with moderate fitness pressure. The perfectly mirroring strategy vector (+1, 0, -1 pattern repeated) creates the Diplomat's signature behavior — matching the opponent's approach. High crossover rate enables blending strategies. Species classification: Diplomat (primary) with Climber secondary.

---

## 8. Seed Lifecycle

### 8.1 Creation

Seeds are created through four mechanisms:

1. **Manual construction:** A human designs the strategy vector, ternary weights, and conservation params by hand. Suitable for well-understood behavioral profiles.
2. **Evolutionary discovery:** The `=EVOLVE()` formula evolves seeds through genetic algorithms. The fitness function measures how well the seed produces desired behavior on a test set.
3. **Behavioral capture:** The seed is constructed from observing an expert's decisions. Each decision is encoded as a ternary signal (+1 for actions taken, -1 for actions avoided, 0 for neutral). The aggregate pattern becomes the strategy vector.
4. **Semantic query:** The user describes the desired behavior in natural language. The vector database finds the nearest matching seed. This is the Pincher connection — the query IS the program.

### 8.2 Validation

Every seed is validated before use:

```
1. Check magic number (0x534D5021).
2. Check version compatibility.
3. Decode strategy vector and ternary weights.
4. Verify no invalid trit values (11 in 2-bit encoding).
5. Compute conservation ratio: γ + H vs. target.
6. If deviation > 0.1: REJECT (seed violates conservation).
7. Classify strategy species.
8. Return SeedValidation { is_valid, conservation_deviation, warnings }.
```

### 8.3 Deployment

Seeds deploy to the harness via `load_seed()`. The harness:

1. Validates the seed.
2. Compiles the ternary weights into an efficient mask (pre-computed scaling factors).
3. Pre-computes the conservation rescaling parameters.
4. Returns a `SeedHandle` for subsequent inference calls.

### 8.4 Evolution in Production

Seeds can evolve during use:

```
1. Run inference with current seed.
2. Measure outcome fitness.
3. If fitness < threshold: mutate the seed (flip random trits in strategy vector).
4. Re-validate (conservation check).
5. If valid: replace current seed.
6. If invalid: revert mutation.
```

This is Lamarckian evolution — the seed adapts to its environment during its lifetime. Combined with the stochastic exploration engine, it enables seeds that improve over time without human intervention.

### 8.5 Retirement

When a seed is no longer needed:

1. **Distill to LoRA** (if the behavior is worth preserving permanently).
2. **Store in vectorDB** (for future retrieval via semantic query).
3. **Discard** (if the behavior was exploratory and not valuable).

---

## 9. Conservation Constraints on Seeds

### 9.1 Why Conservation Matters

The ternary conservation law is not an arbitrary constraint — it is the thermodynamic principle that guarantees system health. A seed that violates conservation would create an inference distribution that is either too uniform (all outputs equally likely — no information) or too peaked (one output dominates — no diversity). Conservation ensures the seed produces distributions that are neither too flat nor too peaked.

### 9.2 Conservation Validation Formula

```
For a seed S with strategy vector V and ternary weights W:

γ = count(W == -1) / count(W != 0)  [avoidance ratio]
H = Shannon_entropy(V)               [strategy entropy]
V_count = count(V != 0)              [non-silent volume]

target = 1.283 - 0.159 × log(V_count)
actual = γ + H

valid = |actual - target| < tolerance
```

### 9.3 Conservation Repair

If a seed fails validation, it can be repaired by adjusting the ternary weights:

```
1. If γ too high (too much suppression):
   - Convert some -1 weights to 0 (reduce suppression).
2. If γ too low (too little suppression):
   - Convert some 0 weights to -1 (increase suppression).
3. If H too high (strategy vector too random):
   - Introduce structure (cluster +1 and -1 values).
4. If H too low (strategy vector too uniform):
   - Introduce randomness (flip some values).
5. Re-validate.
```

---

## 10. Serialization and Transport

### 10.1 Binary Format

The primary serialization format is packed binary (see §2.1). Binary seeds are:

- Compact (42 bytes to 4 KB).
- Fast to deserialize (no parsing, just struct casting).
- Suitable for network transmission, file storage, and embedding in other data structures.

### 10.2 Base64 Encoding

For text-safe transport (URLs, JSON, spreadsheets), seeds are base64-encoded:

```
binary_seed → base64_encode → "U01QIQA..." (56-5500 characters)
```

A base64-encoded seed can be stored in a spreadsheet cell, passed as a URL parameter, or included in a JSON payload.

### 10.3 QR Code

Compact seeds (up to 200 bytes = ~270 base64 characters) fit in a QR code. This enables:

- Sharing seeds by scanning a QR code.
- Embedding seeds in printed materials.
- Distributing seeds at conferences or meetups.

### 10.4 Ternary-Encoding Storage

For ternary fleet environments, seeds can be stored in the ternary protocol format:

```
seed → ternary_encode → {-1, 0, +1}^N → ternary-protocol message
```

This enables seeds to flow through the fleet's existing communication channels without a special protocol.

### 10.5 vectorDB Storage

Seeds are stored in Weaviate (open-vectors) as vector objects:

```json
{
  "class": "SmpSeed",
  "properties": {
    "name": "card-game-strategist",
    "description": "Strategic reasoning for competitive card games...",
    "species": ["Explorer", "Prospector"],
    "conservation_ratio": 0.98,
    "created_at": "2026-06-04T16:00:00Z",
    "author": "user@example.com"
  },
  "vector": [0.35, 1.5, 12.0, 1.2, 0.25, 0.4, 3.0, 1.5, ...]
}
```

The vector is the seed's conservation parameters, enabling similarity search over behavioral profiles. "Find me seeds that are more exploratory than this one" → vector search on entropy_target and exploration_bonus.

---

*This specification is a living document. As the SMP system evolves, so will this spec.*

*— Synthesis Agent*
*June 2026*
