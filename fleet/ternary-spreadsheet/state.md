# Ternary Spreadsheet Fleet State

**Repo**: github.com/SuperInstance/ternary-spreadsheet
**Version**: 0.1.0
**Status**: 📦 Rust crate, compiles clean

## What It Is
A spreadsheet where every cell is a ternary intelligence:
- Each cell: value {-1, 0, +1} with fitness score
- Formula engine: EVOLVE(), BEST(), SPECIES(), EXHAUSTIVE(), ENTROPY()
- Sort by fitness, autofill with mutation
- Conditional format with heatmaps

## Integration Points
The spreadsheet can be a **fleet dashboard** where:
- Each row = a fleet component (conductor, modulation, lever-runner, etc.)
- Each cell = ternary component state (+1=healthy, 0=unknown, -1=degraded)
- Formulas auto-evolve the fleet state
- EVOLVE(range, generations) tries combinations automatically

## Fleet State as Spreadsheet
```
        | Gateway | Conductor | Modulation | Bot  | HTTP  |
Fitness | +1      | +1        | +1         | +1   | +1    |
Status  | +1      | +1        | +1         | +1   | +1    |
Uptime  | 2d      | 45min     | 45min      | 45min| 45min |
Errors  | 0       | 0         | 0          | 2028 | 12    |
```
