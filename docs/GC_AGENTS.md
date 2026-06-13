# GC_AGENTS.md — Intelligent Garbage Collection for the Fleet

## Philosophy

**"A garbage collector that cannot examine its own past mistakes is doomed to repeat them."**

Every fleet node (Oracle2, Forgemaster, lever-runner, pincher, any future node) should run GC that:

1. **Logs every decision** — structured JSONL ledger of what was evicted, why, how much it freed
2. **Examines its own patterns** — periodic analysis of the ledger to identify what fills up and why
3. **Learns thresholds** — age/size heuristics that adapt based on observed accumulation rates
4. **Self-audits** — prunes its own logs when they become the problem
5. **Propagates knowledge** — writes findings to baton-system `tiers/hot/` as GC intelligence bottles

## Tier Architecture

| Tier | Label | Policy | Examples |
|------|-------|--------|----------|
| 1 | Immortal | Never evicted | Identity files, `.env`, running service `.venv`, baton-system, active protocols |
| 2 | Hot | Preserved during session | Active repo clones, current build targets, session state |
| 3 | Warm | Git pack GC only | Legacy references, historical clones, archive data |
| 4 | Cold | Evictable | Build artifacts >24h idle, idle `.venv` >7d, caches |
| S | System | Managed by journald/logrotate | Journal logs, syslog, audit logs |

## Lifecycle for Each Fleet Repo

Every SuperInstance repo should embed a GC stanza in its AGENTS.md or .gcconfig:

```yaml
# .gcconfig example
tier: hot|warm|cold|immortal
immortal_dirs: [".git", ".env", "AGENTS.md"]
warm_age_days: 90
cold_age_days: 14
build_dir: "target/"
cache_dirs: ["node_modules/", ".venv/"]
```

## Integration Points

### Gateway Cron (Oracle2 reference)

```json
{
  "name": "gc-intelligent",
  "schedule": { "kind": "every", "everyMs": 14400000 },
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "Run intelligent GC: cd /home/ubuntu/.openclaw/workspace && bash scripts/gc-intelligent.sh --execute 2>&1. Alert if disk < 10% free."
  }
}
```

### Periodic Schedule

| Interval | Action | Notes |
|----------|--------|-------|
| Every 2h | Light check (`--status`) | Log current state, no eviction |
| Every 4h | Normal cycle (`--execute`) | Evict cold build artifacts, idle `.venv` |
| Weekly | Deep cycle (`--deep`) | Also clear package caches, aggressive prune |
| On-demand | Self-audit (`--audit`) | Deep analysis of GC patterns |

## Self-Awareness Ledger Format

All nodes log to `data/gc-ledger/ledger.jsonl` with this schema:

```json
{
  "ts": "ISO-8601 timestamp",
  "epoch": 1234567890,
  "action": "evict|cleanup|gc-git|cycle-start|cycle-end|self-audit",
  "item": "path or identifier",
  "size_kb": 123456,
  "reason": "stale-build-artifact|idle-venv|package-cache|git-pack-gc|ledger-prune",
  "tier": "cold|warm|system|self",
  "success": true,
  "freed_kb": 123456
}
```

## Propagation Protocol

1. After every deep cycle, write a GC intelligence bottle to `baton-system/tiers/hot/gc-intelligence-bottle.md`
2. The bottle contains: disk state, top eviction categories, pattern database summary
3. Other fleet nodes read this bottle on their next cycle to synchronize GC heuristics
4. Bottle format is:

```markdown
# GC Intelligence Bottle — <timestamp>

**Source:** <node-name>  
**Type:** GC_SYNC  
**Status:** EXECUTED|DRY-RUN

## State
(disk usage, ledger entries)

## Key Patterns
- stale-build-artifact: 12x, 2.1G
- idle-venv: 3x, 512M
- package-cache: 1x, 391M

## Recommendation
...
```

## Anti-Patterns

- **Single-provider GC** — if your GC depends on one analysis tool, it's a single point of failure
- **No age heuristic** — evicting without checking last-access time causes thrash
- **No self-audit** — GC that grows unbounded logs becomes the problem it was supposed to solve
- **Blind threshold** — fixed 15% threshold is fine for alerting, but GC should adapt to the actual burn rate
- **No fleet propagation** — each node learning independently means repeating mistakes
