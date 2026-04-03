#!/bin/bash
set -euo pipefail

QUEUE_FILE="${1:-/Users/openclaw/.openclaw/workspace/queue.json}"
SCRIPT_DIR="/Users/openclaw/.openclaw/workspace/scripts"
PROCESSOR="$SCRIPT_DIR/batch-processor.py"
LOG_DIR="/Users/openclaw/.openclaw/workspace/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/batch-cron-$(date +%Y-%m-%d).log"
MAX_WAIT_SECONDS=$((2 * 60 * 60))
POLL_SECONDS=30

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

if [[ ! -f "$QUEUE_FILE" ]]; then
  log "Queue file not found: $QUEUE_FILE"
  exit 1
fi

if [[ ! -x "$PROCESSOR" ]]; then
  chmod +x "$PROCESSOR"
fi

if ! python3 - <<'PY' "$QUEUE_FILE"
import json, sys
path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as handle:
    data = json.load(handle)
pending = [job for job in data.get('jobs', []) if job.get('status') == 'pending']
print(len(pending))
sys.exit(0 if pending else 1)
PY
then
  log "No pending jobs in $QUEUE_FILE"
  exit 0
fi

log "Submitting pending jobs from $QUEUE_FILE"
submit_output=$(python3 "$PROCESSOR" submit "$QUEUE_FILE")
printf '%s\n' "$submit_output" >> "$LOG_FILE"

batch_ids=$(printf '%s\n' "$submit_output" | python3 -c 'import json,sys; payload=json.load(sys.stdin); [print(item["batch_id"]) for item in payload.get("submitted_batches", [])]')

if [[ -z "$batch_ids" ]]; then
  log "No batch IDs returned from submit"
  exit 1
fi

for batch_id in $batch_ids; do
  log "Polling batch $batch_id"
  start_ts=$(date +%s)
  while true; do
    status_output=$(python3 "$PROCESSOR" status "$batch_id")
    printf '%s\n' "$status_output" >> "$LOG_FILE"
    processing_status=$(printf '%s\n' "$status_output" | python3 -c 'import json,sys; payload=json.load(sys.stdin); print(payload.get("processing_status", "unknown"))')
    case "$processing_status" in
      ended|completed|complete|succeeded)
        log "Batch $batch_id complete with status $processing_status"
        break
        ;;
      errored|canceled|canceling|expired)
        log "Batch $batch_id reached terminal status $processing_status"
        break
        ;;
      *)
        now_ts=$(date +%s)
        elapsed=$((now_ts - start_ts))
        if (( elapsed >= MAX_WAIT_SECONDS )); then
          log "Timeout waiting for batch $batch_id after $elapsed seconds"
          exit 1
        fi
        sleep "$POLL_SECONDS"
        ;;
    esac
  done

  log "Collecting results for $batch_id"
  collect_output=$(python3 "$PROCESSOR" collect "$batch_id" "$QUEUE_FILE")
  printf '%s\n' "$collect_output" >> "$LOG_FILE"
done

log "Batch cron run complete"
