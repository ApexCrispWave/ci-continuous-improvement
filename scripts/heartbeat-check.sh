#!/bin/bash
# CrispWave Heartbeat Health Check
# Pure shell script - NO AI, NO TOKENS
# Checks: local services, disk space, recent activity

WS="/Users/openclaw/.openclaw/workspace"
TIMEOUT=5
STATUS="✅ OPERATIONAL"
ISSUES=()

# 1. OLLAMA LOCAL
if curl -s -m $TIMEOUT http://localhost:11434/api/tags 2>/dev/null | grep -q 'models'; then
    echo "✓ Ollama running"
else
    echo "⚠ Ollama not responding"
fi

# 2. GATEWAY
if curl -s -m $TIMEOUT http://localhost:3000/api/tasks 2>/dev/null | grep -q 'tasks'; then
    echo "✓ Gateway responding"
else
    echo "⚠ Gateway not responding"
    STATUS="⚠ DEGRADED"
fi

# 3. DISK SPACE
DISK_FREE=$(df /Users/openclaw | tail -1 | awk '{print $4}')
DISK_GB=$((DISK_FREE / 1048576))
echo "✓ Disk: ${DISK_GB}GB free"
if [ "$DISK_FREE" -lt 5242880 ]; then  # <5GB
    echo "⚠ WARNING: Low disk space"
    STATUS="⚠ DEGRADED"
fi

# 4. TASK COUNT
TASK_COUNT=$(curl -s -m $TIMEOUT http://localhost:3000/api/tasks 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d.get('tasks',[])))" 2>/dev/null || echo "?")
echo "✓ Tasks: $TASK_COUNT loaded"

# 5. CRON ACTIVITY (last 30 mins)
RECENT=$(find "$WS/logs" -name "*.log" -mmin -30 2>/dev/null | wc -l)
echo "✓ Recent activity: $RECENT log files in last 30 min"

# OUTPUT SUMMARY
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "HEARTBEAT $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Status: $STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Exit clean (always OK - this is just monitoring)
exit 0
