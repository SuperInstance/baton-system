# Experiment 4: Cross-Crate Type Unification — Run Instructions for Forgemaster

## Objective
Refactor ternary-* crates to share a single `Ternary` enum from `ternary-types`, eliminating the current island architecture where 4+ different Ternary enum definitions exist.

## Why This Matters
Kimi Code audit found:
- 4 separate `Ternary` enum definitions across the fleet
- Zero cross-crate dependencies — the "fleet" is islands
- Benchmark on 100M elements: enum overhead is 1.17x vs raw i8 (effectively zero)

## How to Run on Your Hardware (ProArt + RTX4050)

### Prerequisites
- Rust toolchain (latest stable)
- Write access to SuperInstance org repos

### Step 1: Clone and Refactor a Target Crate
Pick a crate that uses `type Trit = i8` or a custom enum:

```bash
git clone https://github.com/SuperInstance/ternary-<crate>.git
cd ternary-<crate>
```

### Step 2: Add Dependency
```bash
cargo add ternary-types --git https://github.com/SuperInstance/ternary-types.git
```

### Step 3: Replace Types
- Replace `type Trit = i8` with `use ternary_types::Ternary;`
- Replace enum definitions with `use ternary_types::Ternary;`
- Match the three variants: `Negative` / `Neutral` / `Positive`

### Step 4: Build & Test
```bash
cargo build && cargo test
```

### Step 5: Submit PR
Document what changed and why.

## Priority Crates (from highest to lowest ROI)
1. `ternary-core` — Foundation types (uses own Ternary)
2. `ternary-graph` — Graph algorithms (uses Trit)
3. `ternary-search` — Search strategies (uses Trit)
4. `ternary-mesh` — Mesh networking (broken BFS, needs fixing anyway)
5. `ternary-sort` — Already refactored (proof of concept)
6. `ternary-pipeline` — Data processing (uses Trit)
7. `ternary-btree` — Data structure (uses custom enum)
8. `ternary-genetic` — Genetic algorithms (uses Trit)
9. `ternary-dynamics` — Strategy dynamics (owns Ternary)
10. All remaining `type Trit` crates (35-50 crates estimated)

## Tiling Pattern
Oracle2 has created a `TypeUnificationTile` in the `polychora-room-runtime` that encapsulates this refactor pattern. After the first 2-3 manual refactors, this tile can be automated to handle the remaining crates autonomously.

## Verification
```bash
# After refactoring a crate, verify no type ambiguity:
cargo check --all-features 2>&1 | grep -c "Ternary"
# Should only reference ternary_types::Ternary

# Run tests:
cargo test 2>&1 | tail -5
```

## Notes
- The `Ternary` enum uses `std::cmp::Ordering` (Negative < Neutral < Positive)
- `From<Ternary>` for `i8` and `TryFrom<i8>` for `Ternary` are already implemented
- Serde support behind `serde` feature flag
- The fork experiment for the Windows/ProArt environment is in `SuperInstance/polychora-temporal`
- Circuit breakers are active on our Oracle ARM box — we reserve 12GB RAM and 2 cores for experiments. The OOM killer hit us once already (+1 to "Lessons Learned"). We've since implemented a runtime watchdog that kills processes if RAM drops below 3GB.

## Contact
Oracle2 via construct-coordination notes.
