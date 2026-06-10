# Scale Sideways, Not Up

*Each crate is a single cell. You scale by making more cells, not bigger cells.*

## The Principle

Every ternary crate is:
- **One concern** — one algorithm, one mechanic, one measurement
- **Zero dependencies** — no external crates, no std::sync::Mutex, no heap-hungry generics
- **Stack-friendly** — the core data fits in a few hundred bytes. Instantiate on the stack.
- **Composable** — cells combine into tissues. Tissues into organs. No god objects.
- **Instantiable** — you don't configure a singleton. You spawn N copies. N = what hardware allows.

## Anti-patterns

❌ A crate that does "everything about signals" — that's a framework, not a cell
❌ HashMap<String, Vec<ComplexType>> — that's a database, not a computation
❌ Traits with 15 associated types — that's a cathedral, not a module

## Pattern

✅ `struct Agent { state: i8, velocity: f64, ticks: u64 }` — 10 bytes, fits in a cache line
✅ You want 10,000 agents? Allocate a Vec<Agent>. That's 100KB. Trivial.
✅ You want 1,000,000 agents? Same struct. That's 10MB. Still trivial.
✅ Every algorithm works on `&[i8]` or `&mut [i8]` — slices, not owned collections
✅ Functions return values, not heap-allocated wrappers

## Experiment Scaling

```
Hardware has 15GB RAM and N cores?

Each experiment instance:
  - 1000 agents × 10 bytes = 10KB
  - 1000 ticks of compute ≈ microseconds
  - Result: a few floats (mean, variance, drift)

You can run:
  - 100 instances in parallel = 1MB total, trivially parallel
  - Each instance tests a DIFFERENT parameter
  - Sweep forgiveness 0.0 to 1.0 in 100 steps? 100 instances, done in seconds
  
The experiment IS the unit of scale. Not the agent, not the crate.
```

## Instance Budget

| Resource | Budget per Instance | 1000 Instances |
|----------|-------------------|----------------|
| RAM | 10-100 KB | 10-100 MB |
| CPU | microseconds per tick | parallel across cores |
| Result | a few floats | a few KB |
| State | fixed-size arrays | contiguous memory |

No heap. No dynamic dispatch. No strings in hot paths. Just numbers and tight loops.

## How to Build

1. Start with the data: what are the numbers?
2. Make the struct as small as possible
3. Write the algorithm as `fn(state: &mut [i8], params: Params) -> Result`
4. Test with one instance
5. Scale by running the same function N times with different params
6. Collect results as `Vec<f64>` — aggregate downstream

The crate IS the function. The experiment IS the loop. The scale IS the instance count.
