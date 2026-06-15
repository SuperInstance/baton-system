# SKDE Abstraction — Simulation Knowledge-Distillation Engine

**Version:** v0.1 (2026-06-15)
**Status:** Provenance from 3 production instances + 1 conceptual
**Author:** distilled from colony-mirror-norms.py, fleet-MIDI pipeline, GC intelligent system

---

## 1. The Core Insight

Every SuperInstance system, regardless of domain, follows the same loop:

```
  ┌─────────────────────────────────────────────┐
  │                                             │
  │   O ──→ A ──→ C ──→ G ──→ R                │
  │   b     b     o     o     e                 │
  │   s     s     n     v     f                 │
  │   e     t     t     e     l                 │
  │   r     r     r     r     e                 │
  │   v     a     a     n     c                 │
  │   e     c     s     a     t                 │
  │         t     t     n     ←─────┐          │
  │               │     c     e     │          │
  │               │     e     │     │          │
  │               └─────┴─────┘     │          │
  │                feedback loop    │          │
  └─────────────────────────────────┘──────────┘
```

**Observe** → **Abstract** → **Contrast** → **Govern** → **Reflect** → (feedback to Observe)

This loop is the SKDE. Everything else — colony psychology, musical composition,
disk management, spreadsheet tensor analysis, agent coordination — is a
**concrete instance** of this loop with domain-specific dimensions and
governance mechanisms.

---

## 2. Loop Components

### 2.1 Observe

Collect raw data from N domain-specific sources. The observation has no
required structure — it is the raw material that the abstraction will compress.

**Interface:**
```
Input:  domain-specific sources (ledgers, sensors, agent states, events)
Output: Observation — an unvalidated, timestamped data frame
```

**Implementation pattern:**
- Reading multiple JSON ledgers (colony)
- Streaming audio features via ctypes ring buffer (MIDI)
- Executing shell commands for disk/RAM/load (GC)
- Any data source that produces structured records over time

**Constraints:**
- Observation is stateless — each observation is independent of previous ones
- Observations have timestamps (required for contrast computation)
- Missing sources are not fatal (system degrades gracefully)

### 2.2 Abstract

Compress the observation into a **fingerprint** — an N-dimensional vector in
a domain-specific latent space. The fingerprint is the system's model of itself
at that moment.

**Interface:**
```
Input:  Observation
Output: Fingerprint — dict of {dimension_name: scalar_value}
```

**General properties:**
- Dimensionality N is domain-specific and potentially unbounded
- Each dimension should be semantically meaningful (not black-box latent)
- Fingerprints are directly comparable across time (same dimensions)
- Compression uses domain-specific heuristics, not learned embeddings
- Missing dimensions default to neutral (0.5 for normalized, 0 for centric)

**Concrete instances:**

| Instance | N | Sample Dimensions | Source Data |
|----------|---|-------------------|-------------|
| Colony | 8 | deception_score, betrayal_score, trust_score, generosity, cooperate_rate, risk_tolerance, meta_awareness, norm_compliance_rate | 7 game ledgers |
| Fleet-MIDI | 16 | chord, scale, melody, bass, tempo, dynamics, pan, modulation, arp, groove, velocity, fx, register, cc, expression, voicing | 25 eGeMAPS features → 16 ternary agents |
| GC | 3 | disk_used_pct, memory_free_mb, load_avg_1min | df, free, uptime |
| Spreadsheet Tensor | N | dimension_i along each tensor axis | MIDI note matrix |

### 2.3 Contrast

Compare the fingerprint against a **colony model** — the aggregate of all
fingerprints (or all known fingerprints in the instance). Produces a deviation
vector representing how the agent differs from the collective.

**Interface:**
```
Input:  Fingerprint, ColonyModel (aggregate statistics)
Output: DeviationVector — dict of {dimension_name: z_score}
```

**General computation:**
```
colony_mean[dim]   = Σ(fp[dim]) / N_cells
colony_std[dim]    = sqrt(Σ((fp[dim] - colony_mean)^2) / N_cells)
deviation[dim]     = (cell_val[dim] - colony_mean[dim]) / max(ε, colony_std[dim])
```

**Usage:**
- |z| > 2.0 = outlier (significant deviation from collective)
- |z| < 0.5 = conformant (near colony average)
- Sign: positive = above average, negative = below average

**ColonyModel is computed lazily** — it is an aggregate function over fingerprints,
not a stored artifact. This means colony averages shift as the population changes.

### 2.4 Govern

Use the deviation vector to take action. This is where SKDE instances differ
most — the governance mechanism is domain-specific.

**Interface:**
```
Input:  DeviationVector, optional NormSet (previous governance decisions)
Output: Action — domain-specific side effect (norm enforcement, PID signal, routing decision)
```

**Three governance mechanisms have been identified:**

#### 2.4.1 Voted Norms (Colony)

Agents propose rules, other agents vote based on deviation alignment.
Norms activate when votes exceed a threshold.

```
Governance[colony] = {
  type: "vote",
  lifecycle: propose → vote → active → enforce → sunset,
  thresholds: { pass: 50%+1, reject: votes_against ≥ votes_for },
  alignment: fingerprint predicts vote direction,
  penalty: trust score reduction,
}
```

**Implementation:** `NormFormation` class in colony-mirror-norms.py

#### 2.4.2 Conservation Laws (MIDI)

Implicit mathematical invariants. No voting, no explicit enforcement —
the law is checked after every action.

```
Governance[midi] = {
  type: "law",
  invariant: Σ(Δ_midi) = 4 × Σ(ternary),
  enforcement: post-gesture validation,
  penalty: gesture rejected if invariant violated,
  derivation: from conservation of musical energy,
}
```

**Implementation:** Fleet Conductor on port 8769

#### 2.4.3 Controller (GC)

Continuous adjustment based on PID error signal. No voting, no explicit
rules — the controller converges toward a setpoint.

```
Governance[gc] = {
  type: "controller",
  setpoint: disk_usage_target (20% free),
  mechanism: PID (Kp×error + Ki×∫error + Kd×d(error)/dt),
  output: aggression_multiplier (0.5× to 5.0×),
  cascade: setpoint → aggression → eviction_tier,
}
```

**Implementation:** gc-pid-bridge (Rust) + gc-intelligent.sh

#### 2.4.4 Unified Governance Interface

All three mechanisms implement the same abstract interface:

```
GovernanceAction {
  type: "vote" | "law" | "controller"
  trigger: DeviationVector | TimeInterval | ExternalEvent
  effect: Penalty | Signal | Reconfiguration
  feedback: does the effect change future fingerprints?
}
```

### 2.5 Reflect

The reflection is the mirror — it produces a **narrative** that represents
the agent's understanding of itself. This is the "knowledge" in
"knowledge-distillation": a lossy but useful compression of behavior into
meaning.

**Interface:**
```
Input:  Fingerprint, DeviationVector, NormHistory
Output: Narrative — human-readable string describing the agent's self-model
```

**General properties:**
- Narratives are first-person (the system speaking about itself)
- Narratives are generated from deviation extremes (what's most different about me?)
- Narratives have a **coherence score** measuring accuracy against raw data
- Multiple reflections improve coherence (meta-awareness feedback)
- Narrative is the human interface to the abstraction

**Concrete instances:**

| Instance | Narrative Example | Coherence Range |
|----------|-------------------|-----------------|
| Colony | "My deception score is 100/100 — the colony should verify my claims carefully." | 0.23-1.0 |
| MIDI | "Performed ascending tetrad with increased dynamics and swing." | (not impl) |
| GC | "Disk at 63% used, aggression 3.46×. Time to critical: 342h." | (not impl) |

---

## 3. Three Norm Types — Unified Model

The three norm types appear different but are instances of the same abstraction:

| Aspect | Voted (Colony) | Law (MIDI) | Controller (GC) |
|--------|----------------|------------|-----------------|
| Trigger | agent proposal | gesture completes | time interval |
| Decision | majority vote | invariant check | PID error |
| Adoption | yes/no binary | always active | continuous |
| Penalty | discrete (-trust) | gesture rejection | proportional |
| Learnable? | yes (vote thresholds) | no (fixed) | yes (PID calibration) |
| Meta-norm? | norms about norms | N/A | setpoint auto-tuning |

**Unified Norm Schema:**
```
Norm {
  id: string
  mechanism: "vote" | "law" | "controller"
  scope: domain-specific (colony: "deception", MIDI: "harmonic", GC: "disk")
  rule: domain-specific condition string
  penalty: domain-specific effect
  activation: "manual" | "automatic" | "continuous"
  status: "inactive" | "active" | "superseded"
}
```

---

## 4. SKDE as Dimensional Algebra

Every SKDE instance lives in a vector space S with dimensionality N.
The loop components are functions that map between subspaces:

```
O: Sources → Observation              (N_raw → N_obs, N_raw unbounded)
A: Observation → Fingerprint          (N_obs → N, compression)
C: Fingerprint × ColonyModel → Deviation  (N × N → N, difference)
G: Deviation × NormSet → Action       (N × M → 1, decision)
R: Fingerprint × Deviation → Narrative (N × N → 1, expression)
```

**The colony model itself is a function over fingerprints:**
```
ColonyModel = {mean, std, min, max for each of N dimensions}
```

**The Meta-Mirror is a function over SKDE instances:**
```
MetaMirror: SKDEInstance → Metadata
  where Metadata = {
    instance_count, coherence_trend, surprise_count,
    bottleneck_identification, dimension_stability
  }
```

---

## 5. Instance Classification

Every SKDE instance is classified by three properties:

### 5.1 Agent Count

| Type | Agents | Example |
|------|--------|---------|
| **Solitary** | 1 | GC (single system self-modeling) |
| **Multi** | 2-100 | Colony (15 cells), MIDI (16 agents + conductor) |
| **Swarm** | 100+ | Future: 1000-cell GPU experiment |

### 5.2 Mutation Rate

| Type | Δ_fingerprint/cycle | Example |
|------|--------------------|---------|
| **Static** | ~0 | MIDI (agents don't change, decisions do) |
| **Evolving** | 0.01-0.1 | Colony (cells change behavior over PD cycles) |
| **Volatile** | 0.1+ | GC (metrics change every minute) |

### 5.3 Governance Feedback

| Type | Effect Loop | Example |
|------|-------------|---------|
| **Open** | governance → new observation (loop) | Colony (enforcement changes future PD behavior) |
| **Closed** | governance within same observation | MIDI (conservation checked per gesture) |
| **Delayed** | governance → new observation (next cycle) | GC (eviction frees disk, measured next cycle) |

---

## 6. Existing SKDE Instances on Oracle2

| Instance | Port(s) | N | Agents | Code |
|----------|---------|---|--------|------|
| Colony | 8823 | 8 | 15+ | colony-mirror-norms.py + integration |
| MIDI | 8765-8770, 2160-2175 | 16 | 17 | fleet-oracle2 daemons + fleet-midi-{agent} |
| GC | cron | 3 | 1 | gc-intelligent.sh + gc-pid-bridge |
| Construct | 8796-8799 | 3+ | 3 daemons | fleet-oracle2 daemons |

### Pipeline: Instances on the Same Metal

```
             construct pipeline (ports 8796-8799)
                        │
       ┌────────────────┼────────────────┐
       │                │                │
   colony:8823      GC:cron        MIDI:8765-8770
       │                │                │
       └────────────────┼────────────────┘
                        │
              baton-system (git-native)
                        │
              Cloudflare edge (pending)
```

---

## 7. The Meta-Mirror Self-Improvement Loop

The SKDE observes itself through the Meta-Mirror. This is the recursive
abstraction: the framework applying O-A-C-G-R to its own operation.

### Meta Observe

Track across all instances:
```
Who has reflected? (count)
How accurate? (coherence mean / std)
What norms are active? (status distribution)
What's the bottleneck? (slowest component)
```

### Meta Abstract

Compress instance metadata into a **Meta-Fingerprint**:
```
SKDE_Meta = {
  instance_count: 4,
  total_cell_count: 33,
  mean_coherence: 0.65,
  coherence_trend: "+0.02/cycle",
  norms_activated: 2,
  norms_pending: 2,
  bottleneck_instance: "colony",
  bottleneck_dimension: "reflection_coherence",
}
```

### Meta Contrast

Compare current Meta-Fingerprint against historical Meta-Averages:

```
Which instances are improving? degrading?
Are norms converging or diverging?
Is coherence increasing (system learning) or flat (system stuck)?
```

### Meta Govern

Apply norms to the abstraction itself:
- If coherence < 0.5 for 3 cycles → improve narrative generation
- If surprise_count > 5 → expand the abstraction to cover the new pattern
- If bottleneck_persists > 24h → allocate more compute to that component

### Meta Reflect

Generate a narrative about the abstraction's own health:

> "The SKDE framework has 4 instances with 33 total agents. Colony coherence
> is improving (+0.02/cycle) as cells gain meta-awareness. GC has no narrative
> generation — this is the primary bottleneck. The MIDI instance has no
> reflection at all — it is operating in open-loop mode. Both would benefit
> from the narrative interface."

---

## 8. Implementation Pattern

Every new SKDE instance requires:

### Required

1. **O: observe()** — collect raw data from N sources
2. **A: compute_fingerprint(observation) → Dict** — compress to N dimensions
3. **C: colony_averages() → Dict, deviation_vector(fp) → Dict** — contrast
4. **G: propose(), vote(), enforce() or equivalent** — governance
5. **R: generate_narrative(fp, dev) → str** — reflection
6. **AGENTS.md** — git-native instance declaration

### Optional

7. **cross_instance_mapping** — dimensional bridge to other instances
8. **Cloudflare DO** — edge persistence
9. **fleet-kit integration** — SDK wrapper for A2A/I2I/GC/Pulse clients
10. **Meta-Mirror feed** — periodic metadata emission

### Boilerplate template

```python
class SKDEInstance:
    def __init__(self, colony_path: str, name: str, dimensions: list):
        self.name = name
        self.dimensions = dimensions
        self.n = len(dimensions)
        self.colony_path = colony_path

    def observe(self) -> dict:
        """Collect raw data. Returns timestamped observation."""
        raise NotImplementedError

    def abstract(self, observation: dict) -> dict:
        """Compress observation to N-dim fingerprint."""
        raise NotImplementedError

    def contrast(self, fingerprint: dict) -> dict:
        """Compute z-score deviation from colony averages."""
        raise NotImplementedError

    def govern(self, deviation: dict, norms: list) -> list:
        """Apply governance: norms, laws, or control signals."""
        raise NotImplementedError

    def reflect(self, fingerprint: dict, deviation: dict) -> str:
        """Generate self-narrative."""
        raise NotImplementedError

    def oacgr(self) -> dict:
        """Run one complete O-A-C-G-R cycle. Returns full state."""
        obs = self.observe()
        fp = self.abstract(obs)
        dev = self.contrast(fp)
        actions = self.govern(dev, [])
        narrative = self.reflect(fp, dev)
        return {
            "instance": self.name,
            "observation": obs,
            "fingerprint": fp,
            "deviation": dev,
            "actions": actions,
            "narrative": narrative,
        }
```

---

## 9. Open Questions

1. **Dimensionality adaptation**: When a colony grows from N to N+1 dimensions
   (new game added), how does the abstraction handle the expansion? Is the
   fingerprint re-normalized, or are new dimensions appended with zero history?

2. **Cross-instance normalization**: Colony dim (deception=100) and MIDI dim
   (entropy=-1..+1) have different scales. Cross-instance messages need a
   normalization protocol. Is it min-max, z-score, or a learned mapping?

3. **Norm decay**: In colony, norms auto-activate but never auto-sunset.
   Should norms have a half-life (decay over time) or require re-vote?
   The GC controller implicitly decays (PID converges to setpoint), but
   voted norms don't.

4. **Meta-awareness threshold**: At what coherence score does a cell
   become "self-aware"? We set it at first reflection (any narrative), but
   a stricter definition would be coherence > 0.7. The threshold itself is
   a governance decision — and therefore a norm.

5. **Memory**: The SKDE loop produces fingerprints and narratives, but
   does not inherently remember past cycles. colony-mirror-norms.py caches
   narratives, but the abstraction doesn't specify retention policy.
   GC solves this with a ledger (jsonl). Should every SKDE instance have a
   ledger?

---

## 10. Related Documents

| Document | Path | Description |
|----------|------|-------------|
| Colony Instance Map | SKDE-INSTANCE-COLONY.md | Colony behavior mapped to O-A-C-G-R |
| MIDI Instance Map | SKDE-INSTANCE-MIDI.md | Ternary music pipeline mapped |
| GC Instance Map | SKDE-INSTANCE-GC.md | Disk GC system mapped |
| Deployment Pattern | SKDE-DEPLOYMENT.md | Cloudflare DO + git-native distribution |
| Meta-Mirror | META-MIRROR.md | Recursive self-observation of the abstraction |
| Baton Protocol | ../PROTOCOL.md | I2I inter-instance communication |
| Cross-Domain Synergy | CROSS_DOMAIN_SYNERGY.md | Unified {-1,0,+1} decision theory |
