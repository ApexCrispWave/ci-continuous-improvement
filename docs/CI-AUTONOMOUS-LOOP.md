# CI Autonomous Improvement Loop

**Last Updated:** 2026-04-02
**Status:** Active — all CI crons persist output to disk AND auto-ingest into research DB
**Model Escalation:** qwen3:8b → claude-opus-4-1 for strategy (see CI-MODEL-STRATEGY.md)

---

## Overview

CrispWave's autonomous improvement loop is a fully self-sustaining data pipeline where CI cron jobs execute, persist structured output to disk, and feed downstream systems (blog generator, heartbeat monitoring, next-cycle planning).

```
┌─────────────────────────────────────────────────────────────────────┐
│                     CI AUTONOMOUS LOOP                              │
│                                                                     │
│  Market Pulse     Video Analysis    Technical     Agent Perf.  GitHub Audit │
│  (Daily/Weekly)   (Weekly)          Audit (Wkly)  Review(Wkly) (Weekly Mon)│
│       │                │                │               │           │      │
│       ▼                ▼                ▼               ▼           ▼      │
│  research/         research/       improvements/   improvements/ research/ │
│  market-pulse/     video-         technical/      agent/        github-   │
│  YYYY-MM-DD.json   analysis/      YYYY-WNN.md     YYYY-WNN.md  audit/    │
│                    YYYY-WNN.md                                  YYYY-WNN.md│
│       │                │                │               │           │      │
│       └────────────────┴────────────────┴───────────────┴───────────┘      │
│                              │                                      │
│                              ▼                                      │
│                    ci-aggregate.sh                                  │
│                              │                                      │
│                              ▼                                      │
│              research/ci-weekly-aggregate.json                      │
│                              │                                      │
│              ┌───────────────┼────────────────┐                    │
│              ▼               ▼                ▼                    │
│       research-db/     Blog Generator   Heartbeat Monitor          │
│       research.db      (generate-blog-  (system health             │
│       (FTS5 SQLite)     post.py)         checks)                   │
│              │               │                                      │
│   ci-research-query.sh       │                                      │
│   (agents query CI           │                                      │
│    data from here)           │                                      │
│                    ┌─────────┴──────────┐                           │
│                    ▼                    ▼                            │
│            Blog Generator       Heartbeat Monitor                   │
│            (generate-blog-      (system health                      │
│             post.py)             checks)                            │
│                    │                                                 │
│                    ▼                                                 │
│            ai-research-blog/                                        │
│            _posts/YYYY-MM-DD-*.md                                   │
│                    │                                                 │
│                    ▼                                                 │
│              Discord #ops                                            │
│              #system-health                                          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## CI Crons: Script Details

### 1. Market Pulse Daily (`scripts/market-pulse.sh`)
- **Schedule:** Every Friday, 6:00 PM PT
- **Model:** `gemma3:4b` (fast, local)
- **Input:** Ollama prompt → sector news scan
- **Output:** `research/market-pulse/YYYY-MM-DD.json`
- **Format:** JSON with findings array, impact levels, significant_events_count
- **Downstream:** CI aggregator reads all files from past 7 days

**Output schema:**
```json
{
  "date": "2026-04-02",
  "model": "gemma3:4b",
  "scan_period": "past_7_days",
  "findings": [
    {
      "sector": "MEP CAD Tools",
      "has_news": true,
      "impact": "high|medium|low",
      "event": "Description",
      "recommended_action": "What to do"
    }
  ],
  "significant_events_count": 3,
  "summary": "One-sentence overall market summary"
}
```

---

### 2. Market Pulse Weekly (`scripts/market-pulse-weekly.sh`)
- **Schedule:** Sunday, 6:30 AM PT
- **Model:** `qwen3.5:9b` (primary), `qwen3:8b` (fallback)
- **Output:** `research/market-pulse/YYYY-MM-DD-market.md`
- **Format:** Rich markdown with sector analysis, opportunities, threats
- **Quality gate:** Must be ≥1000 bytes AND contain "Market|Trend|Opportunity"
- **Downstream:** CI aggregator extracts opportunity lines

---

### 3. Video Analysis (`scripts/video-analysis.sh`)
- **Schedule:** Sunday, 11:00 PM PT
- **Model:** `qwen3:8b` (local)
- **Output:** `research/video-analysis/YYYY-WNN.md`
- **Metrics:** `research/video-analysis/YYYY-WNN-metrics.json`
- **Format:** Markdown report with topic analysis + top 10 insights
- **Downstream:** CI aggregator extracts numbered insights

---

### 4. Technical Audit (`scripts/technical-audit.sh`)
- **Schedule:** Sunday, 10:00 PM PT
- **Model:** `qwen3:8b` (local)
- **Input:** Real system data — disk, memory, ollama models, CI health logs, cron config
- **Output:** `improvements/technical/YYYY-WNN.md`
- **Downstream:** CI aggregator extracts action items + health status (GREEN/YELLOW/RED)

---

### 5. Agent Performance Review (`scripts/agent-performance-review.sh`)
- **Schedule:** Sunday, 9:00 PM PT
- **Model:** `qwen3:8b` (local)
- **Input:** tasks.json, health logs, memory files, cost data
- **Output:** `improvements/agent/YYYY-WNN.md`
- **Downstream:** CI aggregator extracts learnings + task completion rate

---

### 6. GitHub Repository Audit (`scripts/github-audit.sh`)
- **Schedule:** Monday, 6:10 AM PT (cron: `10 6 * * 1`)
- **Model:** `qwen3:8b` (initial scan) → `claude-opus-4-1` (strategic escalation)
- **Input:** `gh repo list ApexCrispWave` + per-repo API checks (README, workflows, issues)
- **Output:** `research/github-audit/YYYY-WNN.md`
- **Research DB Type:** `ci-github`
- **Escalation:** Triggered when health rating is NEEDS_WORK or CRITICAL
- **Escalation Script:** `scripts/ci-escalate-to-opus.sh`
- **Downstream:** CI aggregator, blog generator, planning agents
- **Query:** `bash scripts/ci-research-query.sh --type github --recent 7`

**What it checks:**
- README and .gitignore presence
- GitHub Actions workflow coverage
- Branch protection status
- Open issues/PR counts
- Stale repo detection (30d/60d thresholds)
- Integration gaps between related repos
- Duplicate/abandoned repo detection

**Model Escalation Pattern:**
```
qwen3:8b scans → NEEDS_WORK/CRITICAL found → ci-escalate-to-opus.sh
→ claude-opus-4-1 strategic analysis → P1/P2/P3 action plan
→ qwen3:8b implements fixes
```

See `CI-MODEL-STRATEGY.md` for full escalation rules.

---

## CI Aggregator (`scripts/ci-aggregate.sh`)

Runs after all weekly CI jobs (e.g., Sunday midnight or Monday morning).

**What it does:**
1. Reads all CI output files from past 14 days
2. Extracts structured signals from each
3. Compiles into `research/ci-weekly-aggregate.json`
4. Archives previous week's aggregate to `research/ci-archive/`

**Output feeds:**
- **Blog generator** (`generate-blog-post.py`): Loaded via `load_ci_data()`. Injected as context into blog post generation. Auto-loaded if <12h old or if `INCLUDE_CI_DATA=1`.
- **Heartbeat monitoring**: Future — health dashboard reads aggregate for trend data
- **Next-cycle planning**: Future — planning agent reads strategic insights from aggregate

---

## Health Logging

Every CI cron writes to `health-logs/YYYY-MM-DD.json`:

```json
{
  "date": "2026-04-02",
  "tasks": {
    "market-pulse-daily": {
      "status": "success",
      "start_time": 1743656894,
      "end_time": 1743656906,
      "runtime_seconds": 12,
      "output_size_bytes": 3329,
      "model": "gemma3:4b",
      "error": ""
    }
  }
}
```

The technical audit and agent performance review scripts read these logs to assess CI reliability.

---

## Discord Announcements

Each cron announces completion to Discord:
- **Market pulse** → `#ops` (1484410717900771498)
- **Video analysis** → `#ops`
- **Technical audit** → `#system-health` (1484389324622659717)
- **Agent performance** → `#ops`
- **CI aggregate** → `#ops`

Message format: `_Model: model-name_` suffix on every message (per AGENTS.md).

---

## Blog Generator Integration

`scripts/generate-blog-post.py` integrates CI data via:

```python
# Load CI data (auto-loads if <12h old, or forced with INCLUDE_CI_DATA=1)
ci_data = load_ci_data()

# Injects into blog post generation as context
if ci_data:
    post = inject_ci_context(post, ci_data)
```

CI data enriches blog posts with:
- Market trend signals from market-pulse
- Video insights and emerging topics
- Technical lessons from infrastructure audits
- Performance observations from agent review

---

## Output Directory Structure

```
workspace/
├── research/
│   ├── market-pulse/
│   │   ├── 2026-04-02.json          ← daily market pulse
│   │   ├── 2026-04-05-market.md     ← weekly deep synthesis
│   │   └── ...
│   ├── video-analysis/
│   │   ├── 2026-W13.md              ← weekly video report
│   │   ├── 2026-W13-metrics.json    ← job metrics
│   │   └── ...
│   ├── ci-weekly-aggregate.json     ← current week's compiled data
│   └── ci-archive/
│       └── ci-weekly-aggregate-2026-W12.json  ← archived
├── improvements/
│   ├── technical/
│   │   └── 2026-W13.md              ← infrastructure audit
│   └── agent/
│       └── 2026-W13.md              ← performance review
└── health-logs/
    └── 2026-04-02.json              ← CI job execution metrics
```

---

## Testing the Loop

To manually trigger and verify end-to-end:

```bash
# 1. Run market pulse (fast, ~12s with gemma3:4b)
bash scripts/market-pulse.sh

# 2. Run CI aggregator (fast, <5s, pure python)
bash scripts/ci-aggregate.sh

# 3. Verify blog generator reads CI data
INCLUDE_CI_DATA=1 python3 scripts/generate-blog-post.py --dry-run 2>&1 | grep "CI data"

# 4. Check output files
ls -la research/market-pulse/
ls -la research/ci-weekly-aggregate.json
cat health-logs/$(date +%Y-%m-%d).json | python3 -m json.tool
```

---

## Failure Handling

Each script:
1. Tries primary model → quality gate → success
2. Falls back to secondary model (where applicable)
3. Writes a structured failure JSON/markdown if both fail
4. Logs failure to health-logs/ for audit trail
5. Still attempts Discord announcement on failure

The CI aggregator handles missing/stale files gracefully — it reports `jobs_failed` count but continues processing available data.

---

---

## CI Data in Research Layer

**Added:** 2026-04-02

All CI script outputs are automatically ingested into the SQLite research database (`research-db/research.db`) after every run. This makes CI intelligence queryable alongside all other CrispWave research.

### How It Works

Each CI script calls the ingest hook after writing its output:
```bash
bash "$WORKSPACE/research-db/research-ingest-hook.sh" "$OUTPUT_FILE"
```

The hook calls `research-db/ingest.py --file <path>` which:
1. Detects the source type from the file path
2. Extracts date, domain, tags, and title
3. Inserts into SQLite FTS5 index (`research` table)
4. Skips duplicates (INSERT OR IGNORE)

### CI Source Types in DB

| CI Script | Output File | DB source_type |
|-----------|-------------|----------------|
| `market-pulse.sh` | `research/market-pulse/YYYY-MM-DD.json` | `ci-market` |
| `video-analysis.sh` | `research/video-analysis/YYYY-WNN.md` | `ci-video` |
| `technical-audit.sh` | `improvements/technical/YYYY-WNN.md` | `ci-technical` |
| `agent-performance-review.sh` | `improvements/agent/YYYY-WNN.md` | `ci-agent` |
| `ci-aggregate.sh` | `research/ci-weekly-aggregate.json` | `ci-aggregate` |

### Querying CI Data

**Convenience wrapper (recommended for agents):**
```bash
# All CI data from last 7 days
bash scripts/ci-research-query.sh

# Specific CI type
bash scripts/ci-research-query.sh --type market
bash scripts/ci-research-query.sh --type video
bash scripts/ci-research-query.sh --type technical
bash scripts/ci-research-query.sh --type agent
bash scripts/ci-research-query.sh --type aggregate

# With FTS search + CI type filter
bash scripts/ci-research-query.sh "AI agents" --type market

# More options
bash scripts/ci-research-query.sh --recent 14 --limit 20
bash scripts/ci-research-query.sh --json --type video
bash scripts/ci-research-query.sh --stats   # CI DB stats
```

**Direct research-query with CI type filter:**
```bash
# Full-text search filtered to CI market data
bash research-db/research-query.sh "AI agents" --type ci-market --recent 7

# All technical audit results
bash research-db/research-query.sh --type ci-technical --recent 30

# Agent performance history
bash research-db/research-query.sh --type ci-agent --limit 5
```

### Planning Agent Pattern

Agents preparing weekly plans or blog posts can now query CI insights:
```bash
# Get latest market intelligence
MARKET=$(bash scripts/ci-research-query.sh --type market --recent 7 --json)

# Get video/content trends
VIDEO=$(bash scripts/ci-research-query.sh --type video --recent 14)

# Get technical recommendations from audit
TECH=$(bash scripts/ci-research-query.sh --type technical --recent 7)

# Cross-domain: search all CI data for a topic
bash scripts/ci-research-query.sh "cost optimization" --recent 30
```

---

---

## Model Escalation Strategy

All CI crons follow the **qwen3:8b → claude-opus-4-1** escalation pattern:

```
CI Cron starts
  ↓
gemma3:4b (triage/heartbeat) OR qwen3:8b (default worker scan)
  ↓
Findings evaluation
  ├── GOOD: write output, ingest to research-db, done
  └── NEEDS_WORK / CRITICAL / has_strategy:
        ↓
      ci-escalate-to-opus.sh
        ↓
      claude-opus-4-1 → P1/P2/P3 action plan
        ↓
      Recommendations added to output
        ↓
      qwen3:8b implements fixes (optional immediate action)
```

**When to escalate:** Health rating is NEEDS_WORK or CRITICAL, or findings touch architecture/strategy.
**When NOT to escalate:** Routine status checks, simple scans, no significant findings.
**Cost:** Local scan ~$0.001, Opus escalation ~$0.10–0.30.

Full model assignment matrix: see `CI-MODEL-STRATEGY.md`.

---

## Future Enhancements

- [x] CI outputs auto-ingest into research DB (done 2026-04-02)
- [x] GitHub repo audit cron added (done 2026-04-02)
- [x] Model escalation strategy: qwen3:8b → Opus (done 2026-04-02)
- [x] CI-MODEL-STRATEGY.md created (done 2026-04-02)
- [ ] Add `competitive-analysis.sh` to the loop (writes to `research/competitive/`)
- [ ] Heartbeat monitor reads aggregate for trending metrics dashboard
- [ ] Weekly planning agent reads improvements/ to generate next-week priorities
- [ ] Slack/email digest for weekly aggregate summary
- [ ] Automated model quality scoring (track output quality over time)
