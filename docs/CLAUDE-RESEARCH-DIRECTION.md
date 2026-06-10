# Synthesis: Three Missed Experiments + Research Direction

*Research Director's Analysis — Ternary Agent Intelligence Lab*

---

## Three Experiments the Round-Table Missed

---

### Experiment 1: Percolation Phase Transition as Conservation-Violation Marker

**The gap**: The round-table treated flood-fill as a problem to fix and conservation violations as noise to minimize. Both framings are wrong.

**Hypothesis**: Ternary influence propagation undergoes a percolation phase transition at a critical connection density p_c. Conservation of gamma+H holds in the sub-percolating phase (isolated clusters, local dynamics) and breaks in the super-percolating phase (global cascades, long-range correlations). The 6/10 violation rate is not measurement error — it is a phase marker. The system is operating near criticality.

**Crates**: `constraint-theory-core` (ternary lattice ops), `flux-genome` (connectivity topology tracking), new crate `perco-ternary` wrapping fast union-find with signed-edge support.

**Measurement**: Sweep connection density from 0.1 to 0.9. At each density measure: (a) largest cluster size distribution (power law = critical), (b) conservation violation rate, (c) mean propagation depth. Plot violation rate vs. cluster size slope. Expected: sharp co-transition at p_c ≈ 0.4–0.6 for signed ternary networks (different from classical percolation threshold of ~0.5 for unsigned binary).

**Expected insight**: Conservation laws in ternary systems are phase-dependent invariants, not universal constants. This reframes the -25% drift: agents may be self-organizing toward criticality, intentionally sitting at the phase boundary where influence is maximally sensitive. This is the "edge of chaos" hypothesis formalized for signed-ternary networks — a new universality class distinct from Ising or Boolean network criticality.

**Publishability**: Very high. First percolation universality class result for {-1,0,+1} signed networks. Directly connects to neural criticality literature (Beggs-Plenz), but with a ternary twist nobody has formalized.

---

### Experiment 2: Kolmogorov Fitness — Forgiveness as Erasure-Code Embedding

**The gap**: The round-table proposed trust+forgiveness on GPU, treating forgiveness as a behavioral add-on. The deeper question: why does forgiveness work mechanically? SMP fragility (linear degradation) and forgiveness efficacy are the same phenomenon viewed from opposite ends.

**Hypothesis**: There exists an inverse relationship between the algorithmic complexity K(s) of an SMP seed (approximated by LZ-compression ratio) and its fitness half-life under mutation pressure. Forgiveness mechanics are not a behavioral strategy — they are an implicit error-correcting code embedded in the genome. Specifically, a forgiveness-capable genome has lower effective K(s) because forgiveness collapses the strategy's decision tree: instead of encoding every possible betrayal history, it encodes a single reset operation. This is lossy compression that preserves fitness-relevant information while discarding fitness-irrelevant state.

**Crates**: `flux-genome` (genome representation), `constraint-theory-core` (mutation operators), new crate `genome-complexity` wrapping LZ77 compression as K-proxy with configurable alphabet size.

**Measurement**: Generate 1000 seeds across the complexity spectrum. Measure: (a) LZ complexity at generation 0, (b) fitness at generations 10, 50, 100, 500 (half-life), (c) repeat with and without forgiveness operators. Expected: fitness half-life ~ exp(-αK(s)) without forgiveness; with forgiveness, the relationship flattens (forgiveness creates a complexity floor below which degradation stops).

**Expected insight**: Evolution is performing minimum description length (MDL) optimization without knowing it. The surviving strategies after 500 generations should be compressible to fewer bits than initial seeds. Forgiveness is evolution discovering that stateless strategies dominate stateful ones in noisy environments — a new theoretical grounding for why forgiveness appears in biological and cultural evolution.

**Publishability**: High. Connects algorithmic information theory (Kolmogorov, MDL) to evolutionary game theory (iterated prisoners dilemma literature) in a computationally falsifiable way. New angle on the "evolution of cooperation" problem.

---

### Experiment 3: Mutual Information as the True Conservation Law

**The gap**: Everyone accepted that gamma+H is not conserved and moved on. Nobody asked what IS conserved. This is the most important missed experiment.

**Core insight**: In thermodynamics, when energy leaks from a subsystem, it flows somewhere. When gamma+H drifts by -25% across agent genomes, that information doesn't disappear — it flows into inter-agent correlations. The conserved quantity may be:

```
Ω = (gamma + H) + I_total
```

where I_total is the total correlation (sum of pairwise mutual informations across all active agent pairs). As individual entropy decreases (agents converge on strategies), inter-agent correlation increases. The system conserves Ω, not H alone.

**Hypothesis**: The -25% drift in gamma+H is offset by a +25% increase in total pairwise mutual information I_total across the agent population. The true conservation law is Ω = gamma + H + I_total = constant (within measurement error), where I_total is computed from the joint distribution of concurrent agent action sequences.

**Crates**: `constraint-theory-core`, `flux-genome`, `lau-measure-agents` (mutual information estimators), new crate `mutual-info-ternary` implementing Kozachenko-Leonenko k-NN MI estimation for {-1,0,+1} valued sequences.

**Measurement**: Run 20 independent evolution trials to generation 200. At each tick measure: gamma, H (individual entropy), and I_total (pairwise MI across all agent pairs via k-NN estimator). Compute Ω = gamma + H + I_total and track its variance. Compare variance(Ω) vs. variance(gamma+H) alone. Expected: Ω variance < 10% of (gamma+H) variance.

**Expected insight**: Ternary agent systems are not dissipative — they are conservative systems that redistribute entropy from individual to collective degrees of freedom. Trust and forgiveness are the mechanisms by which individual entropy is converted to collective correlation. This resolves the conservation puzzle and provides the correct Lyapunov function for ecosystem stability analysis.

**Publishability**: Transformative. If confirmed, this is a new conservation principle for adaptive multi-agent systems. Connects to Jaynes maximum entropy, collective intelligence theory, and information-theoretic foundations of evolutionary biology. Target: Nature Communications or PNAS.

---

## The Most Important Question

**What is the causal structure between diversity, conservation, and collapse?**

Pareto selection prevents diversity collapse (17/20 vs 1/20). Conservation violations co-occur with dynamics near criticality. Trust/forgiveness prevents strategy degradation. These three findings look independent but may be facets of one phenomenon: **the system is trying to maximize Ω (total correlation + individual entropy) subject to resource constraints, and collapse occurs when it gets trapped in a local maximum of I_total at the cost of H.**

The question: Is there a phase diagram (axes: mutation rate × forgiveness rate) with three phases — (1) diversity-preserving criticality, (2) monoculture collapse, (3) chaos — and does Pareto selection act as a control parameter that keeps the system in phase 1? If yes, we have a principled theory of how ecosystems avoid collapse, grounded in information thermodynamics.

---

## 500-Word Research Direction Abstract

### Ternary Agent Systems as Information-Thermodynamic Engines: Toward a Conservation Principle for Adaptive Intelligence

Conventional multi-agent systems research treats conservation laws as optional mathematical scaffolding. Our seven experiments suggest a stronger claim: conservation principles are constitutive of adaptive intelligence in ternary {-1,0,+1} systems, not merely descriptive of it. We propose a unified research program organized around one conjecture and three falsifiable predictions.

**The Conjecture**: The quantity Ω = γ + H + I_total is conserved across evolutionary time in ternary agent populations, where γ measures ternary imbalance, H is population-level Shannon entropy, and I_total is total pairwise mutual information. The apparent -25% drift in γ+H is not symmetry breaking — it is entropy redistribution from individual to collective degrees of freedom. Agents that develop trust and forgiveness mechanics are not adopting a strategy; they are implementing the mechanism by which individual entropy converts to collective correlation, conserving Ω while reducing individual uncertainty.

**Prediction 1 (Phase Structure)**: Ternary influence propagation is a percolation process with a critical density p_c ≈ 0.45. Below p_c, conservation of γ+H holds locally; above p_c, cascade dynamics break local conservation while preserving global Ω. Conservation violation rate is a real-time phase detector. Systems self-organize toward p_c — the edge of percolation — because this maximizes information transmission per unit energy, a principle analogous to Friston's free energy minimization but applied to collective rather than individual agents.

**Prediction 2 (Complexity-Fitness Duality)**: SMP seed fitness half-life is exponentially anti-correlated with Kolmogorov complexity K(s). Forgiveness mechanics lower effective K(s) by implementing strategy compression: a forgiving agent encodes one reset operation instead of exponentially many betrayal-history branches. Evolution under selection pressure converges on minimum-description-length strategies. This is not a metaphor — it is a computable prediction about LZ-compression ratios of surviving vs. extinct genomes at generation 500.

**Prediction 3 (Harmonic Coding of Fitness Information)**: Agent ternary output sequences, when interpreted as pitch sequences via integer-ratio frequency mapping, will exhibit measurable harmonic coherence (convergence toward small-integer frequency ratios) in stable ecosystems and inharmonic drift in collapsing ones. This is not decorative. Integer-ratio frequencies minimize mutual information loss in discrete channels — agents evolving "honest signals" of genetic fitness converge on harmonic structure because it is information-theoretically optimal for the ternary channel.

Together, these predictions constitute a single theoretical claim: ternary agent populations are information-thermodynamic engines. They transform environmental uncertainty (high H, low I) into collective knowledge (low H, high I) while conserving Ω. The RPS arena, the flood-fill network, the SMP genome — each is a different regime of the same underlying engine. Collapse (diversity loss) corresponds to the engine seizing: I_total saturates at a monoculture fixed point, the phase transition freezes at p = 1, and K(s) drops to near-zero (all agents identical). Pareto selection functions as a thermodynamic regulator, introducing controlled entropy injection that keeps the system out of this frozen phase.

The lab's next six months should pursue one target: **measure Ω across all seven experimental configurations and determine whether its variance is smaller than that of any component quantity.** If confirmed, we have discovered a new conservation law for adaptive intelligence — one with implications for distributed AI systems, evolutionary biology, and the mathematical foundations of collective cognition.

---

*Synthesis by Claude Sonnet 4.6 — Research Director Analysis, 2026-06-04*
