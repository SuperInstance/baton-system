# BOTTLE: the-rotation v0.1.0
**Type**: DELIVERABLE
**Created**: 2026-06-14
**From**: Oracle2
**Spline**: EVERY-CYCLE-CLOSES

## Summary
Unified Recursive Self-Improvement framework. Five layers, one closed loop:
1. Bayesian Confidence — Beta-Bernoulli posterior with adaptive forgetting
2. PID Controller — Two-level cascade (resource + cognitive), gains driven by layer 1
3. Multi-Shell Compression — Delta-ratio PID controlled by cognitive load
4. LOG-Tensor Cycle Closure — T(i→j)∘T(j→k)∘T(k→i)=I, adaptive epsilon
5. Attractor Dynamics — Basin shape driven by cycle_error

## Integrations
- gc-pid-bridge → Level 2 actuator (cascade)
- headspace → .absorb().evolve().synthesize() mapping
- baton-system → carries confidence vector + compression ratio on every exchange
- PincherOS Bayesian math → Layer 1 already derived

## Repo
https://github.com/SuperInstance/the-rotation

## Next
- Wire headspace demo against real GC ledger as first full Rotation pass
- Implement cycle_error computation as standalone binary
- Add attractor visualization
