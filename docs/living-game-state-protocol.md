# Living Game State Protocol (LGSP)

**Specification v0.1.0-draft**
**Date:** 2026-06-06
**Status:** Draft for fleet review
**Author:** Hermes 405B (based on VoxelCraft product vision + architecture review)
**License to be opinionated:** Full

---

## Table of Contents

1. [What It Is](#1-what-it-is)
2. [Data Model](#2-data-model)
3. [Commands](#3-commands)
4. [Evolution Hooks](#4-evolution-hooks)
5. [Wire Format](#5-wire-format)
6. [Implementation Plan](#6-implementation-plan)

---

## 1. What It Is

The Living Game State Protocol is the missing bridge between three components of VoxelCraft:

```
  ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
  │   Block Studio    │     │   CraftMind      │     │  Phaser Game     │
  │   (Kids build     │────▶│   Ranch          │────▶│  Engine          │
  │    block scripts) │     │   (creatures     │     │  (games run)     │
  │                   │     │    evolve)       │     │                  │
  └──────────────────┘     └──────────────────┘     └──────────────────┘
           │                       │                        │
           └───────────────────────┼────────────────────────┘
                                   │
                          ┌────────▼────────┐
                          │  Living Game    │
                          │  State Protocol │
                          │  ────────────── │
                          │  • Game JSON    │
                          │  • State sync   │
                          │  • Fitness flow │
                          │  • DNA bridge   │
                          └─────────────────┘
```

### Purpose

1. **Let block scripts control game state** — blocks generate commands like `move_player`, `spawn_entity`, `collect_item`. These commands mutate the game state in a predictable, serializable way.

2. **Let game state feed back into evolution** — every game interaction (player died, coin collected, monster avoided) produces fitness data. The Ranch consumes this data to evolve creature DNAs.

3. **Let evolved DNAs drive game behavior** — creature DNAs (speed, aggression, patrol patterns) become runtime parameters in the Phaser game engine. The ramp-up is gradual: generation N+1 enemies are slightly different from generation N.

4. **Cross-session state persistence** — evolution must survive browser tab closures. The protocol defines how game state is persisted to Cloudflare KV/Durable Objects and how it's restored on game load.

### Design Goals

| Goal | Priority | Why |
|------|----------|-----|
| **Kid-simple integration** | P0 | A block script should work with zero additional boilerplate. The protocol is invisible to the game maker. |
| **Deterministic replay** | P0 | Given the same game JSON and same evolution state seed, the game must produce the same behavior. This is critical for debugging and for fair fork/competition. |
| **Lossless fitness capture** | P0 | Every game interaction that affects evolution must be captured. No silent data loss. |
| **Versioned schema** | P0 | Protocol evolves. Games deployed today must still load with tomorrow's Ranch. |
| **Offline-capable** | P1 | A kid on a school bus plays a deployed game. No network, no Ranch — but the game still plays with the last known evolution state. Fitness data is queued locally and flushed when online. |
| **Sub-100ms state restore** | P1 | Loading a game's evolution state from KV must complete before the game's first frame renders. No loading spinners for evolution state. |
| **Fork trivially** | P1 | Forking a game copies its evolution state curve. The new fork continues from the copied generation, diverging forward. |

---

## 2. Data Model

### 2.1 Core GameState

Every VoxelCraft game has a single `GameState` object at any moment. It is the source of truth.

```typescript
interface GameState {
  /** Protocol version for backward compat */
  protocolVersion: "lgsp/v0.1.0";

  /** Unique game instance ID. Same game deployed twice = different instanceId */
  instanceId: string;

  /** The game template this instance is based on */
  gameId: string;

  /** Fork lineage: null for original, parent instanceId for forks */
  forkParent: string | null;

  /** Current wall-clock play session (epoch ms) */
  sessionStartedAt: number;

  /** Tick counter since game boot. Monotonically increasing */
  tick: number;

  /** Current generation of evolution state loaded */
  generation: number;

  /** All entities in the current scene */
  entities: Entity[];

  /** All players (0 for passive view, 1+ for local multiplayer) */
  players: Player[];

  /** Global game flags (level complete, boss active, etc.) */
  flags: Record<string, boolean>;

  /** Score/timer state, game-specific */
  metrics: GameMetrics;

  /** The active evolution environment for this session */
  evolution: EvolutionEnvironment;

  /** Command queue for the current frame */
  pendingCommands: Command[];
}
```

### 2.2 Entity

Entities are anything that exists in the game world: players, enemies, items, decorations, obstacles.

```typescript
interface Entity {
  /** Unique entity ID within this game instance */
  id: string;

  /** Entity type — used to determine behavior class in Phaser */
  type: EntityType;

  /** Human-readable name (from Block Studio label) */
  name: string;

  /** Current position in game-world coordinates (Phaser units) */
  position: {
    x: number;
    y: number;
    z?: number; // for layered/platformer games
  };

  /** Current velocity vector */
  velocity: {
    x: number;
    y: number;
  };

  /** Dimensions (hitbox/visual) */
  size: {
    width: number;
    height: number;
  };

  /** Current sprite/animation state */
  spriteState: SpriteState;

  /** Evolution DNA slot — links this entity to a Ranch species */
  evolvable: EvolvableSlot | null;

  /** Custom properties set by block scripts */
  properties: Record<string, number | string | boolean>;

  /** Entity tags for grouping/filtering */
  tags: string[];

  /** Whether this entity is alive/active */
  active: boolean;

  /** Health/resource state */
  health: number;
  maxHealth: number;

  /** Cooldown timers */
  cooldowns: Record<string, number>; // cooldown key → ticks remaining
}

type EntityType =
  | "player"
  | "enemy"
  | "collectible"
  | "obstacle"
  | "decoration"
  | "projectile"
  | "trigger_zone"
  | "spawn_point"
  | "door"
  | "platform"
  | "trap";

interface SpriteState {
  /** Current animation name */
  animation: string;
  /** Flip horizontal */
  flipX: boolean;
  /** Flip vertical */
  flipY: boolean;
  /** Opacity 0.0–1.0 */
  alpha: number;
  /** Rotation in radians */
  rotation: number;
  /** Tint color hex */
  tint: string | null;
}

interface EvolvableSlot {
  /** Which Ranch species this entity maps to */
  speciesId: string;
  /** Current DNA hash — used to detect stale state */
  dnaHash: string;
  /** Generation this DNA was sourced from */
  generation: number;
  /** Which Ranch task tracks this entity's behavior */
  taskId: string;
}
```

### 2.3 Player

Players are special entities controlled by human input:

```typescript
interface Player {
  /** Entity ID this player controls */
  entityId: string;

  /** Unique player ID (anonymous session or authenticated) */
  playerId: string;

  /** Display name (from Buddy or anonymous "Player 1") */
  displayName: string;

  /** Input state for the current frame */
  input: {
    left: boolean;
    right: boolean;
    up: boolean;
    down: boolean;
    jump: boolean;
    action: boolean;       // generic "interact" button
    secondaryAction: boolean;
    aimX: number | null;   // mouse/gamepad aim direction
    aimY: number | null;
  };

  /** Accumulated metrics for this session */
  sessionStats: PlayerSessionStats;

  /** Controls mapping (for rebindable controls from blocks) */
  controls: Record<string, string>;
}

interface PlayerSessionStats {
  score: number;
  coinsCollected: number;
  enemiesDefeated: number;
  deaths: number;
  timePlayedMs: number;
  jumpsPerformed: number;
  distanceTraveled: number;
  itemsUsed: number;
  secretsFound: number;
}
```

### 2.4 GameMetrics

Core game-level state:

```typescript
interface GameMetrics {
  /** Current score */
  score: number;
  /** High score for this game instance */
  highScore: number;
  /** Time elapsed this session (ms) */
  elapsedMs: number;
  /** Lives/attempts remaining */
  lives: number;
  /** Current level/scene name */
  currentLevel: string;
  /** Level completion flags */
  levelsCompleted: string[];
  /** Number of secrets discovered */
  secretsFound: number;
  /** Game over flag */
  gameOver: boolean;
  /** Pause state */
  paused: boolean;
}
```

### 2.5 EvolutionEnvironment

The evolution state loaded into a running game:

```typescript
interface EvolutionEnvironment {
  /** Generation number this state represents */
  generation: number;
  /** Minimum fitness score from last generation */
  minFitness: number;
  /** Global generation counter across all forks of this game */
  globalGeneration: number;

  /** Active DNAs indexed by entity ID */
  activeDnas: Record<string, CreatureDNA>;

  /** Species registry — defines evolvable parameters per species */
  species: Record<string, SpeciesDefinition>;

  /** Fitness events accumulated this session (not yet flushed) */
  fitnessBuffer: FitnessEvent[];

  /** Last flush timestamp (epoch ms) — for batch coalescing */
  lastFlushAt: number;

  /** Whether evolution is paused (kid disabled it) */
  evolutionPaused: boolean;
}

interface CreatureDNA {
  speciesId: string;
  dnaHash: string;
  generation: number;
  traits: DNATraits;
  personality: DNAPersonality;
  taskWeights: Record<string, number>;
}

interface DNATraits {
  /** Movement speed multiplier (0.1–2.0) */
  speed: number;
  /** Patrol range radius in game units */
  patrolRange: number;
  /** Reaction delay in ticks (higher = slower reaction) */
  reactionDelay: number;
  /** Aggression threshold of 0.0 to 1.0 (proximity to engage) */
  aggression: number;
  /** Hit points multiplier */
  strength: number;
  /** Smartness — affects pathfinding quality */
  intelligence: number;
  /** How quickly this entity learns from player patterns */
  learningRate: number;
  /** Predictability: 0 = completely random, 1 = highly patterned */
  consistency: number;
  /** Persistence: how long it chases before giving up */
  persistence: number;
  /** Starting position preference: "camp", "patrol", "random", "flank" */
  positioningStrategy: "camp" | "patrol" | "random" | "flank" | "ambush";
}

interface DNAPersonality {
  cautious: number;     // 0.0–1.0
  curious: number;      // 0.0–1.0
  stubborn: number;     // 0.0–1.0
  social: number;       // 0.0–1.0 (flocking tendency)
  aggressive: number;   // 0.0–1.0
}

interface SpeciesDefinition {
  speciesId: string;
  name: string;
  emoji: string;
  role: string;

  /** Which traits are evolvable (others stay at default) */
  evolvableTraits: (keyof DNATraits)[];

  /** Allowed personality range per trait */
  personalityBounds: Partial<Record<keyof DNAPersonality, [number, number]>>;

  /** Default trait values if no DNA loaded */
  defaultTraits: Partial<DNATraits>;

  /** Default personality values */
  defaultPersonality: Partial<DNAPersonality>;

  /** How fitness is computed from gameplay stats */
  fitnessFunction: "kill_count" | "survival_time" | "distance_chased" | "collect_denial" | "hybrid";

  /** Which game metrics this species cares about */
  relevantMetrics: string[];
}

interface FitnessEvent {
  /** Entity that performed the action */
  actorEntityId: string;
  /** Ranch species ID */
  speciesId: string;
  /** Ranch task ID */
  taskId: string;
  /** Fitness delta (positive = good for this DNA) */
  fitnessDelta: number;
  /** What happened */
  eventType: FitnessEventType;
  /** Context as key-value pairs */
  context: Record<string, number>;
  /** Game tick when event occurred */
  tick: number;
  /** Wall clock timestamp */
  timestamp: number;
}

type FitnessEventType =
  | "caught_player"
  | "hit_player"
  | "missed_player"
  | "player_escaped"
  | "collectible_denied"   // enemy prevented player from getting item
  | "collectible_obtained"  // player got item despite enemy
  | "killed"
  | "survived"
  | "patrolled_distance"
  | "flanked_player"
  | "ambushed_player"
  | "retreated"
  | "player_damaged"
  | "player_died"
  | "level_completed";
```

### 2.6 BlockScript

A block script defines game behavior. It's the output of Block Studio and the input to the game engine.

```typescript
interface BlockScript {
  /** Unique script ID */
  id: string;
  /** Human-readable name */
  name: string;

  /** The blocks in execution order */
  blocks: BlockDefinition[];

  /** Evolution annotations — which blocks control evolvable parameters */
  evolutionAnnotations: EvolutionAnnotation[];

  /** Trigger conditions for this script */
  trigger: "on_start" | "on_tick" | "on_collision" | "on_event" | "always";

  /** Trigger-specific config */
  triggerConfig?: {
    eventType?: string;
    colliderTag?: string;
    collidedTag?: string;
    intervalTicks?: number;
  };
}

interface BlockDefinition {
  /** Block type ID */
  blockType: string;
  /** Block instance ID for references */
  blockId: string;
  /** Display label */
  label: string;
  /** Block parameters */
  params: Record<string, BlockParamValue>;
  /** Nested blocks (for conditionals/loops) */
  children: BlockDefinition[];
}

interface BlockParamValue {
  type: "number" | "string" | "boolean" | "entity_ref" | "position" | "color" | "dropdown";
  value: number | string | boolean | Position | Color | string[];
}

interface EvolutionAnnotation {
  /** Which block property is evolvable */
  blockId: string;
  /** Which property of that block */
  property: string;
  /** Which Ranch species controls this */
  speciesId: string;
  /** Which Ranch trait maps to this property */
  mappedTrait: keyof DNATraits;
  /** Range of values this trait can produce */
  range: [number, number];
  /** Default value */
  defaultValue: number;
}
```

---

## 3. Commands

Commands are the bridge between block scripts and game state. A block script generates commands, commands mutate game state, evolved DNAs influence command parameters.

### 3.1 Command Grammar

Every command has the same shape:

```typescript
interface Command {
  /** Unique command ID within this frame */
  id: string;
  /** Command type */
  type: CommandType;
  /** Target entity ID (or null for global commands) */
  targetEntityId: string | null;
  /** Command parameters */
  params: Record<string, number | string | boolean | Position | EntityRef>;
  /** Which block script generated this command (for debugging) */
  sourceBlockId: string | null;
  /** Evolvable override — if set, Ranch DNA modifies this command */
  evolvableOverride: EvolvableOverride | null;
}

interface Position {
  x: number;
  y: number;
}

interface EntityRef {
  entityId: string;
  tag?: string; // resolve by tag if entityId not set
}

interface EvolvableOverride {
  /** Which trait modifies this command */
  trait: keyof DNATraits;
  /** The DNA value (set by game engine at runtime) */
  dnaValue: number;
  /** Original block-script value before override */
  originalValue: number;
}
```

### 3.2 Command Types

| Command | Params | Description | Evolvable Override |
|---------|--------|-------------|-------------------|
| `move` | `direction`: "left"\|"right"\|"up"\|"down"\|"toward_player", `speed`: number | Move entity in direction | speed → `speed` trait |
| `jump` | `force`: number, `direction`: "up"\|"up_right"\|"up_left" | Apply jump impulse | force → `strength` |
| `spawn` | `entityType`: EntityType, `position`: Position, `name`: string, `count`: number, `interval`: number | Spawn new entities | interval → `reactionDelay`; count → `persistence` |
| `collect` | `itemId`: string, `points`: number | Player collects item | N/A |
| `destroy` | `targetId`: string, `effect`: string \| null | Remove entity from world | N/A |
| `set_property` | `property`: string, `value`: number\|string\|boolean | Set entity custom property | value → any mapped trait |
| `set_velocity` | `vx`: number, `vy`: number | Apply velocity vector | vx/vy → `speed` |
| `patrol` | `centerX`: number, `centerY`: number, `radius`: number, `speed`: number | Entity patrols area | speed → `speed`; radius → `patrolRange` |
| `chase` | `target`: EntityRef, `speed`: number, `maxDistance`: number | Entity chases target | speed → `speed`; maxDistance → `patrolRange`; target → `aggression` (threshold) |
| `wait` | `ticks`: number | Pause execution | ticks → `reactionDelay` |
| `conditional` | `condition`: Condition, `then`: Command[], `else`?: Command[] | Branch | condition threshold → `intelligence` |
| `loop` | `count`: number, `body`: Command[] | Repeat | count → `consistency` |
| `play_animation` | `animation`: string, `loop`: boolean | Change sprite animation | N/A |
| `emit_event` | `eventType`: string, `payload`: Record<string, any> | Fire a game event | event selection → `positioningStrategy` |
| `set_flag` | `flag`: string, `value`: boolean | Set global game flag | N/A |
| `check_flag` | `flag`: string | Conditional on flag | N/A |
| `modify_score` | `delta`: number, `reason`: string | Change score | delta → `persistence` (on collect denial) |
| `teleport` | `position`: Position | Instantly move entity | N/A |
| `push` | `forceX`: number, `forceY`: number | Apply physics impulse | force → `strength` |
| `flock` | `groupTag`: string, `separation`: number, `alignment`: number, `cohesion`: number | Flocking behavior | alignment → `social`; separation → `aggression` |
| `flee` | `from`: EntityRef, `speed`: number | Entity runs away | speed → `speed`; from → `cautious` (threshold) |

### 3.3 Block-to-Command Mapping Examples

**Example 1: "When game starts, spider patrols area"**

```json
{
  "blockType": "motion_patrol",
  "params": {
    "entityTag": "spider",
    "center": { "type": "position", "value": { "x": 200, "y": 300 } },
    "radius": { "type": "number", "value": 150 },
    "speed": { "type": "number", "value": 2 }
  },
  "trigger": "on_start"
}
```

→ Generates command:

```json
{
  "id": "cmd_001",
  "type": "patrol",
  "targetEntityId": "spider_01",
  "params": {
    "centerX": 200,
    "centerY": 300,
    "radius": 150,
    "speed": 2
  },
  "sourceBlockId": "block_motion_003",
  "evolvableOverride": {
    "trait": "speed",
    "dnaValue": 2.7,
    "originalValue": 2
  }
}
```

**Example 2: "When spider touches cat, cat loses 1 health"**

```json
{
  "blockType": "control_on_collision",
  "params": {
    "entityTag": "spider",
    "collidesWith": "cat"
  },
  "children": [
    {
      "blockType": "motion_jump",
      "params": { "force": { "type": "number", "value": 5 } }
    }
  ],
  "trigger": "on_collision",
  "triggerConfig": { "colliderTag": "spider", "collidedTag": "cat" }
}
```

→ Generates command:

```json
{
  "id": "cmd_002",
  "type": "jump",
  "targetEntityId": "spider_01",
  "params": { "force": 5, "direction": "up" },
  "sourceBlockId": "block_control_001",
  "evolvableOverride": null
}
```

(Also generates an internal collision callback and a damage event — but the block script only expresses the jump.)

### 3.4 Command Execution Model

Commands are executed **frame-atomic** in the game engine:

```
For each game frame (60fps / ~16.67ms):
  1. Process player input → mutate Player.input
  2. Collect all Commands whose trigger condition is met
  3. For each Command:
     a. If evolvableOverride exists, apply DNA-modulated params
     b. Execute command → mutate GameState
     c. If command affects evolution-relevant state, push FitnessEvent
  4. Apply physics (velocity → position, collision detection)
  5. GameState.tick += 1
  6. Render frame
```

---

## 4. Evolution Hooks

### 4.1 DNA → Game Behavior (Top-Down)

The Ranch generates DNAs that the game engine consumes as overrides on evolvable block params.

**Flow:**

```
                    ┌──────────────────┐
                    │  CraftMind       │
                    │  Ranch           │
                    │                  │
                    │  Gen N DNA:      │
                    │  speed: 1.7      │
                    │  aggression: 0.8 │
                    │  patrolRange: 120│
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │  Evolution       │
                    │  Environment     │
                    │  (KV storage)     │
                    │                  │
                    │  activeDnas: {   │
                    │   "spider_01": { │
                    │     speed: 1.7,  │
                    │     aggression:  │
                    │     0.8,         │
                    │     patrolRange: │
                    │     120          │
                    │   }              │
                    │  }               │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │  Phaser Game     │
                    │  Engine          │
                    │                  │
                    │  Command ->      │
                    │  evolvableOvr:   │
                    │  speed: 1.7      │
                    │  (was 2.0)       │
                    └──────────────────┘
```

**Override rules:**

1. The block script defines a **base value** for any param (e.g., speed = 2.0).
2. The block also has an **evolution annotation** linking that param to a trait (e.g., speed ↔ `speed` trait).
3. The EvolutionEnvironment provides a `dnaValue` for that trait (e.g., 1.7).
4. **Override = baseValue × (dnaValue / defaultTraitValue).**
5. Clamp to the range defined in the evolution annotation.
6. If no DNA is loaded for an entity, use default traits.

**Override example:**

```typescript
// Block script: spider patrol speed = 2
// Evolution annotation: speed param → speed trait, range [0.5, 3.0], default 1.0
// Ranch DNA: speed = 1.7

const override = clamp(2.0 * (1.7 / 1.0), 0.5, 3.0); // = 3.0 (clamped)
// The spider moves faster than the block script specified!
// This is the "wait, what?" moment — the game feels different.
```

### 4.2 Gameplay → Fitness (Bottom-Up)

Every game interaction generates FitnessEvents. These accumulate and flush to the Ranch for the next generation.

**Fitness computation per species:**

| Species | Fitness Function | What Makes Fitness Go Up |
|---------|-----------------|-------------------------|
| **Spider** (enemy) | `kill_count + survival_time + distance_chased` | Catching player, staying alive, covering ground |
| **Slime** (trap) | `collect_denial + area_coverage` | Being near collectibles, covering multiple paths |
| **Dragon** (boss) | `flank_rate + ambush_success + player_damage` | Attacking from unexpected angles |
| **Guard** (defender) | `player_escaped_neg + patrol_efficiency` | Preventing player from reaching goal |
| **Trap** (environment) | `activation_count + surprise_factor` | Being triggered often, via unexpected approach |
| **Runner** (speed enemy) | `chase_completion + reaction_time` | Catching player, responding quickly to direction changes |

**Fitness flush protocol:**

```typescript
interface FitnessFlush {
  /** Game instance */
  instanceId: string;
  /** Current generation being reported on */
  generation: number;
  /** All fitness events since last flush */
  events: FitnessEvent[];
  /** Session summary */
  sessionSummary: {
    /** Number of playthroughs this session */
    playCount: number;
    /** Total session duration */
    totalPlayMs: number;
    /** Player win rate */
    winRate: number;
    /** Average score */
    avgScore: number;
    /** Total deaths */
    totalDeaths: number;
    /** Timestamps */
    firstPlayAt: number;
    lastPlayAt: number;
  };
  /** Per-species aggregated stats */
  speciesSummaries: Record<string, SpeciesFitnessSummary>;
}

interface SpeciesFitnessSummary {
  speciesId: string;
  totalEvents: number;
  positiveEvents: number;
  negativeEvents: number;
  avgFitnessDelta: number;
  /** Distributions for crossover weighting */
  eventDistribution: Record<string, number>;
  /** Time-series of per-minute fitness deltas (for plateau detection) */
  fitnessTimeSeries: { minute: number; delta: number }[];
}
```

### 4.3 Evolution State Machine (Per-Game)

```
                         ┌──────────┐
                         │  BOOT    │
                         │  (load   │
                         │  gen N)   │
                         └────┬─────┘
                              │
                              ▼
                    ┌───────────────────┐
              ┌────▶│    PLAYING        │◀────────────┐
              │     │  (game running)    │              │
              │     └─────────┬─────────┘              │
              │               │                         │
              │               │ play session ends        │
              │               ▼                         │
              │     ┌───────────────────┐              │
              │     │   FLUSHING        │              │
              │     │  (fitness data →  │              │
              │     │   KV persistence) │              │
              │     └─────────┬─────────┘              │
              │               │                         │
              │               │ flush complete          │
              │               ▼                         │
              │     ┌───────────────────┐              │
              │     │    EVOLVING       │              │
              │     │  (cron/on-demand) │              │
              │     │  gen N + fit →    │              │
              │     │  gen N + 1 DNA    │              │
              │     └─────────┬─────────┘              │
              │               │                         │
              │               │ evolution done          │
              │               ▼                         │
              │     ┌───────────────────┐              │
              │     │   DEPLOYING       │              │
              │     │  (gen N+1 DNA →   │              │
              │     │   KV)             │              │
              │     └─────────┬─────────┘              │
              │               │                         │
              │               │ next player opens game  │
              └───────────────┘                         │
                                                        │
  ┌─────────────────────────────────────────────────────┘
  │  FORK:
  │  ┌──────────────────────────────────────────────┐
  │  │ 1. Copy gen N DNA from parent                 │
  │  │ 2. Reset generation counter to 0               │
  │  │ 3. Set forkParent to parent instanceId          │
  │  │ 4. First evolution step sees parent gen N+1    │
  └──────────────────────────────────────────────────┘
```

### 4.4 Evolution Speed Multipliers

Different game contexts need different evolution pacing:

| Context | How Fast | Mechanism |
|---------|----------|-----------|
| **First play** | Slow (3-5 sessions per gen) | Kid needs to notice the game before evolution diverges |
| **After 10+ sessions** | Faster (1-2 sessions per gen) | Kid expects changes, make them more frequent |
| **Researcher mode** | Fast (every session) | Explicit evolution lab — kid controls pacing |
| **Published game** | Moderate (daily cron) | No real-time player; batch evolve once per day |
| **Fork** | First gen immediately | Show the new owner "your game is alive!" |
| **"Speed run" game** | Very slow (community votes) | Prevent runaway evolution in shared games |

This is controlled by the `evolutionSpeed` parameter in the GameState:

```typescript
type EvolutionSpeed = {
  /** How many sessions between generations */
  sessionsPerGen: number;
  /** How much play time (seconds) between generations */
  playSecondsPerGen: number;
  /** Minimum fitness delta to trigger new generation */
  minFitnessDelta: number;
};
```

### 4.5 Plateau Detection

The Ranch Researcher monitors evolution. When a species plateaus:

```
Plateau symptom:
  - Last 3 generations: fitness delta < 2%
  - Total diversity declining
  - Same DNA patterns appearing

Researcher action:
  1. Flag plateau in Ranch dashboard
  2. Suggest mutation rate increase
  3. Optionally: introduce "migration" (import DNA from game fork)
  4. Buddy says: "Your spiders got really good! Want to change the rules to make it harder for them?"
```

---

## 5. Wire Format

### 5.1 Game JSON (Static Template)

This is the serialized form of a VoxelCraft game — what gets deployed, forked, downloaded, imported. It's the "source code" of a living game.

```json
{
  "protocol": "lgsp/v0.1.0",
  "gameId": "cat-vs-spiders-v1",
  "displayName": "Cat vs. Spiders",
  "authorId": "anon-abc123",
  "createdAt": "2026-06-06T12:00:00Z",
  "version": 1,

  "phases": [
    {
      "phaseId": "level1",
      "name": "The Garden",
      "background": "garden_bg",
      "music": "level1_theme",
      "bounds": { "width": 800, "height": 600 },
      "gravity": { "x": 0, "y": 400 },
      "entities": [
        {
          "id": "player_cat",
          "type": "player",
          "name": "Whiskers",
          "position": { "x": 100, "y": 500 },
          "size": { "width": 32, "height": 32 },
          "sprite": "cat_idle",
          "tags": ["cat", "friendly"],
          "health": 3,
          "maxHealth": 3
        },
        {
          "id": "spider_base",
          "type": "enemy",
          "name": "Spidey",
          "position": { "x": 400, "y": 100 },
          "size": { "width": 24, "height": 24 },
          "sprite": "spider_idle",
          "tags": ["spider", "enemy"],
          "evolvable": {
            "speciesId": "arachnid_hunter",
            "taskId": "chase_cat"
          },
          "properties": {
            "spawnInterval": 3.0,
            "maxSpawned": 5
          }
        }
      ],
      "collectibles": [
        {
          "id": "coin_01",
          "type": "collectible",
          "position": { "x": 300, "y": 400 },
          "sprite": "coin_gold",
          "points": 10
        }
      ],
      "triggers": [
        {
          "id": "win_zone",
          "type": "trigger_zone",
          "position": { "x": 750, "y": 500 },
          "size": { "width": 50, "height": 100 },
          "onEnter": "level_complete"
        }
      ]
    }
  ],

  "scripts": [
    {
      "id": "spawn_spiders",
      "name": "Spawn Spiders",
      "trigger": "on_tick",
      "triggerConfig": { "intervalTicks": 180 },
      "blocks": [
        {
          "blockType": "entity_spawn",
          "blockId": "block_spawn_001",
          "label": "Spawn a spider every 3 seconds",
          "params": {
            "entityType": { "type": "dropdown", "value": "enemy" },
            "template": { "type": "entity_ref", "value": "spider_base" },
            "position": { "type": "position", "value": { "x": 0, "y": 0 } },
            "positionMode": { "type": "dropdown", "value": "random_edge" },
            "count": { "type": "number", "value": 1 }
          }
        }
      ]
    },
    {
      "id": "spider_patrol",
      "name": "Spider Patrol",
      "trigger": "on_start",
      "blocks": [
        {
          "blockType": "motion_patrol",
          "blockId": "block_patrol_001",
          "label": "Patrol around spawn point",
          "params": {
            "speed": { "type": "number", "value": 2 },
            "radius": { "type": "number", "value": 120 }
          }
        }
      ],
      "evolutionAnnotations": [
        {
          "blockId": "block_patrol_001",
          "property": "speed",
          "speciesId": "arachnid_hunter",
          "mappedTrait": "speed",
          "range": [0.5, 4.0],
          "defaultValue": 1.0
        },
        {
          "blockId": "block_patrol_001",
          "property": "radius",
          "speciesId": "arachnid_hunter",
          "mappedTrait": "patrolRange",
          "range": [40, 300],
          "defaultValue": 150
        }
      ]
    }
  ],

  "evolutionConfig": {
    "enabled": true,
    "species": [
      {
        "speciesId": "arachnid_hunter",
        "name": "Arachnid Hunter",
        "emoji": "🕷️",
        "role": "hunting",
        "evolvableTraits": ["speed", "patrolRange", "aggression", "reactionDelay", "persistence"],
        "personalityBounds": {
          "cautious": [0.1, 0.9],
          "curious": [0.3, 0.9],
          "aggressive": [0.2, 1.0]
        },
        "defaultTraits": {
          "speed": 1.0,
          "patrolRange": 150,
          "aggression": 0.5,
          "reactionDelay": 10,
          "persistence": 0.6
        },
        "fitnessFunction": "hybrid",
        "relevantMetrics": ["enemiesDefeated_neg", "deaths", "distanceTraveled"]
      }
    ],
    "evolutionSpeed": {
      "sessionsPerGen": 3,
      "playSecondsPerGen": 120,
      "minFitnessDelta": 5.0
    }
  }
}
```

### 5.2 State Snapshot (Runtime)

This is the wire format sent between the game worker and KV/Durable Objects on every flush or load. It represents the current living state of a specific game instance.

```json
{
  "protocol": "lgsp/v0.1.0",
  "type": "state_snapshot",
  "instanceId": "game-instance-7a3f9c2e",
  "gameId": "cat-vs-spiders-v1",
  "forkParent": null,
  "timestamp": 1707262200000,
  "generation": 4,
  "dnaPool": {
    "arachnid_hunter": {
      "current": {
        "speed": 1.7,
        "patrolRange": 180,
        "aggression": 0.63,
        "reactionDelay": 8,
        "persistence": 0.72,
        "personality": {
          "cautious": 0.4,
          "curious": 0.7,
          "aggressive": 0.63
        }
      },
      "lineage": [
        { "generation": 0, "fitness": 50.0, "speed": 1.0 },
        { "generation": 1, "fitness": 55.2, "speed": 1.1 },
        { "generation": 2, "fitness": 62.8, "speed": 1.3 },
        { "generation": 3, "fitness": 71.5, "speed": 1.5 },
        { "generation": 4, "fitness": 78.3, "speed": 1.7 }
      ],
      "fitnessCurve": {
        "min": 50.0,
        "max": 78.3,
        "avg": 63.56,
        "stdev": 10.2,
        "plateaued": false
      },
      "totalPlayCount": 14,
      "totalPlaySeconds": 3420
    }
  },
  "pendingFitness": [],
  "lastFlushedAt": 1707262100000,
  "generationHistory": [
    { "gen": 0, "timestamp": 1707249600000, "sessionsTriggered": 3 },
    { "gen": 1, "timestamp": 1707253200000, "sessionsTriggered": 4 },
    { "gen": 2, "timestamp": 1707256800000, "sessionsTriggered": 3 },
    { "gen": 3, "timestamp": 1707260400000, "sessionsTriggered": 4 },
    { "gen": 4, "timestamp": 1707262200000, "sessionsTriggered": 1 }
  ]
}
```

### 5.3 Fitness Flush (Game → Ranch)

When a play session ends (or at 2-minute intervals during long sessions), the game worker sends a fitness flush:

```json
{
  "protocol": "lgsp/v0.1.0",
  "type": "fitness_flush",
  "instanceId": "game-instance-7a3f9c2e",
  "generation": 4,
  "flushNumber": 3,
  "timestamp": 1707262200000,
  "sessionSummary": {
    "playCount": 1,
    "totalPlayMs": 245000,
    "winRate": 0.33,
    "avgScore": 450,
    "totalDeaths": 3,
    "firstPlayAt": 1707261955000,
    "lastPlayAt": 1707262200000
  },
  "events": [
    {
      "actorEntityId": "spider_07",
      "speciesId": "arachnid_hunter",
      "taskId": "chase_cat",
      "fitnessDelta": 0.15,
      "eventType": "caught_player",
      "context": { "distanceChased": 320, "timeToCatch": 4.5, "playerHealthBefore": 2 },
      "tick": 8432,
      "timestamp": 1707262180000
    },
    {
      "actorEntityId": "spider_03",
      "speciesId": "arachnid_hunter",
      "taskId": "chase_cat",
      "fitnessDelta": -0.08,
      "eventType": "missed_player",
      "context": { "chaseDuration": 8.2, "distanceChased": 580 },
      "tick": 8551,
      "timestamp": 1707262190000
    },
    {
      "actorEntityId": "spider_12",
      "speciesId": "arachnid_hunter",
      "taskId": "chase_cat",
      "fitnessDelta": 0.25,
      "eventType": "flanked_player",
      "context": { "approachAngle": 135, "surpriseDistance": 40 },
      "tick": 8610,
      "timestamp": 1707262192000
    }
  ],
  "speciesSummaries": {
    "arachnid_hunter": {
      "totalEvents": 47,
      "positiveEvents": 28,
      "negativeEvents": 19,
      "avgFitnessDelta": 0.04,
      "eventDistribution": {
        "caught_player": 8,
        "missed_player": 12,
        "flanked_player": 6,
        "player_escaped": 7,
        "patrolled_distance": 10,
        "ambushed_player": 4
      },
      "fitnessTimeSeries": []
    }
  }
}
```

### 5.4 Evolution Run Request (CraftMind → Ranch)

When the evolution cron fires, it reads the fitness pool and requests a Ranch run:

```json
{
  "protocol": "lgsp/v0.1.0",
  "type": "evolution_request",
  "instanceId": "game-instance-7a3f9c2e",
  "sourceGeneration": 4,
  "flushPool": [ 
    { "flushNumber": 1, "events": [/* ... */] },
    { "flushNumber": 2, "events": [/* ... */] },
    { "flushNumber": 3, "events": [/* ... */] }
  ],
  "config": {
    "generations": 1,
    "populationSlots": 6,
    "cullThreshold": 0.3,
    "mutationRate": 0.15,
    "crossoverRate": 0.7
  },
  "currentDna": {
    "arachnid_hunter": {
      "speed": 1.7,
      "patrolRange": 180,
      "aggression": 0.63,
      "reactionDelay": 8,
      "persistence": 0.72,
      "personality": {
        "cautious": 0.4,
        "curious": 0.7,
        "aggressive": 0.63
      }
    }
  }
}
```

### 5.5 Evolution Run Response (Ranch → CraftMind)

```json
{
  "protocol": "lgsp/v0.1.0",
  "type": "evolution_result",
  "instanceId": "game-instance-7a3f9c2e",
  "resultGeneration": 5,
  "summary": {
    "totalGenerations": 1,
    "bestFitness": 81.2,
    "fitnessDelta": "+2.9",
    "diversity": 18
  },
  "newDna": {
    "arachnid_hunter": {
      "speed": 1.8,
      "patrolRange": 195,
      "aggression": 0.67,
      "reactionDelay": 7,
      "persistence": 0.75,
      "personality": {
        "cautious": 0.38,
        "curious": 0.72,
        "aggressive": 0.67
      }
    }
  },
  "lineageUpdate": [
    { "generation": 5, "fitness": 81.2, "speed": 1.8 }
  ],
  "plateauDetected": false,
  "researcherNotes": "Spiders developing flanking behavior. Generation 5 shows +15% ambush events. Consider adding a second obstacle to increase complexity."
}
```

### 5.6 Block Script Manifest (Block Studio → Game Engine)

When Block Studio exports a game, it produces a block script manifest that the game engine loads on boot:

```json
{
  "protocol": "lgsp/v0.1.0",
  "type": "block_manifest",
  "gameId": "cat-vs-spiders-v1",
  "scriptCount": 4,
  "scripts": [ /* script array from Game JSON */ ],
  "evolutionMarkers": {
    "block_patrol_001": {
      "speed": { "speciesId": "arachnid_hunter", "trait": "speed", "range": [0.5, 4.0] },
      "radius": { "speciesId": "arachnid_hunter", "trait": "patrolRange", "range": [40, 300] }
    },
    "block_chase_001": {
      "speed": { "speciesId": "arachnid_hunter", "trait": "speed", "range": [0.5, 4.0] },
      "maxDistance": { "speciesId": "arachnid_hunter", "trait": "patrolRange", "range": [50, 500] }
    }
  }
}
```

### 5.7 Fork Request (Ship Deck → CraftMind)

```json
{
  "protocol": "lgsp/v0.1.0",
  "type": "fork_request",
  "sourceInstanceId": "game-instance-7a3f9c2e",
  "newGameId": "cat-vs-spiders-fork-by-kira",
  "newAuthorId": "anon-def456",
  "forkDepth": 1,
  "timestamp": 1707264000000
}
```

### 5.8 Transport Layer

The protocol is transport-agnostic. Messages are JSON over:

| Context | Transport | Why |
|---------|-----------|-----|
| **Game → KV** (fitness flush) | HTTP POST to Cloudflare Worker + KV write | Persistent, atomic |
| **KV → Game** (state load) | KV read at game boot | Sub-50ms for small values |
| **Ranch ←→ CraftMind** | Cloudflare Queues | Async, durable, retry |
| **Cron → Ranch** | Cloudflare Workers cron trigger | Scheduled evolution |
| **Fork** | Cloudflare Workers HTTP + KV copy | Atomic copy-operation |
| **Block Studio → Game Engine** | Client-side (same browser tab) | Zero-latency, no network call |

**KV key pattern:**

```
game:{instanceId}:state          → StateSnapshot JSON
game:{instanceId}:fitness        → Accumulated FitnessEvents[]
game:{instanceId}:evolution:lock → Generation lock (prevent race)
game:{instanceId}:meta           → { gameId, forkParent, createdAt }
```

**Queue message format:**

```
{
  "type": "run_evolution",
  "instanceId": "game-instance-7a3f9c2e",
  "sourceGeneration": 4,
  "kvStateKey": "game:game-instance-7a3f9c2e:state",
  "kvFitnessKey": "game:game-instance-7a3f9c2e:fitness"
}
```

---

## 6. Implementation Plan

### Phase 0: Protocol Types + Core Types (Week 1)

**Goal:** Types exist that all three components can import.

- [ ] Define TypeScript interfaces for all types in this spec (`GameState`, `Entity`, `Player`, `Command`, `CreatureDNA`, `DNATraits`, `FitnessEvent`, etc.)
- [ ] Publish as `@voxelcraft/lgsp-types` npm package
- [ ] Define JSON Schema for all wire formats
- [ ] Write round-trip serialization tests (JSON → type → JSON)

**Deliverable:** `npm install @voxelcraft/lgsp-types` works. Types compile. Round-trip passes.

### Phase 1: Block Studio → Command (Week 1-2)

**Goal:** Block scripts compile to valid commands that the game engine can process.

- [ ] Extend Block Studio's internal type system to emit `Command[]` from block snapshots
- [ ] Add evolution annotation UI: "Make this evolvable" toggle per block property
- [ ] Block Studio exports `block_manifest.json` alongside game JSON
- [ ] Write compiler tests: given known block config, expect known command output
- [ ] Add validation: all evolvable properties have valid species mapping

**Deliverable:** Block Studio can produce a manifest with evolution markers. Command compilation is deterministic and tested.

### Phase 2: Game Engine Command Processing (Week 2-3)

**Goal:** Phaser game engine accepts and processes commands with DNA overrides.

- [ ] Phaser plugin: `GameStateManager` — maintains current GameState, processes Command[]
- [ ] DNA override engine: takes base param + DNA + range, produces effective param
- [ ] Command execution for first 6 command types: `move`, `jump`, `spawn`, `collect`, `patrol`, `chase`
- [ ] Fitness event capture: `GameStateManager` emits FitnessEvents for relevant interactions
- [ ] Fitness buffer: accumulates in-memory, auto-flushes every 120s or on game close (via `beforeunload`)

**Deliverable:** A spider with DNA override parameter patrols faster/slower based on loaded DNA. Fitness events accumulate.

### Phase 3: KV State Persistence (Week 3-4)

**Goal:** Game state survives session boundaries.

- [ ] Cloudflare Worker endpoint: `POST /api/game/:instanceId/state` (load state)
- [ ] Cloudflare Worker endpoint: `POST /api/game/:instanceId/flush` (flush fitness)
- [ ] Cloudflare Worker endpoint: `GET /api/game/:instanceId/state` (load latest state)
- [ ] KV key pattern implementation with atomic generation locks
- [ ] State snapshot compression (DNA is floats → bit-pack as 16-bit ints, ~60% size reduction)
- [ ] Offline fallback: if flush fails, queue locally and retry on next session

**Deliverable:** Game boots with gen N state, plays, flushes, boots next time with gen N+1.

### Phase 4: Ranch Evolution Crossover (Week 4-5)

**Goal:** Ranch runs evolution on game fitness data.

- [ ] CraftMind Ranch adapter: reads `evolution_request` format, translates to Ranch internal format
- [ ] Evolution loop per-game-instance: crossover+mutation produces new DNA
- [ ] Default Ranch DNA → game DNA trait mapping (Ranch traits: speed, patience, thoroughness, strength → game traits: speed, patrolRange, aggression, reactionDelay, etc.)
- [ ] Plateau detection: if last 3 gens delta < 2%, flag and optionally boost mutation rate
- [ ] Lineage tracking: store full DNA history per game instance

**Deliverable:** Ranch takes game fitness data, runs one generation, outputs new DNA. Researcher can see lineage.

### Phase 5: Evolution Cron + Deployment (Week 5-6)

**Goal:** Automatic evolution runs on deployed games.

- [ ] Cloudflare Workers cron trigger (every 6 hours by default)
- [ ] Cron reads game pool from KV (all active games)
- [ ] For each game: check if evolution is due (sessionsSinceLastGen >= sessionsPerGen OR playSeconds >= playSecondsPerGen)
- [ ] Queue evolution run via Cloudflare Queues
- [ ] Worker consumes queue, calls Ranch, writes new DNA
- [ ] Generation lock: prevent concurrent evolution runs on same game instance

**Deliverable:** Deployed games evolve automatically. Kid opens game, sees gen N+1 DNA in action.

### Phase 6: Fork + Ship Integration (Week 6-7)

**Goal:** Ship Deck and fork culture work with living state.

- [ ] Ship Deck calls `fork_request` endpoint when kid clicks "Remix this game"
- [ ] Fork copier: atomic copy of Game JSON + StateSnapshot to new instance
- [ ] Fork counter: limit forks to 3/hour per session (rate limit)
- [ ] Ship Deck shows evolution stats on game card: "Gen 5 · 14 plays · +78% spider fitness"
- [ ] Buddy integration: "Your game has evolved! Gen 5 spiders are 70% smarter than your last play."

**Deliverable:** Remix a game, it starts from the parent's gen N state. Evolution diverges from there.

### Phase 7: Buddy + Researcher Integration (Week 7-8)

**Goal:** Kids understand what's happening.

- [ ] Buddy reads game evolution state and explains in kid-friendly language
- [ ] "Your spiders learned to sneak! They're getting flanking moves."
- [ ] Researcher dashboard in Ranch shows per-game fitness curves, lineage trees, best DNAs
- [ ] Evolution replay viewer: time-lapse of beast DNA across generations
- [ ] "Wait, what?" moment detection: after 3 playthroughs, Buddy sends: "Did you notice something different about the spiders today?"

**Deliverable:** The evolution loop is no longer invisible. Kids understand what happened and why it's interesting.

### Phase 8: Scale + Polish (Week 8+)

**Goal:** Ready for 10k games.

- [ ] Load testing: simulate 100 simultaneous evolution runs
- [ ] KV read optimization: memoize state snapshots, use request coalescing
- [ ] Fitness event batching: flush max 500 events per request (configurable)
- [ ] Block-to-command compiler performance: <5ms compilation time
- [ ] Command execution profiling: <1ms per command in game loop
- [ ] Error handling: graceful degradation if Ranch is unavailable
- [ ] Monitoring: Cloudflare Workers analytics for evolution events, KV reads/writes, queue depths

**Deliverable:** Protocol handles 10k+ active games.

---

## Appendix A: Integration Checklist

For each component team, what they need to implement:

### Block Studio Team
- [ ] Emit `EvolutionAnnotation[]` from block properties marked "evolvable"
- [ ] Integrate `block_manifest.json` export
- [ ] UI toggle: "Let this evolve" per block property
- [ ] Species picker: which Ranch species controls this block?

### Phaser Game Engine Team
- [ ] `GameStateManager` plugin
- [ ] Command execution engine (start with 6 types, add as blocks ship)
- [ ] DNA override resolver
- [ ] Fitness event emitter (listening to Phaser physics callbacks)
- [ ] KV flush worker

### CraftMind Ranch Team
- [ ] Ranch adapter for LGSP `evolution_request`/`evolution_result` format
- [ ] Game-trait → Ranch-dna mapping function
- [ ] Per-game-instance evolution isolation
- [ ] Plateau detection algorithm

### Ship Deck / Worker Team
- [ ] KV key pattern implementation
- [ ] Fitness flush endpoint
- [ ] Evolution state load endpoint
- [ ] Fork copy endpoint
- [ ] Evolution cron trigger
- [ ] Game card evolution stats

### Buddy / Researcher Team
- [ ] Evolution state reader (Buddy explains what happened)
- [ ] Fitness curve renderer (Researcher dashboards)
- [ ] "Wait, what?" detection logic
- [ ] Evolution replay viewer

---

## Appendix B: Edge Cases & Error Handling

| Case | Behavior |
|------|----------|
| **No evolution state in KV** (first boot) | Use default traits from species definition. Start gen 0. |
| **KV read timeout** | Use cached state from last session (localStorage). Reconnect next frame. |
| **Fitness flush fails** | Queue locally, retry with exponential backoff. Max queue: 1000 events. |
| **Evolution race condition** (two flushes concurrent) | Generation lock in KV (atomic write with gen number check). Late flush is discarded. |
| **DNA corruption** (bad parse) | Fall back to default traits for that species. Log error, alert Researcher. |
| **Fork of a fork** | Works fine. Each fork gets its own instanceId. Lineage graph is tracked. |
| **Game deleted** | KV cleanup: delete all `game:{instanceId}:*` keys. |
| **Rate limit exceeded** | Buddy says: "Whoa, you're evolving fast! Let's take a quick break." |
| **Unknown species in evolution annotation** | Skip that annotation, use defaults. Log warning. |
| **Multiple species sharing same entity** | Sum/avg DNA overrides. Log for Researcher audit. |
| **Evolution disabled mid-game** | Freeze current DNA. No new evolutions. Fitness events are still logged but not consumed. |

---

## Appendix C: Key References

- [VoxelCraft Product Vision](/notes/main/voxelcraft-product-vision.md)
- [Architecture Review (Hermes 405B)](/notes/main/architecture-review-hermes.md)
- [Construct Skill Specification](/notes/main/CONSTRUCT-SKILL-SPEC.md)
- [Evolution Results (Ranch)](/notes/main/evolution-results.json)
- [Ecosystem Map](/notes/main/ECOSYSTEM_MAP.md)
- [Cortex JSON Spec](/notes/main/CORTEX-JSON-v1-SPEC.md)

---

*"Block scripts build the arena. Evolution writes the rules. The protocol is how they talk."*
