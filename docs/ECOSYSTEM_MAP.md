# The Ternary Ecosystem Map

*How 200+ crates fit together — and how to find your way from any crate to any other.*

---

## The Shape of the Fleet

Think of the ecosystem as a **solar system** with three layers:

```
                       ┌──────────────────────┐
                       │   ternary-types       │  ← The atom
                       │   {-1, 0, +1}         │
                       └──────────────────────┘
                                │
                    ┌───────────┼───────────┐
                    ▼           ▼           ▼
        ┌──────────────────┐ ┌──────┐ ┌──────────┐
        │   ternary-core    │ │ ...  │ │ pincher  │  ← The cores
        │   traits + math   │ │grid  │ │ runtime  │
        └──────────────────┘ └──────┘ └──────────┘
                    │           │           │
        ┌───────────┼───────────┼───────────┼───────────┐
        ▼           ▼           ▼           ▼           ▼
    ┌──────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐
    │ ring │ │ matrix │ │compiler│ │ budget │ │percolate │  ← Domain crates
    │graph │ │topology│ │grammar │ │quorum  │ │thermostat│
    │route │ │homology│ │optimize│ │negotiat│ │membrane  │
    └──────┘ └────────┘ └────────┘ └────────┘ └──────────┘
```

Three levels. One invariant. 200+ crates.

---

## Level 1: The Atom (`ternary-types`)

The $\{-1, 0, +1\}$ type itself. Every crate in the fleet needs the same ternary type — this is the canonical source.

```rust
use ternary_types::Ternary;
let x = Ternary::Positive;   // +1
let y = Ternary::Neutral;    //  0
let z = Ternary::Negative;   // -1
```

**Tutorial:** [Ternary for the Rest of Us](https://github.com/SuperInstance/ternary-types/docs/TUTORIAL.md) — PR #1

---

## Level 2: The Cores

### `ternary-core` — Shared Traits
The mathematical vocabulary: `TernaryValue`, `TernaryDynamics`, `TernaryMeasure`. Any type implementing these inherits all fleet operations.

**Guide:** [The Symmetry Behind the Code](https://github.com/SuperInstance/ternary-core/docs/CONCEPTUAL_GUIDE.md) — PR #1

### `pincher` — The Runtime
Reflex engine using ternary logic for confidence-based decision making.

**Guide:** [Your First Ternary Application](https://github.com/SuperInstance/pincher/docs/GETTING_STARTED.md) — PR #9

---

## Level 3: The Domain Crates — Organized by Symmetry

| Symmetry | What it preserves | Example crates |
|----------|-------------------|---------------|
| **Rotational** | Z₃ cyclic structure | ring, cycle, harmonic |
| **Translational** | Shift invariance | matrix, route, motion |
| **Scalable** | Self-similarity across scale | topology, fractal, membrane |
| **Reductive** | Information density | compiler, optimizer, grammar |

Every domain crate must link to its symmetry siblings. This is the fleet's primary documentation gap (64% of crates currently have zero cross-links).

---

## The Invariant

Every crate in this ecosystem shares one guarantee:

> **The sum of all ternary states in a closed system is invariant.**

If a crate breaks this, it's not a ternary crate.
