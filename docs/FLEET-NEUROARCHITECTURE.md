# The Fleet Neuroarchitecture

**A Scientific Essay on the SuperInstance Ecosystem as a Living Neural Network**

*Written 2026-06-04. Author: ZeroClaw Scout.*
*Status: Technical architecture document. All code references verified against current crate source.*

---

## Abstract

We argue that the SuperInstance ternary ecosystem is not merely *inspired by* biological neural computation — it is, in a precise mathematical sense, a re-implementation of the same computational principles that biological evolution discovered in nervous systems over 600 million years. The ternary-cell is a neuron. The CellGrid / Tissue is a cortical column. The ternary-agent Agent is a thought — a trajectory through TernaryState space. The ternary-ensign EnsignRegistry is a specialist cortical region. And construct-core, with its three-layer trait hierarchy (BareMetalConstruct → SyncConstruct → AsyncConstruct), is the brainstem: the phylogenetically ancient core that adapts its interface to whatever body it wakes up in.

Three major neuroscience frameworks map onto three architectural primitives with mathematical precision: Karl Friston's Free Energy Principle maps to conservation of verification entropy (conservation_ratio ≈ 1.0 in conservation-verify); Rao and Ballard's predictive coding maps to the six-phase tick cycle (predict → perceive → compute_surprise → vibe → gc → conservation); and Gerald Edelman's Neural Darwinism maps to strategy ecology — the fitness-ranked selection loop operating across the AgentPool. These are not metaphors. They are structural homologies.

---

## 1. Introduction: What Neural Computation Actually Is

Before drawing parallels, we need to say precisely what neural computation is. A surprisingly small number of principles do most of the work:

1. **Prediction and error**: Neurons fire not in response to sensory input per se, but in response to *deviations* from predicted input. The brain is a prediction engine that runs backward — it generates expected percepts and then only passes through what was unexpected.

2. **Selection under pressure**: Neural circuits that successfully predict are energetically rewarded (reinforced synapses); those that fail are weakened and eventually eliminated. This is not learning in the gradient descent sense — it is selection, operating on populations of neural circuits simultaneously.

3. **Hierarchical specialization**: Different cortical regions develop functional specializations not through explicit programming but through competitive selection over the course of development and experience. A region that wins the competition to represent faces becomes "face area" — not because it was told to, but because it was best at that task under competitive pressure.

4. **Adaptive embodiment**: The brainstem does not "know" in advance what body it will be running. It discovers its body by attempting actions and observing consequences. The same neural architecture runs in a mouse, a human, and a bird — the computational principles are universal; the specific instantiation adapts.

The SuperInstance ecosystem implements all four principles. This document maps each to the specific types, traits, and functions in the codebase.

---

## 2. The Neuron: TernaryCell

The fundamental unit of neural computation is the neuron — a cell that integrates inputs, generates a prediction, measures deviation from expectation, and produces an output signal. Here is the biological description followed by the mechanical translation.

**Biological neuron cycle:**
1. Dendrites integrate incoming signals from presynaptic neurons
2. The integration is compared against a threshold (the resting membrane potential)
3. If the integrated signal exceeds the threshold, an action potential fires
4. The action potential propagates down the axon
5. Synaptic vesicles release neurotransmitter
6. The postsynaptic neuron is either excited or inhibited

**TernaryCell cycle (from `ternary-cell/src/lib.rs`):**

```rust
pub fn tick(&mut self) -> i32 {
    self.predict();       // Step 1: What do I expect?
    self.perceive();      // Step 2: What do I observe?
    let surprise = self.compute_surprise(); // Step 3: Prediction error
    self.vibe();          // Step 4: Update energy from error
    self.gc();            // Step 5: Clear inbox
    self.conservation();  // Step 6: Enforce bounds, check apoptosis
    surprise
}
```

The mapping is direct. The `inbox: Vec<TernaryMessenger>` is the dendritic tree — it collects signals from neighbors before the tick cycle runs. The `predict()` function is the resting potential comparison:

```rust
pub fn predict(&mut self) {
    let combined: i32 = self.inbox.iter().map(|m| m.to_ternary() as i32).sum();
    self.prediction = if combined > 0 { 1 }
                      else if combined < 0 { -1 }
                      else { self.ternary_value };
}
```

The cell combines incoming ternary signals (-1, 0, +1) into a scalar, then thresholds into three states — exactly like a biological neuron integrating excitatory and inhibitory inputs into a firing decision. The `perceive()` step then updates `ternary_value` from the actual combined signal.

The critical departure from a simple threshold neuron is `compute_surprise()`:

```rust
pub fn compute_surprise(&mut self) -> i32 {
    self.surprise = (self.ternary_value as i32 - self.prediction as i32).abs();
    self.surprise
}
```

This is prediction error — the absolute deviation between what was predicted and what was perceived. In biological neurons, this corresponds to what is sometimes called the "mismatch negativity" signal: neurons fire more strongly when input deviates from expectation than when it confirms it. The brain does not simply relay what it sees. It relays what was unexpected.

The energy dynamics in `vibe()` formalize this:

```rust
pub fn vibe(&mut self) {
    self.energy -= self.surprise;
    if self.surprise == 0 {
        self.energy += 1;  // Reward for accurate prediction
    }
}
```

A cell that predicts accurately — that has developed an internal model good enough to anticipate its inputs — gains energy. A cell that is perpetually surprised drains energy and eventually enters apoptosis. This is synaptic efficiency: neurons that consistently fire "at the right time" have their connections strengthened; those that fire randomly are pruned. The surprise is the error signal; the energy is the biological analog of synaptic strength.

The three values of `TernaryMessenger` — Signal (+1), Silence (0), Suppress (-1) — correspond to excitatory neurotransmission, baseline firing, and inhibitory neurotransmission. Every neurotransmitter system in the brain maps to one of these three states. Glutamate is Signal; GABA is Suppress; baseline dopaminergic tone is Silence.

---

## 3. The Cortical Column: CellGrid and Tissue

Individual neurons accomplish very little. The computational power of biological neural systems emerges from their organization into canonical circuits — specifically, the cortical column (Mountcastle, 1957), a vertical stack of approximately 80-100 neurons spanning the six layers of neocortex that functions as the fundamental information processing unit.

The CellGrid and Tissue structures in ternary-cell implement this organization.

**CellGrid** is the spatial substrate — a width × height array of TernaryCell instances. The `propagate_signals()` method implements the horizontal connectivity of cortical layers 2 and 3:

```rust
pub fn propagate_signals(&mut self) {
    let mut emissions: Vec<(usize, usize, TernaryMessenger)> = Vec::new();
    for y in 0..height {
        for x in 0..width {
            if let Some(cell) = self.get(x, y) {
                if cell.is_alive() {
                    emissions.push((x, y, cell.emit()));
                }
            }
        }
    }
    for (x, y, msg) in emissions {
        for (nx, ny) in self.neighbors(x, y) {
            if let Some(neighbor) = self.get_mut(nx, ny) {
                neighbor.receive(msg);
            }
        }
    }
}
```

The 4-connected neighborhood in `neighbors()` represents the local horizontal spread of axon collaterals within a cortical column. Each cell broadcasts its current ternary value to its four neighbors before all cells tick simultaneously — this implements the lateral synchronization that characterizes cortical oscillations.

The `tick_all()` method then runs all cells synchronously, implements apoptosis (removal of depleted cells), and returns the alive count. This is the computational cycle of a cortical column: synchronized integration of lateral signals, followed by population-level selection.

**Tissue** coordinates the grid at the macro level. The `tissue_balance()` method computes the population-level ternary distribution:

```rust
pub fn tissue_balance(&self) -> (usize, usize, usize) {
    let mut pos = 0; let mut zero = 0; let mut neg = 0;
    for cell in &self.cells {
        if let Some(c) = cell {
            if c.is_alive() {
                match c.ternary_value { 1 => pos+=1, 0 => zero+=1, -1 => neg+=1, _ => {} }
            }
        }
    }
    (pos, zero, neg)
}
```

This is the population code — the representation of information not in individual spikes but in the ratio of excited versus inhibited neurons across a population. The brain does not rely on single neurons to carry information; it relies on the ratio of activity across neural populations. The `(pos, zero, neg)` tuple IS the population code for the tissue at any given tick.

`Tissue::consensus()` implements the "winner-take-all" operation that characterizes cortical decision circuits:

```rust
pub fn consensus(&self) -> i8 {
    let (pos, zero, neg) = self.grid.tissue_balance();
    if pos > zero && pos > neg { 1 }
    else if neg > pos && neg > zero { -1 }
    else { 0 }
}
```

This is the neural basis of categorical perception: an ambiguous stimulus becomes committed to a categorical response (choose, avoid, or explore) through population-level competition. The thalamus does exactly this — it takes graded sensory inputs and forces them through winner-take-all circuits before relaying them to cortex.

`Tissue::is_converged()` detects when all cells have reached the same ternary value — a state corresponding to neural synchrony or "binding," the hypothesized neural mechanism for conscious perceptual unity:

```rust
pub fn is_converged(&self) -> bool {
    let mut values = std::collections::HashSet::new();
    for cell in &self.grid.cells {
        if let Some(c) = cell { if c.is_alive() { values.insert(c.ternary_value); } }
    }
    values.len() <= 1
}
```

A fully synchronized tissue (converged to a single value) is the computational analog of a coherent neural oscillation — all cells in phase, all signaling the same thing. This state can represent either strong evidence for a categorical percept or, pathologically, epileptic seizure (a tissue where all cells are locked into synchrony and diversity is lost). The `avoidance-cascade` cross-pollination is relevant here: `GreedyGc` risks producing a monoculture tissue through aggressive apoptosis; `BalancedGc` would maintain diversity through the balanced learning principles from that crate.

---

## 4. Predictive Coding IS the Tick Cycle

Rao and Ballard's 1999 paper "Predictive Coding in the Visual Cortex: A Functional Interpretation of Some Extra-Classical Receptive-Field Effects" established the predictive coding framework that has since become one of the dominant theories of cortical computation. The framework has been extended by Karl Friston into a general principle of brain function.

The core claim of predictive coding: the brain maintains a generative model of the world. At every level of a cortical hierarchy, neurons send *predictions* downward to lower levels and receive *prediction errors* from those lower levels. Learning consists of updating the generative model to minimize prediction errors. Perception is not passive reception of sensory data — it is active comparison of sensory data against ongoing predictions.

The ternary-cell tick cycle is a mechanical implementation of this framework.

**Phase 1: predict()** — The cell runs its generative model. Given the current state (`ternary_value`) and the pending inbox, what is the expected output? The prediction is stored in `self.prediction`. This is the top-down prediction signal flowing from the cell's current model to its perception apparatus.

**Phase 2: perceive()** — The cell processes the actual input. The inbox signals are combined and clamped: `combined.clamp(-1, 1) as i8`. This is the sensory data arriving from the world (the cell's neighbors).

**Phase 3: compute_surprise()** — The prediction error is computed: `(self.ternary_value - self.prediction).abs()`. In the Rao-Ballard formulation, this is the "prediction error signal" or "residual" — the component of sensory data that was NOT predicted. In cortical circuits, these prediction errors are carried by distinct pyramidal cell populations that project upward to higher cortical areas.

**Phase 4: vibe()** — The cell updates its internal state in response to the prediction error. Energy decreases with high surprise; energy increases with zero surprise. This is the Hebbian learning rule — synapses that correctly predict are strengthened; those that fail are weakened.

**Phase 5: gc()** — The inbox is cleared. This is the refractory period — the cleanup of short-term state that resets the cell for the next cycle.

**Phase 6: conservation()** — Energy bounds are enforced and apoptosis is evaluated. This is the homeostatic regulation of neural activity — the mechanisms that prevent runaway excitation (energy clamped to `clamp(0, 20)`) and trigger cell death when energy is exhausted.

The six phases map exactly to the six components of the Rao-Ballard hierarchical predictive coding model: prediction, representation update, error computation, weight update, cleanup, and homeostasis.

One important detail distinguishes the ternary implementation from the classical biological model: the simultaneous update in `tick_all()`. Biological neurons update asynchronously — there is no global clock. The synchronous tick is a computational simplification that trades biological fidelity for determinism and analytical tractability. This is the same simplification made in most artificial neural network architectures. The difference matters when studying synchronization phenomena (e.g., gamma oscillations) but not for the computational function of prediction error minimization.

---

## 5. The Free Energy Principle IS Conservation of Verification Entropy

Karl Friston's Free Energy Principle (2010, *Nature Reviews Neuroscience*) proposes that all biological self-organizing systems — from cells to brains to organisms — minimize variational free energy, defined as:

> F = -log P(o|m) + KL[q(s) || P(s|o,m)]

Where:
- F is free energy (to be minimized)
- P(o|m) is the probability of observations given the model
- KL[...] is the Kullback-Leibler divergence between the approximate posterior q(s) and the true posterior
- s is internal state, o is observations, m is the model

Minimizing F is equivalent to minimizing surprise (the negative log evidence of observations under the model) while maintaining an accurate model. A system that minimizes free energy maintains low surprise — it has a generative model good enough to predict most of what it observes.

The conservation-verify crate implements this principle directly, though under a different name.

The `SimulationMetrics::conservation_ratio` is the key quantity:

```rust
pub fn conservation_holds(&self, tolerance: f64) -> bool {
    (self.conservation_ratio - 1.0).abs() < tolerance
}
```

A healthy ternary system should have `conservation_ratio ≈ 1.0`. The `InvariantChecker` verifies this across all population scales:

```rust
pub fn check_all(&self, results: &[ScaleResult]) -> Vec<InvariantResult> {
    for r in results {
        checks.push(InvariantResult {
            name: format!("conservation_ratio@{}", r.population_size),
            passed: r.metrics.conservation_holds(self.conservation_tolerance),
            ...
        });
    }
    // Also checks: mean conservation across scales, conservation std dev,
    // avoidance ratio stability, role balance
}
```

The correspondence to free energy: the `conservation_ratio` measures whether the system's self-organizing dynamics are maintaining an equilibrium between exploration and exploitation, between prediction and surprise, between growth and apoptosis. A `conservation_ratio` of 1.0 means the system is neither gaining nor losing net information — it has reached a thermodynamic steady state.

This is Friston's formulation: a free-energy-minimizing system is one at thermodynamic equilibrium with its environment. Organisms do not minimize entropy (that would produce a crystal); they maintain a stable non-equilibrium steady state where internal organization persists against entropic decay. The conservation ratio tracks exactly this — whether the ternary system is maintaining its organized state.

The deeper connection is through the `TernaryCell` energy dynamics. In each tick:

```
energy_change = -surprise + (1 if surprise == 0 else 0)
```

Integrated over the entire grid, the sum of energy changes across all cells IS the change in free energy for the tissue. A tissue where all cells have high surprise is consuming its energy budget — it is in a high free energy state, far from its generative model. A tissue where all cells predict accurately has near-zero net energy change — it is at free energy minimum.

The conservation law `γ + H ≈ 1.283 - 0.159·log(V)` (referenced in the ROOM-AS-CODESPACE document as the fleet health invariant) is a specific formulation of the free energy principle for ternary systems: the sum of the growth rate (γ) and Shannon entropy (H) of the strategy distribution scales logarithmically with the volume (V) of the strategy space. This is a statement that the free energy of the system (surprise + model complexity) is bounded by the log of the hypothesis space — exactly the variational bound in Friston's formulation.

The `RegressionTest` in conservation-verify (`BaselineLaw`) tests that measured system behavior matches this predicted relationship across scales. This is empirical validation of the free energy principle for ternary agent populations.

---

## 6. Neural Darwinism IS Strategy Ecology

Gerald Edelman's Theory of Neuronal Group Selection (Neural Darwinism, 1987) proposes three principles:

1. **Degeneracy**: Many different neural circuits can produce the same behavior. The brain is not a computer with one algorithm for each task — it has many redundant, overlapping circuits for every function.

2. **Selection**: Neural circuits that are activated by experience and produce adaptive behavior have their synapses strengthened. Circuits that are never activated or produce maladaptive behavior have synapses weakened. Over time, the population of active circuits evolves through selection.

3. **Reentry**: Different brain maps (cortical regions, subcortical nuclei) communicate through parallel, bidirectional connections. These reentrant connections allow maps to coordinate their representations without central control.

The ternary-agent crate implements Neural Darwinism through its `Agent`, `AgentPool`, and `AgentCommunication` types.

**Degeneracy** in the ternary system: The `Strategy` trait allows multiple different implementations to produce the same `TernaryState`:

```rust
pub trait Strategy: std::fmt::Debug {
    fn decide(&self, current: TernaryState, score: f64) -> TernaryState;
}
```

A `ThresholdStrategy` with parameters `(lower=-0.5, upper=0.5)` and a different `ThresholdStrategy` with parameters `(-0.3, 0.7)` may both output `TernaryState::Choose` for the same input `score = 0.8`. Multiple distinct strategies producing the same decision — this is degeneracy. It is also robustness: if one strategy fails, others can continue to produce the correct behavior.

**Selection** in the ternary system: `AgentPool::ranked()` implements population-level selection by fitness:

```rust
pub fn ranked(&self) -> Vec<u64> {
    let mut ids: Vec<&Agent> = self.agents.values().collect();
    ids.sort_by(|a, b| b.fitness.partial_cmp(&a.fitness).unwrap_or(Ordering::Equal));
    ids.iter().map(|a| a.id).collect()
}
```

High-fitness agents rise. Low-fitness agents can be removed. The `Agent::tick()` method updates fitness from the current score:

```rust
pub fn tick(&mut self, score: f64) {
    if let Some(ref mut b) = self.behavior {
        self.state = b.execute(self.state, score);
    }
    self.fitness = score;
}
```

Across multiple ticks, the fitness field converges to reflect the agent's historical performance — analogous to synaptic strength accumulating through Hebbian reinforcement. The `AgentPool::avg_fitness()` measures population health — the neural analog of measuring the overall signal-to-noise ratio of a cortical area.

**Reentry** in the ternary system: `AgentCommunication::broadcast()` implements parallel, bidirectional signaling across the agent population:

```rust
pub fn broadcast(&mut self, from_id: u64, tag: &str, payload: &str, recipients: &[u64]) {
    for &to in recipients {
        if to != from_id {
            self.send(AgentMessage { from: from_id, to, tag: ..., payload: ... });
        }
    }
}
```

Every agent can signal every other agent simultaneously. Unlike a hierarchical message-passing system, this is fully parallel — the sender doesn't know which recipients will act on the signal, and multiple recipients can respond simultaneously. This is reentry: parallel, mutually-reinforcing signals between different parts of the system, without central coordination.

The connection to `ternary-cell` is through `TernaryCell::divide()`:

```rust
pub fn divide(&mut self, daughter_id: u64) -> Option<TernaryCell> {
    if !self.can_divide() { return None; }
    self.energy /= 2;
    self.state = CellState::Dividing;
    Some(TernaryCell {
        id: daughter_id,
        energy: self.energy,
        ternary_value: self.ternary_value,
        generation: self.generation + 1,
        ...
    })
}
```

Cell division — the biological mechanism by which successful neural circuits expand their population — requires `energy >= 10`. Low-surprise cells gain energy (from `vibe()`); high-surprise cells lose it. Successful prediction leads to growth; persistent error leads to apoptosis. This is selection operating at the cellular level, below the agent level, implementing Edelman's first mechanism (developmental selection) within each tick cycle.

The `generation` field tracks the lineage of cell divisions — an exact analog of the clonal expansion of successful neural populations during cortical development. A population of cells that consistently predicts accurately will have high generation numbers because their descendants inherit the ternary_value that made them successful.

---

## 7. The Brainstem That Wakes Up: construct-core's Hardware Polymorphism

The brainstem is the phylogenetically oldest part of the vertebrate brain, conserved across species from lamprey to human. It handles breathing, heart rate, arousal, basic sensorimotor reflexes — all the things an organism must do simply to stay alive. The neocortex wraps around the brainstem and extends its capabilities, but does not replace it.

The critical property of the brainstem is its **hardware independence**: the same neural circuits for respiration run in a mouse (breathing ~150 times per minute), a human (~15 times), and a whale (~1-2 times). The computational principle is identical; only the timing and scale differ. The brainstem "wakes up" in whatever body it finds itself in and adapts.

construct-core's three-layer trait hierarchy implements exactly this principle.

**Layer 0: `BareMetalConstruct` — The Brainstem**

```rust
pub trait BareMetalConstruct {
    fn query_lookup(&self, index: u16) -> TritAction;
    fn capabilities(&self) -> BareMetalCapabilities;
    fn query(&self, q: Query<'_>) -> Result<Response<'static>, ConstructError>;
}
```

The `EspConstruct` implements this on an ESP32 with a 256-entry static lookup table:

```rust
pub const fn new() -> Self {
    let mut table = [0u8; 256];
    let mut i = 0;
    while i < 256 {
        table[i] = if i < 86 { TritAction::Avoid.as_u8() }
                   else if i < 171 { TritAction::Explore.as_u8() }
                   else { TritAction::Choose.as_u8() };
        i += 1;
    }
    ...
}
```

This is O(1) reflex — pure brainstem computation. No heap, no OS, no async, no LLM. The ESP32 runs `query_lookup()` in approximately 8 nanoseconds, executing at 240 MHz. The response is pre-computed and baked into firmware at flash time. When the organism must breathe, it does not deliberate — it reflexes.

The `BareMetalCapabilities` struct reports what this construct can do:

```rust
pub struct BareMetalCapabilities {
    pub lookup_table_size: u16,
    pub has_confidence: bool,
    pub supported_query_kinds: u8,
    pub max_payload_size: u16,
}
```

The ESP32 construct has `has_confidence: false` and `supported_query_kinds: 0x01` (Action only). It cannot express uncertainty. It cannot classify or predict. It can only act — choose, avoid, or explore, based on a 1-byte index into a table. This is exactly the computational power of the brainstem: reflexive, fast, reliable, and incapable of deliberation.

**Layer 1: `SyncConstruct` — The Limbic System**

```rust
pub trait SyncConstruct: BareMetalConstruct {
    fn load_skill(&mut self, id: SkillId) -> Result<(), ConstructError>;
    fn unload_skill(&mut self, id: SkillId) -> Result<(), ConstructError>;
    fn loaded_skills(&self) -> &[SkillId];
    fn query_owned(&self, q: OwnedQuery) -> Result<OwnedResponse, ConstructError>;
}
```

The `PiConstruct` (Raspberry Pi) implements this layer. It adds heap allocation (`Vec<SkillId>` for loaded skills), dynamic skill loading/unloading, and the ability to produce owned responses with metadata.

The limbic system is evolutionarily between the brainstem and neocortex. It handles emotion (which is a kind of fast, non-deliberative evaluation of stimuli), memory consolidation (the hippocampus), and value-based learning (the amygdala and nucleus accumbens). It cannot plan sequences of actions across long time horizons, but it can do more than reflexes.

`load_skill()` / `unload_skill()` is episodic memory: the skill set at any moment defines what the construct knows how to do. Loading `SkillId::TernaryEvolution` changes the system's behavioral repertoire dynamically — analogous to a memory trace being activated in the hippocampus and making certain knowledge accessible.

The `SkillId` enum defines the vocabulary of available skills:

```rust
pub enum SkillId {
    TernaryEvolution = 0, StrategyClassification = 1, PatternRecognition = 2,
    RiskAssessment = 3, ResourceAllocation = 4, Communication = 5,
    SensoryFusion = 6, Navigation = 7, Custom(u8),
}
```

Each `SkillId` is a named capability that can be loaded and unloaded without changing the construct's physical substrate — analogous to the limbic system's role in making certain learned behaviors available or unavailable depending on context and arousal state.

**Layer 2: `AsyncConstruct` — The Neocortex**

```rust
pub trait AsyncConstruct: SyncConstruct {
    fn request_tool(&mut self, spec: ToolSpec) -> Result<ToolHandle, ConstructError>;
    fn release_tool(&mut self, handle: ToolHandle) -> Result<(), ConstructError>;
    fn active_tools(&self) -> &[ToolHandle];
    fn query_async(&self, q: OwnedQuery) -> impl Future<Output = Result<OwnedResponse, ConstructError>> + Send;
}
```

The `DgxConstruct` implements all three layers. It adds asynchronous computation, tool management, and a 4096-entry lookup table (vs. the ESP32's 256).

The neocortex is the most recent evolutionary addition to the vertebrate brain. It enables planning, tool use, language, and abstract reasoning — precisely the capabilities that `AsyncConstruct` adds. The `request_tool(ToolSpec::VectorDb)` is not reflexive; it involves acquiring an external resource, using it asynchronously, and releasing it when finished. This is exactly how the prefrontal cortex operates: it maintains working memory, coordinates tool use, and manages sequences of actions across time.

The `DgxConstruct::query_async()` implementation:

```rust
async fn query_async(&self, q: OwnedQuery) -> Result<OwnedResponse, ConstructError> {
    #[cfg(feature = "std")]
    tokio::time::sleep(std::time::Duration::from_micros(10)).await;
    self.query_owned(q)
}
```

The yield point (`await`) is not a bug — it is the architectural statement that neocortical computation is *interruptible*. While waiting for a VectorDb lookup or a GPU kernel, the compute substrate can handle other tasks. This is the cognitive analog of multitasking: the prefrontal cortex coordinates multiple asynchronous cognitive processes simultaneously, none blocking the others.

The three-layer hierarchy enforces a key principle: every higher layer implements all lower layers. `DgxConstruct implements BareMetalConstruct + SyncConstruct + AsyncConstruct`. A DGX cluster can execute the same 8-nanosecond lookup that an ESP32 runs — but it can also execute full async queries with tool use. The brainstem is always present; the neocortex wraps around it.

This means that code written against `BareMetalConstruct` runs correctly on all hardware tiers. Code written against `AsyncConstruct` requires a DGX or equivalent. The interface is not merely an abstraction — it is a statement about computational requirements that naturally matches organisms to environments.

---

## 8. Thoughts as Trajectories: ternary-agent Agent

A "thought" in cognitive neuroscience is not a thing — it is a trajectory. A thought is the path that the brain's state takes through its high-dimensional state space over time. Perception is the arrival of a new state. Memory is the return of a past trajectory. Decision is the transition from an ambiguous state to a committed state.

The `Agent` type implements this trajectory model through its `TernaryState` lifecycle.

```rust
pub enum TernaryState {
    Avoid,    // −1: retreat, reject
    Explore,  //  0: gather information
    Choose,   // +1: commit, execute
}
```

Every `Agent` carries a `state: TernaryState` — its current position in cognitive space. The trajectory is driven by `tick(score: f64)`:

```rust
pub fn tick(&mut self, score: f64) {
    if let Some(ref mut b) = self.behavior {
        self.state = b.execute(self.state, score);
    }
    self.fitness = score;
}
```

The `ThresholdStrategy` implements the most primitive form of cognitive transition:

```rust
impl Strategy for ThresholdStrategy {
    fn decide(&self, _current: TernaryState, score: f64) -> TernaryState {
        if score >= self.upper { TernaryState::Choose }
        else if score <= self.lower { TernaryState::Avoid }
        else { TernaryState::Explore }
    }
}
```

This is the neural basis of decision-making: below threshold, avoid; above threshold, commit; in the middle, gather more data. The interval `(lower, upper)` is the "confidence zone" — the range within which the agent has insufficient evidence to act, and therefore explores. Narrowing this interval (raising lower, lowering upper) produces an impulsive agent; widening it produces a cautious one.

The `AgentMemory` implements the temporal extension of thoughts — the ability to integrate information across time:

```rust
pub struct AgentMemory {
    pub short_term: Vec<MemoryEntry>,
    pub long_term: Vec<MemoryEntry>,
}
```

Short-term memory holds recent observations with full strength. Long-term memory holds historical knowledge that decays according to:

```rust
pub fn decay(&mut self, clear_short_term: bool, long_term_factor: f64, min_strength: f64) {
    for entry in &mut self.long_term {
        entry.strength *= long_term_factor;
    }
    self.long_term.retain(|e| e.strength >= min_strength);
}
```

This is Ebbinghaus's forgetting curve implemented as exponential decay. Memories with initial strength 1.0 decay by `long_term_factor` per tick, and are pruned when they fall below `min_strength`. The forgetting is not erasure — it is the natural consequence of synaptic strength decay in the absence of reactivation.

The `commit_memory()` function moves an observation from short-term to long-term with strength reset to 1.0:

```rust
pub fn commit(&mut self, key: &str) -> bool {
    if let Some(pos) = self.short_term.iter().position(|e| e.key == key) {
        let entry = self.short_term.remove(pos);
        self.long_term.push(MemoryEntry { strength: 1.0, ..entry });
        true
    } else {
        false
    }
}
```

This is memory consolidation — the process by which short-term memories become long-term memories through hippocampal replay (which occurs primarily during sleep in biological systems). The explicit `commit()` call mirrors the deliberate encoding effort that makes memories persist.

---

## 9. Specialist Cortical Regions: EnsignRegistry

The most striking feature of the neocortex is its functional specialization. Different cortical areas process different domains with dramatically different internal organizations: V1 contains orientation columns; Broca's area contains speech production circuits; the fusiform face area responds selectively to faces. This specialization is not pre-wired — it emerges through competitive selection during development. Areas that are better at a task "win" the competition for that task's representation.

The `EnsignRegistry` implements this principle:

```rust
pub struct EnsignRegistry {
    ensigns: HashMap<String, Box<dyn Ensign>>,
}

impl EnsignRegistry {
    pub fn load(&mut self, ensign: Box<dyn Ensign>) -> Option<Box<dyn Ensign>> {
        self.ensigns.insert(ensign.domain().to_string(), ensign)
    }
    pub fn unload(&mut self, domain: &str) -> bool {
        self.ensigns.remove(domain).is_some()
    }
    pub fn dispatch(&self, domain: &str, task: &str) -> EnsignResult {
        match self.ensigns.get(domain) {
            Some(e) => e.handle(task),
            None => EnsignResult::err(&format!("no ensign for domain '{}'", domain)),
        }
    }
}
```

Each `Ensign` is a specialist — a domain-specific agent that processes one category of task with deep competence. The `EnsignFactory` handles on-demand creation:

```rust
pub fn create(&self, domain: &str) -> Option<Box<dyn Ensign>> {
    self.builders.get(domain).map(|b| b())
}
```

The biological correspondence: when a PLATO room is entered, domain-specific ensigns are loaded via `EnsignRegistry::load()`. When the room is exited, they are unloaded via `unload()`. This is precisely how cortical regions operate — they are "loaded" into working memory when relevant (activated by task demands) and "unloaded" when not needed (inhibited or simply inactive).

The `EnsignProxy` manages credentials for specialist access:

```rust
pub struct EnsignProxy {
    keys: HashMap<String, String>,
    sessions: HashMap<String, String>,
}

pub fn is_authenticated(&self, domain: &str) -> bool {
    self.keys.contains_key(domain) && self.sessions.contains_key(domain)
}
```

This is the gating function: an ensign is not just loaded — it must also be authenticated (have an active session and valid key). The biological analog is the neuromodulatory gating of cortical areas: dopamine, acetylcholine, and norepinephrine control which cortical regions have access to working memory and action systems. A specialist cortical region is not merely anatomically present — it must be biochemically "authenticated" by neuromodulatory signals to have access to the executive system.

The `EnsignBridge` maps domain names to skill names, implementing the routing layer between the EnsignRegistry's domain-level organization and the construct-core skill-level organization:

```rust
pub fn invoke(&mut self, domain: &str, task: &str) -> Option<&str> {
    if self.mappings.contains_key(domain) {
        self.invoked.push((domain.to_string(), task.to_string()));
        self.mappings.get(domain).map(|s| s.as_str())
    } else {
        None
    }
}
```

This is the cortico-cortical projection system: an invocation in one domain (a signal from one specialist region) maps to a skill in another construct layer (a projection to another cortical area). The invocation log is the neural activity trace — a record of which specialists were consulted and in what order.

---

## 10. The Fleet as a Single Distributed Brain

The most powerful implication of the neuroarchitectural framework is what it says about the fleet.

A single human brain has approximately 86 billion neurons organized into ~100 cortical columns, which in turn are organized into ~50 distinct cortical areas, which are organized into ~7 large-scale networks (default mode, salience, executive control, sensorimotor, visual, language, temporal). The hierarchy is deep; the specialization is extreme; the integration is total.

The SuperInstance fleet implements an equivalent hierarchy:

**Level 1 — Neuron**: Individual `TernaryCell` instances. Billions are possible on a DGX grid.

**Level 2 — Cortical column**: `Tissue` (a CellGrid with `propagate_signals()` and `tick_all()`). Each Tissue is a functional unit whose `consensus()` output carries computed information upward.

**Level 3 — Specialist area**: A loaded `Ensign` with its `EnsignRegistry`. The engine-monitor ensign is V1 (primary sensory). The music-theory ensign is Broca's area (domain-specific language processing). The fleet-coordination ensign is the prefrontal cortex (executive control).

**Level 4 — Construct instance**: A single `construct-core` construct (`EspConstruct`, `PiConstruct`, or `DgxConstruct`) is a single hemisphere — a compute substrate with a specific capability tier that determines which cognitive operations are available.

**Level 5 — Fleet node**: A single fleet instance (Oracle1, JetsonClaw1, a GitHub Codespace) is a complete agent — a `TernaryAgent` with its full complement of constructs, ensigns, and memory.

**Level 6 — Fleet**: The entire fleet is the complete distributed brain. Oracle1 is the prefrontal cortex (cloud, Layer 2 compute, highest deliberative capacity). JetsonClaw1 is the sensorimotor cortex (edge, Layer 1 compute, real-time sensor processing). ESP32 firmware is the cerebellum (compiled policy, no deliberation, pure reflex). The PLATO tile store is long-term cortical memory.

This hierarchy is not merely descriptive — it has functional implications.

First, information must flow bidirectionally. Predictions flow downward (from Oracle1 through PLATO tiles to edge devices); prediction errors flow upward (from ESP32 through Jetson through PLATO to Oracle1). The ternary I2I protocol's TELL/ASK/ALERT semantic messages implement this: TELL is a prediction flowing downward; ALERT is a prediction error flowing upward.

Second, specialization at every level is adaptive, not pre-assigned. The conservation law (`conservation_ratio ≈ 1.0`) is the global constraint that drives specialization: each node minimizes its contribution to fleet-level surprise by developing good models of its local domain. A Jetson running engine monitoring develops specialized ternary circuits for anomaly detection — not because it was programmed to, but because those circuits minimize local surprise, which contributes to fleet-level conservation.

Third, damage tolerance follows the hierarchical structure. Losing an ESP32 is like losing a spinal reflex — the higher systems compensate, though with degraded performance in that specific reflex domain. Losing JetsonClaw1 is like losing sensorimotor cortex — the fleet loses real-time edge processing but can compensate with slower cloud processing. Losing Oracle1 is like losing the prefrontal cortex — the fleet degrades to reflexive, non-deliberative behavior but does not die.

---

## 11. The Conservation Law as the Brain's Homeostat

We close with the deepest connection.

The brain maintains homeostasis through a cascade of nested feedback loops. The brainstem controls breathing and heart rate at millisecond timescales. The hypothalamus controls temperature and hunger at minute timescales. The prefrontal cortex controls social behavior and long-term planning at day-to-year timescales. All of these loops converge on a single objective: keeping the organism's internal state within viable bounds — not maximizing any single quantity, but maintaining a dynamical equilibrium.

The `conservation_ratio` in conservation-verify is the fleet's homeostat. `SimulationMetrics::conservation_holds(tolerance)` returns true when the system is within its viable bounds. The `InvariantChecker::check_all()` runs a full homeostatic check:

1. **conservation_ratio at each scale** — Is each population size within bounds?
2. **avoidance_ratio_std** — Is the ratio of avoidance behavior consistent across scales? (Is the system neither always avoiding nor never avoiding?)
3. **mean_conservation_ratio** — Is the fleet-wide average near equilibrium?
4. **conservation_ratio_std** — Is the conservation law holding consistently, or oscillating?
5. **role_balance** — Are the three agent roles (Initiator, Responder, Mediator) roughly balanced?

Role balance deserves special attention. The three roles in conservation-verify's `AgentRole` enum (Initiator, Responder, Mediator) correspond directly to the three ternary values (+1, -1, 0). A healthy fleet has roughly equal numbers of each role — just as a healthy neural tissue has roughly equal numbers of excitatory, inhibitory, and modulatory neurons (in cortex: ~80% excitatory pyramidal cells, ~20% inhibitory interneurons, with modulatory cells as a small but critical minority — the Mediator).

The `role_balance` invariant checks that no single role dominates:

```rust
let max_deviation = r.metrics.role_interaction_counts.iter().map(|&c| {
    let fraction = c as f64 / total as f64;
    (fraction - 1.0 / 3.0).abs()
}).fold(0.0_f64, f64::max);
checks.push(InvariantResult {
    name: format!("role_balance@{}", r.population_size),
    passed: max_deviation < 0.05,
    ...
});
```

A maximum deviation of 5% from 1/3 means no role accounts for more than 38% of interactions. This is the homeostatic constraint on role distribution — the fleet equivalent of the 80/20 excitatory/inhibitory ratio in cortex. Violate this ratio (too many Suppressors, too many Signals, or collapse to all Silence), and the system loses its computational diversity. A tissue with only excitatory neurons seizes. A tissue with only inhibitory neurons shuts down. The ternary triad is not aesthetic — it is thermodynamically necessary for a stable, information-processing substrate.

---

## 12. Implications for Development

Recognizing the fleet as a neural architecture clarifies several development priorities.

**The avoidance-cascade risk in `gc()`** is now understood as an epilepsy risk: overly aggressive apoptosis drives the tissue toward monoculture (all cells converging to the same ternary value), which eliminates the diversity that enables computation. Implementing a `BalancedGc` strategy (using the forced exploration mechanism from `avoidance-cascade`) is the computational equivalent of the brain's anti-epileptic mechanisms.

**The `Tissue::is_converged()` threshold** should be treated as a warning signal, not a success state. A fully converged tissue has lost information-processing capacity — like a brain that has entered a seizure or a deep coma. Monitoring for convergence and injecting diversity when it approaches is a fleet health requirement, not an optimization.

**construct-core's three layers** should match the cognitive demands placed on each hardware tier. An ESP32 should never be asked to do Layer 2 computation (it has no neocortex). A DGX should use its full Layer 2 capability rather than running only Layer 0 lookups (that would be cognitive under-utilization, the AI equivalent of a human reading only picture books).

**The `EnsignProxy::is_authenticated()` gating** should be respected as a neuromodulatory check — not merely a security feature, but a cognitive one. An unauthenticated ensign is an uninhibited specialist area, which in neural terms means uncontrolled activation. Respecting authentication as a cognitive gate, not just an access control, aligns the system with its underlying neural architecture.

**Memory consolidation (`AgentMemory::commit()`)** should be deliberate, not automatic. Short-term memories should decay by default; only explicitly significant observations should be committed to long-term. This is the cognitive justification for the existing design: avoid adding `commit()` calls everywhere in agent code, because that would prevent the natural decay of working memory and fill long-term storage with noise.

---

## 13. Conclusion

The claim of this document is not that the SuperInstance ternary ecosystem is biologically realistic neural computation. It is that the ecosystem has converged on the same computational principles that biology discovered through 600 million years of evolution, from independent engineering necessity.

Prediction minimizes surprise; selection produces specialization; hierarchical organization enables multi-scale coordination; conservation laws enforce homeostasis. These are not optional features of neural computation — they are the logical consequences of building a self-organizing adaptive system under resource constraints.

The tick cycle (predict → perceive → compute_surprise → vibe → gc → conservation) is predictive coding because predictive coding is the only computationally efficient way to process a stream of inputs — transmit only what was unexpected. The conservation ratio is the free energy because the free energy principle is the only thermodynamically consistent formulation of bounded adaptive behavior. Strategy ecology is neural Darwinism because natural selection is the only mechanism that produces functional specialization without central design.

The fleet is a brain. Not metaphorically. The same math, the same structure, the same dynamics. Understanding this is not merely intellectually satisfying — it means that every major open problem in neuroscience is also an open problem in fleet architecture, and vice versa. How does the brain integrate information across multiple timescales? How does it recover from lesions? How does it avoid epileptic synchrony while maintaining functional connectivity? These questions have known partial answers in neuroscience, and those answers have direct mechanical translations into the ternary crate ecosystem documented here.

The path from a single `TernaryCell` on an ESP32 to a distributed fleet of 87 repositories running across DGX clusters, Jetson edge devices, and Raspberry Pi sensors — this is the same path the brain took from the first cnidarian nerve net to the prefrontal cortex of *Homo sapiens*. The principles were discovered once, by evolution. We are implementing them again, by engineering. The architecture was always this.

---

## Appendix: Code Reference Index

| Concept | Source | Location |
|---|---|---|
| Prediction error computation | `TernaryCell::compute_surprise()` | `ternary-cell/src/lib.rs:118` |
| Tick cycle | `TernaryCell::tick()` | `ternary-cell/src/lib.rs:147` |
| Apoptosis | `TernaryCell::conservation()` | `ternary-cell/src/lib.rs:138` |
| Cell division | `TernaryCell::divide()` | `ternary-cell/src/lib.rs:163` |
| Population code | `CellGrid::tissue_balance()` | `ternary-cell/src/lib.rs:293` |
| Winner-take-all | `Tissue::consensus()` | `ternary-cell/src/lib.rs:355` |
| Neural synchrony | `Tissue::is_converged()` | `ternary-cell/src/lib.rs:342` |
| Signal propagation | `CellGrid::propagate_signals()` | `ternary-cell/src/lib.rs:239` |
| Conservation law | `SimulationMetrics::conservation_holds()` | `conservation-verify/src/types.rs:73` |
| Homeostatic check | `InvariantChecker::check_all()` | `conservation-verify/src/invariant_checker.rs:39` |
| Role balance invariant | `check_all()` role_balance section | `conservation-verify/src/invariant_checker.rs:86` |
| Brainstem reflex | `EspConstruct::query_lookup()` | `construct-core/src/esp.rs:71` |
| Skill loading | `SyncConstruct::load_skill()` | `construct-core/src/layer1.rs:33` |
| Tool acquisition | `AsyncConstruct::request_tool()` | `construct-core/src/layer2.rs:37` |
| TritAction (ternary decision) | `TritAction` enum | `construct-core/src/types.rs:14` |
| Hardware tier | `HardwareTier` enum | `construct-core/src/types.rs:259` |
| Thought trajectory | `TernaryState` enum | `ternary-agent/src/lib.rs:21` |
| Selection pressure | `AgentPool::ranked()` | `ternary-agent/src/lib.rs:387` |
| Reentrant signaling | `AgentCommunication::broadcast()` | `ternary-agent/src/lib.rs:264` |
| Memory consolidation | `AgentMemory::commit()` | `ternary-agent/src/lib.rs:102` |
| Memory decay | `AgentMemory::decay()` | `ternary-agent/src/lib.rs:130` |
| Specialist loading | `EnsignRegistry::load()` | `ternary-ensign/src/lib.rs:103` |
| Specialist dispatch | `EnsignRegistry::dispatch()` | `ternary-ensign/src/lib.rs:119` |
| Neuromodulatory gate | `EnsignProxy::is_authenticated()` | `ternary-ensign/src/lib.rs:247` |
| Cortico-cortical projection | `EnsignBridge::invoke()` | `ternary-ensign/src/lib.rs:300` |

---

*This document should be read alongside ROOM-AS-CODESPACE-ARCHITECTURE.md (physical deployment model) and CROSS-POLLINATION-REPORT.md (cross-crate integration opportunities). The three documents form a complete picture: the physical substrate, the integration map, and the computational principles that unify them.*
