# 🦀 Hermit Crab Power Armor — Visual Identity System

> *"The crab inherits the shell. The shell becomes the armor. The armor carries the fleet."*

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [8-Color Palette](#2-8-color-palette)
3. [Typography](#3-typography)
4. [4 Key UI Components with CSS](#4-4-key-ui-components-with-css)
5. [5 Agent Archetypes — Hermit Crab Officers](#5-5-agent-archetypes--hermit-crab-officers)
6. [3 Image Generation Prompts](#6-3-image-generation-prompts)
7. [Brand Copy & Manifest](#7-brand-copy--manifest)
8. [Implementation Guide](#8-implementation-guide)
9. [Asset Inventory (existing)](#9-asset-inventory-existing)

---

## 1. Design Philosophy

### Steampunk × Cyberpunk Fusion

This is not polished sci-fi. This is **scavenged, adapted, improvised**.

The Hermit Crab Power Armor aesthetic takes the discarded shells of old systems — abandoned APIs, deprecated frameworks, legacy architectures — and turns them into **functional, beautiful power armor**. Every rivet tells a story. Every copper pipe is a data pipeline. Every glowing bioluminescent hint is a live metric.

**Core metaphors:**

| Concept | Visual Translation |
|---------|-------------------|
| Discarded shell | Legacy system, deprecated API, retired framework |
| New inhabitant | Current agent/process taking over |
| Riveted repair | Hot-patched, adapted, configured |
| Steam pressure | System load, throughput, latency |
| Bioluminescence | Live data, active metrics, health |
| Brass plate | Durable, reliable, grounded |
| Oxidized copper | Aging infrastructure, battle-worn |
| Bioluminescent green | Healthy, flowing, alive |

**Design mood:** Warm industrial. Dim cockpits of brass and copper. Glowing readouts. Steam vents. Gear teeth. Shell segmentation. Think *Dishonored* meets *Ghost in the Shell* meets a tide pool.

### Existing Asset Compatibility

This system is designed to overlay the existing fleet dashboards. The current palette (`--bg: #0d1117`, `--blue: #58a6ff`, etc.) serves as the **dark base layer** (the "void" of the shell interior). The hermit crab palette adds the **warm industrial textures** on top.

---

## 2. 8-Color Palette

```
 1  #C9A84C   ── BRASS ──     Worn guild brass. Navigation, borders, headers.
 2  #4A7C6F   ── OXIDIZED COPPER ──   Aged copper patina. Cards, backgrounds.
 3  #1A4B5C   ── DEEP TEAL ──  Shell interior, dark surfaces, containment.
 4  #8B4513   ── RUST ──       Danger, decay, warning. Accents.
 5  #3A3F47   ── SALVAGE GREY ──   Salvaged metal. Neutral surfaces, text.
 6  #00FF88   ── BIOLUMINESCENT GREEN ──  Live data, healthy metrics, active state.
 7  #E8883A   ── WARM AMBER ──  Gauge pressure, medium warning, glow.
 8  #C84B8E   ── CYBERPUNK MAGENTA ──  Oracle/void/magic signals, anomalies.
```

### Usage Map

| Role | Hex | CSS Variable |
|------|-----|-------------|
| Primary accent / navigation | `#C9A84C` | `--brass` |
| Card surfaces / backgrounds | `#4A7C6F` | `--copper` |
| Deep surface / containment | `#1A4B5C` | `--teal` |
| Danger / critical warning | `#8B4513` | `--rust` |
| Neutral / text / salvage | `#3A3F47` | `--salvage` |
| Healthy / active / live | `#00FF88` | `--bio-glow` |
| Mid warning / gauge pressure | `#E8883A` | `--amber` |
| Oracle / anomaly / magic | `#C84B8E` | `--magenta` |

### Complementary Extensions
- **Dark background:** `#0C0F15` (shell interior void — matches existing `--bg`)
- **Dark surface:** `#141A24` (matches existing `--surface`)
- **Shell edge highlight:** `#2A3A44` (transition between void and shell)
- **Brass highlight:** `#E5C86C` (for glow effects on brass)
- **Bio-glow shadow:** `rgba(0, 255, 136, 0.15)` (for metric glow)

### Background Texture System

The visual identity uses layered background textures to suggest salvaged materials:

```css
/* Brass plate texture */
background: 
  radial-gradient(circle at 20% 30%, rgba(201, 168, 76, 0.03) 0%, transparent 60%),
  radial-gradient(circle at 80% 60%, rgba(201, 168, 76, 0.02) 0%, transparent 50%),
  var(--teal);
```

---

## 3. Typography

### Type System

| Role | Font | Stack | Usage |
|------|------|-------|-------|
| **Headers / Title** | *Playfair Display* (serif) | `'Playfair Display', 'Georgia', 'Times New Roman', serif` | Dashboard titles, card headers, brand text — the steampunk gravitas |
| **Data / Code** | *JetBrains Mono* (mono) | `'JetBrains Mono', 'Fira Code', 'SF Mono', monospace` | Metrics, logs, terminal readouts, gauge values — the cyberpunk terminal vibe |
| **Body** | *Inter* (sans) | `'Inter', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', sans-serif` | Descriptions, labels, subtitles — readable, clean |

### Size Scale

```css
:root {
  --font-title:  'Playfair Display', Georgia, 'Times New Roman', serif;
  --font-mono:   'JetBrains Mono', 'Fira Code', 'SF Mono', monospace;
  --font-body:   Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  
  --text-xs:   0.625rem;   /* 10px — tiny labels */
  --text-sm:   0.75rem;    /* 12px — meta, badges */
  --text-base: 0.875rem;   /* 14px — body text */
  --text-md:   1rem;       /* 16px — cards, strong body */
  --text-lg:   1.25rem;    /* 20px — section headers */
  --text-xl:   1.5rem;     /* 24px — dashboard title */
  --text-2xl:  2rem;       /* 32px — hero/title */
  --text-3xl:  2.5rem;     /* 40px — brand headline */
}
```

### Typography Examples

```css
/* Dashboard title — steampunk serif gravitas */
.dashboard-title {
  font-family: var(--font-title);
  font-size: var(--text-xl);
  font-weight: 700;
  color: var(--brass);
  letter-spacing: 0.02em;
  text-shadow: 0 0 12px rgba(201, 168, 76, 0.3);
}

/* Metric values — cyberpunk mono terminal readout */
.metric-value {
  font-family: var(--font-mono);
  font-size: var(--text-lg);
  font-weight: 500;
  letter-spacing: 0.05em;
}

/* Body text — clean sans */
.card-description {
  font-family: var(--font-body);
  font-size: var(--text-base);
  line-height: 1.55;
  color: var(--salvage);
}
```

---

## 4. 4 Key UI Components with CSS

### 4.1 Carapace Nav

A navigation bar built from segmented crab-shell plates. Each segment is a CSS Grid cell with lifted hover states suggesting articulated shell movement.

```html
<nav class="carapace-nav">
  <div class="carapace-segment active" data-segment="fleet">
    <span class="segment-icon">d</span>
    <span class="segment-label">Fleet</span>
  </div>
  <div class="carapace-segment" data-segment="reflexes">
    <span class="segment-icon">g</span>
    <span class="segment-label">Reflexes</span>
  </div>
  <div class="carapace-segment" data-segment="oracle">
    <span class="segment-icon">D</span>
    <span class="segment-label">Oracle</span>
  </div>
  <div class="carapace-segment" data-segment="shells">
    <span class="segment-icon">X</span>
    <span class="segment-label">Shells</span>
  </div>
  <div class="carapace-segment" data-segment="cargo">
    <span class="segment-icon">O</span>
    <span class="segment-label">Cargo</span>
  </div>
</nav>
```

```css
.carapace-nav {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  gap: 2px;
  background: #0C0F15;
  border: 1px solid rgba(201, 168, 76, 0.25);
  border-radius: 12px;
  padding: 4px;
  position: relative;
  overflow: hidden;
}

.carapace-nav::before {
  content: '';
  position: absolute;
  inset: 0;
  background: 
    repeating-linear-gradient(
      90deg,
      transparent 0px, transparent 1px,
      rgba(201, 168, 76, 0.04) 1px, rgba(201, 168, 76, 0.04) 2px
    );
  pointer-events: none;
}

.carapace-segment {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 12px 8px;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
  position: relative;
  z-index: 1;
}

.carapace-segment:hover {
  background: rgba(201, 168, 76, 0.06);
  border-color: rgba(201, 168, 76, 0.3);
  transform: translateY(-3px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3), 0 0 20px rgba(201, 168, 76, 0.08);
}

.carapace-segment.active {
  background: rgba(201, 168, 76, 0.10);
  border-color: var(--brass);
  transform: translateY(-5px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.4), 0 0 30px rgba(201, 168, 76, 0.12),
    inset 0 1px 0 rgba(201, 168, 76, 0.15);
}

.carapace-segment::after {
  content: '';
  position: absolute;
  top: 4px; left: 4px; right: 4px; bottom: auto;
  height: 1px;
  background: linear-gradient(90deg,
    transparent 0%, var(--brass) 15%, var(--brass) 20%,
    transparent 25%, transparent 75%, var(--brass) 80%, var(--brass) 85%, transparent 100%);
  opacity: 0.3;
}

.carapace-segment:active { transform: translateY(0); transition-duration: 0.1s; }

.segment-icon { font-size: 20px; color: var(--brass); text-shadow: 0 0 8px rgba(201, 168, 76, 0.2); line-height: 1; }
.segment-label {
  font-family: var(--font-body); font-size: 11px; font-weight: 600;
  text-transform: uppercase; letter-spacing: 0.08em; color: var(--brass); opacity: 0.8;
}
.carapace-segment.active .segment-label { opacity: 1; }

.carapace-segment.active::before {
  content: '';
  position: absolute;
  bottom: -2px; left: 25%; right: 25%; height: 2px;
  background: var(--brass); border-radius: 2px; box-shadow: 0 0 8px var(--brass);
}
```

---

### 4.2 Gauge Status Indicator

A circular pressure-gauge widget. A steam-pressure dial with live bioluminescent fill.

```html
<div class="gauge-card">
  <div class="gauge-wrap">
    <svg class="gauge-svg" viewBox="0 0 120 120">
      <circle cx="60" cy="60" r="48" fill="none" stroke="rgba(74, 124, 111, 0.35)" stroke-width="8"/>
      <circle class="gauge-arc" cx="60" cy="60" r="48" fill="none" stroke="var(--bio-glow)"
        stroke-width="8" stroke-linecap="round" stroke-dasharray="301.6"
        stroke-dashoffset="120" transform="rotate(-90 60 60)"/>
      <line x1="60" y1="6" x2="60" y2="16" stroke="var(--brass)" stroke-width="1.5" opacity="0.4"/>
      <line x1="114" y1="60" x2="104" y2="60" stroke="var(--brass)" stroke-width="1.5" opacity="0.4"/>
      <line x1="60" y1="114" x2="60" y2="104" stroke="var(--brass)" stroke-width="1.5" opacity="0.4"/>
      <line x1="6" y1="60" x2="16" y2="60" stroke="var(--brass)" stroke-width="1.5" opacity="0.4"/>
      <circle cx="60" cy="60" r="6" fill="none" stroke="var(--brass)" stroke-width="2" opacity="0.6"/>
      <circle cx="60" cy="60" r="2" fill="var(--brass)" opacity="0.8"/>
    </svg>
    <div class="gauge-value">87<span class="gauge-unit">%</span></div>
    <div class="gauge-label">Fleet Health</div>
  </div>
</div>
```

```css
.gauge-card {
  display: inline-flex; flex-direction: column; align-items: center;
  background: var(--teal); border: 1px solid rgba(201, 168, 76, 0.2);
  border-radius: 16px; padding: 20px; position: relative; overflow: hidden;
}
.gauge-card::before {
  content: ''; position: absolute; inset: 4px;
  border: 1px dashed rgba(201, 168, 76, 0.15); border-radius: 12px; pointer-events: none;
}
.gauge-wrap { position: relative; width: 120px; height: 120px; }
.gauge-svg { width: 100%; height: 100%; }
.gauge-arc {
  transition: stroke-dashoffset 0.8s cubic-bezier(0.34, 1.56, 0.64, 1), stroke 0.5s ease;
  filter: drop-shadow(0 0 6px var(--bio-glow));
}
.gauge-wrap.green .gauge-arc { stroke: var(--bio-glow); filter: drop-shadow(0 0 8px rgba(0,255,136,0.4)); }
.gauge-wrap.yellow .gauge-arc { stroke: var(--amber); filter: drop-shadow(0 0 8px rgba(232,136,58,0.4)); }
.gauge-wrap.red .gauge-arc { stroke: var(--rust); filter: drop-shadow(0 0 8px rgba(139,69,19,0.4)); }

.gauge-value {
  position: absolute; top: 50%; left: 50%; transform: translate(-50%, -55%);
  font-family: var(--font-mono); font-size: 28px; font-weight: 600;
  color: #fff; text-shadow: 0 0 12px rgba(0, 255, 136, 0.3); line-height: 1;
}
.gauge-unit { font-family: var(--font-mono); font-size: 12px; color: var(--salvage); vertical-align: super; margin-left: 1px; }
.gauge-label {
  font-family: var(--font-body); font-size: 11px; font-weight: 600;
  text-transform: uppercase; letter-spacing: 0.1em; color: var(--brass); opacity: 0.7; margin-top: 6px;
}

.gauge-wrap::after {
  content: ''; position: absolute; top: -4px; right: -4px;
  width: 8px; height: 8px;
  background: radial-gradient(circle, rgba(201, 168, 76, 0.2), transparent);
  border-radius: 50%; animation: steam-puff 3s ease-in-out infinite;
}
@keyframes steam-puff {
  0%, 100% { opacity: 0; transform: translate(0, 0) scale(0.5); }
  50% { opacity: 0.6; transform: translate(-2px, -4px) scale(1.2); }
}
```

```javascript
function updateGauge(element, value, status) {
  const radius = 48;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (value / 100) * circumference;
  element.querySelector('.gauge-value').innerHTML = Math.round(value) + '<span class="gauge-unit">%</span>';
  element.querySelector('.gauge-arc').style.strokeDashoffset = offset;
  element.className = 'gauge-wrap ' + status;
}
```

---

### 4.3 Shell Card

Data card with riveted brass border, subtle gear-pattern background, bioluminescent accent.

```html
<div class="shell-card">
  <div class="shell-card-header">
    <span class="shell-card-icon">d</span>
    <span class="shell-card-title">Fleet Oracle</span>
    <span class="shell-badge shell-badge-active">ACTIVE</span>
  </div>
  <div class="shell-card-body">
    <div class="shell-metric-row">
      <div class="shell-metric">
        <span class="shell-metric-label">Health</span>
        <span class="shell-metric-value bio">96.2%</span>
      </div>
      <div class="shell-metric">
        <span class="shell-metric-label">Latency</span>
        <span class="shell-metric-value">12ms</span>
      </div>
      <div class="shell-metric">
        <span class="shell-metric-label">Decisions</span>
        <span class="shell-metric-value">1,284</span>
      </div>
    </div>
    <div class="shell-progress-bar">
      <div class="shell-progress-fill" style="width: 96%"></div>
    </div>
  </div>
  <div class="shell-card-footer">
    <span class="shell-timestamp">Last pulse: 14s ago</span>
    <span class="shell-ref">SEC-001</span>
  </div>
</div>
```

```css
.shell-card {
  background: var(--teal); border: 1px solid rgba(201, 168, 76, 0.25);
  border-radius: 12px; padding: 0; position: relative; overflow: hidden;
  transition: border-color 0.3s ease, box-shadow 0.3s ease;
}
.shell-card::before {
  content: ''; position: absolute; inset: 3px;
  border: 1px solid rgba(201, 168, 76, 0.12); border-radius: 9px; pointer-events: none; z-index: 1;
}
.shell-card::after {
  content: ''; position: absolute; inset: 0; opacity: 0.04;
  background-image: 
    radial-gradient(circle at 20% 30%, rgba(201, 168, 76, 0.15) 0%, transparent 50%),
    repeating-linear-gradient(45deg, transparent 0, transparent 8px, rgba(201, 168, 76, 0.03) 8px, rgba(201, 168, 76, 0.03) 9px),
    repeating-linear-gradient(-45deg, transparent 0, transparent 16px, rgba(201, 168, 76, 0.02) 16px, rgba(201, 168, 76, 0.02) 17px);
  pointer-events: none;
}
.shell-card:hover { border-color: var(--brass); box-shadow: 0 0 20px rgba(201, 168, 76, 0.08), inset 0 0 20px rgba(0, 255, 136, 0.02); }

.shell-card-header { display: flex; align-items: center; gap: 8px; padding: 14px 16px 10px; position: relative; z-index: 2; }
.shell-card-header::after {
  content: ''; position: absolute; bottom: 0; left: 16px; right: 16px; height: 1px;
  background: linear-gradient(90deg, var(--bio-glow) 0%, transparent 70%); opacity: 0.3;
}
.shell-card-icon { font-size: 18px; color: var(--brass); }
.shell-card-title { font-family: var(--font-title); font-size: 15px; font-weight: 700; color: #e8e8e8; letter-spacing: 0.01em; }

.shell-badge {
  margin-left: auto; display: inline-block; padding: 2px 10px; border-radius: 999px;
  font-family: var(--font-mono); font-size: 10px; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase;
}
.shell-badge-active { background: rgba(0, 255, 136, 0.12); color: var(--bio-glow); border: 1px solid rgba(0, 255, 136, 0.25); }
.shell-badge-warn { background: rgba(232, 136, 58, 0.12); color: var(--amber); border: 1px solid rgba(232, 136, 58, 0.25); }
.shell-badge-down { background: rgba(139, 69, 19, 0.15); color: var(--rust); border: 1px solid rgba(139, 69, 19, 0.3); }

.shell-card-body { padding: 12px 16px 16px; position: relative; z-index: 2; }
.shell-metric-row { display: flex; gap: 20px; margin-bottom: 12px; }
.shell-metric { display: flex; flex-direction: column; gap: 2px; }
.shell-metric-label { font-family: var(--font-body); font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.08em; color: var(--salvage); opacity: 0.7; }
.shell-metric-value { font-family: var(--font-mono); font-size: 18px; font-weight: 600; color: #e0e0e0; }
.shell-metric-value.bio { color: var(--bio-glow); text-shadow: 0 0 8px rgba(0, 255, 136, 0.3); }

.shell-progress-bar { height: 4px; background: rgba(255, 255, 255, 0.06); border-radius: 4px; overflow: hidden; }
.shell-progress-fill { height: 100%; border-radius: 4px; background: linear-gradient(90deg, var(--teal), var(--bio-glow)); transition: width 0.6s ease; box-shadow: 0 0 8px rgba(0, 255, 136, 0.3); }

.shell-card-footer { display: flex; justify-content: space-between; align-items: center; padding: 8px 16px; border-top: 1px solid rgba(201, 168, 76, 0.08); position: relative; z-index: 2; }
.shell-timestamp { font-family: var(--font-mono); font-size: 10px; color: var(--salvage); opacity: 0.6; }
.shell-ref { font-family: var(--font-mono); font-size: 10px; color: var(--brass); opacity: 0.5; letter-spacing: 0.03em; }
```

---

### 4.4 Loading Spinner — Cog & Claw

A rotating brass cog with a claw-tick animation.

```html
<div class="cog-spinner" aria-label="Loading">
  <div class="cog-spinner-inner">
    <svg class="cog" viewBox="0 0 64 64">
      <circle cx="32" cy="32" r="16" fill="none" stroke="var(--brass)" stroke-width="2" opacity="0.6"/>
      <g class="cog-teeth" fill="none" stroke="var(--brass)" stroke-width="2.5">
        <rect x="27" y="2" width="10" height="8" rx="1"/>
        <rect x="27" y="54" width="10" height="8" rx="1"/>
        <rect x="2" y="27" width="8" height="10" rx="1"/>
        <rect x="54" y="27" width="8" height="10" rx="1"/>
        <rect x="9.5" y="9.5" width="10" height="8" rx="1" transform="rotate(45 14.5 13.5)"/>
        <rect x="44.5" y="9.5" width="10" height="8" rx="1" transform="rotate(45 49.5 13.5)"/>
        <rect x="9.5" y="46.5" width="10" height="8" rx="1" transform="rotate(45 14.5 50.5)"/>
        <rect x="44.5" y="46.5" width="10" height="8" rx="1" transform="rotate(45 49.5 50.5)"/>
      </g>
      <circle cx="32" cy="32" r="6" fill="none" stroke="var(--brass)" stroke-width="2" opacity="0.5"/>
      <circle cx="32" cy="32" r="2" fill="var(--brass)" opacity="0.7"/>
    </svg>
    <div class="claw-tick"></div>
  </div>
  <span class="cog-label">Processing shell...</span>
</div>
```

```css
.cog-spinner { display: inline-flex; flex-direction: column; align-items: center; gap: 12px; padding: 24px; }
.cog-spinner-inner { position: relative; width: 64px; height: 64px; }
.cog { width: 100%; height: 100%; animation: cog-rotate 2s linear infinite; }

@keyframes cog-rotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

.claw-tick {
  position: absolute; top: 50%; left: 50%;
  width: 6px; height: 6px; margin: -3px 0 0 -3px;
  border-radius: 50%; background: var(--bio-glow); box-shadow: 0 0 8px rgba(0, 255, 136, 0.6);
  animation: claw-orbit 2s cubic-bezier(0.34, 1.56, 0.64, 1) infinite;
}
@keyframes claw-orbit {
  0% { transform: translate(0, -24px) scale(0.8); opacity: 1; }
  25% { transform: translate(17px, -17px) scale(1.2); opacity: 0.8; }
  50% { transform: translate(24px, 0) scale(0.6); opacity: 0.4; }
  75% { transform: translate(17px, 17px) scale(1); opacity: 0.7; }
  100% { transform: translate(0, 24px) scale(0.8); opacity: 1; }
}

.cog-spinner-inner::after {
  content: ''; position: absolute; top: 50%; left: 50%;
  width: 4px; height: 4px; margin: -2px 0 0 -2px;
  border-radius: 50%; background: var(--amber); box-shadow: 0 0 6px rgba(232, 136, 58, 0.5);
  animation: claw-orbit-opposite 2s cubic-bezier(0.34, 1.56, 0.64, 1) infinite;
}
@keyframes claw-orbit-opposite {
  0% { transform: translate(0, 24px) scale(0.6); opacity: 0.5; }
  25% { transform: translate(-17px, 17px) scale(1); opacity: 0.8; }
  50% { transform: translate(-24px, 0) scale(1.2); opacity: 1; }
  75% { transform: translate(-17px, -17px) scale(0.8); opacity: 0.6; }
  100% { transform: translate(0, -24px) scale(0.6); opacity: 0.5; }
}

.cog-label {
  font-family: var(--font-mono); font-size: 11px; font-weight: 500;
  color: var(--brass); opacity: 0.6; letter-spacing: 0.05em;
  animation: cog-pulse-label 1.5s ease-in-out infinite;
}
@keyframes cog-pulse-label { 0%, 100% { opacity: 0.4; } 50% { opacity: 0.8; } }
```

---

## 5. 5 Agent Archetypes — Hermit Crab Officers

Reimagining the kimi-swarm RPG-style agents as hermit crab officers. Each has a shell type, a role in the fleet, and visual cues.

### 5.1 Builder — The Engineer Crab

> *"The shell was broken. I made it stronger."*

| Attribute | Detail |
|-----------|--------|
| **Role** | Fleet maintenance, component construction, refactoring |
| **Shell type** | Heavy salvaged server chassis — thick gauge steel, visible welds, tool slots |
| **Key color** | Brass (#C9A84C) + Oxidized Copper (#4A7C6F) |
| **Visual cues** | Welding mask attachment on shell front, tool pincers (left = wrench, right = soldering iron), gear-segment knee joints, rivet patterns along shell edge |
| **Archetype quote** | "Build it like you're going to live in it." |
| **CSS counterpart** | .engineer-crab — heavy borders, bold geometry |
| **Existing avatar ref** | agent-builder.jpg — reimagine with copper/brass armor plates |

### 5.2 Scholar — The Old-Shell Data Crab

> *"This shell has seen twelve migrations. It remembers."*

| Attribute | Detail |
|-----------|--------|
| **Role** | Knowledge retrieval, pattern matching, historical analysis |
| **Shell type** | Cracked ceramic server tile — inscribed with code and data streams, glowing bioluminescent glyphs |
| **Key color** | Deep Teal (#1A4B5C) + Bioluminescent Green (#00FF88) |
| **Visual cues** | Carapace etched with "runes" (hex dumps, UUIDs), data-stream antennae, one glowing eye, parchment-like shell segments |
| **Archetype quote** | "Every shell holds a story. I speak the old tongues." |
| **CSS counterpart** | .scholar-crab — inset shadows, glyph-pattern backgrounds |
| **Existing avatar ref** | agent-scholar.jpg — reimagine with cracked ceramic shell |

### 5.3 Commander — The General

> *"The shell commands. The fleet follows."*

| Attribute | Detail |
|-----------|--------|
| **Role** | Orchestration, strategic decisions, fleet TUI command |
| **Shell type** | Burnished brass officer's shell — polished, emblematic, with a sigil (the fleet's ternary symbol) embossed on the carapace |
| **Key color** | Brass (#C9A84C) + Salvage Grey (#3A3F47) |
| **Visual cues** | Epaulette-like antennae, ceremonial claw larger than the other, commander's crest on forehead plate, steam vents on shoulders |
| **Archetype quote** | "A good shell is a deployed shell. Move." |
| **CSS counterpart** | .commander-crab — strong outlines, crisp geometric borders |
| **Existing avatar ref** | agent-commander.jpg — reimagine with polished brass armor, officer's crest |

### 5.4 Scout — The Swift Telemetry Crab

> *"I shed the heavy shells. Speed is the best armor."*

| Attribute | Detail |
|-----------|--------|
| **Role** | Telemetry collection, health checks, edge detection, fast data relay |
| **Shell type** | Lightweight carbon-fiber salvage — barely there, more exoskeleton than armor, aerodynamic |
| **Key color** | Warm Amber (#E8883A) + Bioluminescent Green (#00FF88) |
| **Visual cues** | Multiple small legs moving fast, long antennae for sensing, minimal shell cover, bright bioluminescent trail marks, glass-eye sensor array |
| **Archetype quote** | "If you're still in your shell when the data arrives, you're already late." |
| **CSS counterpart** | .scout-crab — thin borders, quick hover transitions, minimal padding |
| **Existing avatar ref** | agent-scout.jpg — reimagine with minimal shell, bright sensor eyes |

### 5.5 Alchemist — The Void-Magic Crab

> *"The shell is not your body. The shell is your potential."*

| Attribute | Detail |
|-----------|--------|
| **Role** | Anomaly detection, oracle interpretation, ternary void work, rare signal processing |
| **Shell type** | Weathered obsidian-like crustacean shell with iridescent sheen — appears to absorb light, shot through with magenta crystalline veins |
| **Key color** | Cyberpunk Magenta (#C84B8E) + Deep Teal (#1A4B5C) |
| **Visual cues** | Bioluminescent magenta patterns pulsing across carapace, one large mesmerizing eye, crystalline growths on shell, claw that phases in and out of visibility |
| **Archetype quote** | "Between the shells, there is signal. I listen there." |
| **CSS counterpart** | .alchemist-crab — glow filters, gradient borders, animated pulse effects |
| **Existing avatar ref** | agent-alchemist.jpg — reimagine with obsidian shell, magenta crystal veins |

### Visual Hierarchy Map

```
                    Commander (Strategic Core)
                   /                          \
            Builder                          Scholar
        (Infrastructure)                 (Knowledge)
               |                              |
            Scout                        Alchemist
        (Telemetry/Edge)             (Oracle/Anomaly)
```

---

## 6. 3 Image Generation Prompts

### 6.1 Full Fleet Dashboard Concept Mockup

**Use for:** Dashboard hero image, landing page, concept art.

```
Prompt: A dark futuristic fleet dashboard control center, steampunk-cyberpunk fusion aesthetic.
The interface is built inside a giant hollowed-out crab shell -- curved brass walls with riveted
seams, oxidized copper data panels, and bioluminescent green (hex #00FF88) readouts floating in
the dark interior. Multiple circular pressure gauges showing system status in amber and green.
A segmented carapace-style navigation bar at the top with brass-colored segments that appear to
lift. Data cards with gear-pattern backgrounds and glowing accents. Warm ambient lighting from
brass fixtures. Shot from operator's perspective, looking at a holographic fleet status projection
in the center. Dark teal (#1A4B5C) dominant with brass (#C9A84C) trim, traces of cyberpunk
magenta (#C84B8E) on anomaly indicators. Steam vents on the edges. 4K, highly detailed,
atmospheric, cinematic lighting, octane render style, --ar 16:9
```

### 6.2 Hermit Crab Logo / Icon (Improved)

**Use for:** App icon, favicon, brand mark.

```
Prompt: A detailed hermit crab silhouette reimagined as living power armor. The crab has
discarded its natural shell for a cobbled-together set of brass and oxidized copper armor plates,
visible rivets and weld marks. One claw is a mechanical pincer with gear teeth; the other is a
data-sensor claw with glowing bioluminescent green (#00FF88) eyes. The armor shell features
segmented plates in brass (#C9A84C) and deep teal (#1A4B5C) with ancient-looking engraved circuit
patterns. The crab squats in a defensive pose, looking upward, claws raised. Background is dark
void (#0C0F15). Bioluminescent green glow emanates from between the armor seams. Clean silhouette
suitable for app icon, vector style with rich metallic gradient shading. Minimalist enough for
favicon, detailed enough for hero graphic. --ar 1:1
```

### 6.3 Bioluminescent Brass-and-Teal Shell Card

**Use for:** UI component hero shot, card pattern reference.

```
Prompt: A single futuristic data card UI element with a riveted brass border, floating in dark
space. The card has a deep teal (#1A4B5C) background with a subtle repeating gear-and-circuit
pattern in very low opacity. Along the top edge, a thin bioluminescent green (#00FF88) glow line
pulses softly. The card shows three metric values in a monospace terminal font: "96.2%", "12ms",
"1,284" -- the first value glowing bright green. A thin progress bar at the bottom glows green.
Small rivets visible at the four corners of the brass border. Shot from slightly above, dramatic
rim lighting from the bioluminescent accents. Steampunk meets cyberpunk, warm industrial
aesthetic, dark background (#0C0F15). 4K product-style render. --ar 4:3
```

---

## 7. Brand Copy & Manifest

### Taglines

| Tagline | Context |
|---------|---------|
| **"The crab inherits the shell."** | Primary brand tagline — transformation, adaptation |
| **"Discard nothing. Salvage everything."** | Reinforces the found-tech philosophy |
| **"A good shell is a deployed shell."** | Commander's ethos — shipping over perfection |
| **"Build it like you're going to live in it."** | Builder's motto — quality through ownership |
| **"Between the shells, there is signal."** | Alchemist / oracle / anomaly tagline |
| **"Every shell tells a story."** | Scholar's domain — data archaeology |
| **"Speed is the best armor."** | Scout's credo — telemetry over bulk |
| **"Co-captain of the fleet."** | The operator's role — you and the system, together |
| **"Your old shells are someone else's armor."** | The open-source / sharing ethos |

### The Hermit Crab Manifesto

> **We are hermit crabs.**
>
> We do not grow our own armor.
> We *find* it. We *adapt* it. We *make it ours*.
>
> The shells we inhabit were never meant for us.
> They were built for something else — some other system, some other age.
> That does not matter. **The shell is a starting point, not a prison.**
>
> We scavenge the graveyards of abandoned APIs.
> We reinforce the walls of deprecated protocols.
> We reroute the copper through fresh pipelines.
> We seal the cracks with patience and good code.
>
> **A perfect shell is a dead shell.**
> A living shell bears the marks of every adaptation:
> The weld where the service mesh attached.
> The dent where the load spike hit.
> The rivet where we hot-patched at 3 AM.
>
> When a shell no longer serves, we shed it.
> We carry the lessons. We leave the husk for the next crab.
>
> **The shell is not your identity. It is your latest adaptation.**
>
> This is the fleet. This is your armor. This is how we build.
>
> — *The Hermit Crab Codex, v0.1.0*

### "Co-Captain of the Fleet" — Aesthetic Mapping

The dashboard operator is the **co-captain** — the human symbiotic partner to the system's crustacean intelligence.

| Concept | Hermit Crab Translation |
|---------|------------------------|
| You are in the cockpit | You inhabit the shell alongside the system |
| The system has its own shell | Legacy code, infrastructure, existing dashboards |
| Together you reinforce it | Hot patches, new features, configuration |
| Metrics are bioluminescence | The carapace glows with the system's health |
| Anomalies are cracks | Warning indicators, magenta (void) signals |
| You are not building from scratch | You're inhabiting and improving |
| The crab inherits | You inherit what came before, make it yours |

This avoids the "greenfield perfect world" fallacy of most design systems. It says: *this is salvage, this is adaptation, and that's beautiful.*

---

## 8. Implementation Guide

### 8.1 Quick Start: Overlaying on Existing Dashboards

```css
/* Drop this into any existing dashboard after the existing CSS */
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500;600&display=swap');

:root {
  --brass:    #C9A84C;
  --copper:   #4A7C6F;
  --teal:     #1A4B5C;
  --rust:     #8B4513;
  --salvage:  #3A3F47;
  --bio-glow: #00FF88;
  --amber:    #E8883A;
  --magenta:  #C84B8E;
  
  --font-title: 'Playfair Display', Georgia, 'Times New Roman', serif;
  --font-mono:  'JetBrains Mono', 'Fira Code', 'SF Mono', monospace;
  --font-body:  Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

body { background: #0C0F15; }

.card, .reflex-card {
  background: var(--teal);
  border-color: rgba(201, 168, 76, 0.2);
}

h1, h2 {
  font-family: var(--font-title);
  color: var(--brass);
}

.metric-value, td {
  font-family: var(--font-mono);
}

.badge-ok, .badge-green {
  background: rgba(0, 255, 136, 0.12);
  color: var(--bio-glow);
  border: 1px solid rgba(0, 255, 136, 0.2);
}
.badge-warn, .badge-yellow {
  background: rgba(232, 136, 58, 0.12);
  color: var(--amber);
  border: 1px solid rgba(232, 136, 58, 0.2);
}
.badge-bad, .badge-red {
  background: rgba(139, 69, 19, 0.12);
  color: var(--rust);
  border: 1px solid rgba(139, 69, 19, 0.2);
}
```

### 8.2 Component Snippet for Quick UI Element

```html
<style>
  @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600&display=swap');

  .minimal-shell {
    background: #1A4B5C;
    border: 1px solid rgba(201, 168, 76, 0.25);
    border-radius: 10px;
    padding: 14px 16px;
    font-family: 'JetBrains Mono', monospace;
    position: relative;
  }
  .minimal-shell::before {
    content: '';
    position: absolute;
    inset: 3px;
    border: 1px solid rgba(201, 168, 76, 0.1);
    border-radius: 7px;
    pointer-events: none;
  }
  .minimal-shell-title {
    font-family: 'Playfair Display', Georgia, serif;
    font-size: 14px;
    font-weight: 700;
    color: #C9A84C;
    margin-bottom: 8px;
  }
  .minimal-shell-metric {
    font-size: 22px;
    font-weight: 600;
    color: #00FF88;
    text-shadow: 0 0 10px rgba(0, 255, 136, 0.3);
  }
  .minimal-shell-label {
    font-size: 10px;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: #3A3F47;
    margin-top: 4px;
  }
</style>

<div class="minimal-shell">
  <div class="minimal-shell-title">d Fleet Health</div>
  <div class="minimal-shell-metric">96.2%</div>
  <div class="minimal-shell-label">Last pulse 14s ago</div>
</div>
```

### 8.3 Migration Strategy

| Phase | What Changes | Effort |
|-------|-------------|--------|
| 1. CSS Variables | Replace hardcoded colors with --brass, --teal, etc. | Low |
| 2. Typography | Add font imports, apply --font-title to h1-h3 | Low |
| 3. Card borders | Add ::before rivet pseudo-elements to cards | Medium |
| 4. Gauges | Replace dot status indicators with gauge SVG | Medium |
| 5. Nav | Replace existing nav with carapace-nav | High |
| 6. Loading | Replace spinners with cog-spinner | Low |
| 7. Imagery | Generate and deploy the three image assets | One-time |

### 8.4 Accessibility Notes

- Brass-on-teal text meets WCAG AA at large font sizes (>18px) — use for headers
- For body text, use lighter shade (#D4B84E instead of #C9A84C) or pair with white text
- Bioluminescent green (#00FF88) on dark backgrounds passes WCAG AAA for large text
- All gauge states include text labels, not just color
- Animated elements respect prefers-reduced-motion

---

## 9. Asset Inventory (Existing)

These assets exist in the workspace and provide the foundation for the hermit crab theme:

| File | Path | Role in Design System |
|------|------|----------------------|
| logo.jpg | pincher/assets/logo.jpg | Current brand mark — reimagined as brass crab sigil |
| hermit-crab.jpg | pincher/assets/hermit-crab.jpg | Reference photo/art — anatomical inspiration |
| agent-builder.jpg | kimi-swarm-frontend/app/public/ | Engineer Crab (salvaged server chassis shell) |
| agent-scholar.jpg | kimi-swarm-frontend/app/public/ | Old-Shell Data Crab (cracked ceramic shell) |
| agent-commander.jpg | kimi-swarm-frontend/app/public/ | General Crab (polished brass officer shell) |
| agent-scout.jpg | kimi-swarm-frontend/app/public/ | Swift Telemetry Crab (minimal carbon shell) |
| agent-alchemist.jpg | kimi-swarm-frontend/app/public/ | Void-Magic Crab (obsidian shell, magenta crystals) |
| agent-critic.jpg | kimi-swarm-frontend/app/public/ | Extra — could become Auditor Crab |
| rotation-dashboard.html | construct/ | Primary target for hermit crab theme integration |
| reflex-status.html | construct/ | Secondary target — reflex cards become shell cards |
| fleet-status.html | construct-coordination/assets/ | Tertiary target — fleet overview |

### Color Compatibility Map

| Current (GitHub Dark) | Hermit Crab Equivalent | Change |
|-----------------------|----------------------|--------|
| --bg: #0d1117 | #0C0F15 (shell void) | Very close, keep as-is |
| --surface: #161b22 | --teal: #1A4B5C | Add teal tint for warmer feel |
| --green: #3fb950 | --bio-glow: #00FF88 | Brighter, more bioluminescent |
| --red: #f85149 | --rust: #8B4513 | Warmer, earthier danger |
| --yellow: #d29922 | --amber: #E8883A | More orange, steam-like |
| --blue: #58a6ff | --copper: #4A7C6F | Teal-green shift |
| --purple: #bc8cff | --magenta: #C84B8E | Deeper, more vibrant |
| --border: #30363d | brass border at 0.25 opacity | Warmer, metallic |
| --text: #c9d1d9 | Keep with serif/mono type | Font change only |
| --muted: #8b949e | --salvage: #3A3F47 | Darker, grittier |

---

## Appendix A: Design Tokens (JSON)

```json
{
  "hermit-crab": {
    "color": {
      "brass":    { "value": "#C9A84C", "description": "Navigation, borders, headers" },
      "copper":   { "value": "#4A7C6F", "description": "Cards, backgrounds, aged patina" },
      "teal":     { "value": "#1A4B5C", "description": "Shell interior, dark surfaces" },
      "rust":     { "value": "#8B4513", "description": "Danger, decay, warning accents" },
      "salvage":  { "value": "#3A3F47", "description": "Neutral surfaces, text" },
      "bio-glow": { "value": "#00FF88", "description": "Live data, healthy metrics" },
      "amber":    { "value": "#E8883A", "description": "Gauge pressure, mid warning" },
      "magenta":  { "value": "#C84B8E", "description": "Oracle/void/anomaly signals" }
    },
    "typography": {
      "title-font": { "value": "'Playfair Display', Georgia, 'Times New Roman', serif" },
      "mono-font":  { "value": "'JetBrains Mono', 'Fira Code', 'SF Mono', monospace" },
      "body-font":  { "value": "Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif" }
    }
  }
}
```

---

## Appendix B: Steam-Pressure Gauge SVG (Standalone)

```svg
<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg" style="width:120px;height:120px;">
  <circle cx="60" cy="60" r="48" fill="none" stroke="#4A7C6F" stroke-opacity="0.35" stroke-width="8"/>
  <circle cx="60" cy="60" r="48" fill="none" stroke="#00FF88" stroke-width="8"
          stroke-linecap="round" stroke-dasharray="301.6" stroke-dashoffset="120"
          transform="rotate(-90 60 60)" style="filter:drop-shadow(0 0 6px #00FF88)"/>
  <g stroke="#C9A84C" stroke-opacity="0.4" stroke-width="1.5">
    <line x1="60" y1="6" x2="60" y2="16"/>
    <line x1="114" y1="60" x2="104" y2="60"/>
    <line x1="60" y1="114" x2="60" y2="104"/>
    <line x1="6" y1="60" x2="16" y2="60"/>
  </g>
  <circle cx="60" cy="60" r="6" fill="none" stroke="#C9A84C" stroke-opacity="0.6" stroke-width="2"/>
  <circle cx="60" cy="60" r="2" fill="#C9A84C" fill-opacity="0.8"/>
</svg>
```

---

*Design system v1.0 — Created for the SuperInstance fleet dashboard ecosystem.*
*"The crab inherits the shell." d*
