# HEARTBEAT — Minimal Rules

## Steps (In Order)

### 1. Cloud Health
```bash
curl -s -o /dev/null -w "%{http_code}" --max-time 5 https://api.anthropic.com/v1/models
```
- 200/401 = OK | 429/5xx/timeout = Limp Mode
- Post to #task-board (1484408539974860871) if down or recovering

### 2. Scan Ronald Messages
Check #general, #ops, #jack, #task-board, #status-updates, #ideas-intake, #approvals, #life-admin, #family, #research, #dev-sandbox, #mvp-builds, #agent-logs, #system-health, #crispwave-dashboard, #launched, #baby-books-kdp, #mep-autocad-block-library, #plumbing-cad-suite (Ronald: 228535096309841922) for unanswered in last 30 min. Reply to anything unanswered.

### 3. Task Accountability
- Read tasks.json, check pending/in-progress
- Verify completions, retry failures (3x max)
- New IDs: `bash scripts/new-task-id.sh`

### 4. Queue Check
```bash
python3 scripts/queue-manager.py status
python3 scripts/queue-manager.py check-stalls
```
Max 5 per model, 12 total. Start pending if slots open.

### 5. Post Rules
- Status → #status-updates (1484389278246240368) ONLY
- Post only if action needed (silent otherwise, never HEARTBEAT_OK)
- End Discord posts with: `_Model: [model-name]_`

### 6. Channel Routing (Task Posts)
MEP: 1484816208984412170 | Plumbing: 1484816201665351701 | Baby Books: 1485396317512405144 | HeartWatch: 1485396338836242524 | Contractor Pack: 1485397806679199926 | Solar: 1485397837339426866 | Dashboard: 1484816197668311040 | Budget: 1484816193888981032

### 7. Ideas Intake
If Ronald posts idea → research (web, Reddit, competitors, YouTube) → PDF via Opus → post to #ideas-intake (1484389265784836197) + task

## Model Rules
- Heartbeat = cheapest | Complex coding = Sonnet | Strategy = Opus | Local first
