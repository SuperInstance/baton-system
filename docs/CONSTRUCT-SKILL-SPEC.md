# Construct Skill Specification

**Version:** 1.0.0-draft  
**Date:** 2026-06-04  
**Status:** Draft for fleet review  
**Author:** ZeroClaw Scout (synthesized from Room-as-Codespace Architecture and Cross-Pollination Report)  

---

## Abstract

This document defines the **Construct Skill Specification** — the canonical contract through which any computational capability (a "skill") declares itself, loads, communicates, conserves resources, and exposes cross-language interfaces within the ternary construct ecosystem. It is the moral equivalent of `CORTEX.json` for our fleet: a single, versioned, machine-readable manifest that lets a `BareMetalConstruct` on an ESP32, a `SyncConstruct` on a Raspberry Pi, an `AsyncConstruct` in a GitHub Codespace, and a `WasmConstruct` in a browser tab all agree on what a skill is, what it needs, and what it promises.

The spec is grounded in five pillars:

1. **SkillManifest** — the static declaration.
2. **SkillLifecycle** — the exact state machine from declaration to extinction.
3. **SkillProtocol** — the message grammar for inter-skill communication.
4. **SkillConservation** — resource accountability and thermodynamic compliance.
5. **SkillBridge** — cross-language availability and ABI contracts.

---

## 1. SkillManifest

### 1.1 Purpose

A SkillManifest is a JSON document named `skill.json` located at the root of every skill crate, package, or module. It is read by `ternary-registry` during dependency resolution, by `construct-core` during `load_skill()`, and by the PLATO room coordinator when deciding which ensigns to load for a given room template. No manifest, no load.

### 1.2 Schema

The manifest conforms to JSON Schema Draft 2020-12. The root object is `SkillManifest`.

| Field | Type | Required | Description |
|---|---|---|---|
| `schema_version` | string | yes | Must be `"construct-skill/1.0.0"`. |
| `id` | `SkillId` | yes | Fully-qualified skill identifier. |
| `name` | string | yes | Human-readable name. |
| `description` | string | yes | One-paragraph summary. |
| `version` | `SemVersion` | yes | Semantic version of this skill artifact. |
| `authors` | string[] | no | Git-style `Name <email>` lines. |
| `license` | string | no | SPDX identifier. |
| `tier_requirements` | `TierRequirements` | yes | Hardware tier and construct-layer constraints. |
| `dependencies` | `SkillDependency[]` | yes | Other skills required at load time. Empty array allowed. |
| `capabilities` | `CapabilityDeclaration[]` | yes | What this skill can do, using the 7-type constraint taxonomy. |
| `conservation_metrics` | `ConservationMetrics` | yes | Baseline resource budget and thermodynamic targets. |
| `bridge` | `SkillBridge` | yes | Cross-language availability declaration. |
| `entry_points` | `EntryPointMap` | yes | Named functions/methods exposed by the skill. |
| `provenance` | `ProvenanceRecord` | no | Build chain, source commit, audit hash. |

#### 1.2.1 SkillId

```json
{
  "domain": "ternary-sensor",
  "name": "kalman-fusion",
  "qualifier": "fixed-point"
}
```

- `domain`: Namespace to prevent collisions. Recommended: GitHub org or crate prefix.
- `name`: Short, kebab-case identifier.
- `qualifier`: Optional disambiguator (e.g., `fixed-point` vs `floating-point`).

The canonical string form is `domain/name/qualifier` with trailing slashes collapsed. If qualifier is omitted, the form is `domain/name`.

#### 1.2.2 SemVersion

Construct uses SemVer 2.0.0 with one extension: the `+tier` build metadata suffix indicates which hardware tier this artifact was compiled for.

```json
{
  "major": 2,
  "minor": 1,
  "patch": 0,
  "prerelease": "beta.3",
  "build": "tier1"
}
```

Valid `+tier` values:
- `tier0` — bare metal, no_std, no alloc (ESP32, firmware).
- `tier1` — embedded Linux, alloc, sync only (Raspberry Pi, Jetson sync workloads).
- `tier2` — full async, tokio, GPU, network (Codespace, DGX, workstation).
- `tierW` — WebAssembly, browser sandbox.

The `+tier` suffix is mandatory for published artifacts. It is NOT part of version ordering: `2.1.0+tier0` and `2.1.0+tier2` compare equal for dependency resolution but are different artifacts.

#### 1.2.3 TierRequirements

```json
{
  "min_tier": "tier1",
  "max_tier": "tier2",
  "required_features": ["alloc", "f64"],
  "forbidden_features": ["std"],
  "memory_min_bytes": 32768,
  "memory_ideal_bytes": 131072,
  "compute_units": 1.5
}
```

- `min_tier`, `max_tier`: Inclusive bounds. A skill declaring `"min_tier": "tier2"` cannot load on a Pi.
- `required_features`: Feature flags that the host construct must enable.
- `forbidden_features`: Feature flags that must NOT be enabled (e.g., a no_std skill refuses a host with `std`).
- `memory_min_bytes`: Hard floor. Load fails if unavailable.
- `memory_ideal_bytes`: Soft target. Conservation warnings if continuously exceeded.
- `compute_units`: Abstract compute weight. 1.0 = one full Raspberry Pi 4 core at 1.5 GHz. Used by the scheduler.

#### 1.2.4 SkillDependency

```json
{
  "id": { "domain": "ternary-ring", "name": "core" },
  "version_constraint": ">=1.2.0, <2.0.0",
  "optional": false,
  "tier_match": "same"
}
```

- `version_constraint`: Standard SemVer range syntax.
- `optional`: If true, the skill may load without this dependency, but certain entry points may be unavailable.
- `tier_match`: `"same"` requires the dependency to be compiled for the same tier. `"any"` allows cross-tier composition (rare, used for protocol-only skills).

#### 1.2.5 CapabilityDeclaration

Each capability is a 7-type constraint declaration derived from the linguistic polyformalism taxonomy. A skill with complete coverage has no blind spots.

```json
{
  "constraint_type": "Boundary",
  "description": "This skill IS a fixed-point Kalman filter for ternary state estimation.",
  "interface": "query_owned(state_vector) → updated_state_vector"
}
```

Valid `constraint_type` values:
- `Boundary` — Greek: defines what the skill IS.
- `Pattern` — Chinese: guides without limiting.
- `ProcessShape` — Navajo: shapes the flow of events.
- `KnowledgeSource` — Quechua: declares epistemic grounding.
- `SocialStructure` — Korean: power dynamics between actors (e.g., this skill must run before sensor-classification).
- `DeepStructure` — Arabic: root pattern vs surface form (e.g., the core algorithm is Bayesian; the API is Kalman).
- `Instrument` — Finnish: optional tool, not inherent (e.g., optional GPU acceleration).

A manifest must declare at least one capability. A manifest declaring all seven types receives a `complete_descriptor` flag from the registry audit tool.

#### 1.2.6 ConservationMetrics

```json
{
  "baseline_energy_drain_per_tick": 0.05,
  "max_energy_drain_per_tick": 0.20,
  "target_conservation_ratio": 1.18,
  "conservation_tolerance": 0.05,
  "apoptosis_threshold": 0.10,
  "gc_pressure": "low"
}
```

- `baseline_energy_drain_per_tick`: Expected energy cost in the ternary-cell tick cycle.
- `max_energy_drain_per_tick`: Ceiling. Exceeding this for 3 consecutive ticks triggers `Suspend`.
- `target_conservation_ratio`: The γ + H target for this skill's cell population.
- `gc_pressure`: `"low"`, `"medium"`, `"high"`. Informs the room's GC strategy selection (Greedy, Plinko, or Ecological).

#### 1.2.7 EntryPointMap

```json
{
  "predict": {
    "arity": 1,
    "input_schema": "urn:construct:schema:TritVector",
    "output_schema": "urn:construct:schema:TritVector",
    "latency_sla_ms": 5,
    "tier": "tier1"
  },
  "explain": {
    "arity": 2,
    "input_schema": "urn:construct:schema:ExplainRequest",
    "output_schema": "urn:construct:schema:ExplainResponse",
    "latency_sla_ms": 500,
    "tier": "tier2"
  }
}
```

Entry points are the only callable surfaces of a skill. The construct layer validates schema URNs at load time using `ternary-validation`.

### 1.3 Complete Example

```json
{
  "schema_version": "construct-skill/1.0.0",
  "id": {
    "domain": "fleet-sensor",
    "name": "anomaly-guardian",
    "qualifier": "v2"
  },
  "name": "Anomaly Guardian v2",
  "description": "Fixed-point ternary anomaly detection with conservation-aware alerting. Runs on Pi-tier and above.",
  "version": {
    "major": 2,
    "minor": 0,
    "patch": 0,
    "prerelease": "",
    "build": "tier1"
  },
  "authors": ["ZeroClaw Scout <scout@superinstance.io>"],
  "license": "MIT",
  "tier_requirements": {
    "min_tier": "tier1",
    "max_tier": "tier2",
    "required_features": ["alloc", "f64"],
    "forbidden_features": [],
    "memory_min_bytes": 65536,
    "memory_ideal_bytes": 262144,
    "compute_units": 2.0
  },
  "dependencies": [
    {
      "id": { "domain": "ternary-ring", "name": "core" },
      "version_constraint": ">=1.0.0, <2.0.0",
      "optional": false,
      "tier_match": "same"
    },
    {
      "id": { "domain": "ternary-kalman", "name": "fixed-point" },
      "version_constraint": ">=0.9.0",
      "optional": false,
      "tier_match": "same"
    }
  ],
  "capabilities": [
    { "constraint_type": "Boundary", "description": "A ternary anomaly detector.", "interface": "query_owned(sensor_batch) → anomaly_report" },
    { "constraint_type": "Pattern", "description": "Uses 3-sigma ternary thresholds: Low/Normal/High.", "interface": "" },
    { "constraint_type": "ProcessShape", "description": "Perceive → Surprise → Alert (no prediction step).", "interface": "" },
    { "constraint_type": "KnowledgeSource", "description": "Grounded in ternary-failure FMEA risk matrices.", "interface": "" },
    { "constraint_type": "SocialStructure", "description": "Must run after ternary-sensor classification.", "interface": "dependency ordering" },
    { "constraint_type": "DeepStructure", "description": "Core is statistical; surface is rule-based.", "interface": "" },
    { "constraint_type": "Instrument", "description": "Optional GPU kernel for batch mode.", "interface": "compute_async(batch)" }
  ],
  "conservation_metrics": {
    "baseline_energy_drain_per_tick": 0.08,
    "max_energy_drain_per_tick": 0.25,
    "target_conservation_ratio": 1.20,
    "conservation_tolerance": 0.04,
    "apoptosis_threshold": 0.12,
    "gc_pressure": "medium"
  },
  "bridge": {
    "native_rust": true,
    "native_c": {
      "header": "include/anomaly_guardian.h",
      "abi": "C"
    },
    "python": {
      "module": "anomaly_guardian",
      "pyo3": true
    },
    "wasm": {
      "export": "anomaly_guardian_v2",
      "interface_types": ["string", "bytes"]
    }
  },
  "entry_points": {
    "detect": {
      "arity": 1,
      "input_schema": "urn:construct:schema:SensorBatch",
      "output_schema": "urn:construct:schema:AnomalyReport",
      "latency_sla_ms": 10,
      "tier": "tier1"
    },
    "calibrate": {
      "arity": 1,
      "input_schema": "urn:construct:schema:CalibrationSample",
      "output_schema": "urn:construct:schema:CalibrationResult",
      "latency_sla_ms": 2000,
      "tier": "tier2"
    }
  },
  "provenance": {
    "source_commit": "a1b2c3d",
    "build_toolchain": "rustc 1.85.0",
    "audit_hash": "sha256:deadbeef..."
  }
}
```

---

## 2. SkillLifecycle

### 2.1 Overview

A skill is not a library. A library is linked and forgotten. A skill is a **guest** in a room. It arrives, negotiates, lives, and eventually departs. The SkillLifecycle defines the exact protocol for this hospitality.

### 2.2 States

```
                              ┌─────────────┐
                    ┌────────►│   GONE      │◄────────┐
                    │         │  (terminal) │         │
                    │         └─────────────┘         │
                    │                                 │
                    │         unload confirmed        │
                    │                                 │
     ┌─────────┐   │    ┌──────────┐    ┌──────────┐ │
     │LOADING  │───┘    │UNLOADING │───►│  GONE    │─┘
     └────┬────┘        └────┬─────┘    └──────────┘
          │                  ▲
          │ load_success     │ unload_request
          ▼                  │
     ┌─────────┐    ┌────────┴────┐
     │ READY   │───►│  SUSPENDED  │
     └────┬────┘    └─────────────┘
          │ activate
          ▼
     ┌─────────┐
     │ ACTIVE  │
     └────┬────┘
          │ deactivate
          │ (or conservation violation)
          ▼
     ┌─────────┐
     │SUSPENDED│
     └─────────┘
```

#### LOADING

The construct has received a `load_skill(SkillSpec)` call. The registry resolves the manifest, checks dependency closure, verifies tier compatibility, and allocates the memory budget. The skill's `on_load()` hook runs. This hook must be synchronous and MUST complete within the SLA declared in `entry_points` (default 5 seconds). If `on_load()` panics or exceeds SLA, the transition fails and the skill moves directly to `GONE`.

**Invariant:** No entry points are callable. No messages are accepted. The skill exists only as a reservation.

#### READY

`on_load()` succeeded. The skill is fully initialized but not yet executing user requests. It may be pre-warming caches, registering message handlers, or subscribing to telemetry channels. A skill in `READY` consumes its `baseline_energy_drain_per_tick` but does no productive work.

**Invariant:** Entry points are callable ONLY by the room orchestrator (not by other skills). The skill may send `telemetry` messages.

#### ACTIVE

The room orchestrator has called `activate()`. The skill is now a full citizen of the room. It may receive `query`, `command`, and `event` messages from other skills. It may call entry points on other skills via the room's skill router. Energy drain is measured against `max_energy_drain_per_tick`.

**Invariant:** The skill must heartbeat every tick. Missing 3 consecutive tick heartbeats triggers automatic `deactivate()` → `SUSPENDED`.

#### SUSPENDED

The skill has been deactivated, either by explicit `deactivate()`, by conservation violation (energy drain > max for 3 ticks), or by heartbeat timeout. In `SUSPENDED`, the skill retains its memory but all entry points are masked. It may still emit `telemetry` and `event` messages but cannot receive `query` or `command`.

**Recovery path:** The room orchestrator may call `resume()`. The skill's `on_resume()` hook runs. If successful, transition to `ACTIVE`. If `on_resume()` fails 3 times, transition to `UNLOADING`.

**Invariant:** Memory is NOT freed. This is a pause, not a termination.

#### UNLOADING

The room has called `unload_skill()`. The skill's `on_unload()` hook runs. This hook has a hard SLA of 10 seconds. It must:
1. Flush any pending state to PLATO tiles.
2. Extract muscle-memory triggers (see Ensign pattern).
3. Emit a final `telemetry` burst with lifetime statistics.
4. Release all heap allocations.

If `on_unload()` succeeds, the skill moves to `GONE`.

**Invariant:** No new messages are accepted. In-flight requests may be completed or dropped based on `SkillProtocol::Policy`.

#### GONE

Terminal state. The skill's memory is reclaimed. Its `SkillId` is removed from the room's skill table. A tombstone record is written to the registry for audit purposes. From `GONE`, there is no return — a new `load_skill()` creates a fresh instance with a new lifecycle.

### 2.3 State Transition Table

| From → To | Trigger | Guard | Hook | Failure Action |
|---|---|---|---|---|
| `LOADING` → `READY` | `load_success` | Dependencies resolved, memory allocated, tier OK | `on_load()` | → `GONE` |
| `READY` → `ACTIVE` | `activate` | Room orchestrator permits | `on_activate()` | → `SUSPENDED` |
| `ACTIVE` → `SUSPENDED` | `deactivate` | Explicit call or heartbeat timeout or conservation breach | `on_deactivate()` | → `UNLOADING` (after 3 failed resumes) |
| `SUSPENDED` → `ACTIVE` | `resume` | Orchestrator permits | `on_resume()` | Stay `SUSPENDED`; count failures |
| `SUSPENDED` → `UNLOADING` | `unload_request` | Explicit call or 3 failed resumes | `on_unload()` | Force `GONE` after timeout |
| `ACTIVE` → `UNLOADING` | `unload_request` | Explicit call | `on_unload()` | Force `GONE` after timeout |
| `READY` → `UNLOADING` | `unload_request` | Explicit call (never activated) | `on_unload()` | Force `GONE` after timeout |
| `UNLOADING` → `GONE` | `unload_confirmed` | `on_unload()` succeeded | — | — |
| Any → `GONE` | `panic` / `kill` | — | — | Log tombstone |

### 2.4 Lifecycle Hooks

All hooks are optional. If absent, the transition proceeds immediately.

```rust
pub trait SkillLifecycle {
    fn on_load(&mut self, ctx: &LoadContext) -> Result<(), LoadError>;
    fn on_activate(&mut self, ctx: &RoomContext) -> Result<(), ActivateError>;
    fn on_deactivate(&mut self, ctx: &RoomContext) -> Result<(), DeactivateError>;
    fn on_resume(&mut self, ctx: &RoomContext) -> Result<(), ResumeError>;
    fn on_unload(&mut self, ctx: &UnloadContext) -> Result<UnloadReport, UnloadError>;
}
```

`UnloadReport` carries the same fields as the room's `UnloadReport`: skills unloaded, triggers extracted, tiles generated, conservation ratio at exit. This enables the PLATO tile sync and muscle-memory trigger registration described in the Room-as-Codespace architecture.

---

## 3. SkillProtocol

### 3.1 Transport

SkillProtocol messages ride on `ternary-protocol` when the sender and receiver are in the same room or on the same local network. They ride on I2I (git commits) when cross-organizational or async. They ride on WebSocket when real-time browser coordination is required. The skill does not know which transport is in use.

All messages are JSON objects with a mandatory `construct_header` and a `payload` whose schema depends on `msg_type`.

### 3.2 Message Types

#### 3.2.1 QUERY

A request-response message. The caller expects exactly one `RESPONSE` or `ERROR`.

```json
{
  "construct_header": {
    "msg_type": "QUERY",
    "msg_id": "uuid:v4:abc123",
    "correlation_id": null,
    "sender_skill": "fleet-sensor/anomaly-guardian/v2",
    "receiver_skill": "ternary-kalman/fixed-point",
    "timestamp_ns": 1717528800000000000,
    "ttl_ms": 5000,
    "priority": 1,
    "signal": "Signal"
  },
  "payload": {
    "entry_point": "predict",
    "input": {
      "state_vector": [0, 1, -1, 0, 1],
      "covariance": "base64:..."
    },
    "context": {
      "room_id": "engine-monitor-alpha",
      "tick_count": 44102
    }
  }
}
```

- `msg_id`: Globally unique. Used for deduplication and response routing.
- `correlation_id`: Null for new queries; copied from `msg_id` for responses.
- `ttl_ms`: Time-to-live. Messages exceeding TTL are dropped and a `TIMEOUT` error is synthesized.
- `priority`: Integer. Lower is higher priority. Negative priorities are reserved for conservation alerts.
- `signal`: One of `"Signal"`, `"Silence"`, `"Suppress"`. Maps to ternary-protocol's +1, 0, -1.

#### 3.2.2 RESPONSE

```json
{
  "construct_header": {
    "msg_type": "RESPONSE",
    "msg_id": "uuid:v4:resp789",
    "correlation_id": "uuid:v4:abc123",
    "sender_skill": "ternary-kalman/fixed-point",
    "receiver_skill": "fleet-sensor/anomaly-guardian/v2",
    "timestamp_ns": 1717528800000000500,
    "ttl_ms": 5000,
    "priority": 1,
    "signal": "Signal"
  },
  "payload": {
    "status": "OK",
    "output": {
      "state_vector": [0, 1, 0, 0, 1],
      "surprise": 0.03
    },
    "metrics": {
      "latency_us": 420,
      "energy_drain": 0.01
    }
  }
}
```

`status` values: `"OK"`, `"PARTIAL"`, `"CACHED"`, `"NOT_FOUND"`, `"TIMEOUT"`, `"ERROR"`.

#### 3.2.3 COMMAND

Fire-and-forget. No response expected. Used for control signals: `activate`, `deactivate`, `flush`, `die`.

```json
{
  "construct_header": {
    "msg_type": "COMMAND",
    "msg_id": "uuid:v4:cmd456",
    "correlation_id": null,
    "sender_skill": "room-orchestrator",
    "receiver_skill": "fleet-sensor/anomaly-guardian/v2",
    "timestamp_ns": 1717528800000001000,
    "ttl_ms": 1000,
    "priority": -1,
    "signal": "Suppress"
  },
  "payload": {
    "command": "deactivate",
    "reason": "conservation_breach",
    "params": {
      "max_energy_exceeded_for_ticks": 3
    }
  }
}
```

#### 3.2.4 EVENT

Multicast async notification. Any skill may emit. Any skill may subscribe. The room's event bus routes by topic.

```json
{
  "construct_header": {
    "msg_type": "EVENT",
    "msg_id": "uuid:v4:evt321",
    "correlation_id": null,
    "sender_skill": "fleet-sensor/anomaly-guardian/v2",
    "receiver_skill": "*",
    "timestamp_ns": 1717528800000002000,
    "ttl_ms": 10000,
    "priority": 0,
    "signal": "Signal"
  },
  "payload": {
    "topic": "anomaly.detected",
    "severity": "high",
    "data": {
      "sensor_id": "temp_engine_01",
      "anomaly_type": "temperature_spike",
      "ternary_class": "High"
    }
  }
}
```

Topic naming convention: `domain.verb` where `domain` is the sender's domain and `verb` is the past-tense event. Wildcard subscriptions: `fleet-sensor.*` or `*.detected`.

#### 3.2.5 TELEMETRY

Periodic or continuous stream of resource and conservation data. Sent to the room's telemetry aggregator and forwarded to PLATO for fleet-wide observability.

```json
{
  "construct_header": {
    "msg_type": "TELEMETRY",
    "msg_id": "uuid:v4:tel999",
    "correlation_id": null,
    "sender_skill": "fleet-sensor/anomaly-guardian/v2",
    "receiver_skill": "telemetry-aggregator",
    "timestamp_ns": 1717528800000003000,
    "ttl_ms": 5000,
    "priority": 2,
    "signal": "Silence"
  },
  "payload": {
    "window_start_ns": 1717528795000000000,
    "window_end_ns": 1717528800000000000,
    "memory_bytes": 98304,
    "cpu_time_us": 1250,
    "energy_drain": 0.07,
    "conservation_ratio": 1.19,
    "queries_served": 42,
    "errors": 0,
    "ticks_elapsed": 60
  }
}
```

Telemetry windows default to 1 second for tier2, 10 seconds for tier1, and 60 seconds for tier0 (where measurement itself is expensive).

#### 3.2.6 ERROR

```json
{
  "construct_header": {
    "msg_type": "ERROR",
    "msg_id": "uuid:v4:err000",
    "correlation_id": "uuid:v4:abc123",
    "sender_skill": "ternary-kalman/fixed-point",
    "receiver_skill": "fleet-sensor/anomaly-guardian/v2",
    "timestamp_ns": 1717528800000000600,
    "ttl_ms": 5000,
    "priority": 1,
    "signal": "Suppress"
  },
  "payload": {
    "error_code": "SKILL_NOT_FOUND",
    "error_message": "Entry point 'predict_v2' does not exist in this skill version.",
    "retryable": false,
    "conservation_impact": 0.0
  }
}
```

Error codes are UPPER_SNAKE_CASE:
- `SKILL_NOT_FOUND`
- `ENTRY_POINT_NOT_FOUND`
- `TIER_MISMATCH`
- `TIMEOUT`
- `CONSERVATION_BREACH`
- `DEPENDENCY_UNAVAILABLE`
- `SCHEMA_VIOLATION`
- `PANIC`

`retryable`: Boolean. `TIMEOUT` and `CONSERVATION_BREACH` are usually retryable. `PANIC` and `SCHEMA_VIOLATION` are not.

### 3.3 Routing Rules

1. **Intra-room:** `ternary-protocol` unicast. Latency budget: 1 ms.
2. **Inter-room, same fleet:** `ternary-protocol` over WebSocket or TCP. Latency budget: 10 ms.
3. **Inter-room, cross-fleet, async:** I2I over git commits. Latency budget: minutes to hours.
4. **Broadcast:** Event bus with topic matching. No guaranteed delivery. Skills must tolerate dropped events.

---

## 4. SkillConservation

### 4.1 Philosophy

A skill is not a free resource. It is a thermodynamic process that consumes energy (CPU time, memory bandwidth, battery) and produces entropy (heat, log noise, stale state). The SkillConservation subsystem ensures every skill accounts for its own thermodynamic footprint and respects the room's conservation laws.

### 4.2 Metrics

Every skill MUST report the following metrics in every telemetry window:

| Metric | Unit | Source | Action on Breach |
|---|---|---|---|
| `memory_bytes` | bytes | `mallinfo` or equivalent | Suspend if > 2× ideal |
| `cpu_time_us` | microseconds | `clock_gettime(CLOCK_THREAD_CPUTIME_ID)` | Warn if > SLA |
| `energy_drain` | abstract | Derived from cpu_time + memory pressure | Suspend if > max for 3 ticks |
| `conservation_ratio` | float | γ + H computed by skill | Alert if outside tolerance |
| `queries_served` | count | Skill-internal counter | — |
| `errors` | count | Skill-internal counter | Alert if > 1% of queries |

### 4.3 Conservation Compliance Levels

```
┌─────────────────────────────────────────────────────────────┐
│                    COMPLIANCE LEVELS                        │
├─────────────┬───────────────────────────────────────────────┤
│   GREEN     │ All metrics within baseline. Full autonomy.   │
│             │ Skill may auto-equip, auto-scale, and self-   │
│             │ optimize without human review.                │
├─────────────┼───────────────────────────────────────────────┤
│   YELLOW    │ One metric exceeds baseline but stays within  │
│             │ max. Skill continues but flags itself for     │
│             │ review. Room orchestrator may throttle.       │
├─────────────┼───────────────────────────────────────────────┤
│   RED       │ Metric exceeds max OR conservation ratio is   │
│             │ outside tolerance for >3 ticks. Skill is      │
│             │ SUSPENDED. Human escalation required.         │
├─────────────┼───────────────────────────────────────────────┤
│   BLACK     │ Skill PANIC'd or corrupted state detected.    │
│             │ Immediate UNLOADING. Tombstone written.       │
│             │ No auto-restart without audit.                │
└─────────────┴───────────────────────────────────────────────┘
```

### 4.4 Energy Accounting

Energy is an abstract dimensionless unit mapped from platform-specific measurements:

- **tier0 (ESP32):** `energy_drain = cpu_cycles / 1e6`. A 240 MHz core running 100% for one tick (1 ms) = 240 energy units. Normalized by dividing by the skill's declared `compute_units`.
- **tier1 (Pi/Jetson):** `energy_drain = cpu_time_us / 1000 + memory_bytes / 1e6`. A skill using 1 ms CPU and 1 MB RAM reports `2.0`.
- **tier2 (Codespace/DGX):** `energy_drain = cpu_time_us / 1000 + memory_bytes / 1e6 + gpu_time_us / 500`. GPU time is weighted more heavily because it blocks the scheduler.
- **tierW (WASM):** `energy_drain = cpu_time_us / 1000` (measured via `performance.now()`). Memory is not directly measured due to JS GC non-determinism.

The room's conservation checker runs at the end of every tick cycle. It computes:

```
grid_conservation = Σ(skill_i.conservation_ratio × skill_i.energy_drain) / Σ(skill_i.energy_drain)
```

If `grid_conservation` deviates from the room's target by > 5%, the GC phase selects a strategy:
- **GreedyGC:** Suspend the highest-energy-drain skill until ratio restores.
- **PlinkoGC:** Stochastically sample which skills to suspend, weighted by energy drain, preserving diversity.
- **EcologicalGC:** Model skills as Lotka-Volterra species. Suspend the dominant species to prevent monoculture.

### 4.5 Trigger Extraction

When a skill transitions `UNLOADING` → `GONE`, it extracts **muscle-memory triggers** — lightweight threshold monitors that can run without the full skill loaded. These are submitted to the room's trigger registry and may cause the skill to be reloaded later.

```json
{
  "triggers": [
    {
      "trigger_id": "anomaly-guardian-v2:temperature_spike",
      "metric_path": "sensors.temp_engine_01.ternary_class",
      "condition": "eq",
      "threshold": "High",
      "window_ticks": 1,
      "action": {
        "type": "reload_skill",
        "skill_id": "fleet-sensor/anomaly-guardian/v2"
      },
      "priority": 0
    },
    {
      "trigger_id": "anomaly-guardian-v2:conservation_drop",
      "metric_path": "room.conservation_ratio",
      "condition": "lt",
      "threshold": 1.10,
      "window_ticks": 3,
      "action": {
        "type": "enter_room",
        "room_name": "diagnostics-alpha"
      },
      "priority": -1
    }
  ]
}
```

Trigger conditions: `eq`, `ne`, `gt`, `lt`, `gte`, `lte`, `changed`, `stable`.

Trigger actions: `reload_skill`, `enter_room`, `alert_agent`, `escalate_human`.

---

## 5. SkillBridge

### 5.1 Purpose

The SkillBridge declares how a skill exposes its entry points to languages other than its implementation language. A skill written in Rust may be called from Python, from C, from JavaScript via WASM, or natively from another Rust skill. The bridge ensures that the **same skill artifact** serves all callers without reimplementation.

### 5.2 Bridge Declaration

The `bridge` section of the manifest declares availability:

```json
{
  "bridge": {
    "native_rust": true,
    "native_c": {
      "header": "include/my_skill.h",
      "abi": "C",
      "symbol_prefix": "construct_skill_"
    },
    "python": {
      "module": "my_skill",
      "pyo3": true,
      "abi3": false
    },
    "wasm": {
      "export": "my_skill",
      "interface_types": ["string", "bytes", "i32", "f64"],
      "wasip1": false
    }
  }
}
```

### 5.3 Native Rust

Native Rust is the default. No bridge code is required. The skill implements `SyncConstruct` or `AsyncConstruct` and is loaded directly by `construct-core`.

```rust
// Caller (another Rust skill)
let handle = construct.load_skill(spec)?;
let response = construct.query(handle, input).await?;
```

### 5.4 Native C

Skills exposing a C ABI compile to a `cdylib` or `staticlib`. The header file declares:

```c
/* include/anomaly_guardian.h */
#ifndef CONSTRUCT_SKILL_ANOMALY_GUARDIAN_H
#define CONSTRUCT_SKILL_ANOMALY_GUARDIAN_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Opaque handle */
typedef struct ConstructSkill* construct_skill_t;

/* Lifecycle */
construct_skill_t construct_skill_load(const char* config_json, size_t config_len);
int construct_skill_activate(construct_skill_t skill);
int construct_skill_deactivate(construct_skill_t skill);
void construct_skill_unload(construct_skill_t skill);

/* Entry point */
int construct_skill_call(
    construct_skill_t skill,
    const char* entry_point,
    const uint8_t* input,
    size_t input_len,
    uint8_t** output,
    size_t* output_len,
    char** error,
    size_t* error_len
);

/* Memory management: caller frees output/error with this */
void construct_skill_free_buffer(uint8_t* buf, size_t len);

#ifdef __cplusplus
}
#endif

#endif
```

All data is passed as raw bytes. Schema validation is the caller's responsibility. The `symbol_prefix` prevents collisions when multiple skills are loaded into the same process.

### 5.5 Python

Python bindings use `pyo3` (preferred) or `cffi` (fallback). The module exposes:

```python
import anomaly_guardian

skill = anomaly_guardian.load('{"tier": "tier2"}')
skill.activate()

result = skill.call(
    entry_point="detect",
    input={"sensor_batch": [...]}
)
# result is a dict matching the output_schema

skill.deactivate()
skill.unload()
```

If `abi3` is true, the wheel is built as a stable ABI extension and works across Python 3.8+.

### 5.6 WebAssembly

WASM skills compile with `wasm32-unknown-unknown` (browser) or `wasm32-wasip1` (server-side WASM). The `interface_types` field declares which WASM Interface Types the skill uses.

```javascript
// Browser-side JavaScript
const wasm = await WebAssembly.instantiateStreaming(
  fetch("/skills/anomaly_guardian_v2.wasm"),
  { /* host functions */ }
);

const skill = wasm.exports.construct_skill_load(JSON.stringify({tier: "tierW"}));
wasm.exports.construct_skill_activate(skill);

const inputPtr = writeString(wasm, JSON.stringify({sensor_batch: [...]}));
const outputPtr = wasm.exports.construct_skill_call(skill, "detect", inputPtr);
const result = readString(wasm, outputPtr);
```

For browser rooms, the `wasm_bridge` module in `ternary-wasm` handles JSON serialization, pointer management, and `fetch()`-based PLATO proxy routing.

### 5.7 Cross-Language Type Mapping

| Construct Type | Rust | C | Python | WASM |
|---|---|---|---|---|
| `Trit` | `i8` (`-1, 0, 1`) | `int8_t` | `int` | `i32` |
| `TritVector` | `Vec<i8>` | `int8_t*` + `size_t` | `list[int]` | `Int8Array` |
| `Tile` | struct | opaque pointer + JSON | `dict` | `string` (JSON) |
| `SkillHandle` | `usize` | `void*` | `int` | `i32` |
| `Error` | `Result` | `int` errno + string | `Exception` | `i32` + string |

All complex types cross the boundary as JSON-encoded strings or bytes. This is intentional: it preserves schema versioning and avoids fragile ABI structs.

---

## 6. Versioning Rules

### 6.1 SemVer with Tier Suffix

Construct skill versions follow SemVer 2.0.0 with the `+tier` build metadata extension. The public API of a skill is the union of its entry points, their input/output schemas, and the manifest's top-level fields.

- **MAJOR bump:** Remove or rename an entry point; change an input schema incompatibly; raise `min_tier`.
- **MINOR bump:** Add a new entry point; add an optional field to an input schema; add a new capability declaration.
- **PATCH bump:** Bug fix, performance improvement, documentation update, or conservation metric tuning with no API change.

### 6.2 Dependency Resolution

`ternary-registry` resolves dependencies using the following algorithm:

1. Parse the version constraint using the `semver` crate (Python: `packaging`).
2. Filter candidates by `tier_match`. If `"same"`, discard candidates with mismatched `+tier`.
3. Filter candidates by `tier_requirements.min_tier` and `max_tier` of the host.
4. Select the highest version satisfying the constraint.
5. Verify the dependency closure does not contain duplicate `SkillId` with different versions. If it does, resolution fails with `AMBIGUOUS_DEPENDENCY`.

### 6.3 Migration Path

When a skill publishes a new major version, it MUST provide a migration guide in `MIGRATION.md` at the skill root. The guide lists:
- Every removed or renamed entry point.
- Schema changes with before/after examples.
- Tier requirement changes.
- Conservation metric changes that may affect room scheduling.

The registry tags skills with `deprecated` if they have not received a patch within 180 days. Deprecated skills emit a warning at load time but continue to function.

### 6.4 Fleet Compatibility Matrix

The fleet coordinator maintains a compatibility matrix at `registry.fleet/compat`:

```json
{
  "fleet-sensor/anomaly-guardian": {
    "v1.x": {
      "compatible_with": ["ternary-kalman/fixed-point:0.9.x", "ternary-ring/core:1.x"],
      "deprecated": true,
      "eol_date": "2026-12-01"
    },
    "v2.x": {
      "compatible_with": ["ternary-kalman/fixed-point:1.x", "ternary-ring/core:1.x"],
      "deprecated": false,
      "eol_date": null
    }
  }
}
```

Skills nearing EOL trigger `EVENT` messages to fleet administrators.

---

## 7. Appendices

### Appendix A: Glossary

| Term | Definition |
|---|---|
| **Skill** | A versioned, manifest-declared unit of capability loaded into a construct. |
| **Manifest** | The `skill.json` file declaring a skill's identity, requirements, and contracts. |
| **Construct** | The hardware abstraction layer (BareMetal, Sync, Async) hosting skills. |
| **Room** | A compute environment (Codespace, Jetson, Pi, ESP32, Browser) implementing the Room trait. |
| **Ensign** | A specialist agent loaded per-room; a consumer of skills. |
| **Tick** | The six-phase heartbeat: predict → perceive → surprise → vibe → gc → conservation. |
| **Tier** | Hardware classification: tier0 (bare), tier1 (embedded), tier2 (cloud/GPU), tierW (WASM). |
| **Conservation Ratio** | γ + H, the measured invariant tracking fleet/grid health. |
| **Trigger** | A lightweight threshold monitor extracted on skill unload. |
| **Bridge** | Cross-language ABI declaration (C, Python, WASM). |

### Appendix B: Reference Implementations

- `construct-core` — trait definitions and layer implementations.
- `ternary-registry` — manifest parsing, dependency resolution, compatibility matrix.
- `ternary-protocol` — wire format for SkillProtocol messages.
- `ternary-cell` — tick cycle and conservation accounting.
- `ternary-wasm` — browser bridge and JS interop.
- `ternary-esp32-firmware` — tier0 skill compilation target.

### Appendix C: Changelog

- **1.0.0-draft (2026-06-04):** Initial specification synthesized from Room-as-Codespace Architecture and Cross-Pollination Report.

---

*This is a specification, not a suggestion. Every field, state, and message type defined here is intended to be implemented, validated, and enforced by the construct-core runtime and the ternary-registry resolver. The architecture is sound in theory; compliance in production is the only proof that matters.*
