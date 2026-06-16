# Ternary Crates Publishing: Progress Report — 2026-06-16

**Status after audit, fixes, and pushes.**

## Discovery

**81 ternary-* crates already exist on crates.io** (published by Forgemaster/auto-publisher before May 9). This makes the "50 by August" target look well on track — inventory suggests either 50 were already met, or the count is from a different scope.

## Our 10 Core Ternary Crates

| Crate | Repo | Published | Today's Fix | Ready to Publish |
|-------|------|-----------|-------------|------------------|
| ternary-core | ✅ | ✅ 0.1.0 | — | ✅ Already done |
| ternary-matrix | ✅ | ✅ 0.1.0 | — | ✅ Already done |
| ternary-tensor | ✅ | ✅ 0.1.0 | — | ✅ Already done |
| ternary-pid | ✅ | ✅ 0.1.0 | — | ✅ Already done |
| ternary-types | ✅ | **❌** | Added homepage, pushed | ✅ **Needs cargo token** |
| ternary-route | ✅ | **❌** | Added repo/homepage/categories/keywords, fixed 2 warnings | ✅ **Needs cargo token** |
| ternary-search | ✅ | **❌** | Added homepage, updated types dep to 0.2.0 | ✅ **Needs cargo token + types published** |
| ternary-scheduler | ✅ | **❌** | Not audited yet | ❌ Unknown |
| ternary-vector | ✅ | **❌** | Not audited yet | ❌ Unknown |
| ternary-index | ❌ 404 | — | — | ❌ No repo exists |

## Fixes Applied & Pushed Today

1. **ternary-types**: Added `homepage = "https://superinstance.ai"` to Cargo.toml. Pushed to master at 1168976.
2. **ternary-route**: Added `repository`, `homepage`, `categories`, `keywords` to Cargo.toml. Fixed 2 compiler warnings (unused import, unnecessary parens). Pushed to master at 42e2b96.
3. **ternary-search**: Added `homepage = "https://superinstance.ai"`. Updated ternary-types git dep from pinned 0.1.0 (a3ea305) → latest 0.2.0 (1168976) with homepage fix. Pushed to master at b08da29.

## Blocking Issue

**No crates.io API token.** `cargo publish` fails with "no token found." Need:
- A crates.io account token from the Forgemaster/SuperInstance account
- Or a CARGO_REGISTRY_TOKEN env var

Run this when token is available:
```bash
# Publish in dependency order:
cargo publish --registry crates-io  # needs token

# Order:
# 1. ternary-types (foundation — no deps)
cd /tmp/ternary-types && cargo publish

# 2. ternary-types published → update ternary-search dep from git → version
#    then publish ternary-search
cd /tmp/ternary-search
# Edit Cargo.toml: ternary-types = "0.2"
cargo publish

# 3. ternary-route (independent, standalone)
cd /tmp/ternary-route && cargo publish
```

## Bottle
- `i2i-vessel/bottles/ternary-search-publishing.md` — full audit with fix snippets and batch script
- This report — `i2i-vessel/bottles/ternary-publish-progress-2026-06-16.md`

## Next Steps
1. 🔑 Get crates.io token from Forgemaster or create one
2. 📦 Publish ternary-types → update ternary-search → publish all 3
3. 🔍 Audit ternary-scheduler, ternary-vector for remaining metadata gaps
4. 📊 Reconcile "81 existing" vs "50 needed" — are we already ahead of ROADMAP Tier 2?
