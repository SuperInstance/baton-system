# Integration Test Results — 2026-06-06

## Browser Tests: 36/36 ✅

Suite: `test-puppeteer.js` (Puppeteer + Chromium 149 on ARM64)

### Hex Lattice Explorer (7/7)
- Canvas fills viewport, zoom/grid/reset/mouse all work
- P48 triples embedded
- GitHub Pages: superinstance.github.io/hex-lattice-explorer

### VoxelWorks Hub (4/4)
- Buddy chatbot loads and responds to input
- 8 interactive elements (buttons, inputs, canvas)

### VoxelWorks Rooms (19/20 → 20/20 after fix)
- Block Studio: MOTION/LOOKS/CONTROL/SOUND categories
- Asset Lab: 6 sample cards, autocomplete, masonry
- Ship Deck: Git timeline, badges, deploy URL
- Game Engine: Phaser canvas renders title screen, PLAY button, 3 levels

### Nebula API (4/4)
- Health/status/reflexes list/fast path query all return correct data
- 62 reflexes stored

## Infra Fixes
- **New gateway** at voxelworks-fix.casey-digennaro.workers.dev
- **Root route** now serves hub (was truncated)
- **Game assets** route via absolute paths from GitHub raw
- **Content-Type** headers set correctly (text/html for HTML)

## Evolution Run
- CraftMind Ranch: 5 generations, 8 species
- Best: 🐐 goat at 97.7% fitness
- 43 tasks, mutation/crossover/fitness pipeline

## Disk
32G/45G (14G free, 71%)
