#!/usr/bin/env bash
# ==============================================================================
# GC System — Garbage Collection for Oracle2 Vessel
# ==============================================================================
# Runs lifecycle management: eviction, compaction, immortal protection
# Modeled on the baton program: every byte has a lifecycle.
#
# Policies:
#   Tier-1 (Immortal):      workspace identity files, active protocols, .env, running service .venvs
#   Tier-2 (Hot):            active repo clones being worked on this session
#   Tier-3 (Warm):           legacy reference, historical artifacts
#   Tier-4 (Cold/Evictable): build artifacts, caches, idle .venv (>1d no service), node_modules
#
# Usage:
#   bash scripts/gc-system.sh           # dry-run (report only)
#   bash scripts/gc-system.sh --execute  # actually evict cold data
#   bash scripts/gc-system.sh --status   # show tier inventory
# ==============================================================================

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$SCRIPT_DIR/.."

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

MODE="${1:-dry-run}"
SUMMARY_FILE="/tmp/gc-summary-$$.txt"

echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🦀  ORACLE2 VESSEL GARBAGE COLLECTOR    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "Mode: $MODE"
echo "Date: $(date -u)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  TIER INVENTORY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── Tier-1: Immortal (never touched) ───
echo -e "${GREEN}[IMMORTAL]${NC} Never evicted:"
echo "  - workspace/memory/*"
echo "  - workspace/MEMORY.md"
echo "  - workspace/SOUL.md"
echo "  - workspace/IDENTITY.md"
echo "  - workspace/baton-system/"
echo "  - workspace/FLEET_ARCHITECTURE.md"
echo "  - /tmp/i2i-vessel/"
echo "  - .env files"
echo "  - lever-runner/.venv (active systemd services)"
echo ""

# ─── Tier-2: Hot (active session data) ───
echo -e "${YELLOW}[HOT]${NC} Active session repos:"
for d in "$WORKSPACE"/baton-system; do
  echo "  $(du -sh "$d" 2>/dev/null | cut -f1) $d"
done
echo ""

# ─── Tier-3: Warm (reference, GC but don't delete) ───
echo -e "${YELLOW}[WARM]${NC} Reference data (GC git packs, keep content):"
for d in "$WORKSPACE"/pincher-legacy-mine/*/; do
  if [ -d "$d/.git" ]; then
    size=$(du -sh "$d" 2>/dev/null | cut -f1)
    name=$(basename "$d")
    echo "  $size $name"
  fi
done
echo "  $(du -sh "$WORKSPACE/forgemaster-archive" 2>/dev/null | cut -f1) forgemaster-archive"
echo ""

# ─── Tier-4: Cold (evictable) ───
echo -e "${RED}[COLD]${NC} Build artifacts, caches, .venv:"
# Find all target/ dirs
find /tmp /home/ubuntu -maxdepth 6 -name "target" -type d 2>/dev/null | while read d; do
  size=$(du -sh "$d" 2>/dev/null | cut -f1)
  echo "  $size $d"
done
# Find .venv > 50M — but protect .venvs referenced by active systemd services
find /home/ubuntu -maxdepth 5 -name ".venv" -type d 2>/dev/null | while read d; do
  size=$(du -sh "$d" 2>/dev/null | cut -f1)
  if [ "$(echo "$size" | sed 's/[^0-9.]//g' | cut -d. -f1)" -gt 50 ] 2>/dev/null; then
    svc_name=$(basename "$(dirname "$d")")
    if systemctl is-active --quiet "${svc_name}-*.service" 2>/dev/null ||
       systemctl is-active --quiet "${svc_name}.service" 2>/dev/null; then
      echo -e "  ${GREEN}$size $d (protected — active service)${NC}"
    else
      echo "  $size $d"
    fi
  fi
done
# pip caches
find /tmp -maxdepth 2 -name "pip-*" -type d 2>/dev/null | while read d; do
  size=$(du -sh "$d" 2>/dev/null | cut -f1)
  echo "  $size $d"
done
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  DISK STATE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
df -h / | tail -1

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  RAM STATE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
free -h | head -2

# ─── EXECUTION: Only if --execute flag ───
if [ "$MODE" != "--execute" ]; then
  echo ""
  echo -e "${YELLOW}⚠️  Dry-run mode. Use --execute to evict cold data.${NC}"
  exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  EVICTING COLD DATA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
EVICTED=0

# Evict idle/abandoned .venv > 500M (no active systemd service)
find /home/ubuntu -maxdepth 4 -name ".venv" -type d -size +500M 2>/dev/null | while read d; do
  svc_name=$(basename "$(dirname "$d")")
  if ! systemctl is-active --quiet "${svc_name}.service" 2>/dev/null &&
     ! systemctl is-active --quiet "${svc_name}-*.service" 2>/dev/null; then
    echo -e "${RED}Evicting idle .venv:${NC} $d ($(du -sh "$d" | cut -f1))"
    echo "   Reason: No active systemd service references this .venv"
    if [ "$MODE" == "--execute" ]; then
      rm -rf "$d"
      EVICTED=$((EVICTED + 1))
      echo "   ✅ Evicted"
    fi
  else
    echo -e "${GREEN}Protected:${NC} $d (active systemd service references this)"
  fi
done

# GC legacy git packs (already shallow-cloned)
for d in "$WORKSPACE"/pincher-legacy-mine/*/; do
  if [ -d "$d/.git" ]; then
    name=$(basename "$d")
    before=$(du -sh "$d/.git" 2>/dev/null | cut -f1)
    (cd "$d" && git gc --aggressive --prune=now 2>/dev/null)
    after=$(du -sh "$d/.git" 2>/dev/null | cut -f1)
    echo -e "${YELLOW}GC'd:${NC} $name ($before → $after)"
  fi
done

# ─── EVICT COLD BUILD ARTIFACTS ───
# Find cargo/npm target directories >100M, older than 7 days, not part of active repos
echo -e "\n${RED}[EVICTING COLD BUILD ARTIFACTS]${NC}"
echo "Finding stale build targets (>100M, >7 days old, not active repos):"
find /tmp /home/ubuntu -maxdepth 6 -name "target" -type d 2>/dev/null | while read d; do
  # Skip active workspace repos
  if [[ "$d" == *"/baton-system/"* || "$d" == *"/pincher/"* || "$d" == *"/lever-runner/"* || "$d" == *"/fleet-conductor/"* || "$d" == *"/fleet-agent/"* ]]; then
    echo -e "  ⚠️  Skipping active repo target: $d"
    continue
  fi
  # Get size info
  size=$(du -sh "$d" 2>/dev/null | cut -f1)
  size_num=$(echo "$size" | sed 's/[^0-9.]//g' | cut -d. -f1 || echo 0)
  if [ -z "$size_num" ] || [ "$size_num" -lt 100 ] 2>/dev/null; then
    continue
  fi
  # Get age info (7 days = 604800 seconds)
  mtime=$(stat -c "%Y" "$d" 2>/dev/null || echo 0)
  age=$(( $(date +%s) - mtime ))
  if [ "$age" -lt 604800 ]; then
    continue
  fi
  # Report/evict
  if [ "$MODE" == "--execute" ]; then
    echo -e "${RED}Evicting:${NC} $d ($size, $((age/86400)) days old)"
    rm -rf "$d"
    EVICTED=$((EVICTED + 1))
  else
    echo -e "  🕐 Would evict: $d ($size, $((age/86400)) days old)"
  fi
done

# Clean npm/node_modules caches
echo -e "\n${RED}[EVICTING NPM CACHES]${NC}"
if [ -d "/home/ubuntu/.npm" ]; then
  echo -e "  Cleaning global npm cache"
  rm -rf /home/ubuntu/.npm/* 2>/dev/null || true
fi
find /tmp -maxdepth 3 -name "node_modules" -type d -mtime +3 2>/dev/null | while read d; do
  if [ "$MODE" == "--execute" ]; then
    echo -e "${RED}Evicting:${NC} $d (stale node_modules)"
    rm -rf "$d"
    EVICTED=$((EVICTED + 1))
  else
    echo -e "  🕐 Would evict: $d (stale node_modules)"
  fi
done

# Clean pip cache
if [ -d "/home/ubuntu/.cache/pip" ]; then
  echo -e "${RED}Evicting:${NC} pip cache"
  rm -rf /home/ubuntu/.cache/pip 2>/dev/null || true
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  POST-GC STATE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
df -h / | tail -1

echo ""
echo -e "${GREEN}✅ GC cycle complete. $EVICTED items evicted.${NC}"

# Log cleanup (added 2026-06-06)
echo "=== Log Cleanup ==="
sudo journalctl --vacuum-size=500M 2>/dev/null
sudo truncate -s 0 /var/log/syslog 2>/dev/null
echo "Log size: $(du -sh /var/log/ | cut -f1)"
