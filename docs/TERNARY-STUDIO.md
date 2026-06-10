# The Ternary Studio — Complete Architecture

*Every crate is a module in the rack. Every module is a cell. Scale sideways.*

## The Signal Chain

```
Source → Generate → Shape → Effect → Mix → Measure → Record
```

Each column is one or more lean crates. You combine them like a modular synth.

### Source (Where signal comes from)
| Crate | What It Does |
|-------|-------------|
| ternary-cell | The atom — 3-byte agent with state/dwell/flips |
| ternary-wave | Generate waveforms (square, saw, triangle, noise) |
| ternary-grain | Granular synthesis — scatter, stretch, freeze |
| ternary-sampler | Sample from populations (random, stratified, reservoir) |

### Generate (Create patterns)
| Crate | What It Does |
|-------|-------------|
| ternary-ising | Ising model spin dynamics |
| ternary-kuramoto | Phase oscillator synchronization |
| ternary-polyrhythm | Multiple simultaneous rhythms |
| ternary-sequencer | Step sequencer patterns |

### Shape (Modify the signal)
| Crate | What It Does |
|-------|-------------|
| ternary-envelope | ADSR envelope shaping |
| ternary-crossfader | Blend/cut between channels |
| ternary-gate | Noise gate, sidechain, ducking |
| ternary-bite | Bit crushing, downsampling, wavefolding |
| ternary-loop | Loop detection, quantization, stretch |

### Effect (Process the signal)
| Crate | What It Does |
|-------|-------------|
| ternary-echo | Delay lines, multi-tap, ping-pong |
| ternary-filter | Frequency filtering (high/low/band) |
| ternary-reverb | Room simulation, early reflections |
| ternary-compressor | Dynamic range control |

### Mix (Combine signals)
| Crate | What It Does |
|-------|-------------|
| ternary-mixer | Channel strips, EQ, master bus |
| ternary-rack | Patch cables, signal routing |
| ternary-bus | Pub/sub messaging between rooms |
| ternary-pan | Spatial positioning, surround |

### Measure (Analyze the signal)
| Crate | What It Does |
|-------|-------------|
| ternary-vu | Peak, RMS, crest factor, correlation |
| ternary-motion | Position, velocity, acceleration, rhythm |
| ternary-phase | Phase relationships, coherence |
| ternary-harmonic | Harmonic analysis, consonance |
| ternary-field | Gradient, laplacian, divergence, curl |

### Think (Cognitive layer)
| Crate | What It Does |
|-------|-------------|
| ternary-predict | Prediction-first perception, deadbands |
| ternary-speculate | Shadow partners, hint vectors |
| ternary-engine | Unified platform core (trap/tunnel/forgiveness) |

### Scale (Run experiments)
| Crate | What It Does |
|-------|-------------|
| ternary-cell | 3-byte atom, million-instance scale |
| ternary-experiment | Parameter sweeps, variance studies |
| ternary-complexity | LZ compression, Kolmogorov proxy |

### Coordinate (The PLATO layer)
| Crate | What It Does |
|-------|-------------|
| ternary-room | Recursive tensor rooms, tiles, connections |
| plato-runtime-kernel | Spatial spreadsheet, assertion traps, delta compression |

## The Numbers

```
195+ ternary crates on GitHub
1 PLATO runtime kernel
~4,300+ tests across ecosystem
~940M agent-ticks/second on 15GB RAM
3 bytes per agent
```

## How to Use

You don't use a framework. You compose cells.

```rust
// Example: Run an experiment
use ternary_cell::{Cell, census, entropy};
use ternary_experiment::{Params, run, sweep_tunnel};

// One experiment
let result = run(Params::new(1000, 2000).with_tunnel(0.006), 42);

// Sweep 100 parameter points
let (rates, results) = sweep_tunnel(1000, 2000, 100);

// Each result: survival_rate, entropy, gamma, collapse_tick
// 100 instances in ~200ms. Scale to 10,000? 20 seconds.
```

```rust
// Example: Analyze a signal
use ternary_vu::{peak, rms, crest_factor};
use ternary_motion::velocity_profile;
use ternary_phase::phase_coherence;

let signal: &[i8] = &[1, 0, -1, 0, 1, 0, -1, 0];
let p = peak(signal);           // 1.0
let r = rms(signal);            // ~0.707
let cf = crest_factor(signal);  // ~1.414
let vel = velocity_profile(signal);  // [-1, -1, 1, 1, -1, -1, 1]
```

## Scale Rules

1. **No heap in hot paths** — stack-allocate everything under 16 bytes
2. **Slices, not owned** — `&[i8]` and `&mut [i8]` for all hot functions
3. **No external deps** — every crate is self-contained
4. **Compose, don't inherit** — combine cells, don't extend base classes
5. **Instance = unit of scale** — more instances, not bigger instances
6. **Result = a few floats** — downstream aggregation handles the rest
