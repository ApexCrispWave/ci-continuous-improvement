#!/bin/bash
# CI Escalation Helper — Send scan findings to claude-opus-4-1 for strategic review
# Usage: bash scripts/ci-escalate-to-opus.sh "<findings_json_or_text>" "<context_label>"
#
# Takes input from any qwen3:8b / gemma3:4b CI scan and escalates to Opus when:
#   - Health rating is NEEDS_WORK or CRITICAL
#   - Findings involve architecture decisions
#   - Strategic tradeoffs or long-term planning are needed
#
# Returns: structured markdown with Opus recommendations
# Cost: ~$0.10-0.30 per escalation (use sparingly — only for real findings)

set -euo pipefail

WORKSPACE="/Users/openclaw/.openclaw/workspace"
FINDINGS="${1:-}"
CONTEXT_LABEL="${2:-ci-escalation}"
DATE=$(date +%Y-%m-%d)
LOG_DIR="$WORKSPACE/health-logs"

if [ -z "$FINDINGS" ]; then
  echo "Usage: $0 '<findings_json_or_text>' '<context_label>'"
  echo "Example: $0 '\$SCAN_RESULT' 'github-audit'"
  exit 1
fi

echo "[$(date)] Escalating $CONTEXT_LABEL findings to claude-opus-4-1..." >&2

PROMPT="You are the strategic advisor for CrispWave, an AI-first software company.

A CI scan agent (qwen3:8b) has completed a $CONTEXT_LABEL audit and found the following:

--- SCAN FINDINGS ---
$FINDINGS
--- END FINDINGS ---

Your job: Review these findings with strategic intent.

1. What are the most critical issues that need immediate action?
2. What patterns indicate systemic problems (vs one-off fixes)?
3. What are the strategic implications for CrispWave's development velocity?
4. Recommend a prioritized action plan (P1/P2/P3)
5. Are there any architecture decisions embedded in these findings?
6. What should the implementation agent (qwen3:8b) do first?

Output as structured markdown with:
- ## Critical Issues (fix this week)
- ## Strategic Patterns (systemic problems)
- ## Action Plan (P1 / P2 / P3 with specific tasks)
- ## Architecture Notes (if any)
- ## Implementation Instructions for qwen3:8b"

# Use openclaw claude wrapper
RECOMMENDATIONS=""

if command -v openclaw &>/dev/null; then
  RECOMMENDATIONS=$(openclaw ask \
    --model "anthropic/claude-opus-4-1" \
    --system "You are a strategic technical advisor for CrispWave." \
    "$PROMPT" 2>/dev/null || echo "")
fi

# Fallback: try direct anthropic API via curl if openclaw unavailable
if [ -z "$RECOMMENDATIONS" ]; then
  ANTHROPIC_KEY="${ANTHROPIC_API_KEY:-}"
  if [ -n "$ANTHROPIC_KEY" ]; then
    RECOMMENDATIONS=$(curl -s https://api.anthropic.com/v1/messages \
      -H "x-api-key: $ANTHROPIC_KEY" \
      -H "anthropic-version: 2023-06-01" \
      -H "content-type: application/json" \
      -d "$(python3 -c "
import json, sys
prompt = '''$PROMPT'''
payload = {
    'model': 'claude-opus-4-1',
    'max_tokens': 2048,
    'messages': [{'role': 'user', 'content': prompt}]
}
print(json.dumps(payload))
")" 2>/dev/null \
      | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d['content'][0]['text'])
except:
    print('')
" 2>/dev/null || echo "")
  fi
fi

# Fallback: use qwen3:14b locally for strategic analysis if Opus is unavailable
if [ -z "$RECOMMENDATIONS" ]; then
  echo "[$(date)] Opus unavailable — falling back to qwen3:14b for strategic analysis" >&2
  RECOMMENDATIONS=$(echo "$PROMPT" | timeout 1800 ollama run qwen3:14b 2>/dev/null \
    | "$WORKSPACE/research-db/clean-thinking.sh" 2>/dev/null \
    || echo "_Strategic analysis unavailable — all models offline_")
  RECOMMENDATIONS="_[Fallback: qwen3:14b used — Opus unavailable]_

$RECOMMENDATIONS"
fi

if [ -z "$RECOMMENDATIONS" ]; then
  RECOMMENDATIONS="_Escalation failed — no models available_"
fi

# Log escalation cost event
python3 -c "
import json, os
log_file = '$LOG_DIR/$DATE.json'
try:
    with open(log_file) as f:
        data = json.load(f)
except:
    data = {'date': '$DATE', 'tasks': {}}
data.setdefault('escalations', []).append({
    'context': '$CONTEXT_LABEL',
    'model': 'claude-opus-4-1',
    'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
})
with open(log_file, 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || true

echo "$RECOMMENDATIONS"
