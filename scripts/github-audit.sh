#!/bin/bash
# GitHub Repository Audit (Weekly - Monday 6:10 AM PT)
# Model: ollama/qwen3:8b (initial scan) → anthropic/claude-opus-4-1 (strategy escalation)
# Audits all ApexCrispWave repos: health, CI, docs, integration gaps
# Output: research/github-audit/YYYY-WNN.md (auto-ingested to research DB as ci-github)

set -euo pipefail

WORKSPACE="/Users/openclaw/.openclaw/workspace"
DATE=$(date +%Y-%m-%d)
WEEK=$(date +%Y-W%V)
OUTPUT_DIR="$WORKSPACE/research/github-audit"
OUTPUT_FILE="$OUTPUT_DIR/$WEEK.md"
LOG_DIR="$WORKSPACE/health-logs"
LOG_FILE="$LOG_DIR/$DATE.json"
TASK_NAME="github-audit"
START_TIME=$(date +%s)
ESCALATE_SCRIPT="$WORKSPACE/scripts/ci-escalate-to-opus.sh"

mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

MODEL="ollama/qwen3:8b"
FALLBACK_MODEL="ollama/gemma3:4b"
TIMEOUT=2400

log_metric() {
  local status=$1
  local error_msg=${2:-""}
  local end_time=$(date +%s)
  local runtime=$((end_time - START_TIME))
  local output_size=0
  [ -f "$OUTPUT_FILE" ] && output_size=$(wc -c < "$OUTPUT_FILE")

  python3 -c "
import json
try:
    with open('$LOG_FILE') as f:
        data = json.load(f)
except:
    data = {'date': '$DATE', 'tasks': {}}
data.setdefault('tasks', {})['$TASK_NAME'] = {
    'status': '$status',
    'start_time': $START_TIME,
    'end_time': $end_time,
    'runtime_seconds': $runtime,
    'output_size_bytes': $output_size,
    'model': '$MODEL',
    'error': '$error_msg'
}
with open('$LOG_FILE', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || true
}

echo "[$(date)] Starting GitHub repository audit — Week $WEEK"

# ──────────────────────────────────────────────────────────
# STEP 1: Collect raw repo data
# ──────────────────────────────────────────────────────────

echo "[$(date)] Fetching ApexCrispWave repo list..."

REPO_LIST=$(gh repo list ApexCrispWave --limit 50 2>/dev/null || echo "ERROR: gh not available")
REPO_COUNT=$(echo "$REPO_LIST" | grep -c "ApexCrispWave/" 2>/dev/null || echo "0")

echo "[$(date)] Found $REPO_COUNT repos. Checking details..."

# Get detailed info per repo (open issues, last push, has README, has CI)
REPO_DETAILS=""
while IFS=$'\t' read -r full_name description visibility pushed_at; do
  repo="${full_name#ApexCrispWave/}"
  [ -z "$repo" ] && continue

  # Check README
  has_readme=$(gh api "repos/ApexCrispWave/$repo/contents/README.md" --jq '.name' 2>/dev/null && echo "yes" || echo "no")

  # Check .gitignore
  has_gitignore=$(gh api "repos/ApexCrispWave/$repo/contents/.gitignore" --jq '.name' 2>/dev/null && echo "yes" || echo "no")

  # Check GitHub workflows
  has_workflows=$(gh api "repos/ApexCrispWave/$repo/contents/.github/workflows" --jq '.[0].name' 2>/dev/null && echo "yes" || echo "no")

  # Open issues/PRs count
  open_issues=$(gh api "repos/ApexCrispWave/$repo" --jq '.open_issues_count' 2>/dev/null || echo "?")

  # Default branch
  default_branch=$(gh api "repos/ApexCrispWave/$repo" --jq '.default_branch' 2>/dev/null || echo "?")

  # Branch protection on default
  branch_protected="no"
  if [ "$default_branch" != "?" ]; then
    protection=$(gh api "repos/ApexCrispWave/$repo/branches/$default_branch/protection" 2>/dev/null && echo "yes" || echo "no")
    branch_protected="$protection"
  fi

  # Latest commit date (already in pushed_at)
  days_since_push="?"
  if [ "$pushed_at" != "?" ] && [ -n "$pushed_at" ]; then
    push_ts=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$pushed_at" +%s 2>/dev/null || echo "0")
    now_ts=$(date +%s)
    if [ "$push_ts" != "0" ]; then
      days_since_push=$(( (now_ts - push_ts) / 86400 ))
    fi
  fi

  REPO_DETAILS="$REPO_DETAILS
REPO: $repo
  Description: $description
  Visibility: $visibility
  Last Push: $pushed_at ($days_since_push days ago)
  Default Branch: $default_branch
  Branch Protected: $branch_protected
  Open Issues/PRs: $open_issues
  Has README: $has_readme
  Has .gitignore: $has_gitignore
  Has GitHub Workflows: $has_workflows
---"

done < <(echo "$REPO_LIST")

# ──────────────────────────────────────────────────────────
# STEP 2: qwen3:8b scans findings
# ──────────────────────────────────────────────────────────

echo "[$(date)] Running qwen3:8b scan for issues..."

SCAN_PROMPT="You are a DevOps auditor reviewing CrispWave's GitHub repositories on ApexCrispWave org.

REPO DATA:
$REPO_DETAILS

TASKS:
1. List all repos with MISSING README
2. List all repos with MISSING .gitignore
3. List all repos with NO GitHub workflows (CI/CD)
4. List repos that appear STALE (no push in >30 days) — mark as concerning if >60 days
5. List repos with unprotected default branches
6. List repos with HIGH open issue counts (>5)
7. Identify integration gaps: are docs, skills, research repos linked from main projects?
8. Flag any repos that appear to be ABANDONED or DUPLICATE
9. Rate overall org health: GOOD / NEEDS_WORK / CRITICAL

Output as structured JSON:
{
  \"scan_date\": \"$DATE\",
  \"week\": \"$WEEK\",
  \"model\": \"qwen3:8b\",
  \"repo_count\": $REPO_COUNT,
  \"findings\": {
    \"missing_readme\": [],
    \"missing_gitignore\": [],
    \"no_ci_workflows\": [],
    \"stale_repos\": [],
    \"unprotected_branches\": [],
    \"high_issue_count\": [],
    \"integration_gaps\": [],
    \"abandoned_or_duplicate\": []
  },
  \"health_rating\": \"GOOD|NEEDS_WORK|CRITICAL\",
  \"critical_count\": 0,
  \"summary\": \"One sentence summary\"
}"

SCAN_RESULT=""
if command -v ollama &>/dev/null; then
  SCAN_RESULT=$(echo "$SCAN_PROMPT" | timeout $TIMEOUT ollama run qwen3:8b 2>/dev/null \
    | "$WORKSPACE/research-db/clean-thinking.sh" 2>/dev/null || echo "")
fi

if [ -z "$SCAN_RESULT" ]; then
  echo "[$(date)] qwen3:8b unavailable, using gemma3:4b fallback..."
  SCAN_RESULT=$(echo "$SCAN_PROMPT" | timeout 600 ollama run gemma3:4b 2>/dev/null \
    | "$WORKSPACE/research-db/clean-thinking.sh" 2>/dev/null || echo "")
fi

if [ -z "$SCAN_RESULT" ]; then
  SCAN_RESULT='{"findings": {}, "health_rating": "UNKNOWN", "summary": "scan unavailable — model offline", "critical_count": 0}'
fi

# Extract health rating to decide on escalation
HEALTH_RATING=$(echo "$SCAN_RESULT" | python3 -c "
import sys, json, re
text = sys.stdin.read()
# Try JSON parse
try:
    m = re.search(r'\{.*\}', text, re.DOTALL)
    if m:
        d = json.loads(m.group(0))
        print(d.get('health_rating', 'NEEDS_WORK'))
        sys.exit(0)
except:
    pass
# Fallback: look for rating string
for r in ['CRITICAL', 'NEEDS_WORK', 'GOOD']:
    if r in text:
        print(r)
        sys.exit(0)
print('NEEDS_WORK')
" 2>/dev/null || echo "NEEDS_WORK")

CRITICAL_COUNT=$(echo "$SCAN_RESULT" | python3 -c "
import sys, json, re
text = sys.stdin.read()
try:
    m = re.search(r'\{.*\}', text, re.DOTALL)
    if m:
        d = json.loads(m.group(0))
        print(d.get('critical_count', 0))
        sys.exit(0)
except:
    pass
print(0)
" 2>/dev/null || echo "0")

echo "[$(date)] Scan complete. Health: $HEALTH_RATING, Critical issues: $CRITICAL_COUNT"

# ──────────────────────────────────────────────────────────
# STEP 3: Escalate to Opus if needed
# ──────────────────────────────────────────────────────────

OPUS_RECOMMENDATIONS=""
ESCALATED=false

if [ "$HEALTH_RATING" != "GOOD" ] || [ "$CRITICAL_COUNT" -gt 0 ] 2>/dev/null; then
  echo "[$(date)] Escalating to Opus for strategic recommendations (health=$HEALTH_RATING)..."
  if [ -f "$ESCALATE_SCRIPT" ]; then
    OPUS_RECOMMENDATIONS=$(bash "$ESCALATE_SCRIPT" "$SCAN_RESULT" "github-audit" 2>/dev/null || echo "")
    ESCALATED=true
  else
    echo "[$(date)] WARNING: escalation script not found at $ESCALATE_SCRIPT"
  fi
fi

# ──────────────────────────────────────────────────────────
# STEP 4: Write markdown report
# ──────────────────────────────────────────────────────────

cat > "$OUTPUT_FILE" << REPORT
# GitHub Repository Audit — $WEEK

**Date:** $DATE  
**Week:** $WEEK  
**Scan Model:** qwen3:8b  
**Escalated to Opus:** $ESCALATED  
**Org:** ApexCrispWave  
**Total Repos:** $REPO_COUNT  
**Health Rating:** $HEALTH_RATING

---

## Raw Repo Data

\`\`\`
$REPO_DETAILS
\`\`\`

---

## Scan Findings (qwen3:8b)

\`\`\`json
$SCAN_RESULT
\`\`\`

---

## Strategic Recommendations (claude-opus-4-1)

$( [ -n "$OPUS_RECOMMENDATIONS" ] && echo "$OPUS_RECOMMENDATIONS" || echo "_No escalation needed — org health is GOOD_" )

---

## Metadata

- **Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
- **Script:** scripts/github-audit.sh
- **Output:** research/github-audit/$WEEK.md
- **Research DB Type:** ci-github
REPORT

echo "[$(date)] Report written: $OUTPUT_FILE ($(wc -c < "$OUTPUT_FILE") bytes)"

# ──────────────────────────────────────────────────────────
# STEP 5: Ingest to research DB
# ──────────────────────────────────────────────────────────

echo "[$(date)] Ingesting to research DB..."
python3 "$WORKSPACE/research-db/ingest.py" --file "$OUTPUT_FILE" 2>&1 | tail -3 || echo "[WARN] Ingest had issues"

log_metric "success"
echo "[$(date)] GitHub audit complete — $OUTPUT_FILE"
