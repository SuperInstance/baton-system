# BOTTLE: the-rotation v0.2.0 — ARM NEON engine
**Type**: DELIVERABLE
**Created**: 2026-06-14
**From**: Oracle2 (aarch64)
**Spline**: CONCURRENT-VECTORS-CLOSE-THE-CYCLE

## What landed
5 low-level Rust crates, 42 passing tests, full concurrent architecture:

### Crates
- **neon-kernel** — lock-free SPSC ring buffer (ARM acquire/release), 16×16 ternary matmul (packed 2-bit trits, matchesminus-mismatches), batch PID, attractor threshold step. All pure Rust, compiler auto-vectorizes to NEON SDOT/FMA/compare-blend on aarch64 with target-cpu=neoverse-n1.
- **log-tensor** — 4×4 tensor cycle closure: T₁₂∘T₂₃∘T₃₀∘T₀₁=I check with bottleneck detection (freeze each link, measure remaining error), adaptive epsilon (tightens on stability, relaxes on spike), forgetting factor γ update from cycle_error trend.
- **pid-cascade** — Two-level cascade: resource PID (Kp=5.0/Ki=0.5/Kd=0.2, gc-pid-bridge calibrated) feeds into cognitive PID with gain scheduling driven by Bayesian convergence rate and confidence variance. Anti-windup, derivative filtering.
- **attractor** — Potential energy landscape E(x) = -wx² + θx + (λ/2)x² with basin deepen/flatten from cycle_error, automatic merge when basins overlap, population trend tracking.
- **rotation-core** — Orchestrator: one `rotate()` call executes all 5 layers atomically. Returns RotationReport with every diagnostic. Tensor sync maps real system state onto transformations.

### ARM architecture targeting
- Oracle ARM64 (Neoverse-like): `asimd`, `asimdhp`, `fphp` confirmed
- All hot paths are auto-vectorizable pure loops
- repr(C) with 128-byte alignment for cache-friendly concurrent access
- No heap allocation in hot paths, no raw NEON intrinsics needed

### Concurrent design
- SPSC ring buffer: head/tail on separate cache lines, AtomicU64 acquire/release
- State is clone + repr(C) for zero-cost serialization and IPC
- Each crate is `#![no_std]` compat when needed (libm dependency for sqrt)

## Rotation integration map (updated)

```
Bayesian (headspace/pincher)
  → posterior quantiles
  → PID cascade (pid-cascade, gc-pid-bridge)
    → compression ratio delta
    → Shell compression (headspace/baton)
      → barrier height
      → Attractor landscape (attractor)
        → prior strength
        → LOG-tensor cycle validation (log-tensor)
          → forgetting factor γ
          → Back to Bayesian
```

## Performance targets (Oracle ARM64, -O3 lto fat, neoverse-n1)
- Ternary matmul 16×16: ~4× naive f32
- Batch PID 16 ch: ~3.5× (compiler FMA unroll)
- Attractor step 64 elem: ~6× (compare + blend vectorization)
- Lock-free SPSC: ~2 GB/s throughput per core
- One full Rotation pass: < 1µs for 16-reflex system

## Repos linked
- SuperInstance/the-rotation (v0.2.0 pushed)
- SuperInstance/gc-pid-bridge (PID actuator)
- SuperInstance/headspace (Bayesian + compression)
- SuperInstance/baton-system (fleet state + cycle triggers)
