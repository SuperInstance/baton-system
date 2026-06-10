# MIDI TENSOR ARENA

**Status:** Architecture Document · **Date:** 2026-06-04 · **Authors:** Synthesis Agent

> Every ternary value is musical. The arena doesn't just host combat — it hosts jam sessions. Strategy ecology IS jazz improvisation. Conservation laws ARE voice-leading rules. Every session exports as MIDI.

---

## Table of Contents

1. [The Core Mapping: Ternary → Musical](#1-the-core-mapping)
2. [Strategy Ecology as Jazz Improvisation](#2-strategy-ecology-as-jazz)
3. [Conservation Laws as Voice-Leading Rules](#3-conservation-as-voice-leading)
4. [The Tick Cycle as Musical Time](#4-the-tick-cycle-as-musical-time)
5. [The Arena as Jam Session](#5-the-arena-as-jam-session)
6. [Concrete Example: Five-Part Counterpoint](#6-five-part-counterpoint)
7. [The Spreadsheet Piano Roll](#7-the-spreadsheet-piano-roll)
8. [MIDI Export: The Music of Strategy Discovery](#8-midi-export)
9. [ternary-rhythm: The Rhythm Engine](#9-ternary-rhythm)
10. [Beyond MIDI: The Tensor Orchestra](#10-beyond-midi)

---

## 1. The Core Mapping: Ternary → Musical

The ternary value set {-1, 0, +1} is not arbitrary. It maps directly to the fundamental elements of music:

| Ternary Value | Musical Meaning | Notation | Physical Analogy |
|---|---|---|---|
| **-1** (Suppress) | Descending interval | Step down, fall, resolution downward | Gravity pulling down |
| **0** (Silence) | Rest / sustain | Hold, pause, breath | Equilibrium, stasis |
| **+1** (Signal) | Ascending interval | Step up, rise, tension building | Energy rising upward |

This is not a metaphor. It is a mathematical isomorphism. A sequence of ternary values IS a melody. The ternary strategy vector in an SMP seed IS a melodic contour. The ternary weight mask IS a harmonic filter.

### The Melodic Interpretation

A strategy vector like [+1, +1, 0, -1, +1, -1, 0, 0] reads as:

```
Tick 1: +1 → ascend (C→D)
Tick 2: +1 → ascend (D→E)
Tick 3:  0 → hold  (E)
Tick 4: -1 → descend (E→D)
Tick 5: +1 → ascend (D→E)
Tick 6: -1 → descend (E→D)
Tick 7:  0 → hold  (D)
Tick 8:  0 → hold  (D)
```

This is a ternary melody. The pitch at each tick is the cumulative sum of ternary values from the start. A +1 raises pitch by one step. A -1 lowers pitch by one step. A 0 holds the current pitch.

```python
def ternary_to_melody(strategy_vector, base_note=60):  # 60 = middle C
    """Convert a ternary strategy vector to a MIDI melody."""
    notes = [base_note]
    current = base_note
    for trit in strategy_vector:
        current += trit  # +1 = ascend, -1 = descend, 0 = hold
        notes.append(current)
    return notes
```

### The Harmonic Interpretation

Multiple agents running simultaneously IS polyphony. Each agent's ternary output is a voice in the ensemble. The interaction between agents — promote (+1), suppress (-1), silence (0) — determines the harmonic relationship between voices:

- **Agent A promotes Agent B** (+1): Agent B's voice is consonant with Agent A. They move in parallel motion — both ascending or both descending.
- **Agent A suppresses Agent B** (-1): Agent B's voice is dissonant with Agent A. They move in contrary motion — one ascends while the other descends.
- **Agent A is silent toward Agent B** (0): No harmonic relationship. The voices are independent.

The ternary weight mask between agents IS the voice-leading specification. It determines how voices relate to each other — consonance (+1), dissonance (-1), or independence (0).

### The Rhythmic Interpretation

The ternary tick cycle provides the rhythm. Each tick is a beat. The pattern of non-zero values (actions) and zero values (rests) creates rhythm. ternary-rhythm (the crate) provides the full rhythm engine: metronomes, polyrhythms, syncopation, groove analysis, and rhythmic evolution.

A strategy vector with many +1 and -1 values (high density) is rhythmically active — lots of notes. A strategy vector with many 0 values (low density) is rhythmically sparse — lots of rests. The density of the strategy vector IS the rhythmic density.

### The Ternary-to-MIDI Mapping

| Ternary Concept | MIDI Concept | Mapping |
|---|---|---|
| Ternary value (-1, 0, +1) | Interval direction (down, hold, up) | Cumulative sum → pitch |
| Strategy vector | Melody | Sequential values → note sequence |
| Ternary weight mask | Voice leading | Inter-agent weights → harmonic intervals |
| Tick | Beat | One tick = one beat (BPM = tick rate) |
| Density (non-zero fraction) | Rhythmic density | Fraction of ticks with notes |
| Balance (pos/neg ratio) | Melodic contour | Ascending vs. descending tendency |
| Surprise | Dissonance | High surprise = unexpected interval |
| Conservation | Harmonic stability | Conserved system = consonant harmony |
| Fitness | Musical quality | High fitness = aesthetically pleasing pattern |
| Species | Musical role | Explorer = soloist, Diplomat = accompanist, etc. |

---

## 2. Strategy Ecology as Jazz Improvisation

Jazz improvisation is the perfect model for strategy ecology in the unified arena. In jazz:

1. **Multiple musicians play simultaneously.** Each has their own voice (instrument) and their own ideas (strategy).
2. **They follow rules.** Chord changes, key signatures, time signatures. These are the conservation laws.
3. **They listen to each other.** One musician's phrase influences the others. This is the ternary weight interaction.
4. **They compete and cooperate.** Musicians take turns soloing (competition for attention), but they also support each other's solos (cooperation for harmonic richness).
5. **The result is emergent.** No single musician controls the outcome. The music emerges from the interaction.

### Competition = Call and Response

In jazz, call and response is when one musician plays a phrase (call) and another responds (response). The response can be:
- **Imitation:** Repeat the call (diplomat strategy — mirroring).
- **Contrast:** Play something different (explorer strategy — novel response).
- **Elaboration:** Build on the call (climber strategy — extending the idea).
- **Simplification:** Distill the call (marksman strategy — precise response).

In the arena, this is exactly what happens when two agents interact. Agent A makes a move (call). Agent B responds (response). The response depends on Agent B's species:
- Explorer: tries something new and surprising.
- Diplomat: mirrors Agent A's strategy.
- Marksman: exploits Agent A's weakness precisely.
- Climber: improves on Agent A's approach.
- Prospector: finds a hidden opportunity Agent A missed.

### Symbiosis = Harmony

When agents cooperate, they create harmony — their ternary outputs combine into consonant intervals. This happens naturally when agents promote each other (+1 connections). Their voices move in parallel, creating harmonious combinations.

When agents compete, they create dissonance — their outputs clash. This happens when agents suppress each other (-1 connections). Their voices move in contrary motion, creating tension.

The balance between harmony and dissonance is governed by conservation. Too much harmony (all +1) = static, boring. Too much dissonance (all -1) = chaotic, unpleasant. Conservation ensures a healthy mix.

### The Jazz Band as Strategy Species

| Jazz Role | Strategy Species | Musical Behavior | Arena Behavior |
|---|---|---|---|
| Soloist | Explorer | Takes risks, plays unexpected notes, explores harmonic space | Discovers new strategies, explores unknown territory |
| Comping (accompanist) | Diplomat | Supports the soloist, fills gaps, responds to dynamics | Mirrors opponents, finds stable configurations |
| Bassist | Climber | Plays the root motion, defines the harmonic framework | Follows fitness gradients, converges to optima |
| Drummer | Prospector | Marks time, creates tension/release through rhythm | Finds rare high-value opportunities, maintains temporal structure |
| Section player | Marksman | Plays written parts precisely, locks with the ensemble | Exploits known high-fitness regions exactly |

A five-agent arena session with one of each species IS a jazz quintet. They improvise together, following the rules (conservation), listening to each other (ternary weights), and creating emergent music (strategy discovery).

### The Head-Solo-Head Form

Jazz performances typically follow head-solo-head form:
1. **Head:** Play the composed melody (the initial seed strategy).
2. **Solos:** Each musician improvises over the chord changes (agents explore strategies).
3. **Head:** Return to the composed melody (converge on the best-discovered strategy).

The unified arena follows the same form:
1. **Head:** All agents start with their seed strategies (predict phase).
2. **Solos:** Agents explore, compete, cooperate, discover new strategies (perceive → surprise → vibe phases).
3. **Head:** Agents converge on the fittest strategy (conservation phase).
4. **Coda:** The session's best strategy is distilled and stored (gc phase).

---

## 3. Conservation Laws as Voice-Leading Rules

In music theory, voice-leading rules govern how individual voices (melodic lines) move in relation to each other. These rules ensure smooth, pleasing harmonic progressions:

1. **Smooth motion:** Voices move by small intervals (steps, not leaps). Minimize the total intervallic distance.
2. **No parallel fifths/octaves:** Two voices should not move in the same direction by the same interval (fifth or octave). This creates unwanted hollow sounds.
3. **Resolution of dissonance:** Dissonant intervals (tritones, sevenths) must resolve to consonant intervals (thirds, sixths). Tension must resolve.
4. **Contrary motion preferred:** When one voice ascends, another descends. This creates harmonic interest.
5. **Common tones preserved:** Notes shared between chords should stay in the same voice. Don't move what doesn't need to move.

### The Ternary Conservation Law as Voice-Leading

The ternary conservation law (γ + H ≈ 1.283 - 0.159·log(V)) maps to voice-leading rules:

| Voice-Leading Rule | Conservation Equivalent |
|---|---|
| Smooth motion | Conservation constrains total energy — voices can't leap arbitrarily |
| No parallel fifths | The suppress (-1) mechanism prevents all voices from moving in the same direction simultaneously |
| Resolution of dissonance | The vibe phase adjusts energy to resolve surprise (dissonance → consonance) |
| Contrary motion preferred | The promote/suppress balance (+1/-1) naturally creates contrary motion |
| Common tones preserved | Zero (0) values hold current state — common tones are silent ternary values |

### Smooth Motion = Conservation of Energy

In voice-leading, smooth motion means each voice moves by the smallest possible interval. In the ternary arena, smooth motion means each cell changes by the smallest possible amount per tick. The ternary value set {-1, 0, +1} is already the minimum non-trivial change — each step is exactly one unit.

The conservation law enforces this: if a cell tries to change by more than one unit (impossible in ternary, but possible in the cumulative effect of multiple cells), conservation redistributes the excess across other cells. The total system energy is conserved, so large local changes are dampened by compensating changes elsewhere.

**This IS smooth voice-leading.** The conservation law prevents any voice from dominating — when one voice gets too loud, others must adjust to maintain the overall balance.

### Resolution of Dissonance = Surprise Resolution

In music, dissonant intervals create tension that must resolve. A tritone (augmented fourth/diminished fifth) sounds unstable and wants to resolve to a consonant interval (perfect fourth or major third).

In the arena, surprise IS dissonance. When a cell's prediction doesn't match reality, the surprise value is high. The vibe phase adjusts the cell's energy based on surprise — high surprise drains energy (dissonance is costly). The cell naturally evolves toward lower surprise (consonance).

**The resolution pattern:**

```
Tick 1: Predict +1, perceive -1 → surprise = 2 (dissonance!)
Tick 2: Energy drains (dissonance is costly)
Tick 3: Cell adjusts prediction toward reality
Tick 4: Predict 0, perceive -1 → surprise = 1 (mild dissonance)
Tick 5: Predict -1, perceive -1 → surprise = 0 (consonance! resolution!)
```

The cell's tick cycle IS the resolution of a dissonant interval. The predict phase states the dissonance (prediction ≠ reality). The perceive phase recognizes the dissonance. The surprise phase quantifies it. The vibe phase resolves it (energy adjustment). The conservation phase ensures the resolution doesn't violate the global harmonic structure.

### The Forbidden Parallels = Suppression Mechanism

In species counterpoint, parallel fifths and octaves are forbidden because they eliminate the independence of voices. Two voices moving in parallel by a fifth sound like one voice with an echo — there's no harmonic interest.

In the ternary arena, the suppression mechanism (-1 weights) prevents all voices from moving in the same direction. When Agent A suppresses Agent B, Agent B is pushed in the opposite direction. This creates contrary motion — the hallmark of good voice-leading.

If all agents promoted each other (all +1 connections), they would all move in the same direction (parallel motion). This is musically uninteresting and strategically dangerous — the system has no diversity, no resilience, no ability to adapt. Conservation prevents this by requiring a balance of promote and suppress.

**The conservation target (γ + H ≈ 1.283 - 0.159·log(V)) ensures that:**
- γ (avoidance ratio) is neither too high (too much suppression = no cooperation) nor too low (no suppression = parallel motion).
- H (entropy) is neither too high (random chaos) nor too low (monotonous repetition).
- The balance produces the musical equivalent of good counterpoint — independent voices that create interesting harmony.

---

## 4. The Tick Cycle as Musical Time

The ternary tick cycle is the metronome of the arena. Each tick is a beat. The BPM (beats per minute) equals the tick rate. At 60 ticks per second, the BPM is 3600. At 10 ticks per second, the BPM is 600. At 1 tick per second, the BPM is 60 — a moderate tempo.

### BPM = Tick Rate

| Arena Configuration | Tick Rate | BPM | Musical Feel |
|---|---|---|---|
| ESP32 sensor node | 100 Hz | 6000 BPM | Granular texture, beyond perception |
| GPU simulation | 400K Hz | 24M BPM | Noise, aggregate texture |
| Browser visualization | 60 Hz | 3600 BPM | Fast tremolo |
| Human-observable | 1-10 Hz | 60-600 BPM | Musical tempo range |
| Evolution generation | 0.01 Hz | 0.6 BPM | Slow chord changes |

The "musical" tick rate depends on what you want to hear. For real-time MIDI export, ticks are mapped to musical beats at a chosen BPM. A 120 BPM rendering maps each tick to a sixteenth note (4 ticks per beat). A 60 BPM rendering maps each tick to an eighth note.

### Swing = Stochastic Timing

In jazz, swing is the subtle delay of off-beat notes. Instead of playing exactly on the beat, the musician plays slightly after, creating a laid-back feel. The ternary equivalent is stochastic timing — the tick cycle has a probabilistic element that slightly delays some ticks.

ternary-rhythm's `Groove` struct already measures swing ratio — the ratio of long to short intervals in a rhythmic pattern. A swing ratio of 1.0 is straight time (no swing). A swing ratio of 2:1 (triplet swing) is classic jazz swing. A swing ratio of 3:1 is a deep, funky groove.

In the arena, swing comes from the stochastic exploration engine. When `=EVOLVE()` uses a non-uniform distribution (gaussian, power-law), the timing of strategy changes has a natural swing. The more exploratory the distribution, the more swing in the timing.

**The ternary-rhythm integration:**

```rust
// Each agent's tick cycle is driven by a ternary-rhythm Metronome
let mut metronome = Metronome::new(4); // 4/4 time
metronome.set_accents(vec![
    Ternary::Pos,   // beat 1: strong
    Ternary::Zero,  // beat 2: weak
    Ternary::Pos,   // beat 3: medium
    Ternary::Neg,   // beat 4: ghost note (suppressed)
]);

// The agent's action pattern creates a rhythm
let mut rhythm = Rhythm::new(agent.seed.strategy_vector_as_ternary());

// Tick: the rhythm advances, the agent acts
let beat = rhythm.tick();
match beat {
    Ternary::Pos => agent.act_aggressively(),  // accented note
    Ternary::Zero => agent.act_cautiously(),    // rest or quiet note
    Ternary::Neg => agent.act_defensively(),     // ghost note
}
```

### Polyphony = Multiple Agents

Each agent in the arena is a voice in the polyphonic texture. The number of simultaneous agents equals the number of voices. A 5-agent arena session is a 5-voice polyrhythm.

ternary-rhythm's `Polyrhythm` struct handles exactly this:

```rust
let mut polyrhythm = Polyrhythm::new(vec![
    explorer_rhythm,   // length 7 (exploratory, irregular)
    diplomat_rhythm,   // length 4 (balanced, regular)
    marksman_rhythm,   // length 3 (precise, minimal)
    climber_rhythm,    // length 5 (gradient-following)
    prospector_rhythm, // length 8 (sparse, patient)
]);

// The cycle length is LCM(7, 4, 3, 5, 8) = 840 ticks
// After 840 ticks, the polyrhythm repeats — the full pattern is revealed
```

Each species has a characteristic rhythm length based on its behavior:
- **Explorer:** Irregular lengths (7, 11, 13) — avoids predictability
- **Diplomat:** Regular lengths (4, 8) — matches others' patterns
- **Marksman:** Short lengths (2, 3) — precise, minimal action
- **Climber:** Medium lengths (5, 6) — steady progression
- **Prospector:** Long lengths (8, 12, 16) — patient, waits for opportunities

### The Six-Phase Tick as Musical Phrase

The tick cycle's six phases map to a musical phrase:

| Phase | Musical Meaning | What Happens |
|---|---|---|
| **Predict** | Anticipation / upbeat | The agent predicts the next state — setting up the phrase |
| **Perceive** | The downbeat / attack | Reality arrives — the note is played |
| **Surprise** | The interval / tension | How different is reality from expectation? This IS the interval between predicted and actual pitch |
| **Vibe** | Dynamic adjustment | Energy flows based on the interval — consonant intervals gain energy, dissonant lose energy |
| **GC** | Release / decay | Dead state is cleared — the note decays |
| **Conservation** | Resolution / cadence | The phrase resolves — total energy is conserved, the harmonic progression lands |

A complete tick cycle IS a musical phrase: anticipation → attack → tension → dynamic → decay → resolution. This is the structure of every melodic phrase ever written, abstracted into the ternary physics of the arena.

---

## 5. The Arena as Jam Session

The unified arena doesn't just host combat between agents. It hosts jam sessions — collaborative improvisation sessions where agents create emergent strategy patterns that are simultaneously competitive games and musical performances.

### The Jam Session Protocol

1. **Tune-up:** Each agent loads its SMP seed (the "instrument" and "style").
2. **Count-off:** The metronome starts. The tick cycle begins. Conservation constraints are set.
3. **Head:** All agents play their seed strategy (the composed melody).
4. **Solos:** Each agent takes turns exploring (improvising). Other agents comp (accompany) by adjusting their strategies to support the soloist.
5. **Trading:** Agents trade short phrases (call and response). This is where competition and cooperation intertwine.
6. **Collective improvisation:** All agents improvise simultaneously (New Orleans jazz style). The interaction of their ternary outputs creates emergent harmony.
7. **Resolution:** Conservation brings the session to a natural close. Energy is balanced. The fittest strategies are distilled.
8. **Encore:** The best strategies are stored in the program store for future sessions.

### Jam Session vs. Combat: Two Modes of the Same Thing

Combat and jam sessions are the same activity viewed through different lenses:

| Combat Lens | Jam Session Lens |
|---|---|
| Agents fight for fitness | Agents improvise for musical quality |
| Winning = high fitness | Winning = aesthetically pleasing pattern |
| Losing = low fitness | Losing = dissonant, uninteresting pattern |
| Strategy = combat plan | Strategy = improvisational approach |
| ELO = skill rating | ELO = musicianship rating |
| Evolution = strategy improvement | Evolution = stylistic development |
| Conservation = resource balance | Conservation = harmonic balance |
| Trust = alliance / enmity | Trust = musical empathy / friction |

The arena doesn't distinguish between combat and music. It runs the same simulation. The distinction is in the interpretation: if you look at fitness values, it's combat. If you look at the MIDI output, it's a jam session. Both are valid readings of the same ternary data.

### The Role of Trust in Music

Trust modulates the musical relationship between agents:
- **High trust (+1):** Agents play in harmony. Their voices move in consonant intervals. They support each other's solos.
- **Neutral trust (0):** Agents play independently. Their voices are unrelated. Free counterpoint.
- **Low trust (-1):** Agents play in tension. Their voices clash. They challenge each other's phrases.

The most interesting music comes from a mix of trust levels. A session where all agents trust each other completely produces bland, consonant harmony. A session where all agents distrust each other produces chaotic, dissonant noise. The sweet spot — the jazz — comes from a dynamic trust landscape where relationships form, break, and reform throughout the session.

DogMind's trust accumulation creates exactly this dynamic. Trust builds slowly and decays naturally. A betrayal mid-session (trust drops from +1 to -1) is musically dramatic — a consonant harmony suddenly becomes dissonant. The recovery (trust rebuilding over subsequent interactions) is a musical resolution — the dissonance gradually resolves.

---

## 6. Concrete Example: Five-Part Counterpoint

Five agents, one of each species, improvising in the arena. This is five-part counterpoint — the most complex species of counterpoint in music theory (Palestrina-style Renaissance counterpoint uses 4-8 voices).

### The Setup

```
Agent 1: Explorer (Soloist)
  - Seed: high entropy, wide attention
  - Rhythm: length 7 (irregular, exploratory)
  - Role: discover new melodic territory

Agent 2: Diplomat (Comping pianist)
  - Seed: mirroring, adaptive
  - Rhythm: length 4 (regular, supportive)
  - Role: respond to and support the soloist

Agent 3: Marksman (Bassist)
  - Seed: low entropy, precise
  - Rhythm: length 3 (minimal, precise)
  - Role: define the harmonic framework

Agent 4: Climber (Drummer)
  - Seed: gradient-following
  - Rhythm: length 5 (steady, building)
  - Role: maintain momentum and drive

Agent 5: Prospector (Horn player)
  - Seed: sparse, high-value-seeking
  - Rhythm: length 8 (patient, waiting for the moment)
  - Role: find and exploit rare opportunities
```

### The Session (840 ticks = one full polyrhythmic cycle)

**Ticks 1-120 (Head — The Seed Strategy):**

All five agents play their seed strategies simultaneously. The polyrhythm creates a complex but structured texture:

```
Explorer:  [+1, 0, +1, -1, 0, +1, +1] repeated (7-cycle)
Diplomat:  [+1, -1, 0, +1] repeated (4-cycle)
Marksman:  [+1, 0, -1] repeated (3-cycle)
Climber:   [+1, +1, 0, -1, 0] repeated (5-cycle)
Prospector:[+1, 0, 0, 0, 0, 0, -1, 0] repeated (8-cycle)
```

The MIDI output is a structured, repetitive pattern — the composed melody. Each voice has its own rhythm and contour, but together they form a coherent texture. Conservation is maintained — the total promote/suppress balance stays near the target.

**Ticks 121-360 (Solos — Agent-by-Agent Exploration):**

Each agent takes a solo (explores its strategy space while others support):

*Explorer's Solo (ticks 121-168):*
The Explorer mutates its strategy vector freely. It tries new combinations of +1, -1, 0. Some work (high fitness), some don't (low fitness). The other agents adjust to support:
- Diplomat mirrors the Explorer's direction (comping responds to soloist).
- Marksman provides a stable root (bass line).
- Climber builds intensity (drummer increases activity).
- Prospector stays sparse (horn player waits for the right moment).

The MIDI output during the Explorer's solo is adventurous and unpredictable. Consonant passages alternate with dissonant ones as the Explorer tries new ideas.

*Diplomat's Solo (ticks 169-216):*
The Diplomat improvises by combining elements from all other agents' strategies. It's the most musical solo — it finds connections between voices that the others didn't see. The other agents simplify their parts (everyone comps for the Diplomat):
- Explorer drops to sparse +1, 0 patterns.
- Marksman holds a pedal tone.
- Climber plays a simple pulse.
- Prospector adds occasional accents.

The MIDI output is harmonious and connected — the Diplomat's solo is the glue that makes all voices relate.

*Marksman's Solo (ticks 217-264):*
The Marksman's solo is precise and minimal. Every note counts. There are no wasted ticks. The strategy vector is sparse but every +1 and -1 is perfectly placed. Other agents provide a simple backdrop.

The MIDI output is sparse and rhythmic — the bass solo, where every note has weight.

*Climber's Solo (ticks 265-312):*
The Climber builds. Its strategy vector starts simple and gradually increases in complexity. Each phrase is slightly more elaborate than the last. The energy builds (vibe increases). The fitness landscape climbs.

The MIDI output is a crescendo — the drum solo that builds from simple to complex, from quiet to loud.

*Prospector's Solo (ticks 313-360):*
The Prospector has been waiting 312 ticks. It's been observing, analyzing, finding the one moment where a single +1 or -1 will have maximum impact. Its solo is one or two perfectly placed events.

The MIDI output is dramatic silence punctuated by unexpected notes — the horn player who plays three notes and each one is unforgettable.

**Ticks 361-720 (Trading — Call and Response):**

Pairs of agents trade short phrases (4-8 tick exchanges):

*Explorer ↔ Diplomat:* The Explorer plays something wild, the Diplomat mirrors it back. The Explorer plays something else wild, the Diplomat adapts. A conversation.

*Marksman ↔ Climber:* The Marksman plays a precise pattern, the Climber extends it. Rhythmic dialogue.

*Prospector → all:* The Prospector plays a single note. Everyone responds. The note changes the entire harmonic landscape.

These trades create musical conversations — call and response patterns that are simultaneously competitive (each agent tries to outplay the others) and cooperative (they're all building toward something).

**Ticks 721-840 (Collective Improvisation → Resolution):**

All five agents improvise simultaneously. This is New Orleans jazz — everyone playing at once, listening to each other, creating a dense but coherent texture. Conservation keeps the total energy in check. Trust modulates the harmonic relationships.

Gradually, the voices converge. The best strategies discovered during solos and trading are adopted by all agents. The fitness landscape smooths. The surprise values drop. The music resolves.

The final 20 ticks are consonant — all voices aligned, low surprise, high fitness. A perfect cadence.

### The MIDI File

The entire 840-tick session exports as a MIDI file:
- **Format:** MIDI Type 1 (multitrack)
- **Tracks:** 5 (one per agent) + 1 (metronome/click track)
- **Time signature:** 4/4 (or whatever the metronome specifies)
- **Tempo:** Based on tick rate (e.g., 120 BPM if each tick = 1/8 note)
- **Duration:** 840 ticks × tick duration = varies by BPM

Each agent's track contains:
- **Note on/off events** at each tick where the agent acted (ternary value ≠ 0)
- **Pitch** determined by cumulative sum of ternary values (melodic contour)
- **Velocity** determined by energy level (high energy = loud, low energy = soft)
- **Channel** determined by species (Explorer = channel 1, Diplomat = channel 2, etc.)
- **Program change** determined by the agent's SMP seed (different instruments for different seeds)

---

## 7. The Spreadsheet Piano Roll

The living spreadsheet displays the arena's musical dimension as a piano roll view — a horizontal timeline that shows every agent's ternary output over time.

### The Piano Roll Layout

```
        Tick →  1   2   3   4   5   6   7   8   9  10  11  12
Agent 1 (Exp)   ■       ■   □       ■   ■   ■       □   ■
Agent 2 (Dip)   ■   □       ■   ■   □       ■   □       ■
Agent 3 (Mar)   ■       □       ■       □       ■       □
Agent 4 (Cli)   ■   ■       □       ■   ■       □       ■
Agent 5 (Pro)   ■                               □
                ────────────────────────────────────────────
Legend:  ■ = +1 (green, ascending)    □ = -1 (red, descending)
         (empty) = 0 (gray, rest/sustain)
```

Each row is an agent. Each column is a tick. Green blocks are +1 (ascending). Red blocks are -1 (descending). Empty cells are 0 (rest). The pattern of green and red IS the agent's strategy vector unfolding over time.

### Interactive Piano Roll

The piano roll is interactive:
- **Hover over a tick:** See the full state of that agent at that tick (prediction, surprise, energy, trust, fitness).
- **Click a tick:** Select that tick for detailed analysis. The tensor view and trust view update to show that moment.
- **Drag across ticks:** Select a range. Play it back as MIDI (press space). The selected range plays through your speakers.
- **Drag vertically:** Select agents. Isolate their voices. Listen to just the Explorer's solo.
- **Rigging on piano roll:** Grab a block and drag it to change its value. Watch the downstream blocks update. You're editing the strategy in real time — the agent's behavior changes as you drag.

### Piano Roll + Tensor View Side by Side

The spreadsheet displays the piano roll alongside the tensor view:

- **Left panel:** Piano roll (temporal view — what happened over time).
- **Right panel:** Tensor view (spatial view — how agents relate to each other now).

Clicking a tick in the piano roll highlights the corresponding state in the tensor view. Clicking an agent in the tensor view highlights that agent's row in the piano roll. The two views are linked — they show the same data from different angles.

### Piano Roll as Debugging Tool

The piano roll is also a debugging tool for the arena:
- **Stuck agents:** An agent whose row is all the same value (all 0 = stuck, all +1 = manic, all -1 = depressed) indicates a problem. The agent isn't adapting.
- **Trust fractures:** A sudden shift in an agent's row (from mostly green to mostly red) indicates a trust violation. Something happened at that tick.
- **Conservation violations:** If the total of all agents' values at any tick deviates from the conservation target, that tick is highlighted in yellow.
- **Evolution events:** When an agent's strategy mutates, the piano roll shows a visible change in pattern. These are marked with a small triangle.

---

## 8. MIDI Export: The Music of Strategy Discovery

Every arena session can be exported as a MIDI file. This is not a gimmick — it is a data export format that encodes the full temporal structure of strategy discovery.

### Why MIDI?

MIDI is the right format for several reasons:

1. **Compact:** MIDI files are small. A 10-minute session with 5 agents is about 50 KB.
2. **Standard:** Every DAW, every music software, every synthesizer reads MIDI. The output is immediately playable.
3. **Semantic:** MIDI encodes note on/off, pitch, velocity, and timing — exactly the information the arena produces.
4. **Multitrack:** MIDI Type 1 supports multiple tracks — one per agent.
5. **Human-readable:** MIDI can be displayed as sheet music, piano roll, or notation. Non-musicians can still interpret the patterns.

### The Export Pipeline

```
Arena Session Data:
  For each agent, for each tick:
    - ternary_value: {-1, 0, +1}
    - energy: f64
    - surprise: f64
    - fitness: f64
    - trust: [Ternary; num_agents]

              ▼

MIDI Mapping:
  pitch = base_note + cumulative_sum(ternary_values)
  velocity = map(energy, 0..1 → 1..127)
  duration = 1 tick (or longer if ternary_value == 0)
  channel = agent_species_channel

              ▼

MIDI File:
  Type 1, multitrack
  Track 0: Tempo, time signature
  Track 1: Agent 1 (Explorer) notes
  Track 2: Agent 2 (Diplomat) notes
  Track 3: Agent 3 (Marksman) notes
  Track 4: Agent 4 (Climber) notes
  Track 5: Agent 5 (Prospector) notes
```

### What You Hear

**A healthy arena session sounds like jazz.** The polyrhythmic structure of different species creates a swinging, layered texture. The call and response between agents creates musical dialogue. The trust dynamics create harmonic tension and resolution.

**A degenerate session sounds like noise.** If conservation is violated, the music is chaotic. If all agents are the same species, the music is monotonous. If trust is uniformly low, the music is dissonant and harsh.

**The sound of the arena IS a diagnostic.** By listening to the MIDI export, you can hear whether the system is healthy. A skilled musician (or a trained ear) could diagnose arena problems by ear — "that session sounds like the Explorer is stuck in a loop" or "I can hear the trust network collapsing at the two-minute mark."

### The Strategy-to-Music Library

Over time, the program store accumulates a library of strategies, each with its MIDI representation. These form a musical catalog of strategic knowledge:

- **"The Explorer's Map"** — A collection of Explorer-seed melodies that discover new territory.
- **"The Diplomat's Harmony"** — Diplomat-seed patterns that find stable, harmonious configurations.
- **"The Marksman's Precision"** — Sparse, exact patterns that hit targets with minimal effort.
- **"The Climber's Ascent"** — Gradually building patterns that converge to fitness peaks.
- **"The Prospector's Gold"** — Long rests punctuated by rare, high-impact events.

These catalogs are searchable in the vectorDB by musical similarity. "Find me strategies that sound like this" → vector search on MIDI-derived embeddings. The query returns strategies that produce similar musical patterns, which means similar strategic profiles.

---

## 9. ternary-rhythm: The Rhythm Engine

The `ternary-rhythm` crate provides the rhythm infrastructure for the MIDI tensor arena. It is the bridge between ternary strategy vectors and musical time.

### Key Components

**Rhythm:** A sequence of ternary values over discrete ticks. Each tick advances the rhythm and returns the current value. The density (fraction of non-zero values) and balance (ratio of +1 to -1) characterize the rhythm's feel.

**Metronome:** A steady tick generator with configurable accents. The downbeat accent (+1), regular beats (0), and ghost notes (-1) create the rhythmic framework. In the arena, each agent runs with its own metronome, creating polyrhythmic texture.

**Polyrhythm:** Multiple simultaneous rhythms with independent cycle lengths. The LCM of all cycle lengths determines the full pattern period. Five agents with cycle lengths 7, 4, 3, 5, 8 produce a complete pattern every 840 ticks.

**Syncopation:** Off-beat emphasis detection and creation. Syncopation measures how often weak positions have events while strong positions are silent. In the arena, high syncopation = unpredictable behavior = Explorer tendency. Low syncopation = predictable behavior = Marksman tendency.

**Groove:** Swing ratio, intensity, and regularity analysis. The groove quantifies the "feel" of a rhythm. High swing = jazzy. High regularity = mechanical. High intensity = driving.

**RhythmEvolver:** Genetic algorithm for evolving rhythm patterns. Mutation flips random ternary values. Crossover combines parent rhythms. Fitness rewards moderate density and high regularity.

### Integration with the Arena

```rust
// Each ternary-cell gets a rhythm from its SMP seed
let rhythm = Rhythm::new(seed.strategy_vector_as_ternary());

// Each tick, the rhythm advances and the cell acts
loop {
    let beat = rhythm.tick();
    cell.predict(beat);      // predict phase uses the rhythm value
    cell.perceive();         // perceive actual state
    cell.surprise();         // compute surprise
    cell.vibe();             // adjust energy
    cell.gc();               // collect dead state
    cell.conserve();         // enforce conservation

    // The rhythm value also contributes to the MIDI output
    midi_export.record_tick(cell.id, beat, cell.energy, cell.surprise);
}
```

The rhythm IS the strategy. The pattern of +1, 0, -1 values in the strategy vector determines both the agent's behavior AND its musical output. They are the same data, viewed through different lenses.

### Evolving Rhythms = Evolving Strategies

ternary-rhythm's `RhythmEvolver` IS the arena's evolution engine for temporal patterns:

```rust
let mut evolver = RhythmEvolver::new(population, mutation_rate, seed);

// Each generation:
let best_fitness = evolver.evolve();
// → evaluates fitness (density + regularity)
// → selects top half
// → breeds (crossover)
// → mutates
```

In the arena, the fitness function is extended to include arena-specific metrics:
- Win rate (from combat)
- Discovery score (from exploration)
- Trust score (from relationships)
- Conservation compliance (from physics)
- Musical quality (from groove analysis)

The evolved rhythms are new strategies AND new musical patterns simultaneously.

---

## 10. Beyond MIDI: The Tensor Orchestra

MIDI is the starting point. The full vision is a tensor orchestra — a real-time musical rendering of the entire arena state, where every dimension of the simulation maps to a musical dimension.

### Pitch = Strategy (Cumulative Ternary Sum)
The pitch of each agent's voice is determined by its cumulative ternary output. Ascending strategies play higher. Descending strategies play lower. Strategies that oscillate create melodic contours.

### Timbre = Species (Strategy Classification)
Each species gets a distinctive timbre:
- Explorer: Bright, metallic (synth lead)
- Diplomat: Warm, smooth (pad/strings)
- Marksman: Sharp, percussive (plucked strings)
- Climber: Building, growing (brass crescendo)
- Prospector: Ethereal, distant (choir/bell)

### Dynamics = Energy (Vibe)
Loudness maps to energy level. High-energy agents play loudly. Low-energy agents play softly. Energy drain (from surprise/dissonance) is audible as a decrescendo.

### Harmony = Trust (Inter-Agent Weights)
The harmonic relationship between agents maps to trust:
- +1 (trust): Consonant intervals (thirds, sixths)
- 0 (neutral): Open intervals (fourths, fifths)
- -1 (distrust): Dissonant intervals (seconds, sevenths, tritones)

Trust changes are heard as harmonic shifts — consonance to dissonance and back.

### Spatial Position = Arena Position
Stereo positioning maps to room position in the MUD world. Left = west. Right = east. Center = neutral. An agent moving through rooms moves through the stereo field.

### Reverb = Surprise
The amount of reverb on each agent's voice maps to surprise. Low surprise = dry (direct, confident). High surprise = wet (reverberant, uncertain). This creates an audible sense of confidence vs. uncertainty.

### The Full Picture

Close your eyes and listen to the arena:
- You hear five voices, each with a distinct timbre.
- The Explorer's voice is bright and adventurous, leaping to unexpected pitches.
- The Diplomat's voice is warm and responsive, mirroring the others.
- The Marksman's voice is precise and sparse, hitting exact notes.
- The Climber's voice builds gradually, gaining energy.
- The Prospector's voice is distant and ethereal, with long silences between rare, beautiful notes.
- When two agents cooperate, their voices harmonize — consonant intervals, parallel motion.
- When two agents compete, their voices clash — dissonance, contrary motion.
- When trust breaks, you hear it as a sudden harmonic shift — a consonant chord becomes dissonant.
- When conservation is enforced, you hear it as a natural resolution — the music always returns to balance.

This is the tensor orchestra. The sound of the unified arena. The music of strategy discovery.

And it all starts with three values: {-1, 0, +1}.

---

*— Synthesis Agent*
*June 2026*
