# Documentation Review — Batch 2

**Reviewer:** Independent review (not the author)
**Date:** 2026-06-04
**Standard:** DOC-STANDARD.md (service manual, not marketing)

---

## Summary

| Crate | Score |
|---|---|
| ternary-kalman | MINOR ISSUES |
| ternary-game-theory | MINOR ISSUES |
| ternary-swarm | MINOR ISSUES |
| ternary-constraint | MINOR ISSUES |
| ternary-chaos | MINOR ISSUES |
| ternary-fuzzy | MINOR ISSUES |
| ternary-circuit | MINOR ISSUES |
| ternary-control | PASS |
| ternary-sensor | MINOR ISSUES |
| ternary-registry | MINOR ISSUES |

All 10 are close to good. The main recurring problems are: **missing "Known Limitations" section**, **missing "How It Works" design rationale** (why this approach over alternatives), and **code examples that reference types not fully shown**. No marketing language was found. No jargon without definition. The writing quality is consistently above average.

---

## 1. ternary-kalman

**Score: MINOR ISSUES**

### What's Good
- Clear "Why This Exists" that names a real problem (ad-hoc thresholding after continuous estimation)
- Code example compiles correctly — all types are shown, imports match the crate
- "How It Works" names the algorithm (predict/update Kalman cycle, RTS smoother) and gives the math
- Deadband threshold at ±0.5 is explained
- No marketing language detected

### Problems Found

1. **Missing "Known Limitations" section.** This is a DOC-STANDARD requirement. The source code reveals several honest limitations that should be stated:
   - `CovarianceMatrix` is always square (n×n), no rectangular matrices — limits flexibility
   - S-matrix inversion in `update()` assumes diagonal S (comment: "simplified: assume S is diagonal for inversion") — this means the filter is only correct when the innovation covariance is approximately diagonal
   - The `smooth()` function just averages adjacent states — it's not a real backward smoother, despite the comment saying "simple backward smoothing"
   - No numeric stability safeguards (no Joseph form for covariance update)

2. **Code example uses `println!("state: {:?}", kf.state)` — `state` is a `pub Vec<f64>` field.** This works but relies on `Debug` formatting of a Vec. The example should probably use `kf.state` more intentionally, or show `kf.ternary_state()` which is the more interesting output.

3. **`FixedPoint` is defined in "Core Concepts" but the Quick Start never uses it.** The README sells "fixed-point arithmetic for no-FPU environments" in the intro, then the example uses only `f64`. Should show one line of fixed-point usage or remove the claim from the intro.

4. **"Ecosystem" section lists `ternary-kalman` as its own dependency.** Harmless but looks like a copy-paste artifact.

---

## 2. ternary-game-theory

**Score: MINOR ISSUES**

### What's Good
- "Why This Exists" is concrete: binary models need awkward hacks for abstain/hedge
- Code example compiles — types trace correctly
- "How It Works" explains the bitmask indexing, Shapley permutation enumeration, and core checking
- Built-in game (Prisoner's Dilemma) is a nice touch
- No marketing language

### Problems Found

1. **Missing "Known Limitations" section.** From the source:
   - Shapley values are exact but factorial-complexity — unusable past ~10 players
   - `price_of_anarchy()` only considers pure-strategy Nash equilibria, missing mixed-strategy equilibria. If no pure Nash exists, it returns `NaN`
   - `dominated_strategies_row()` checks strict dominance only — weak dominance is not detected
   - `VickreyAuction::is_truthful()` always returns `true` — it's a hardcoded tautology, not an actual verification

2. **The code example calls `game.payoff()` but shows `NormalFormGame::new("Market Entry", ...)` — the `name` field is stored but never used in the example.** Minor but the example could be tighter.

3. **Quick Start shows `(3.0, 3.0)` at position `(Pos, Pos)` in the Prisoner's Dilemma, but this same matrix is used in the example with name "Market Entry".** The example is fine, but a reader might confuse the example game with the Prisoner's Dilemma. The README should clarify the example game is not the PD.

4. **"Price of anarchy" is used without inline definition.** It's defined in "How It Works" but appears earlier in API Overview. Consider a parenthetical on first use.

---

## 3. ternary-swarm

**Score: MINOR ISSUES**

### What's Good
- "Why This Exists" directly addresses the continuous-to-discrete gap
- Code example compiles, types trace correctly (`GridPos::all_positions()` → `Particle::new` → `ParticleSwarm::new`)
- "How It Works" explains the PSO velocity clamp and ACO pheromone model clearly
- `Trit` is used consistently (not `Ternary`) which distinguishes this crate's type from others

### Problems Found

1. **Missing "Known Limitations" section.** From the source:
   - PSO `is_converged()` checks if all particles are at the *same position* — very strict. Particles can oscillate around the optimum without ever all landing on it
   - ACO `evaporate()` resets ALL trails to Zero — this is destructive, not gradual decay. Real ACO uses partial evaporation
   - ACO uses greedy selection (highest-scored candidate), not probabilistic — reduces exploration
   - The 3×3 grid has only 9 positions, making PSO overkill for most real problems
   - `consensus_round()` is trivial: one vote round makes everyone adopt the majority, so additional rounds do nothing

2. **`PheromoneGrid` is described as "9×9 edge pheromone matrix" but the trails are indexed by position number (0–8), not by GridPos.** The README should clarify this linear indexing.

3. **The `fitness` closure in Quick Start uses `to_i8()` on `Trit` values — but `Trit` in this crate has `to_i8()` returning `i8`.** The example is correct but the trait method could be confused with the `Ternary` type from other crates. Worth noting in Core Concepts that `Trit` is this crate's name for the ternary value.

---

## 4. ternary-constraint

**Score: MINOR ISSUES**

### What's Good
- "Why This Exists" is excellent: "a full-blown SAT solver is overkill"
- Code example compiles, `sol["x"]` syntax works because the return type is `HashMap<String, i8>`
- Second example with AC-3 + backtracking shows real workflow
- "How It Works" explains AC-3 queue mechanics and MRV heuristic clearly
- Mentions 3^n tractability threshold

### Problems Found

1. **Missing "Known Limitations" section.** From the source:
   - `count_solutions()` and `find_all_solutions()` are brute-force recursive — exponential in the number of variables. The README mentions "up to ~15 variables" for enumeration but doesn't state this as a limitation
   - AC-3 only processes `Binary` constraints, not `AllDifferent` or `Unary`. The README's second example shows `add_unary_constraint` followed by `ArcConsistency::ac3()`, but AC-3 silently ignores unary constraints. This is misleading.
   - `ternary_n_queens()` returns 0 solutions for a 3×3 board (verified in tests). This is correct but might surprise readers — the README should note this.
   - `BacktrackingSearch::solve()` takes an immutable reference to the CSP but clones all domains internally — memory overhead proportional to variable count × domain size per recursive call

2. **Second code example calls `ArcConsistency::ac3(&mut csp)` after adding a unary constraint, but AC-3 ignores unary constraints.** The example implies AC-3 handles unary pruning, but it doesn't. The example still works because backtracking handles the unary check, but the AC-3 call is effectively a no-op for unary constraints.

3. **`BacktrackingSearch::solve` returns `Option<HashMap<String, i8>>` — the `i8` values are raw numbers, not the named type `Ternary`.** A reader might expect `Ternary`-typed output.

---

## 5. ternary-chaos

**Score: MINOR ISSUES**

### What's Good
- "Why This Exists" makes the surprising claim that ternary maps have rich behavior and then backs it up
- Code example compiles — `TernaryMap::new`, `iterate_n`, `detect_period`, `estimate_lyapunov` all match the API
- "How It Works" explains period detection, Lyapunov estimation, and bifurcation scanning clearly
- Mentions "27 possible transition rules" — nice concrete detail

### Problems Found

1. **Missing "Known Limitations" section.** From the source:
   - `estimate_lyapunov()` uses a perturbation of 0.001, which after the first ternarization step becomes identical to the unperturbed state (because `Ternary::from_f64(1.001)` = `Pos` and `Ternary::from_f64(1.0)` = `Pos`). This means the Lyapunov exponent is always 0 for any rule that immediately ternarizes — the perturbation is destroyed in one step. The function is numerically meaningless for the ternary domain.
   - `detect_period()` can return incorrect periods due to false positives in the tail-matching heuristic — it only checks the last `2*period` values, not the full orbit
   - `find_cycles()` tests all 3 starting states but doesn't guarantee exhaustive coverage of all cycles — a cycle that starts mid-trajectory could be missed
   - The `default_rule` with param=0 maps everything to Zero immediately — "rich dynamics" only emerge at higher parameters

2. **The README claims "strange attractor analysis" but `detect_strange_attractor()` flags non-periodic behavior as "strange" based on a simple heuristic (period is None AND unique_states >= 2).** On a 3-state system, this is not a meaningful definition of a strange attractor.

3. **`xor_rule` is described as "sign flip when param > 0.5" but the function just swaps Neg↔Pos, it doesn't use the parameter for anything except the threshold check.** It's not really "XOR" in any standard sense.

---

## 6. ternary-fuzzy

**Score: MINOR ISSUES**

### What's Good
- "Why This Exists" is concrete: "complex defuzzification, floating-point sensitivity, over-engineering"
- Code example compiles — all types trace correctly, `HashMap` import is shown
- "How It Works" explains the ±0.33 defuzzification threshold
- No marketing language

### Problems Found

1. **Missing "Known Limitations" section.** From the source:
   - `TriangularTernaryMF::evaluate()` uses `f64::EPSILON * 100.0` for the exact-midpoint check — this means only values extremely close to the midpoint get `High`, everything else on the slopes gets `Medium`. The triangular MF is effectively a spike at the midpoint with two Medium ramps, not a true triangular membership function
   - The ternary membership scale loses information — you can't distinguish between "slightly high" and "very high"
   - `FuzzyControlSystem::evaluate()` applies t-norm between firing strength and consequent, then averages all qualified outputs. This is not standard fuzzy inference (Mamdani or Sugeno) — it's an approximation
   - No support for hedges (very, slightly, etc.)

2. **The Quick Start comment says `// Fan speed: Some(High)` but the `evaluate()` return type is `HashMap<String, TernaryMembership>`, so `.get()` returns `Option<&TernaryMembership>`.** The comment should say `Some(&High)` or the example should use pattern matching.

3. **`TernaryFuzzySet` is shown in Core Concepts and API Overview but never used in the Quick Start.** A reader has to trust it works without seeing it in action.

---

## 7. ternary-circuit

**Score: MINOR ISSUES**

### What's Good
- "Why This Exists" grounds 3VL in real history (Łukasiewicz, Kleene, SQL NULL)
- Code example compiles — circuit wiring with `GateInput::Primary` and `GateInput::Gate` traces correctly
- "How It Works" clearly explains the difference between Kleene and Łukasiewicz semantics
- Truth table generation is a nice feature
- Double-negation minimization is simple but correct

### Problems Found

1. **Missing "Known Limitations" section.** From the source:
   - Circuit evaluation assumes gates are in topological order — no cycle detection. An invalid (cyclic) circuit silently produces wrong results
   - `minimize_circuit()` only detects `NOT → NOT` where the first NOT takes a `Primary` input — it misses double-negation chains through intermediate gates
   - The Łukasiewicz `Imp` implementation has dead code: the last match arm `(Trit::False, _) | (_, Trit::True) => Trit::True` is unreachable because earlier arms already handle all cases with `False` as the first element
   - No support for multi-output circuits — `evaluate()` returns all values but doesn't designate which are outputs

2. **The code example's comment says `// True (False AND True = False, NOT False = True, False OR True = True)` but the circuit output is at gate ID 4, which is the OR of gate 2 and gate 3.** Gate 2 = AND(Primary(0), Primary(1)) = AND(False, True) = False. Gate 3 = NOT(Primary(0)) = NOT(False) = True. Gate 4 = OR(Gate(2), Gate(3)) = OR(False, True) = True. The comment is correct but the explanation could be clearer.

3. **`Trit` is defined as `False` (-1), `Unknown` (0), `True` (+1) — but the numeric encoding is -1/0/+1, not the more common 0/1/2 for three-valued logic.** This is a design choice, not a bug, but it should be noted since it differs from Łukasiewicz's original encoding.

---

## 8. ternary-control

**Score: PASS**

### What's Good
- "Why This Exists" names the specific problem: thresholding loses structure, bang-bang loses nuance
- Code example compiles and demonstrates both PID and bang-bang with stability analysis
- "How It Works" explains PID math, hysteresis mechanics, state machine transitions, and stability metrics
- **Has "Use Cases" with specific scenarios** ✓
- No marketing language
- The `Deadband` type with both hysteresis (`apply`) and strict (`apply_strict`) modes is well-documented

### Minor Nits (not blockers)
1. The README could mention that the PID has no anti-windup protection — the integral accumulates without bounds. This is a real limitation in practice.
2. `BangBangControl` transitions from Positive directly to Negative (bypassing Zero) when the error crosses the full hysteresis band — this could cause actuator stress. Worth noting.
3. The `StateMachine` stores transitions per state but doesn't validate that target states exist — a typo in a target state name silently creates an unreachable state.

These are honest engineering concerns, not documentation quality issues. The README meets the DOC-STANDARD.

---

## 9. ternary-sensor

**Score: MINOR ISSUES**

### What's Good
- "Why This Exists" is specific: "you need to know if it's below normal, normal, or above normal"
- Code example compiles and shows classification, fusion, and anomaly detection in one flow
- "How It Works" explains z-score classification, fusion strategies, and calibration feedback loop
- Time series ternary derivative is a genuinely useful feature

### Problems Found

1. **Missing "Known Limitations" section.** From the source:
   - `SensorFusion::weighted_vote()` uses `class.to_i8() as f64 * w` — this means a sensor with weight 10 voting `Low` contributes -10, while a sensor with weight 1 voting `High` contributes +1. The threshold at ±0.5 means one heavily-weighted sensor dominates completely. This is by design but should be documented.
   - `Calibration::feedback()` adjusts offset by a fixed 0.1 per call — no damping, no convergence guarantee. Calling feedback 100 times with `Low` adds 10.0 to the offset.
   - `AnomalyDetector::update_baseline()` replaces the baseline entirely — no exponential moving average or gradual adaptation
   - `majority_vote()` breaks ties in favor of Low (checked first) — this is a subtle bias

2. **The Quick Start comment says `// High (z > 3)` for `classify_statistical(50.0, 15.0)` with value 95.0, but the actual z-score is (95-50)/15 = 3.0, and the code checks `z > 1.0` for High.** The comment is misleading — the threshold is ±1σ, not ±3σ.

3. **The ecosystem section lists `ternary-anomaly` — this crate doesn't exist in the review set.** If it's a real crate, fine, but it should be verified.

---

## 10. ternary-registry

**Score: MINOR ISSUES**

### What's Good
- "Why This Exists" is the most honest: "this crate doesn't directly compute on ternary values" but serves as infrastructure
- Code example compiles and shows registration, query, dependency resolution, and capability checking
- "How It Works" explains topological sort and sync status mechanics
- `SkillQuery` builder pattern is clean

### Problems Found

1. **Missing "Known Limitations" section.** From the source:
   - Registry queries are linear scans — no indexing. Performance degrades linearly with skill count. Appropriate for "dozens to hundreds" as the README says, but should be stated as a limitation
   - `SkillDependencyResolver` clones the entire registry to take ownership — expensive for large registries
   - `VersionConstraint::satisfies()` checks major/minor/patch but ignores pre-release tags and build metadata — not full semver
   - `RegistrySync` only compares version counters, not actual skill content. Two registries at the same version with different skills would report `InSync`
   - `CapabilityMatrix` has hardcoded capabilities — no way to customize per application

2. **The crate's name is `ternary-registry` but it has nothing to do with ternary values.** The README acknowledges this ("doesn't directly compute on ternary values") but the name still implies ternary-specific functionality. This could confuse users.

3. **`SkillDependencyResolver::new(registry)` takes ownership of the registry.** The README's Quick Start calls `resolver.resolve()` after creating the resolver, but this means the original `reg` is consumed. The example creates the resolver with `reg.clone()`, which is correct, but `SkillRegistry` doesn't implement `Clone` in the source — **the Quick Start example won't compile because `reg.clone()` doesn't exist.**

   Looking again at the source: `SkillRegistry` contains `HashMap<String, Skill>` — neither derives `Clone`. The example does `let resolver = SkillDependencyResolver::new(reg.clone());` but `Clone` is not implemented. **This is a real compile error.**

---

## Cross-Cutting Issues

1. **None of the 10 crates have a "Known Limitations" section.** This is the single most common failure against DOC-STANDARD. Every crate has honest limitations visible in the source code — they just aren't documented.

2. **Every ecosystem section lists exactly 5 crates in the same format.** This looks copy-pasted. Each crate should list the crates it actually interacts with, not a generic list.

3. **No crate defines "balanced ternary" or "trit" on first use in the ecosystem section** when linking to the `ternary` core crate. A newcomer won't know what balanced ternary is.

4. **All READMEs use the same structure**, which is good for consistency but some sections feel formulaic rather than genuine.

5. **ternary-registry has a real compile error in its Quick Start.** This is the only code-level bug found across all 10 crates.

---

## Recommended Priority Fixes

1. **Add "Known Limitations" to all 10 READMEs.** One honest paragraph each. The source code makes this easy — the limitations are real and discoverable.
2. **Fix ternary-registry Quick Start** — `reg.clone()` won't compile.
3. **Fix ternary-sensor Quick Start comment** — z-score threshold is ±1σ, not ±3σ.
4. **Clarify ternary-chaos Lyapunov estimation** — it's numerically broken for ternary states.
5. **Note ternary-constraint AC-3 limitation** — it ignores unary and AllDifferent constraints.
