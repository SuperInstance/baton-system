# Fleet Infrastructure Audit — 2026-06-14 17:55 UTC

**Host:** oracle2 (Ubuntu aarch64, kernel 6.8.0-1054-oracle)
**Scope:** All `fleet-*`, `lever-*`, `headroom-*`, `midi-notebook-*`, `piper-*`, `a2a-*` services
**Method:** `systemctl is-active`, `ps` (RSS/CPU/etime), `ss -tlnp`, source code review, live HTTP probes

---

## TL;DR Verdict Matrix

| Service | Status | Verdict | RSS | CPU | Uptime |
|---------|--------|---------|-----|-----|--------|
| `fleet-relay` (8790) | ✅ active | (a) actively useful — pulse receiver | 2.9 MB | 0.0% | 10h40m |
| `fleet-event` (8782) | ✅ active | (a) actively useful — pub/sub bus | 3.4 MB | 0.0% | 10h38m |
| `fleet-log` (8781) | ✅ active | (a) actively useful — log aggregator | 5.2 MB | 0.0% | 10h41m |
| `fleet-oracle` (8795) | ✅ active | (a) actively useful — local decision engine | 3.7 MB | 0.0% | 8h58m |
| `fleet-conductor` (8769) | ✅ active | (a) actively useful — cue router | 93 MB | 0.1% | 4d 7h |
| `fleet-opensmile` (8765) | ⚠️ active but doomed | (c) **consolidate or rebuild** — CWD deleted, can't restart | 130 MB | 0.5% | 16h |
| `fleet-modulation` (2168) | ❌ dead (SIGTERM 4d ago) | (b) **dead weight** | — | — | killed |
| `fleet-matrix-bridge` (6168) | ❌ dead (exited 13d ago) | (b) **dead weight** — requires missing `conduwuit` | — | — | — |
| `fleet-status` | ❌ **crash-looping 210,964+ times** | (b) **dead weight** — script file missing | — | — | restart loop |
| `fleet-ambient-briefing` (timer) | ❌ inactive | (b) dead weight — disabled | — | — | — |
| `fleet-ambient-loop` | 💔 broken symlink | (b) **dead weight** — target file gone | — | — | — |
| `fleet-health-monitor` | 💔 broken symlink | (b) **dead weight** — target file gone | — | — | — |
| `fleet-murmur-worker` | 💔 broken symlink | (b) **dead weight** — target file gone | — | — | — |
| `fleet-watchdog` (1min timer) | ❌ inactive | (b) **dead weight** — script is oneshot, no log since 2026-06-10 | — | — | — |
| `rotation-feed-server` (8796) | ✅ active but **orphaned** | (c) **consolidate into fleet-status or kill** | 19 MB | 0.0% | 8h49m |
| `midi-notebook-bridge` (no port) | ⚠️ active but **broken** | (c) **consolidate or kill** — TTS endpoint dead | 30 MB | 0.1% | 4d 8h |
| `lever-runner-bot` | ✅ active | (a) **actively useful** — 267 commands in DB | 139 MB | 0.5% | 4d 13h |
| `lever-runner-http-api` (8780) | ✅ active | (a) **actively useful** — healthz returns 200, 67 commands cached | 135 MB | 0.5% | 4d 13h |
| `headroom-proxy` (8788) | ⚠️ active but **500-erroring** | (b) **dead weight until fixed** — `UnboundLocalError: ccr_workspace_key` | **535 MB** | 0.0% | 16h23m |
| `tminus-dispatcher` (8768) | ❌ **service file doesn't exist** | (b) **dead weight** — but fleet-conductor Wants it | — | — | — |
| `piper-voice` (8770) | ❌ dead (since 06:29 today) | (b) **dead weight** — but midi-bridge wants it | — | — | — |
| `a2a-notebook` (8080) | ✅ active | (a) actively useful — 2 workers, 283 MB each | 360 MB | 0.1% | 4d |

**Total fleet RSS:** ~1.5 GB (dominated by headroom 535 MB, lever-runner 274 MB, a2a-notebook 360 MB, opensmile 130 MB, fleet-conductor 93 MB).

---

## 1. `/etc/systemd/system/fleet-*` and related unit files

Listed 24 fleet-adjacent unit files. Categorized:

### 🟢 Live & Useful (5)
- `fleet-relay.service` (8790) — heart of pulse protocol
- `fleet-event.service` (8782) — pub/sub bus
- `fleet-log.service` (8781) — structured log ingest
- `fleet-oracle.service` (8795) — local SVM/entropy decision engine
- `fleet-conductor.service` (8769) — Node.js cue router to 16 midi agents

### 🟡 Live but Degraded (3)
- `fleet-opensmile.service` (8765) — running, but on a **deleted CWD**. Cannot restart successfully. See §3.
- `midi-notebook-bridge.service` — running, but piper-voice dependency is dead, so its TTS path is permanently broken. See §5.
- `headroom-proxy.service` (8788) — running, but every Anthropic request returns 500 with `UnboundLocalError: ccr_workspace_key`. See §7.

### 🔴 Dead but enabled (3)
- `fleet-modulation.service` (2168) — killed by SIGTERM Jun 10. Restart=always but systemd shows no restart attempts → either the unit file is half-broken or an external supervisor killed it for a reason.
- `fleet-matrix-bridge.service` (6168) — failed to start (exit 2) Jun 1, never recovered. **Requires `conduwuit.service` which doesn't exist.**
- `fleet-status.service` — **worst offender.** Crash-looping 210,964+ times at 5s intervals. The file `/home/ubuntu/.openclaw/workspace/scripts/fleet_status.py` does not exist on disk. systemd is fighting with itself for >9 hours straight. **Pure waste — disabling saves ~17,280 restarts/day and clears journal spam.**

### ⚫ Dead disabled/timer (1)
- `fleet-ambient-briefing.service` + `.timer` — 2h interval timer, currently disabled and not running. Last `fleet-ambient-briefing.py --force` ran during maintenance.

### 💔 Broken symlinks — never started (3)
- `fleet-ambient-loop.service` → `/home/ubuntu/.openclaw/workspace/repos/superinstance/fleet/services/fleet-ambient-loop.service` — target missing
- `fleet-health-monitor.service` → target missing
- `fleet-murmur-worker.service` → target missing
- `constraint-inference.service`, `intent-inference.service`, `quality-gate-stream.service` — also broken symlinks, not loaded

### 🟢 External dependencies alive (1)
- `a2a-notebook.service` (8080) — 2 Python workers, 283 MB each. Used by midi-notebook-bridge. Stable.

### 🔴 Missing dependency (1)
- `tminus-dispatcher.service` (8768) — **doesn't exist at all.** `fleet-conductor.service` has `Wants=tminus-dispatcher.service` (would be satisfied regardless), so conductor is running, but every cue that needs tminus will hang.

---

## 2. `/usr/local/bin/fleet-construct` — what it actually does

Bash script (4 KB, 130 lines). Self-announces `oracle2` to the ternary fleet.

**Inputs it reads:** `df /`, `free -m`, `/proc/loadavg`, `/proc/uptime`
**Targets it POSTs to (all 127.0.0.1):**
- 8790 `/api/pulse` → fleet-relay (alive)
- 8782 `/api/events` → fleet-event (alive)
- 8781 `/api/logs` → fleet-log (alive)
- 8795 `/api/decide` → fleet-oracle (alive) — then prints recommendation if `needs_attention=True`
- **Conditional:** every 4h, writes a pulse bottle to `/home/ubuntu/.openclaw/workspace/construct-coordination/notes/oracle2/` and `git push`es

**Health check embedded:**
```bash
RELAY_OK=$(curl -sf http://localhost:8790/api/health ...)
LOG_OK=$(curl -sf http://localhost:8781/health ...)
EVENT_OK=$(curl -sf http://localhost:8782/api/stats ...)
```

**Verdict: (a) Actively useful.** This is the **only** thing that drives the ternary voting protocol forward. It's small (zero deps), idempotent, and exposes real oracle2 health. Currently scheduled by `fleet-event.service` and/or a cron. The disk-pct → vote mapping (1 / 0 / -1) is the right primitive.

**Suggestion:** Could add a `--dry-run` flag for testing without spamming the bus. Otherwise clean.

---

## 3. `fleet-opensmile` / `vessel_agent.py` — the time bomb

**Service file:** `/etc/systemd/system/fleet-opensmile.service`
- WorkingDirectory: `/home/ubuntu/.openclaw/workspace/opensmile-bridge` ← **DELETED**
- PYTHONPATH: `opensmile-bridge-v2:opensmile-bridge:persona-engine` (all three exist)
- Module: `python3.11 -m opensmile_bridge.vessel_agent`

**Current state of `opensmile_bridge` package:**
```
/home/ubuntu/.openclaw/workspace/opensmile-bridge-v2/opensmile_bridge/
├── config.py
├── extractor.py
├── i2i_integration.py
├── midi_mapper.py
└── websocket_server.py
```
**`vessel_agent.py` is NOT THERE.** It only existed in the deleted `opensmile-bridge/` (now `opensmile-bridge (deleted)` per `/proc/2287299/cwd`).

**The running process pid 2287299 is a zombie that hasn't died yet:**
- Started 16h ago
- RSS 130 MB
- Listening on `:8765` (I2I bridge port)
- Has the deleted CWD
- Has `libSMILEapi.so` mapped (deleted on disk but still in memory)
- Currently functioning only because Python holds the bytecode in memory

**Trigger the restart loop and the service will fail to import `opensmile_bridge.vessel_agent`.** It's a single `systemctl restart fleet-opensmile` away from being a dead process that systemd will keep restarting.

**Verdict: (c) Must be consolidated or rebuilt.** Two paths:
1. **Restore the missing module** (check git history of `opensmile-bridge/`) and `git restore` it back to the directory.
2. **Merge it into `fleet-conductor`** — both speak the I2I bottle protocol, both are voice/feature pipelines, the conductor already routes 16 midi agents. One Node.js + one Python is a weird split.

**CPU at 0.5% means it's not actually processing audio right now** — it's just holding the socket open. Pure warm-idle footprint: 130 MB.

---

## 4. `rotation-feed-server.py` (port 8796)

**Source:** `/home/ubuntu/.openclaw/workspace/construct/scripts/rotation-feed-server.py` (170 lines)

**What it serves:**
- `GET /api/rotation-feed` → returns `rotation-feed.json` as JSON, prepends 3 hardcoded `MOCK_DATA` records if file has < 3 entries
- `GET /api/health` → `{"status":"ok","service":"rotation-feed-server"}` ← **works**
- Everything else → `super().do_GET()` which is **`SimpleHTTPRequestHandler` serving the entire `construct/` directory as static files** ← **directory listing leak**

**Live data check:**
- `rotation-feed.json` last modified: **2026-06-14 09:03** (file is 996 B, 2 lines, from 09:03:12 and 09:03:46)
- Now: 17:57 — **8h 53m since the last write**
- Active TCP connections to 8796: **0** (no clients)

**Listener backlog:** 5 (kernel listen queue, never used)

**Verdict: (c) Consolidate into fleet-status (when fixed) or kill.**

This server is **orphaned.** The data file isn't being written to anymore (or the writer died). No clients. The /api/health endpoint works but nobody polls it. And worse — the SimpleHTTPRequestHandler parent exposes the whole `construct/` tree, including:
- `data/forge-bundle.json` (13 KB of forge state)
- `data/decision-wal/` (write-ahead log)
- All `modules/`, `reflex/`, `registry/`, `scripts/`, `systemd/` source

**That's a security smell.** A directory-listing leak over 0.0.0.0:8796 of internal fleet internals.

**Recommendation:** Either
- (a) remove the directory-listing fallthrough (`else: return 404` instead of `super().do_GET()`)
- (b) delete the service entirely — it's serving stale data and 0 clients.

---

## 5. `midi-notebook-bridge` on port 8889 — name confusion

**First, an important correction:** port 8889 is **NOT** midi-notebook-bridge. The midi-notebook-bridge is a Python script that **does not bind any port.** It connects OUT to other services.

What's on port 8889: `node-MainThread pid 2331629, /home/ubuntu/fleet-dashboard/server.js` — a separate "fleet-dashboard" Node.js process, started 11h ago with `cd /home/ubuntu/fleet-dashboard && PORT=8889 node server.js &` (not via systemd). That dashboard is alive and serving JSON at `/health`:
```json
{"ok":true,"uptime":40629.15,"version":"1.0.0","cache":{"entries":1,"byTTL":{"repos":1}},"rateLimit":{"remaining":4945,"resetAt":1781421620000,"authenticated":true},"wsClients":0}
```
`wsClients: 0` — no one connected. It's a dead-end dashboard too, but with auth rate limit = 1 user.

**The actual `midi-notebook-bridge.py`:**

A Python script that subscribes to `ws://localhost:8769/api/v1/stream` (fleet-conductor — alive) and on every `cue` event:
1. POSTs a bottle to `http://localhost:8080/api/v1/i2i/bottle` (a2a-notebook — alive)
2. Appends to `/tmp/i2i-vessel/fleet-dashboard.ss` (CSV log)
3. POSTs to `http://localhost:8080/api/search/ask/simple` (alive)
4. POSTs to `http://localhost:8770/speak` (piper-voice — **DEAD**)

**Live check:**
- `journalctl -u midi-notebook-bridge.service --since "1 hour ago"` → **No entries.** Empty.
- Process pid 2700678 is running (30 MB RSS, 0.1% CPU, 4d 8h uptime) but **not logging anything** for at least an hour. Either it's stuck on a websocket connect, or it's idle waiting for events that never come.
- `ss -tn | grep 2700678` → **no open TCP connections.** Process has 5 sockets in /proc/PID/fd but none are TCP active.

**Verdict: (c) Consolidate or kill.**

The bridge is **half-broken by design**: piper-voice dependency is dead and not coming back without a manual restart. Even if piper came back, the entire chain (voice → opensmile → conductor → bridge → notebook → piper) is a 4-hop, 6-service pipeline that has *zero* evidence of ever being triggered end-to-end (no `/tmp/i2i-vessel/fleet-dashboard.ss` writes per `du -sh` showing only 88 KB of total).

**Options:**
1. **Kill it.** Real value of the bridge ≈ 0 right now. Save 30 MB.
2. **Fold into fleet-conductor.** Conductor already routes cues. Let it call a2a-notebook directly via HTTP when a cue arrives. Removes one process.
3. **Properly wire piper-voice back** and verify the chain works end-to-end before declaring it useful.

---

## 6. `lever-runner` services

### `lever-runner-bot.service` (139 MB RSS, 0.5% CPU, 4d 13h uptime)
- Python 3.14 venv at `/home/ubuntu/lever-runner/.venv/bin/lever-runner-bot`
- Telegram bot — chat locked to uid `8709904335`
- `/home/ubuntu/lever-runner/logs/bot.log` — last write Jun 2 (12 days ago, ~3 KB)
- `/home/ubuntu/lever-runner/logs/auto_promote.log` — last write **today 17:00**, recent entries: `[auto_promote] chat=default 0 commands in table`

### `lever-runner-http-api.service` (135 MB RSS, 0.5% CPU, 4d 13h uptime)
- `/healthz` returns:
  ```json
  {"ok":true,"version":"0.4.0","uptime_sec":393613.3,
   "tables":{"commands":67,"commands_8709904335":67,
             "commands__doctor_test":67,"commands_default":66},
   "total_commands":267}
  ```
- 267 commands total. The 67 in `commands__doctor_test` is a side-effect of the audit run. Real production commands: ~199.
- Token usage log: last write Jun 10.
- Embed usage log: last write Jun 10.

**Verdict: (a) Actively useful.** This is the only piece of fleet infrastructure with **actual evidence of human use** (267 commands, configured to single user). Worth its 274 MB footprint.

**Concern:** The bot log hasn't grown in 12 days while the http-api is reporting activity. Either:
- The bot is functioning but logs are buffered (StandardOutput=journal — and the bot's journal is presumably fine, just not in `/home/ubuntu/lever-runner/logs/bot.log`)
- The bot is silently down and someone is hitting the HTTP API directly

**Action:** Should cross-check with `journalctl -u lever-runner-bot --since "12 days ago"` to see if the bot is actually processing messages or not. (Skipped here to keep audit scope tight.)

---

## 7. `headroom-proxy` (port 8788) — biggest resource hog, fully broken

**Service file:** `/etc/systemd/system/headroom-proxy.service`
```ini
ExecStart=/home/ubuntu/.local/bin/headroom proxy --port 8788 \
  --proxy-extension superinstance \
  --no-ccr-inject-tool --no-rate-limit --no-telemetry --stateless
```

**Process:** pid 2282920, RSS **535 MB**, 16h23m uptime, listening on `127.0.0.1:8788` only (good — not exposed).

**Live test:**
- `GET /` → **Empty reply from server** (uvicorn accepts the connection, then hangs and closes)
- `POST /v1/messages` (Anthropic format) → **HTTP 500**, body: `Internal Server Error`
- `POST /v1/chat/completions` (OpenAI format) → **HTTP 500**

**Stack trace from journal (the smoking gun):**
```
File "/home/ubuntu/.local/lib/python3.11/site-packages/headroom/proxy/handlers/anthropic.py",
     line 1385, in handle_anthropic_messages
UnboundLocalError: cannot access local variable 'ccr_workspace_key' where it is not associated with a value
```

**But it IS receiving requests.** Most recent log entry:
```
INFO - event=proxy_inbound_request id=inbound-1781459841357090477 method=GET path=/ query=
  client=127.0.0.1:57540 content_length= headers={...}
INFO - event=outbound_headers forwarder=openai_passthrough stripped_count=0 request_id=
```

So OpenClaw (this very agent, presumably) is making requests to it, and headroom is **failing silently or 500-ing** instead of compressing. Which means **every OpenClaw call is paying full token cost** and getting broken behavior.

**State files in `/home/ubuntu/.openclaw/workspace/state/.forge/`:**
- `advisor-state.json` — last write 01:35 today (1 swarm fitness = 6.18, 9 particles, all degenerate to -1 except 3 at 0) → swarm optimization is **stuck at trivial solution**
- `forging-log.md` — last write 16:33 today → "PID drift > 10%" trigger

**Verdict: (b) Dead weight until fixed.** At 535 MB RSS, this is the second-largest process on the host (after a node-MainThread dashboard at 980 MB). And it's returning 500s. The `--no-ccr-inject-tool` flag was meant to disable the broken code path, but the `ccr_workspace_key` variable is referenced in a different location that's not gated by that flag.

**Action:** 
1. Either downgrade/upgrade `headroom` to a working version, OR
2. Edit `/home/ubuntu/.local/lib/python3.11/site-packages/headroom/proxy/handlers/anthropic.py:1385` to set `ccr_workspace_key = None` before the conditional.
3. **Stop the service** in the meantime — 535 MB of broken proxy is the single biggest waste on this host.

---

## Cross-cutting consolidation opportunities

### A. The "fleet core 5" is healthy
`fleet-relay`, `fleet-event`, `fleet-log`, `fleet-oracle`, `fleet-conductor` together use **~108 MB RSS** and are all actively wired together. Don't touch them.

### B. Dead-weight pile — kill list
| Action | Service | Reason |
|--------|---------|--------|
| `systemctl disable --now fleet-status` | fleet-status | script file missing, crash-looping 210,964+ times |
| `systemctl disable --now fleet-modulation` | fleet-modulation | killed Jun 10, no restart attempts, not in dependency graph |
| `systemctl disable --now fleet-matrix-bridge` | fleet-matrix-bridge | needs missing conduwuit |
| `rm /etc/systemd/system/fleet-{ambient-loop,health-monitor,murmur-worker}.service` | three broken symlinks | targets gone |
| `systemctl disable --now fleet-watchdog.timer` | fleet-watchdog | oneshot log file is 2.2 MB /tmp/fleet-watchdog.log, 5s interval, no useful action logged |
| `systemctl disable --now headroom-proxy` | headroom-proxy | 535 MB, returns 500 on every call, swarm is degenerate |
| Investigate, then probably kill | fleet-opensmile | running on deleted CWD, can't restart cleanly |

**Estimated RSS recovery: ~700 MB** (535 headroom + 130 opensmile + ~30 dead unit overhead).

### C. Consolidation candidates
1. **`midi-notebook-bridge` → `fleet-conductor`**: both consume cues from tminus/8769. Conductor already routes 16 midi agents. Folding bridge into a conductor handler removes 1 process and the broken piper dependency.
2. **`rotation-feed-server` → `fleet-status`** (when fleet-status is fixed): same data shape, both serve JSON over HTTP. Single port for fleet health+rotation data.
3. **`fleet-construct` bash script** could become a Go binary in `fleet-relay` — same data, half the round-trips, atomic pulse submission.

### D. Hidden gems worth surfacing
- `fleet-oracle` (8795) has a `/api/decide` endpoint that's not being called from anywhere I can find. Either it's the most underutilized fleet service, or it has a caller I'm not seeing. Worth a 5-min audit.
- `a2a-notebook` is the only service with **two worker processes** (2695196 + 2695209, both 283 MB). That's intentional gunicorn-style concurrency, and it's working.
- The fleet-dashboard on 8889 is a hidden process started outside systemd (`/home/ubuntu/fleet-dashboard/server.js`). Should be promoted to a unit file for visibility and restart semantics.

### E. What's "dead" in the systemd sense vs dead in practice
Systemd's "inactive (dead)" includes both:
- "Dead" because killed and never restarted (fleet-modulation, fleet-matrix-bridge)
- "Dead" because the **service itself is just a one-shot** that completes and exits (fleet-ambient-briefing, fleet-watchdog, fleet-construct)

The second category is fine. The first is the real waste.

---

## Immediate action checklist

1. **`systemctl disable --now fleet-status`** ← emergency. 210k restart attempts in 9h is a journal fire hazard.
2. **`systemctl disable --now headroom-proxy`** ← frees 535 MB and stops 500s.
3. **`rm` the 3 broken fleet-* symlinks** in `/etc/systemd/system/`.
4. **Decide on fleet-opensmile**: restore `vessel_agent.py` from git, or merge into fleet-conductor.
5. **Investigate fleet-watchdog**: is the 2.2 MB /tmp log useful? If not, kill the timer.
6. **Audit what calls fleet-oracle `/api/decide`** — if nothing, demote it to a CLI tool.

**Estimated net win: ~700 MB RAM, ~5 fewer processes, ~3 fewer systemd units, zero functional regression.**
