# SKDE Instance Map — Fleet-MIDI Pipeline

Part of the Simulation Knowledge-Distillation Engine framework.
This document maps the live fleet-MIDI pipeline (ports 8765-8770, 2160-2175)
into the O-A-C-G-R abstraction.

## Instance Identity

```
SKDE Instance: fleet-midi-pipeline
Repos:
  - fleet-oracle2 (daemons/)
  - fleet-midi-{agent} (16 repos)
Ports:
  - 8765: OpenSMILE Bridge (audio capture)
  - 8767: Ghost Track (predictions)
  - 8768: tminus-dispatcher (cue scheduling)
  - 8769: Fleet Conductor (routing)
  - 8770: Piper TTS (voice output)
  - 2160-2175: 16 fleet-midi agent endpoints
Type: musical-generation
Flavor: real-time-ternary
```

## O-A-C-G-R Mapping

### Observe

| Source | Format | Frequency | Freshness |
|--------|--------|-----------|-----------|
| Microphone | raw audio (48kHz) | streaming | 10ms frames |
| OpenSMILE Bridge (:8765) | JSON 25 eGeMAPS features | 100ms | real-time |
| Ghost Track (:8767) | JSON T-0..T-4 predictions | per gesture | ~500ms latency |
| Fleet Conductor (:8769) | JSON agent states (17 agents) | per gesture | ~500ms latency |
| 16 agent endpoints (:2160-2175) | JSON ternary decisions | per gesture | ~50ms each |

**Observation primitive:** ctypes `ExternalAudioSource` (ring buffer + background
thread) feeding OpenSMILE which produces a feature vector every 100ms.

### Abstract

**Fingerprint:** 16-dimensional ternary vector per gesture:

| Agent | Dim | Ternary Values | Semantics |
|-------|-----|----------------|-----------|
| chord | 1 | {-1,0,+1} | Harmony direction |
| scale | 2 | {-1,0,+1} | Mode |
| voicing | 3 | {-1,0,+1} | Chord voicing density |
| tempo | 4 | {-1,0,+1} | Speed adjustment |
| cc | 5 | {-1,0,+1} | Continuous controller |
| expression | 6 | {-1,0,+1} | Dynamic envelope |
| dynamics | 7 | {-1,0,+1} | Volume |
| pan | 8 | {-1,0,+1} | Spatial position |
| modulation | 9 | {-1,0,+1} | LFO depth |
| arp | 10 | {-1,0,+1} | Arpeggio direction |
| groove | 11 | {-1,0,+1} | Swing offset |
| velocity | 12 | {-1,0,+1} | Attack force |
| fx | 13 | {-1,0,+1} | Effect depth |
| register | 14 | {-1,0,+1} | Octave shift |
| melody | 15 | {-1,0,+1} | Melodic contour |
| bass | 16 | {-1,0,+1} | Bass line direction |

**Compression method:** Each agent independently produces a ternary decision
based on its input features. High entropy (each gesture yields ~7 ±3 active
agents). Low latent dimension (ternary is already maximally compressed).

**Abstraction primitive:** `POST /agent` with `{eGeMAPS_25: [...], active_agents: [...]}`

### Contrast

**Deviation vector:** Not currently computed — all agents are orthogonal.
A deviation vector would compare current ternary state against the agent's
historical distribution. High deviation = unusual musical behavior.

**Contrast primitive:** (not implemented) would be:
```
deviation[agent] = (mag(decision) - mean_mag) / max(0.001, std_mag)
```

### Govern

**Primary mechanism:** Conservation Law (implicit, not voted)

```
Σ(Δ_midi) = 4 × Σ(ternary)
```

Meaning: the sum of all MIDI deltas equals 4× the sum of ternary decisions.
This enforces **voice closure** — a musical gesture that moves "out" must
return "in" to balance.

**Secondary mechanism:** Conductor routing. The Fleet Conductor decides
which 7 of 16 agents activate per gesture. This is equivalent to the colony
vote mechanism — agents "vote" through their feature input, conductor
"enforces" by selecting the active set.

**Governance primitive:** Conservation law check after every gesture:
Sum of (chord + scale + voicing + ...) must ≡ 0 (mod 4) × active agent count.

### Reflect

**Narrative:** (not currently implemented). Would be:
- "Performed an ascending tetrad with increased dynamics and swing"
- "Current state: 12 active agents, high entropy (7 gestures/min), dominant chord"

**Reflection primitive:** (not implemented) — would consume 16 agent decisions
and produce a natural language description of the musical gesture.

## Dimensional Expansion

The MIDI pipeline could expand to include:
- SKDE-driven norm formation: "If the colony is in high-aggression mode (many
  PD betrayals), reduce register by 1 octave to match emotional tone"
- Self-modeling: Music can model its own evolution across a session

## Cross-Instance Interface

The MIDI SKDE communicates with other instances via:

```
fleet-midi → I2I → colony-psychology: "I'm playing in C major (low tension)"
colony-psychology → I2I → fleet-midi: "Colony is in high-deception regime (trust=46)"
→ Result: fleet-midi shifts to Locrian mode (high tension) to match colony mood
```

This cross-instance feedback is the primary innovation of SKDE — not just
compressing within a system, but allowing systems to inform each other through
shared abstraction.
