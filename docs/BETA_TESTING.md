# Beta Testing the Ternary Fleet

*A practical guide for testing any of the 200+ ternary crates.*

---

## The One-Test Pattern

Every ternary crate boils down to testing **three properties**:

### 1. The Value Test
Does the crate correctly represent $\{-1, 0, +1\}$?

```bash
cargo test
```

Check: Can you construct each state? Does `tadd(1, -1) == 0` hold?

### 2. The Composition Test
Do multiple ternary values compose correctly?

Check:
- `tadd(a, tadd(b, c)) == tadd(tadd(a, b), c)` (Associativity)
- `tadd(a, 0) == a` (Identity)
- `tadd(a, -a) == 0` (Inverse)

These three are the **group axioms**. If any fail, the crate isn't ternary.

### 3. The Conservation Test
Is the system state invariant under transformation?

```rust
let sum_before: i32 = system.state().iter().map(|t| *t as i32).sum();
system.evolve();
let sum_after: i32 = system.state().iter().map(|t| *t as i32).sum();
assert_eq!(sum_before, sum_after, "Conservation law violated");
```

---

## The "Quick Beta" Workflow

```
1. cargo build          → Does it compile?
2. cargo test           → Do unit tests pass?
3. cargo doc --open     → Is the docs comprehensible?
4. Manual: Does it link to symmetry siblings?
```

If all four pass, the crate is **beta-ready**.

---

## Finding Gaps

When a crate has no "See Also" links to its symmetry siblings, report it:

```markdown
### Crate: ternary-<name>
**Symmetry Group**: Rotational / Translational / Scalable / Reductive
**Missing Link**: Should link to <related-crate> because <reason>.
**Severity**: High / Medium / Low
```
