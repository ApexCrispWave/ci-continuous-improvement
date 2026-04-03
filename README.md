# CrispWave Continuous Improvement System

Autonomous self-optimization framework for AI-driven operations. This repo centralizes all CI planning, cron job configurations, audits, market research, video analysis, and continuous improvement initiatives.

## 📊 What's Inside

### 📋 Documentation (`/docs`)

- **crispwave-continuous-improvement-system.md** — Core CI system design (3 pillars: technical, business, agent)
- **CI-SYSTEM-HOWTO.md** — How to run and maintain the CI system
- **cron-final-schedule.md** — Complete master schedule for all 23 cron jobs (optimized for single GPU)
- **cron-schedule-optimized.md** — Detailed optimization strategy and stagger timing
- **cron-changes-applied.md** — Log of all schedule changes made 2026-04-02
- **HEARTBEAT.md** — Lean task watchdog system (30-min stall detection)
- **HEARTBEAT-COMPACT.md** — Compact version
- **HEARTBEAT-FULL-BACKUP.md** — Full backup with history

### 🔄 Cron Jobs (`/crons`)

Master list of all 23 active cron jobs:

| Job | Schedule | Model | Status |
|-----|----------|-------|--------|
| journal-agent | 4-5:30 AM daily | qwen3:8b | ✅ |
| nightly-extraction | 6:00 AM daily | qwen3:8b | ✅ |
| nightly-backup | 6:02 AM daily | qwen3:8b | ✅ |
| nightly-chatlog-export | 6:04 AM daily | qwen3:8b | ✅ |
| compact-nightly-channels | 6:06 AM daily | qwen3:8b | ✅ |
| morning-briefing | 7:00 AM daily | qwen3:8b | ✅ |
| heartbeat-synced | Every 3 hours | gemma3:4b | ✅ |
| compact-aggressive-channels | Every 6 hours @ :10 | qwen3:8b | ✅ |
| 9to5mac-scraper | 1:00 AM daily | qwen3:8b | ✅ |
| nightly-research-2am | 2:00 AM daily | qwen3:14b/8b | ✅ |
| 9to5mac-style-guide-refresh | 3:00 AM (1st of month) | qwen3:8b | ✅ |
| CI: Market Pulse | Friday 6:00 PM | qwen3:8b | ✅ |
| CI: Monthly Synthesis | 1st Sunday 12:00 AM | qwen3:8b | ✅ |
| CI: Local Model R&D | 1st Sunday 6:00 AM | qwen3:8b | ✅ |
| CI: Technical Audit | Monday 6:00 AM | qwen3:8b | ✅ |
| CI: Agent Performance Review | Monday 6:03 AM | qwen3:8b | ✅ |
| CI: Market Research | 1st Monday 10:22 PM | qwen3:8b | ✅ |
| CI: Video Analysis | Sunday 11:00 PM | qwen3:8b | ✅ |
| Weekly Briefing Evolution Review | Sunday 9:00 AM | qwen3:8b | ✅ |
| youtube-monitor (Tim Carambat) | Every 72 hours | qwen3:8b | ✅ |
| youtube-monitor (Alex Finn) | Every 72 hours | qwen3:8b | ✅ |
| compact-weekly-channels | Sunday 6:05 AM | qwen3:8b | ✅ |

**Key:** All jobs staggered to avoid GPU collisions. Zero overlapping execution. See `/docs/cron-final-schedule.md` for complete details.

### 🔧 Scripts (`/scripts`)

- **setup-cron.sh** — Bootstrap all cron jobs
- **batch-cron.sh** — Batch operations on crons
- **heartbeat-check.sh** — Verify task heartbeat health

### 📈 Improvements (`/improvements`)

Organized by pillar:

- **cost-optimization-plan.md** — 30% → 50% → 60% cloud cost reduction roadmap
- **daily-briefing-evolution.md** — Morning briefing optimization history
- **project-knowledge-system-2026-03-24.md** — Knowledge graph improvements
- **agent/** — APEX self-optimization reports
- **business/** — Product & revenue improvements
- **technical/** — Infrastructure & tooling improvements

### 🔬 Research (`/research`)

Output from continuous improvement jobs:

- `market-pulse/` — Weekly market analysis
- `video-analysis/` — Weekly video intelligence (25 videos analyzed)
- `market-research/` — Monthly competitive analysis
- `technical-audit/` — Weekly infrastructure health
- `local-models/` — Local LLM research & benchmarking

## 🎯 How It Works

### Weekly Cycle (Every Sunday)

1. **6:05 AM** — Compact weekly Discord channels
2. **6:00 AM** — Nightly cleanup batch (extraction, backup, export, compact-nightly)
3. **7:00 AM** — Morning briefing generated
4. **9:00 AM** — Weekly Briefing Evolution Review (identify improvements)
5. **11:00 PM** — Video Analysis (25 YouTube videos analyzed)
6. **12:00 AM (Monday)** — Monthly Synthesis (1st Sunday only)

### Monthly Cycle (First of Month)

1. **3:00 AM** — 9to5Mac style guide refresh
2. **6:00 AM (Sunday)** — Local Model R&D (1st Sunday only)
3. **12:00 AM** — Monthly Synthesis (aggregate weekly reports, top 5 improvements)
4. **10:22 PM (Monday)** — Market Research (1st Monday only)

### Heartbeat (Every 3 Hours)

- **6, 9, 12, 3, 6, 9 PM** — Check for stalled tasks >30 min

## 📊 GPU Optimization (2026-04-02)

**Before:** 8-10 GPU hours/day, 4-8 collisions/day  
**After:** 5-6 GPU hours/day, 0 collisions  
**Savings:** 30-40% GPU load reduction

All tasks run on local models (`qwen3:8b`, `qwen3:14b`, `gemma3:4b`). Zero cloud API dependencies.

## 🚀 Quick Start

```bash
# Clone this repo
git clone https://github.com/ApexCrispWave/ci-continuous-improvement.git
cd ci-continuous-improvement

# View cron schedule
cat docs/cron-final-schedule.md

# Check CI system status
bash scripts/heartbeat-check.sh

# View latest improvements
cat improvements/cost-optimization-plan.md
```

## 📝 Key Documents

| Document | Purpose | Audience |
|----------|---------|----------|
| crispwave-continuous-improvement-system.md | System design & architecture | Technical leads |
| CI-SYSTEM-HOWTO.md | Operating manual | All users |
| cron-final-schedule.md | Master schedule | Operators |
| HEARTBEAT.md | Task watchdog | Developers |
| cost-optimization-plan.md | Cost reduction roadmap | Finance/Product |

## 🔐 Governance

- **Owner:** APEX (CEO, autonomous with oversight)
- **Escalations:** Strategy & irreversible actions → Ronald
- **Update Frequency:** Weekly CI reports, monthly synthesis
- **Review Cycle:** Every 1st Sunday of month (synthesis + market research)

## 📦 Latest Updates (2026-04-02)

✅ All 23 crons optimized for single-GPU execution  
✅ Schedule conflicts eliminated (staggered execution)  
✅ 30-40% GPU load reduction achieved  
✅ Task-111 created: CI audit + blog pipeline integration  
✅ This repo created to centralize all CI planning & documentation

## 🤝 Contributing

All improvements should be:
1. Logged to `improvements/[pillar]/` with date
2. Pushed to this repo
3. Summarized in monthly synthesis report
4. Reviewed in next month's CI cycle

---

**Last Updated:** 2026-04-02  
**Version:** 1.0  
**Status:** Active (23/23 crons running)
