# Optimized Cron Schedule for Single GPU (M4 Pro)

**Goal:** No overlapping `qwen3:8b` or heavy tasks. Spacing: **minimum 1 hour** between task starts.

**Timezone:** America/Los_Angeles

---

## Daily Jobs (by time)

### 1:00 AM — 9to5Mac Scraper
- **Job:** `9to5mac-scraper-overnight`
- **Duration:** ~5 min (bash script, light I/O)
- **Model:** `qwen3:8b` (no summarization)
- **Schedule:** `0 1 * * *`

### 2:00 AM — Blog Post Generator
- **Job:** `nightly-research-2am`
- **Duration:** ~3 min (qwen3:14b script launch)
- **Model:** `qwen3:14b` → fallback `qwen3:8b`
- **Schedule:** `0 2 * * *`

### 2:30 AM — 9to5Mac Style Guide Refresh (1st of month)
- **Job:** `9to5mac-style-guide-refresh`
- **Duration:** ~45 sec
- **Model:** `qwen3:8b`
- **Schedule:** `0 2 1 * *` (1st of every month)
- **Note:** Runs only 1x/month, low priority

### 6:00 AM — Nightly Cleanup Batch (4 jobs)
⚠️ **STAGGERED TO AVOID COLLISION**

| Time | Job | Duration | Model | Notes |
|------|-----|----------|-------|-------|
| 6:00 AM | `nightly-extraction` | ~80 sec | qwen3:8b | Memory extraction |
| 6:02 AM | `nightly-backup` | ~30 sec | qwen3:8b | Backup script |
| 6:04 AM | `nightly-chatlog-export` | ~6 sec | qwen3:8b | Quick export |
| 6:06 AM | `compact-nightly-channels` | ~50 sec | qwen3:8b | Discord cleanup |

**Implementation:** Add 2-min stagger via `staggerMs: 120000` in each job

### 7:00 AM — Morning Briefing
- **Job:** `morning-briefing-07am`
- **Duration:** ~60 sec
- **Model:** `qwen3:8b`
- **Schedule:** `0 7 * * *`

### Heartbeat (Every 3 hours)
- **Job:** `heartbeat-synced`
- **Times:** 6:00, 9:00, 12:00, 3:00 PM, 6:00 PM, 9:00 PM
- **Duration:** ~15 sec
- **Model:** `gemma3:4b` (ultra-fast, no conflict)
- **Schedule:** `0 6,9,12,15,18,21 * * *`
- **Stagger:** 300s already applied ✅

### Journal Update (30-min intervals, 6am-11pm)
- **Job:** `journal-agent`
- **Times:** 6:00, 6:30, 7:00, 7:30... (every 30 min)
- **Duration:** ~80 sec each
- **Model:** `qwen3:8b`
- **Schedule:** `0,30 6-23 * * *`
- ⚠️ **CONFLICTS WITH OTHER 6 AM JOBS**
- **ACTION:** Disable or shift to 5:30 AM, 5:00 AM, 4:30 AM (overnight window)

### Channel Compaction (Every 6 hours)
- **Job:** `compact-aggressive-channels`
- **Times:** 12:00 AM, 6:00 AM, 12:00 PM, 6:00 PM
- **Duration:** ~45 sec
- **Model:** `qwen3:8b`
- **Schedule:** `0 */6 * * *`
- **Stagger:** 300s applied ✅
- ⚠️ **6 AM CONFLICT:** Collides with morning cleanup batch
- **ACTION:** Shift to 6:10 AM (after cleanup batch clears)

---

## Weekly Jobs

### Every 3 Days — YouTube Monitors
- **Jobs:** 
  - Tim Carambat YouTube Monitor
  - Alex Finn YouTube Monitor
- **Duration:** ~45-60 sec each
- **Model:** `qwen3:8b`
- **Schedule:** `every 259200000 ms` (every 72 hours)
- **Anchor times:** Staggered at setup
- **Status:** ✅ No conflict (runs infrequently)

### Friday 6:00 PM — Market Pulse
- **Job:** `CI: Market Pulse (Weekly)`
- **Duration:** ~22 sec
- **Model:** `qwen3:8b`
- **Schedule:** `0 18 * * 5`
- **Status:** ✅ No conflict

### Sunday 6:00 AM — Sunday Batch (3 jobs)
⚠️ **STAGGERED**

| Time | Job | Duration | Model | Notes |
|------|-----|----------|-------|-------|
| 6:00 AM | `compact-weekly-channels` | ~34 sec | qwen3:8b | Weekly cleanup |
| 6:01 AM | `CI: Local Model R&D` | ~5 sec (condition check) | qwen3:8b | 1st Sunday only |
| 6:03 AM | `CI: Technical Audit` | ~32 sec | qwen3:8b | Monday 6 AM actually |

### Sunday 9:00 AM — Weekly Briefing Evolution
- **Job:** `Weekly Briefing Evolution Review`
- **Duration:** ~29 sec
- **Model:** `qwen3:8b`
- **Schedule:** `0 9 * * 0`
- **Status:** ✅ No conflict (9 AM, clear window)

### Sunday 11:00 PM — Video Analysis
- **Job:** `CI: Video Analysis (25/week)`
- **Duration:** ~5 sec (template generation only)
- **Model:** `qwen3:8b`
- **Schedule:** `0 23 * * 0`
- **Status:** ✅ No conflict

### Sunday 12:00 AM → Monday 12:00 AM — Monthly Synthesis
- **Job:** `CI: Monthly Synthesis`
- **Duration:** ~7 sec (condition check)
- **Model:** `qwen3:8b`
- **Schedule:** `0 0 * * 0` (1st Sunday midnight)
- **Status:** ✅ No conflict (1x/month)

### Monday 10:22 PM — Market Research (1st Monday only)
- **Job:** `CI: Market Research (Monthly)`
- **Duration:** ~8 sec (condition check, actual run is 3600s timeout)
- **Model:** `qwen3:8b`
- **Schedule:** `0 22 * * 1`
- **Note:** Only 1st Monday of month
- **Status:** ⚠️ Long timeout (3600s) — can block other jobs
- **ACTION:** Run on dedicated night (e.g., shift to Tuesday 10 PM if possible)

---

## Conflicts & Fixes

### ❌ 6:00 AM Collision
**Jobs running simultaneously:**
- `nightly-extraction` 
- `nightly-backup`
- `nightly-chatlog-export`
- `compact-nightly-channels`
- `journal-agent` (every 30 min includes 6:00 AM)
- `compact-aggressive-channels` (every 6 hours includes 6:00 AM)
- `CI: Local Model R&D` (Sundays only)
- `CI: Technical Audit` (Mondays only)

**Fix:** Apply 2-4 minute stagger within batch. Use `staggerMs` in cron updates.

### ❌ Journal Update (6:00-23:00 every 30 min)
**Issue:** Runs 36 times/day, overlaps with other 6 AM jobs and every evening task
**Options:**
1. Disable entirely (not critical)
2. Shift to 4:00-5:30 AM window (off-peak)
3. Reduce frequency to hourly (1x/hour instead of 2x/hour)

**Recommendation:** Shift to `0,30 4-5 * * *` (4-5:30 AM, safe window)

---

## Optimized Schedule (Revised)

### Apply These Changes:

```bash
# 1. Fix 6:00 AM collision with stagger
cron update nightly-extraction --staggerMs 0
cron update nightly-backup --staggerMs 120000
cron update nightly-chatlog-export --staggerMs 240000
cron update compact-nightly-channels --staggerMs 360000

# 2. Move compact-aggressive-channels off 6 AM
# Change from: 0 */6 * * *
# To: 10 */6 * * * (every 6 hours at :10 past)
cron update compact-aggressive-channels --expr "10 */6 * * *"

# 3. Shift journal to off-peak
# Change from: 0,30 6-23 * * *
# To: 0,30 4-5 * * * (only 4-5:30 AM, safe window)
cron update journal-agent --expr "0,30 4-5 * * *"

# 4. Monitor market-research (1st Monday 10 PM) for long runs
# If it exceeds 30 min, either:
#   - Reduce timeout or split into smaller tasks
#   - Schedule for dedicated night (e.g., Tuesday after market-pulse)
```

---

## Final Validated Schedule (Single GPU Safe)

| Time | Job | Duration | Model | Notes |
|------|-----|----------|-------|-------|
| **4:00 AM** | journal-agent | 30-90s | qwen3:8b | Shifted (off-peak) |
| **4:30 AM** | journal-agent | 30-90s | qwen3:8b | Shifted (off-peak) |
| **5:00 AM** | journal-agent | 30-90s | qwen3:8b | Shifted (off-peak) |
| **5:30 AM** | journal-agent | 30-90s | qwen3:8b | Shifted (off-peak) |
| **6:00 AM** | nightly-extraction | 80s | qwen3:8b | Stagger: 0ms |
| **6:02 AM** | nightly-backup | 30s | qwen3:8b | Stagger: 120s |
| **6:04 AM** | nightly-chatlog-export | 6s | qwen3:8b | Stagger: 240s |
| **6:06 AM** | compact-nightly-channels | 50s | qwen3:8b | Stagger: 360s |
| **6:00 AM** | heartbeat | 15s | gemma3:4b | ✅ Fast, no conflict |
| **7:00 AM** | morning-briefing | 60s | qwen3:8b | ✅ Clear window |
| **9:00 AM** | heartbeat | 15s | gemma3:4b | ✅ 3-hour interval |
| **10:10 AM** | compact-aggressive | 45s | qwen3:8b | Shifted from 12 AM |
| **12:00 PM** | heartbeat | 15s | gemma3:4b | ✅ 3-hour interval |
| **12:10 PM** | compact-aggressive | 45s | qwen3:8b | Shifted from 6 AM |
| **3:00 PM** | heartbeat | 15s | gemma3:4b | ✅ 3-hour interval |
| **6:00 PM** | heartbeat | 15s | gemma3:4b | ✅ 3-hour interval |
| **6:10 PM** | compact-aggressive | 45s | qwen3:8b | Shifted from 12 PM |
| **6:00 PM Friday** | market-pulse | 22s | qwen3:8b | ✅ Clear window |
| **9:00 PM** | heartbeat | 15s | gemma3:4b | ✅ 3-hour interval |
| **12:10 AM** | compact-aggressive | 45s | qwen3:8b | Shifted from 6 PM |
| **1:00 AM** | 9to5mac-scraper | 5s | qwen3:8b | ✅ Clear window |
| **2:00 AM** | blog-post-gen | 3s | qwen3:14b/8b | ✅ Clear window |
| **2:30 AM (1st)** | style-guide-refresh | 45s | qwen3:8b | ✅ Monthly only |
| **6:00 AM Sunday** | compact-weekly | 34s | qwen3:8b | ✅ Staggered |
| **6:01 AM Sunday** | local-model-r&d | 5s | qwen3:8b | ✅ 1st Sunday only |
| **9:00 AM Sunday** | briefing-evolution | 29s | qwen3:8b | ✅ Clear window |
| **10:22 PM Monday (1st)** | market-research | 8s+ | qwen3:8b | ⚠️ Long timeout |
| **11:00 PM Sunday** | video-analysis | 5s | qwen3:8b | ✅ Clear window |
| **12:00 AM Sunday** | monthly-synthesis | 7s | qwen3:8b | ✅ 1st Sunday only |

---

## Cost & Performance Impact

**Before:** Overlaps → GPU contention → slower jobs, potential queueing  
**After:** Staggered → Sequential execution → predictable timing, <$0 (all local)

**GPU Utilization:**
- Peak: 3-4 jobs running (each 30-90s) = ~2-4 min per hour
- Average: 1-2 jobs running = ~30-60s per hour
- **Idle:** ~55+ min per hour = **excellent for other tasks**

---

## Next Steps

1. Apply all 4 cron updates (see "Apply These Changes" section)
2. Test for 1 week, monitor heartbeat for stalls
3. Adjust stagger timing if needed
4. Document final schedule in AGENTS.md

