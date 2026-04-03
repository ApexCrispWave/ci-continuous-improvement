#!/bin/bash
# Setup Cron Schedule — CrispWave Autonomous Pipeline
# Installs all pipeline cron jobs for nightly execution
# Run once: bash scripts/setup-cron.sh

set -euo pipefail

WORKSPACE="/Users/openclaw/.openclaw/workspace"
SCRIPTS="$WORKSPACE/scripts"
LOGS="$WORKSPACE/logs"

mkdir -p "$LOGS"

# Make all scripts executable
chmod +x "$SCRIPTS"/competitive-analysis.sh \
         "$SCRIPTS"/newsletter-draft.sh \
         "$SCRIPTS"/memory-synthesis.sh \
         "$SCRIPTS"/video-analysis-batch.sh \
         "$SCRIPTS"/market-pulse-weekly.sh \
         "$SCRIPTS"/health-check.sh \
         "$SCRIPTS"/monitor-pipeline.sh \
         "$SCRIPTS"/babysitter-daily.sh \
         2>/dev/null || true

echo "✅ Scripts made executable"

# Get existing crontab (or empty)
EXISTING_CRON=$(crontab -l 2>/dev/null || echo "")

# Check if pipeline entries already exist
if echo "$EXISTING_CRON" | grep -q "CRISPWAVE-PIPELINE"; then
  echo "⚠️ Pipeline cron entries already exist. Remove them first or run: crontab -e"
  echo "Existing pipeline lines:"
  echo "$EXISTING_CRON" | grep "CRISPWAVE\|pipeline\|competitive\|newsletter\|memory-synthesis\|video-analysis-batch\|market-pulse-weekly\|health-check\|monitor-pipeline\|babysitter-daily"
  exit 1
fi

# Build new cron entries
NEW_CRON=$(cat << CRON
# === CRISPWAVE-PIPELINE START ===
# Autonomous nightly pipeline using qwen3.5:9b
# Installed: $(date)

# 12:15 AM — Research aggregation (existing script)
15 0 * * * bash $SCRIPTS/morning-briefing.sh >> $LOGS/research-aggregation.log 2>&1

# 1:00 AM — Ideas analysis (existing script)
0 1 * * * bash $SCRIPTS/scout-pipeline.sh >> $LOGS/ideas-analysis.log 2>&1

# 2:00 AM — Competitive analysis (NEW)
0 2 * * * bash $SCRIPTS/competitive-analysis.sh >> $LOGS/competitive-analysis.log 2>&1

# 3:00 AM — Blog post generation (existing)
0 3 * * * bash $SCRIPTS/daily-snapshot.sh >> $LOGS/blog-post.log 2>&1

# 4:00 AM — Newsletter draft (NEW)
0 4 * * * bash $SCRIPTS/newsletter-draft.sh >> $LOGS/newsletter-draft.log 2>&1

# 5:00 AM — Video analysis batch (NEW)
0 5 * * * bash $SCRIPTS/video-analysis-batch.sh >> $LOGS/video-analysis-batch.log 2>&1

# 6:30 AM — Market pulse weekly synthesis (NEW — Sunday only)
30 6 * * 0 bash $SCRIPTS/market-pulse-weekly.sh >> $LOGS/market-pulse.log 2>&1

# 7:00 AM — Memory synthesis (NEW)
0 7 * * * bash $SCRIPTS/memory-synthesis.sh >> $LOGS/memory-synthesis.log 2>&1

# 8:00 AM — Babysitter daily review (NEW — April 1-3 / every day)
0 8 * * * bash $SCRIPTS/babysitter-daily.sh >> $LOGS/babysitter.log 2>&1

# Health monitoring — every 15 min during pipeline window (12 AM - 9 AM)
*/15 0-9 * * * bash $SCRIPTS/monitor-pipeline.sh >> $LOGS/monitor.log 2>&1

# === CRISPWAVE-PIPELINE END ===
CRON
)

# Install new crontab (preserve existing + add new)
(echo "$EXISTING_CRON"; echo ""; echo "$NEW_CRON") | crontab -

echo ""
echo "✅ Cron schedule installed successfully!"
echo ""
echo "=== Installed Pipeline ==="
crontab -l | grep -A100 "CRISPWAVE-PIPELINE START" | head -40
echo ""
echo "Verify with: crontab -l"
echo "Logs will be written to: $LOGS/"
