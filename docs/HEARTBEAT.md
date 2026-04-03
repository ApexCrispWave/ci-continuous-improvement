# HEARTBEAT — Lean Task Watchdog

**Single Mission:** Detect stalled in-progress tasks. Restart if needed. Nothing else.

## Steps (in order)

### 1. Load Task State
```bash
python3 /Users/openclaw/.openclaw/workspace/scripts/queue-manager.py status --json
```
Parse output. Identify any task with:
- `status: "in-progress"`
- `lastUpdateAtMs` older than threshold (30 min = 1800000 ms)

### 2. Check Sub-Agent Health
If a stalled in-progress task has an associated sub-agent:
```bash
python3 /Users/openclaw/.openclaw/workspace/scripts/queue-manager.py list-agents
```
- If agent still running → wait, task may still be executing
- If agent crashed/exited → mark task stalled, flag for restart

### 3. Action: Stall Detection Only
If stalled task found:
- Reply: `HEARTBEAT_STALL: task-XXX stalled for >30min`
- Post to #task-board (1484408539974860871)
- Do NOT auto-restart — Ronald decides

If no stalls:
- Reply: `HEARTBEAT_OK`

## Model
- Use `gemma3:4b` (local, ~0 cost)

## Schedule
- Every **3 hours**: `0 */3 * * *` (America/Los_Angeles)
- Reduces 24→8 runs/day = 67% token savings

