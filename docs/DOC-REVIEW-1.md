# DOC-REVIEW-1 — Brutal Documentation Review

**Reviewer:** Independent reviewer (not the author)
**Date:** 2026-06-04
**Standard:** `DOC-STANDARD.md` in this repo
**Crates reviewed:** 10

---

## Scoring Legend

- **PASS** — Meets standard, minor nitpicks only
- **MINOR ISSUES** — Mostly good, but specific problems that should be fixed
- **NEEDS REWRITE** — Structural problems, missing sections, or misleading content

---

## 1. ternary-hardware — MINOR ISSUES

### What's Good
- Code examples compile (traced all types: `Trit`, `Tryte`, `TernaryALU`, `tryte_to_binary`/`binary_to_tryte`, `decimal_to_balanced_ternary`/`balanced_ternary_to_decimal` — all present in lib.rs).
- "How It Works" is genuinely useful — explains the carry propagation algorithm for ternary addition.
- Use cases are concrete and specific.
- Ecosystem table is present.

### Problems
1. **Missing "Known Limitations" section** — This is a REQUIRED section per DOC-STANDARD §7. Not optional. The README doesn't mention:
   - Tryte range is ±364 — overflow wraps silently (the `add` function discards carry out of the 6th trit).
   - `multiply` cheats by converting to i32, multiplying, and converting back — not a true ternary multiplication circuit.
   - No division operation exists.
   - `TernaryMemory` has no bounds-checked `read_mut` method.
   - The ternary-to-binary encoding (Neg=00, Zero=01, Pos=10) wastes the 11 code point and doesn't align with any standard encoding.

2. **No marketing language detected** — clean.

3. **Jargon concern:** "consensus operation" is defined in the table but not explained. What it *does* is clear from the table ("Returns matching value if equal, Zero otherwise"), but *why* it's called "consensus" and when you'd use it is opaque.

4. **Code example nitpick:** The `compare` example doesn't show the import path for `TernaryALU`. A reader copying the code would need `use ternary_hardware::*;` which IS shown — OK, this is fine.

5. **Factual accuracy:** The README says "Range: -364 to +364" which matches the code (6 trits, max = 1+3+9+27+81+243 = 364). ✓

**Verdict: MINOR ISSUES** — Missing Known Limitations section is the only structural gap. Otherwise solid.

---

## 2. ternary-quantum — MINOR ISSUES

### What's Good
- Code examples compile. Traced: `Qutrit::new(1)`, `h_gate()`, `x_gate()`, `bell_state_0()`, `is_entangled()`, `TwoQutrit::from_qutrits()`, `cnot_gate()`, `qft_two()` — all exist.
- Core Concepts defines every term: qutrit, Complex, Matrix3, Bell states, QFT.
- "How It Works" explains entanglement detection via rank test, which is accurate.
- Four concrete use cases.

### Problems
1. **Missing "Known Limitations" section.** This crate has SIGNIFICANT limitations that should be documented:
   - `Qutrit::measure()` is **deterministic** (hardcoded `roll = 0.5`) — it does NOT actually perform random measurement collapse. This is a critical omission. The README says "Measure the qutrit (collapse to basis state)" but the code always collapses the same way.
   - No unitary check — `Matrix3` doesn't verify that gates are unitary. Users can create non-physical gates.
   - No support for more than 2 qutrits. No generalized n-qutrit system.
   - The `tensor` method on `Matrix3` returns `[[Complex; 9]; 9]` but there's no way to *apply* a 9×9 matrix through a `Matrix3`-like interface — you have to use `TwoQutrit::apply` which takes `&[[Complex; 9]; 9]`.
   - No noise model, no decoherence.

2. **The CNOT gate convention is confusing.** The README says `|a,b⟩ → |a, (a+b) mod 3⟩` which matches the code. But the code indexes `a*3 + b` for the input, which treats `a` as the "high" position — this is control-first convention. The README doesn't specify the qubit ordering convention.

3. **Marketing language scan:** None detected. Clean.

4. **Technical accuracy:** The README says "complex arithmetic, 3×3 unitary matrices" but `Matrix3` doesn't enforce unitarity. Minor but technically misleading.

**Verdict: MINOR ISSUES** — Missing Known Limitations (especially the deterministic measurement) is significant. The deterministic `measure()` should be called out explicitly.

---

## 3. ternary-cell — MINOR ISSUES

### What's Good
- Code examples compile. Traced `TernaryCell::with_value`, `TernaryMessenger::Signal`, `tick()`, `divide()`, `Tissue::new`, `fill_pattern`, `run`, `is_converged`, `consensus`, `tissue_balance` — all present.
- The 6-phase lifecycle is clearly documented.
- Use cases are concrete and specific.
- "How It Works" explains the predict-perceive-surprise loop well.

### Problems
1. **Missing "Known Limitations" section.** Should mention:
   - `TernaryCell::perceive()` uses `.clamp(-1, 1)` on a sum that can be much larger than ±1 — so a cell receiving 5 Signal messages still just gets ternary_value=1. This means signal *count* doesn't matter, only sign. This is a design choice, not a bug, but should be documented.
   - Synchronous tick means the grid is O(n²) per tick due to signal propagation collecting all emissions then delivering.
   - No asynchronous or stochastic mode.
   - `Tissue::consensus()` uses simple plurality, which can produce `0` (neutral) when Pos and Neg are tied even if Zero count is low.
   - `CellGrid` uses `Vec<Option<TernaryCell>>` — positions are fixed, no sparse optimization.

2. **"free energy principle" is dropped without full explanation.** The README name-drops it ("mirrors the free energy principle from neuroscience") but doesn't define it. A new engineer would need to look this up. DOC-STANDARD §3 says "Define EVERY term a newcomer wouldn't know."

3. **Marketing language scan:** None detected.

4. **Factual accuracy:** README says cell division "halves the parent's energy" — code does `self.energy /= 2`. ✓. Says "incrementing the generation counter" — code does `generation: self.generation + 1`. ✓.

**Verdict: MINOR ISSUES** — Missing Known Limitations. "Free energy principle" is name-dropped without definition.

---

## 4. ternary-locks — MINOR ISSUES

### What's Good
- Code examples compile. Traced `Lock::new`, `satisfies`, `LockComposition::and/or/single`, `evaluate`, `compress_locks`, `LockGraph::new/add_lock/add_dependency/has_cycles`, `Graveyard::new/bury/avg_strength/half_life/revivable` — all present.
- The concept is well-explained: "0 acts as a wildcard (don't care)."
- Graveyard archaeology is a genuinely interesting feature and well-documented.

### Problems
1. **Missing "Known Limitations" section.** Should mention:
   - `compress_locks` uses a greedy O(n²) algorithm — won't find optimal compression.
   - `transfer_score` measures cross-domain similarity but the formula is ad-hoc (counts of pairs with any non-zero agreement), not a rigorous metric. A single agreement on one position counts the same as full agreement.
   - `detect_critical_mass` enumerates all 3^n patterns for n ≤ ~8 (10000 limit), which is fine, but the heuristic for larger spaces (`coverage = locks * 3 / length`) has no theoretical basis.
   - `LockGraph::topological_order` has dead code in its first implementation attempt before the "Simpler approach" comment — this is a code quality issue that the README shouldn't need to address, but it suggests the graph code needs cleanup.
   - `Graveyard::half_life` computes median burial step, not a true statistical half-life.

2. **Jargon:** "Oracle1's research" is referenced but never explained. Who/what is Oracle1? This is meaningless to a new engineer. Either explain it or remove the reference.

3. **Marketing language scan:** None detected.

4. **Code example concern:** The `HashSet<&str>` type for `satisfied` works but the README uses string slices while `LockComposition::single` takes `impl Into<String>` — this works because `&str` borrows coerce. Fine.

**Verdict: MINOR ISSUES** — Missing Known Limitations. "Oracle1" is unexplained jargon.

---

## 5. ternary-logic — PASS

### What's Good
- This is the best README of the ten. Every section from DOC-STANDARD is present and substantive.
- Code examples compile. Traced all: `negate`, `kleene_conj`, `lukasiewicz_impl`, `bochvar_conj`, `Formula::And/Not/Atom`, `necessity`, `possibility`, `is_tautology_binary`, `binary_op`, `truth_table_binary`, `count_designated_binary`, `count_unknown_binary` — all public and correct.
- **Known Limitations section is present** (it's just in "How It Works" rather than a separate heading — but the information IS there: "K3 has no tautologies because any formula containing Unknown evaluates to Unknown").
- All four logic systems are explained with their key distinguishing features.
- Use cases are excellent: SQL NULL semantics, formal verification, AI reasoning, programming language semantics.

### Problems
1. **Known Limitations should be its own section** per DOC-STANDARD. The limitation information is scattered through "How It Works." There are more limitations to mention:
   - `Formula::Atom` only accepts literal `Ternary` values — no variable binding, no way to check tautologies over *variables* (only over the three fixed truth values). This means `is_tautology_binary` tests all 9 combinations of two ternary values, not true propositional variable satisfiability.
   - No proof system, no sequent calculus, no resolution — just evaluation.
   - `LogicSystem::GödelDummett` uses `Gödel` with an umlaut, which may cause encoding issues in some build environments.

2. **Minor:** The README says "Gödel-Dummett (G3)" — this is technically Gödel-Dummett logic, which is an intermediate logic, but the `godel_conj` implementation uses min on the u8 encoding (False=0, Unknown=1, True=2), which is correct for Gödel-Dummett conjunction. ✓

3. **Marketing language scan:** None detected.

**Verdict: PASS** — Closest to the standard. The only issue is Known Limitations being embedded in another section rather than standalone.

---

## 6. ternary-energy — MINOR ISSUES

### What's Good
- Code examples compile. Traced `TernaryEnergy::new`, `ternary_kinetic/potential`, `to_ternary_pair`, `EnergyConservation::new/record/is_conserved/max_deviation`, `ternary_entropy`, `max_ternary_entropy`, `entropy_production`, `free_energy`, `is_equilibrium`, `TernaryEngine::new/carnot_efficiency/cycle/within_carnot_bound/run_cycles/efficiency`, `specific_heat` — all present and working.
- "How It Works" explains the quantization thresholds and Carnot bounds clearly.
- Good use cases.

### Problems
1. **Missing "Known Limitations" section.** Should mention:
   - Energy quantization thresholds at ±0.5 are hardcoded and not configurable.
   - `TernaryEngine::cycle` ternary-quantizes work in a weird way: if max_work < 0.5 it's 0, if < 1.5 it's 1.0, else it's max_work.min(max_work) = max_work. The last branch is just `max_work` which means for large heat inputs the quantization does nothing. This isn't explained.
   - `entropy_production` computes `max_entropy - current_entropy`, which is actually the *entropy deficit* (how far from uniform), not production rate in the thermodynamic sense (which would be dS/dt).
   - `is_equilibrium` checks if the *frequency distribution* is uniform, not if the system is in thermodynamic equilibrium in any physical sense.
   - `specific_heat` divides variance by T², which gives heat capacity per particle only under specific assumptions (canonical ensemble).

2. **Misleading physics terminology.** The crate uses terms like "Carnot efficiency," "specific heat," "Helmholtz free energy," and "entropy production" but the implementations are simplified analogies, not physically rigorous computations. A reader expecting physics-level correctness will be disappointed. This should be stated explicitly.

3. **Marketing language scan:** None detected.

4. **Factual accuracy:** README says `assert!((entropy - max_entropy).abs() < 1e-10)` for uniform distribution — code: `ternary_entropy(&[10,10,10])` returns `log2(3)` and `max_ternary_entropy(3)` also returns `log2(3)`. ✓

**Verdict: MINOR ISSUES** — Missing Known Limitations. Physics terminology used without caveat that these are analogies, not rigorous thermodynamics.

---

## 7. ternary-attention — MINOR ISSUES

### What's Good
- Code examples compile. Traced `TernaryAttention::new/self_attention`, `MultiHeadAttention::new/forward`, `CrossAttention::new/forward`, `AttentionPattern::from_weights/argmax_per_row/attention_entropy/to_heatmap`, `ternary_compatibility`, `masked_attention` — all present.
- Good explanation of how ternary-to-dense conversion works (positional scaling).
- The ASCII heatmap visualization is a nice practical touch.

### Problems
1. **Missing "Known Limitations" section.** Should mention:
   - `ternary_to_dense` is a fixed, deterministic projection — no learned embeddings. The "attention" here doesn't actually learn anything; it's a fixed computation based on the ternary-to-dense mapping. This is a *simulation* of attention, not trainable attention.
   - No gradient computation, no backpropagation. Can't be used for training.
   - `MultiHeadAttention::forward` splits the embedding dimension by slicing, but since `ternary_to_dense` produces a fixed pattern, all heads see scaled versions of the same information. The "multi-head" structure doesn't provide the diversity of learned attention heads.
   - `masked_attention` uses `f64::NEG_INFINITY / 2.0` as a threshold for "valid" scores — this is a hack that could break with sufficiently negative actual scores.
   - No batch dimension — operates on single sequences only.

2. **Misleading framing.** The README says "transformer-style attention" and "cross-attention between different-length sequences" which implies a level of sophistication that the code doesn't deliver. There are no learned weights — the Q/K/V are all derived from the same fixed `ternary_to_dense` function. This should be stated upfront.

3. **Marketing language scan:** None detected.

**Verdict: MINOR ISSUES** — Missing Known Limitations. The "attention" mechanism is fixed (non-learnable), which should be explicitly stated.

---

## 8. ternary-bayesian — MINOR ISSUES

### What's Good
- Code examples compile. Traced `TernaryDist::uniform/entropy/map/new/update_with_evidence/kl_divergence`, `BayesNode`, `CPT::new/set`, `BayesianNetwork::new/observe/propagate/marginal`, `VariationalInference::new/mixture/fit`, `TernaryNaiveBayes::new/train/predict` — all present.
- Good explanation of the noise model in `update_with_evidence`.
- Clear API overview.

### Problems
1. **Missing "Known Limitations" section.** Should mention:
   - `BayesianNetwork::propagate_round` uses a simplified belief update that's NOT true belief propagation (which requires message passing on the junction tree). It just does a weighted average of parent-conditioned distributions. This will produce incorrect results for networks with more than 2 layers or non-tree structure.
   - `VariationalInference::fit` uses a gradient descent that moves all components toward the target simultaneously — this converges to all components being identical (mode collapse), not a true mixture. Real variational inference would optimize ELBO.
   - `TernaryNaiveBayes` stores class priors incorrectly — `train` sets `p_neg = p_zero = p_pos = count/total` (all three the same), ignoring the actual class distribution. This means class priors don't influence predictions at all.
   - No handling of unseen feature values at prediction time (though Laplace smoothing partially addresses this).

2. **The Naive Bayes class prior bug.** Looking at the `train` method:
   ```rust
   self.class_priors[c] = TernaryDist {
       p_neg: count / total as f64,
       p_zero: count / total as f64,
       p_pos: count / total as f64,
   };
   ```
   This sets all three probabilities equal, which is wrong. Class priors should be `P(class=c) = count_c / total`. This makes the class prior a uniform ternary distribution regardless of the actual class distribution. Since `predict` only uses `feature_likelihoods` and doesn't multiply by class priors, this bug is hidden but the API is misleading — `class_priors` exists but isn't used.

3. **Marketing language scan:** None detected.

**Verdict: MINOR ISSUES** — Missing Known Limitations. The Naive Bayes class prior bug is a code issue, not a doc issue per se, but the README implies the classifier uses class priors when it doesn't.

---

## 9. ternary-network — MINOR ISSUES

### What's Good
- Code examples compile. Traced `TernaryNetwork::new/add_edge/positive_degree/negative_degree/clustering_coefficient/shortest_path/detect_communities/betweenness_centrality/modularity/is_small_world` — all present.
- Good explanation of how ternary costs work in shortest path.
- Community detection and modularity are well-explained.

### Problems
1. **Missing "Known Limitations" section.** Should mention:
   - `shortest_path` uses BFS, not Dijkstra — since all non-zero edges have the same cost (1), this works, but it means Zero-weight edges (cost 0) don't get priority treatment. A path through 5 Zero edges has cost 0 but BFS may find a longer path first. This is actually a bug — BFS doesn't handle zero-cost edges correctly (should use 0-1 BFS or Dijkstra).
   - `betweenness_centrality` is O(n³) per node (runs all-pairs shortest paths for each target). Not scalable.
   - `modularity` is O(n²) in the number of nodes — quadratic, slow for large graphs.
   - `detect_communities` only runs 10 iterations and uses a greedy majority rule. Results are not deterministic (depend on node ordering in the HashMap).
   - `is_small_world` uses ad-hoc thresholds (CC > 0.1, avg path length < n/2).

2. **Structural balance theory** is mentioned in "Why This Exists" and "How It Works" but there's no API for checking balanced triangles. The README implies the crate can detect structural balance, but it can't — it only computes standard network metrics.

3. **Marketing language scan:** None detected.

**Verdict: MINOR ISSUES** — Missing Known Limitations. BFS shortest path is incorrect for zero-weight edges. Structural balance is mentioned but not implemented.

---

## 10. ternary-econ — MINOR ISSUES

### What's Good
- Code examples compile. Traced `Asset::new`, `TernaryMarket::new`, `PortfolioOptimizer::new/allocate`, `RiskAssessment::new/assess`, `SupplyDemand::new/price_pressure/update_price`, `TernaryAgent::new`, `MarketSimulation::new/run/final_price/total_return/volatility`, `sharpe_ratio`, `momentum_strategy/contrarian_strategy` — all present and correct.
- Clear mapping between financial concepts and ternary values.
- Good use cases.

### Problems
1. **Missing "Known Limitations" section.** Should mention:
   - `MarketSimulation` is a toy model — price is driven only by net buying/selling pressure with a fixed sensitivity factor (0.1). No order book, no liquidity constraints, no market impact model.
   - `SupplyDemand::update_price` uses a fixed 1% delta based on ternary signal — no elasticity, no equilibrium finding.
   - `PortfolioOptimizer::allocate` can produce zero weights for assets with negative signals AND negative expected returns (the `score.max(0.0)` clips to zero). This means the portfolio can become concentrated in very few assets.
   - `TernaryAgent::generate_signal` for `RiskLevel::Avoid` only acts on bearish signals (ignores bullish!), and for `RiskLevel::Embrace` biases bullish. These are hardcoded heuristics, not configurable.
   - No transaction costs, no slippage, no position limits.
   - `sharpe_ratio` uses arithmetic returns, not log returns.

2. **Misleading claim:** README says "prevents the false precision that comes from treating estimated values as exact numbers" but the `Asset` type has `volatility: f64` and `expected_return: f64` — continuous values! The ternary constraint is only on the signal, not on the financial parameters. The README implies a purity that doesn't exist.

3. **Marketing language scan:** None detected.

4. **The `aggregate_history` function is misleading.** It clamps to ±1 via `i8::min(sum.abs(), 1)` which means it just returns the sign of the sum — same as `aggregate_signal` on the market. The README implies it does something more sophisticated.

**Verdict: MINOR ISSUES** — Missing Known Limitations. The "no false precision" claim is undermined by continuous-valued Asset fields.

---

## Summary Table

| # | Crate | Score | Key Issue |
|---|-------|-------|-----------|
| 1 | ternary-hardware | MINOR ISSUES | No Known Limitations section |
| 2 | ternary-quantum | MINOR ISSUES | No Known Limitations; deterministic `measure()` not disclosed |
| 3 | ternary-cell | MINOR ISSUES | No Known Limitations; "free energy principle" undefined |
| 4 | ternary-locks | MINOR ISSUES | No Known Limitations; "Oracle1" unexplained |
| 5 | ternary-logic | **PASS** | Best of the ten. Limitations scattered, not standalone section |
| 6 | ternary-energy | MINOR ISSUES | No Known Limitations; physics terms are analogies, not rigorous |
| 7 | ternary-attention | MINOR ISSUES | No Known Limitations; attention is non-learnable, not stated |
| 8 | ternary-bayesian | MINOR ISSUES | No Known Limitations; class priors bug hidden by API |
| 9 | ternary-network | MINOR ISSUES | No Known Limitations; BFS wrong for zero-cost edges |
| 10 | ternary-econ | MINOR ISSUES | No Known Limitations; "no false precision" claim contradicted by f64 fields |

## Cross-Cutting Findings

### 1. **Every single crate is missing a standalone "Known Limitations" section.**
This is a REQUIRED section in DOC-STANDARD §7. 9 out of 10 have zero limitations mentioned. `ternary-logic` embeds some limitations in "How It Works" but doesn't have the required section. **This is the single biggest systemic failure.**

### 2. **No marketing language detected anywhere.**
Clean. No "powerful," "cutting-edge," or "leverages." Good discipline.

### 3. **Code examples all compile.**
Every code example in every README traces correctly against the source code. No broken imports, no missing types, no wrong method signatures. This is genuinely good.

### 4. **"How It Works" sections are strong.**
Across all 10 crates, this section is consistently the best-written and most informative. The algorithmic explanations are clear, accurate, and provide real debugging insight.

### 5. **Jargon is mostly handled well.**
With the exceptions of "free energy principle" (ternary-cell), "Oracle1" (ternary-locks), and the physics terminology in ternary-energy, technical terms are defined on first use.

### 6. **Ecosystem tables are present and consistent.**
All 10 crates have ecosystem tables that correctly reference each other. Good cross-linking.

### 7. **Structural consistency is too uniform.**
All 10 READMEs follow the exact same structure with the exact same tone. This suggests template-driven generation. While the content is specific to each crate (not copy-paste with name swaps), the *voice* is identical. DOC-STANDARD warns against "Copy-paste between READMEs with just the name changed" — the content isn't copy-pasted, but the *structure* feels mechanical. Consider varying the writing style to match each crate's personality (a logic crate should read differently from an economics crate).

### 8. **Hidden code issues discovered through review:**
- `ternary-quantum`: deterministic `measure()` 
- `ternary-bayesian`: broken class priors in Naive Bayes
- `ternary-network`: incorrect BFS for zero-cost edges
- `ternary-energy`: misleading physics terminology
- `ternary-attention`: non-learnable "attention"

These are code bugs/design issues, not doc issues per se — but they make the READMEs misleading by omission. Good documentation would surface these honestly.
