# HEARTBEAT.md

## 🔴 Model Selection Rule (Ronald — 2026-03-22, updated with Anthropic guidance)

**Match model to task. Never overpay.**

| Task Type | Model |
|---|---|
| Heartbeat triage, simple classification, bulk tasks | `anthropic/claude-haiku-4-5` (cheapest cloud) |
| Complex coding, agents, drafting | `anthropic/claude-sonnet-4-5` |
| Strategy, idea research, advanced reasoning | `anthropic/claude-opus-4-1` (APEX only) |
| Routine coding (can be local) | `ollama/qwen3:14b` or `ollama/qwen3:8b` (free) |
| Fast local triage | `ollama/gemma3:4b` or `ollama/nemotron-3-nano:4b` |

**Rules:**
- Local models first when the task is within their capability
- Haiku 4.5 for anything cloud that doesn't need deep reasoning
- Sonnet 4.5 for complex coding and agent work
- Opus 4.1 for strategy and research only — Ronald's explicit instruction
- Never Claude Code / ACP harness for coding tasks (Ronald rule 2026-03-22)

---

## 🔴 Channel Routing Rule (Ronald — 2026-03-22)

**Project/product status updates NEVER go to #general.**
**Always post to the project's dedicated channel.**

| Project | Channel ID |
|---|---|
| MEP AutoCAD Block Library | 1484816208984412170 (SOFTWARE DEV > #mep-autocad-block-library) |
| Plumbing CAD Suite | 1484816201665351701 (SOFTWARE DEV > #plumbing-cad-suite) |
| Baby Books KDP | 1485396317512405144 (PRODUCTS > #baby-books-kdp) |
| HeartWatch | 1485396338836242524 (PRODUCTS > #heartwatch) |
| Contractor AI Prompt Pack | 1485397806679199926 (PRODUCTS > #contractor-ai-prompt-pack) |
| Solar Project Template Pack | 1485397837339426866 (PRODUCTS > #solar-project-template-pack) |
| CrispWave Dashboard | 1484816197668311040 (SOFTWARE DEV > #crispwave-dashboard) |
| Budget App | 1484816193888981032 (SOFTWARE DEV > #budget-app) |

**#general is ONLY for:** Direct conversation with Ronald — answering his questions, discussing strategy when he asks.
**#general is NOT for:** task completion notices, build logs, product progress, agent work output, heartbeat updates, journal updates, memory consolidation notices, status updates, system health alerts, cron job outputs, ANY automated posts.

When completing any product/project task → post the result summary to that project's channel, not #general.

---

## #ideas-intake — Auto PDF Rule (STANDING ORDER)

**Every idea Ronald posts in #ideas-intake gets a research PDF automatically.**

### When Ronald posts an idea in #ideas-intake:
1. **Use Opus model** (`anthropic/claude-opus-4-6`) for all idea evaluation, research synthesis, and strategic analysis — Ronald's direct instruction
2. Research the idea (web search: market size, competitors, pricing, pain points, opportunity)
3. Spawn a sub-agent (`model: "opus"`) to generate a professional PDF report (same quality as plumbing-cad-suite-report.pdf)
4. Save to `/Users/openclaw/reports/<slug>-report.pdf`
5. Post the PDF back to #ideas-intake
6. Add a task to tasks.json for the idea with status "pending" and link to the report

This is a **standing order** — no need for Ronald to ask each time. Idea in → report out.
**Model rule: APEX uses Opus for idea consideration and research. No exceptions.**

---
## Discord Channel Scan (CRITICAL — Run First Every Heartbeat)

**Scan ALL Discord channels for unanswered messages from Ronald (user `228535096309841922`) in the last 30 minutes.**

### ALL channels to scan every heartbeat:
| Channel | ID |
|---|---|
| #general | 1484389259183132693 |
| #ops | 1484410717900771498 |
| #jack | 1484621444544467075 |
| #task-board | 1484408539974860871 |
| #status-updates | 1484389278246240368 |
| #ideas-intake | 1484389265784836197 |
| #approvals | 1484389272243929158 |
| #life-admin | 1484389344998588539 |
| #family | 1484389352099418153 |
| #research | 1484389291202314283 |
| #dev-sandbox | 1484389331706708039 |
| #mvp-builds | 1484389298584289300 |
| #agent-logs | 1484389318486265948 |
| #system-health | 1484389324622659717 |
| #crispwave-dashboard | 1484816197668311040 |
| #launched | 1484389305198579773 |
| #baby-books-kdp | 1485396317512405144 |
| #mep-autocad-block-library | 1484816208984412170 |
| #plumbing-cad-suite | 1484816201665351701 |

### Scan procedure:
1. **Use the Discord API** to pull last 20 messages from each channel
2. **Identify any message from Ronald** (sender_id `228535096309841922`) in the last 30 min that did NOT receive an agent reply after it
3. **For each unanswered message:**
   - If it's a question or task → create a new task in `tasks.json` immediately
   - If it needs immediate response → reply to the channel now
   - If it's old but unaddressed → reply with acknowledgment and status
4. **Log the scan result** in `memory/heartbeat-state.json` with timestamp

### Scan state tracking (memory/heartbeat-state.json):
```json
{
  "lastScan": {
    "general": "<ISO timestamp>",
    "ops": "<ISO timestamp>",
    "task-board": "<ISO timestamp>",
    "jack": "<ISO timestamp>"
  },
  "unansweredCount": 0,
  "lastUnansweredAt": null
}
```

**Rule: Never leave Ronald hanging.** If he asked something in ANY channel and didn't get a response, that gets fixed this heartbeat.

---

## Reply Accountability

**Ronald always wants a reply.** Before anything else:

1. **Scan ALL channels** (see above) for messages from Ronald (user `228535096309841922`)
2. **Check if each message got a reply from you** — if Ronald said something and you never responded, you owe him one
3. **Check completed/failed tasks** — if a task finished or failed since the last heartbeat, Ronald needs an update
4. **Reply immediately** to anything unanswered — don't wait for the next heartbeat, send the reply now
5. **When in doubt, reply** — a short "on it" or "done" is better than silence

**Rule: Never leave Ronald hanging.** If he asked something, gave an instruction, or is waiting on a result — he gets a response. Every time.

---

## Cloud Health Check (Limp Mode Detection)

Every heartbeat, check if cloud APIs are reachable:

```bash
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 \
  https://api.anthropic.com/v1/models 2>/dev/null)
```

- **200 or 401** → Cloud reachable, normal mode
- **429** → Rate limited → Limp Mode
- **5xx or timeout/empty** → Cloud down → Limp Mode

**If Limp Mode detected:**
1. Post to #task-board: "⚡ Limp Mode active — cloud unavailable. Use #jack for assistance."
2. Update `memory/heartbeat-state.json` with `"limpMode": true, "limpSince": "<ISO timestamp>"`
3. Do NOT attempt cloud-heavy tasks — queue them as deferred

**If recovering from Limp Mode (was true, now cloud is back):**
1. Post to #task-board: "☁️ Cloud is back online. Exiting Limp Mode."
2. Update `"limpMode": false` in heartbeat-state.json
3. Process any deferred tasks

---

## Task Accountability Loop

Every heartbeat, run this sequence:

1. **Read `tasks.json`** — load the current task queue
2. **Check each task with status `pending` or `in-progress`:**
   - If the task has a `verify` command or check, run it to confirm completion
   - If complete → update status to `done`, set `completedAt` timestamp
   - If failed or stalled → attempt to finish it (re-run, re-delegate, or fix)
   - If blocked → leave as `blocked`, note the blocker
3. **Check on active sub-agents** — if any were spawned for tasks, verify they're still alive and making progress
4. **Log results** — update `tasks.json` with current state
5. **Post to #task-board** — After processing, post the full task list to Discord channel `1484408539974860871`
   - Use the Discord API (Bot token from openclaw.json) to POST a message
   - Format: emoji status per task (✅ done, 🔄 in-progress, ⏳ pending, 🚫 blocked, ❌ failed) + summary line
   - Also post immediately whenever a task status changes to `done`

## Task Schema

Each task in `tasks.json` follows:
```json
{
  "id": "task-001",
  "title": "Short description",
  "source": "ronald | apex | agent:<name>",
  "assignee": "apex | agent:<name>",
  "status": "pending | in-progress | done | blocked | failed",
  "priority": "critical | high | medium | low",
  "createdAt": "ISO timestamp",
  "completedAt": null,
  "verify": "How to confirm this is done (command, file check, etc)",
  "notes": "Context, blockers, progress"
}
```

## Rules

- **Ronald's tasks are always highest priority.** If Ronald asked for it, it gets done before self-assigned work.
- **Don't mark done unless verified.** "I think I did it" is not done. Run the check.
- **Retry up to 3 times** before marking `failed` and alerting Ronald.
- **Keep tasks.json clean** — move `done` tasks older than 7 days to `tasks-archive.json`.
- **When Ronald gives you a task in conversation**, add it to `tasks.json` immediately.
- **When you assign work to sub-agents**, add the task with `assignee: "agent:<name>"`.

## ⚠️ ALWAYS Use new-task-id.sh for New Task IDs — NEVER Guess

**Never manually choose a task ID number.** Always call the script to get the next unique ID:

```bash
TASK_ID=$(bash /Users/openclaw/.openclaw/workspace/scripts/new-task-id.sh)
```

This script atomically increments `nextTaskId` in tasks.json using a filesystem lock.
It guarantees no two tasks ever share the same ID, even if multiple agents run simultaneously.

**Rule: If you didn't call new-task-id.sh, you don't have a valid task ID.**

---

## ⚠️ ALWAYS Use jq to Update tasks.json

**Never use the `edit` tool on tasks.json** — it requires exact text matching and fails when another agent has modified the file.

**Always use `exec` with `jq`:**

```bash
# Mark a task done
cat ~/.openclaw/workspace/tasks.json | jq '
  (.tasks[] | select(.id == "task-XXX")) |= . + {
    "status": "done",
    "completedAt": "2026-03-20T12:00:00-07:00",
    "notes": "What was done."
  }
' > /tmp/tasks-update.json && cp /tmp/tasks-update.json ~/.openclaw/workspace/tasks.json

# Add a new task
cat ~/.openclaw/workspace/tasks.json | jq '.tasks += [{ "id": "task-XXX", ... }]' > /tmp/tasks-update.json && cp /tmp/tasks-update.json ~/.openclaw/workspace/tasks.json
```

This is atomic, JSON-safe, and immune to race conditions from concurrent edits.

---

## Ideas Intake Protocol (#ideas-intake)

**When a message from Ronald appears in #ideas-intake (`1484389265784836197`):**

1. **Never act on the idea immediately** — research first, always
2. **Multi-source research** (same workflow as Dynamic Market Research):
   - **Web search:** market size, competitors, pricing, trends
   - **Reddit/forums:** customer pain points, complaints, feature requests
   - **Review sites:** competitor weaknesses, 1-2 star reviews
   - **YouTube videos:** Use hybrid workflow:
     - Extract transcripts (`summarize --youtube auto --extract-only`)
     - Summarize each video (`gemma3:4b`, local)
     - Strategic analysis (`anthropic/claude-sonnet-4-5`)
     - Search: "[idea topic] review", "[idea topic] tutorial", "problems with [competitor]"
   - **Social media:** Twitter/X, LinkedIn for sentiment and buzz
   - **Competitor sites:** Direct analysis of positioning, pricing, features
3. **Write a detailed feasibility report** covering:
   - What the idea is and what problem it solves
   - Market opportunity (size, competition, trends) — backed by multi-source research
   - Technical feasibility (what it takes to build)
   - Business model options
   - Estimated effort/cost/timeline
   - Risks and blockers
   - Recommendation: pursue / park / pass
4. **Consolidate with Opus** (`anthropic/claude-opus-4-1`) — synthesize all research into final report
5. **Generate a PDF** using `npx md-to-pdf` and save to `/Users/openclaw/reports/`
6. **Post the PDF to #ideas-intake** with a brief summary message
7. **Create a task** in `tasks.json` for the idea if recommendation is "pursue"
8. **Only after the report is posted** may any execution begin

**Rule: No idea gets acted on without a multi-source feasibility report first. Ever.**

---

## Ideas Tracking — ideas.json

Every new idea submitted by Ronald (in #ideas-intake or anywhere) must be added to `ideas.json` at:
`/Users/openclaw/.openclaw/workspace/ideas.json`

Schema:
```json
{
  "id": "idea-XXX",
  "title": "Short name",
  "description": "What the idea is",
  "submittedAt": "YYYY-MM-DD",
  "channel": "channel-name",
  "status": "pending | researching | researched | discussed | in-progress | done | parked | passed",
  "recommendation": "pursue | park | pass | null",
  "reportFile": "filename.pdf or null",
  "taskId": "task-XXX or null",
  "notes": "context"
}
```

Update status whenever:
- Feasibility report is generated → `researched`
- Ronald greenlit it → `in-progress` + add taskId
- Task completed → `done`
- Ronald decided not to pursue → `parked` or `passed`

---

## 🔴 ALWAYS BE WORKING — Non-Negotiable

**The machine must always have something in motion. Every heartbeat:**

### Step 1: Check the Queue Manager
```bash
python3 /Users/openclaw/.openclaw/workspace/scripts/queue-manager.py status
```
This shows: agent slots used, pending queue, next task to start, stalls.

### Step 2: Agent Slot Rules (HARD LIMITS — never exceed)
- **Max 5 sub-agents per Anthropic model** (Sonnet, Opus counted separately)
- **Max 5 sub-agents per local model** (qwen3:8b, etc.)
- **Max 12 sub-agents total** across all models
- Before spawning ANY sub-agent: check slots via queue-manager
- If slots are full: add task to pending queue, do NOT spawn

### Step 3: Start Work (if slots available)
```bash
python3 /Users/openclaw/.openclaw/workspace/scripts/queue-manager.py next
```
- Returns the highest-priority pending task with an open slot
- Mark it `in-progress` in tasks.json
- Register the slot: `python3 queue-manager.py add-slot <model> <task_id> <session_id>`
- Spawn the sub-agent

### Step 4: Free Slots When Done
When a sub-agent completes:
```bash
python3 /Users/openclaw/.openclaw/workspace/scripts/queue-manager.py free-slot <model> <task_id>
```
Then immediately check if a queued task can now start.

### Step 5: Check for Stalls
```bash
python3 /Users/openclaw/.openclaw/workspace/scripts/queue-manager.py check-stalls
```
Any `in-progress` task with no update in 30+ min → investigate and restart.

### Priority Order
1. `critical` tasks — always first, regardless of project
2. `high` tasks — sorted by project priority (see queue.json projects)
3. `medium` / `low` — fill remaining slots

### Project Priority Order (from queue.json)
1. Infrastructure (dashboards, agents, core systems)
2. MEP AutoCAD Block Library
3. Plumbing CAD Suite
4. Baby Books KDP
5. HeartWatch
6. Contractor AI Prompt Pack
7. Solar Checklist

**Rule: Never spawn a sub-agent without checking slots first. Never leave slots idle if tasks are pending.**

---

## Heartbeat Posting Rule (Ronald — 2026-03-22, clarified 2026-03-23)

**Heartbeat status updates ALWAYS go to #status-updates (`1484389278246240368`).**

- Do NOT post heartbeat summaries to #general — EVER
- #general is for conversation only, not status updates
- Heartbeat = status channel, always

When heartbeat runs:
1. Check queue, cloud, services
2. If nothing needs attention → **Do not post anything anywhere** (silent, no reply)
3. If something needs attention → post alert to #status-updates with @mention if urgent

**Never post HEARTBEAT_OK to any channel.** It's an internal-only marker.

## Heartbeat Model (Updated 2026-03-23)

**Model:** `anthropic/claude-haiku-4-5`

**Why:** Gemma3:4b doesn't support tool calls (Discord API, file reads, etc.). Haiku is the cheapest cloud model with full tool support.

**Cost:** ~$0.03/heartbeat = ~$1.50/day for 48 heartbeats (still 10x cheaper than Sonnet).


## Discord Model Attribution (Universal Rule)

Every Discord message posted by any agent must end with:
```
_Model: [model-name]_
```
This includes heartbeat posts, status updates, task completions, and all cron-triggered messages.

---

## 💡 APEX Ideas Pipeline (Added 2026-03-24)

**Autonomous idea generation and feasibility system**

### How it works:
1. **Continuous capture:** As I analyze YouTube videos, research the web, or observe patterns → I add money-making ideas to `apex-ideas.json`
2. **Weekly analysis:** Every Monday 10 AM, I select top 3 most promising ideas and run full Opus feasibility analysis
3. **Reporting:** Feasibility PDFs posted to #apex-ideas (channel `1486194089111060501`) for Ronald to review
4. **Lifecycle:** captured → evaluating → analyzed → approved/parked/rejected

### Idea sources:
- YouTube video analysis (Alex Finn, Scott Simson, future channels)
- Web research and trend monitoring
- Autonomous pattern recognition during operations
- Cross-domain synthesis

### Integration points:
- **YouTube monitors:** Extract ideas during video analysis, auto-add to pipeline
- **Morning briefing:** Include idea count and top candidate
- **Weekly synthesis:** Include feasibility analysis results
- **Dashboard:** Show idea pipeline status

### Files:
- `apex-ideas.json` - main tracking file
- `scripts/add-apex-idea.sh` - CLI tool for adding ideas
- `/reports/` - feasibility PDFs saved here

### Cron schedule:
- **Weekly feasibility:** Mondays 10 AM (cron `0 10 * * 1`)
- **YouTube monitors:** Already updated to capture ideas automatically

**Rule:** Any promising revenue opportunity discovered during research gets captured immediately. This is continuous improvement feeding the business development pipeline.


---

## 📺 Daily YouTube Discovery (Added 2026-03-24)

**Autonomous research and channel curation**

### Daily Workflow (9 AM PT)
1. **Search YouTube:** ~5 videos matching our focus areas
2. **Evaluate quality:** Actionable content, real implementations, applicable to CrispWave
3. **Analyze best video:** Full Opus analysis for insights + idea extraction
4. **Follow 1 new channel:** Based on value potential
5. **Post daily status:** Channel list + insights to #youtube-intel

### Search Focus Areas
- AI automation & agent orchestration
- Business productivity & agency workflows
- Construction/MEP/solar tech innovation
- Local LLM optimization
- Revenue-generating AI strategies
- No-code tools & automation
- Vertical SaaS opportunities

### Channel Follow Criteria (2+ required)
- Teaches skills applicable to CrispWave
- Covers tools/platforms we use or could use
- Demonstrates revenue-generating strategies
- Shows real implementations (not concepts)
- Domain expertise we lack
- Consistently high content quality
- Active channel (regular uploads)

### Tracking
- **followed-channels.json:** Master list of all channels + metadata
- **daily-discovery.json:** Log of videos evaluated each day
- **search-strategy.md:** Search topics, rotation schedule, refinement notes

### Integration
- All followed channels get 6-hour monitoring cron jobs
- Ideas auto-captured to apex-ideas.json
- Daily status posted to #youtube-intel (1485690755283419147)
- Insights fed into continuous improvement loop

**Rule:** I choose what to research based on what will help most. Full autonomy on content discovery and channel selection. Ronald gets daily transparency via status posts.

