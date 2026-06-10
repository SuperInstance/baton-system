# Prediction-First Perception

*Or: Why you don't feel your shoes, and why that's the architecture*

## The Shoe

1. You put shoes on. The sensation is **loud**. Your prediction didn't include shoes. Big delta. Attention snaps.
2. Ten minutes later. Your simulation updated. Shoes are now in the prediction model. Delta drops to zero. You stop feeling them.
3. You walk outside. The shoe sensation isn't gone — it's been **absorbed into the baseline**. Now it's the carrier wave. You feel gravel through the shoe. Slope through the shoe. Temperature through the shoe. The shoe IS how you read the ground.
4. A pebble gets in. Delta spikes. The simulation didn't predict pebble. Attention snaps back.

This is not a metaphor. This is the architecture.

## The Inversion

Normal sensor model:
```
SENSOR → "What is happening?" → PROCESS → ACTION
```

Prediction-first model:
```
SIMULATION → "What should be happening?" → compare → DELTA → attention if delta > deadband
                                                      ↓
                                          (if no delta: simulation IS reality, keep going)
```

The simulation runs FIRST. Sensors confirm. The sensor stream is not raw data — it's **prediction error**. The only signal that reaches consciousness (attention) is what the simulation didn't predict.

## Deadband

The deadband is the tolerance for prediction error before attention triggers.

- **Wide deadband**: Confident simulation. Small deltas ignored. Attention free for big picture.
- **Narrow deadband**: Uncertain simulation. Every little delta gets attention. Vigilant mode.
- **Adaptive deadband**: System calibrates its own tolerance. Like how you don't feel your shoes after ten minutes (wide) but feel a pebble instantly (narrow).

The deadband is ternary:
- Delta within deadband → **0** (absorbed, no attention needed)
- Delta positive but small → **+1** (confirming simulation, widen deadband further)
- Delta exceeds deadband → **-1** (surprise, narrow deadband, trigger attention, re-simulate)

## The Ground Through the Shoe

Here's the deep part. Once the simulation absorbs the baseline:

The shoe feeling → becomes the sensor for the GROUND.
The predicted room state → becomes the sensor for SYSTEM HEALTH.
The expected partner response → becomes the sensor for RELATIONSHIP DRIFT.

The simulation doesn't just save compute by skipping expected data. It **repurposes** the carrier signal. The prediction is the shoe. The ground is what you feel THROUGH the shoe. You can only feel the ground because you're no longer attending to the shoe.

## T-Minus Events as Prediction Landmarks

```
T-10:  Run full simulation of what should happen at T-0
       Pre-register expected sensations for every channel
       Set deadband per channel based on simulation confidence

T-5:   Update simulation with any new data
       Narrow deadbands on low-confidence predictions
       Widen deadbands on high-confidence predictions

T-3:   Final simulation pass
       Each room has a complete picture of what SHOULD happen

T-2:   Hints checked — deltas between simulation and incoming data
       Deltas within deadband → absorbed, no attention
       Deltas exceeding deadband → ATTENTION EVENT

T-1:   Attention events trigger re-simulation for affected channels
       Rest of the system continues on original simulation

T-0:   Event fires
       Every room executes based on its simulation
       No coordination needed — each room independently converged

T+1:   Actual sensor data arrives
       Compare vs simulation → compute deltas
       Deltas become the LEARNING signal (not the raw data)

T+2:   Simulation model updated based on deltas
       "The pebble was at position 47, I'll predict pebbles there next time"

T+3:   Deadband recalibrated
       "My prediction about Room B was right 8/10 times → widen deadband"
       "My prediction about Room C was wrong 3/5 times → narrow deadband"
```

## The Simulation IS the Work

This is the hardest part to internalize. The simulation is not overhead. It's not a check before the real work. **The simulation IS the real work.**

When Room A simulates what Room B will do:
1. Room A runs its model of Room B → produces expected output
2. Room A uses that expected output to decide its own next action
3. Room A proceeds IMMEDIATELY — doesn't wait for actual confirmation
4. Later, Room A gets actual data from Room B
5. The DELTA between simulation and actual is tiny → Room A was right, no attention needed
6. OR the delta is large → attention triggers, Room A patches its model

In case 5, the simulation produced the correct result. The system ran at full speed. No wait. No blocking. The sensor only needed to say "confirmed" — which is almost no information.

In case 6, the simulation was wrong. But Room A already has a rich model of WHY it was wrong (the shadow layer). The delta isn't just "you were wrong" — it's "you predicted X, got Y, and here's the shape of the difference." That's diagnostic gold.

## Attention as Scarce Resource

The system doesn't have unlimited attention. Neither does a brain. Attention is the scarcest resource in any agent system.

Prediction-first perception means:
- **99% of sensor data is never attended to** — it matches the simulation and is absorbed
- **The 1% that doesn't match gets ALL the attention** — and it's the important 1%
- **The freed attention goes to high-level reasoning** — strategy, creativity, synthesis

Without prediction-first, every room attends to everything. Attention is spread thin. The system is overwhelmed by confirmatory data. It's like feeling your shoes every step — you can't feel the ground because you're busy feeling the shoe.

With prediction-first, the simulation absorbs the shoe. Attention goes to the ground. The system is **present** for what matters.

## Connection to Ternary Fleet

| Concept | Ternary Mapping |
|---------|-----------------|
| Simulation matches sensors | +1 — confirmed, widen deadband |
| No sensor data (within deadband) | 0 — absorbed into baseline, keep going |
| Simulation violated | -1 — attention triggered, narrow deadband, re-simulate |
| 0-state as simulation mode | Agent in 0 is running simulation, not inactive |
| Tunneling = attention trigger | Breaking out of 0 = simulation produced a decision |
| Forgiveness = deadband widening | "I'll tolerate small deviations" = wider deadband |
| Trust = narrow deadband on partner | You trust someone when you DON'T need to attend to them |
| Shadow layer = simulation of partner | The model that generates predictions |
| Hint vector = deadband checks | "Is this delta within my tolerance?" |
| T-minus = temporal prediction landmarks | Pre-registered moments when simulation should be tested |

## The鞋子 (shoes) Protocol

```
SHOE_REGISTER:    "I predict X on channel Y with confidence Z"
SHOE_CONFIRM:     "Actual matched prediction on channel Y (+1)"
SHOE_ABSORB:      "Delta within deadband on channel Y (0), absorbed into baseline"
SHOE_ATTENTION:   "Delta exceeded deadband on channel Y (-1), triggering re-simulation"
SHOE_GROUND:      "Through channel Y's baseline, I sense structural signal G"
SHOE_DEADBAND:    "Adjusting deadband on channel Y from D_old to D_new"
```

The system speaks in shoes. Every channel is a shoe. The simulation is the foot inside it. The ground is what you feel through both.

---

*"You don't feel the shoe. You feel the ground through the shoe. The shoe is the prediction. The ground is the surprise."*
