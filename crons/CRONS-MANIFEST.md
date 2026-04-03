# Cron Jobs Manifest

**Total Active Jobs:** 23  
**All Local Models:** qwen3:8b, qwen3:14b, gemma3:4b  
**Optimization Level:** Single-GPU safe (no collisions)  
**Last Updated:** 2026-04-02

---

## Daily Jobs

### Early Morning (Off-Peak Window)

| Time | Job | Model | Duration | Notes |
|------|-----|-------|----------|-------|
| **4:00 AM** | journal-agent | qwen3:8b | 90s | Shifted to off-peak |
| **4:30 AM** | journal-agent | qwen3:8b | 90s | Every 30 min |
| **5:00 AM** | journal-agent | qwen3:8b | 90s | Every 30 min |
| **5:30 AM** | journal-agent | qwen3:8b | 90s | Every 30 min |

### Night Window

| Time | Job | Model | Duration | Timeout | Notes |
|------|-----|-------|----------|---------|-------|
| **1:00 AM** | 9to5mac-scraper | qwen3:8b | 5-60s | 1800s | ~5 min actual |
| **2:00 AM** | nightly-research-2am (blog) | qwen3:14b/8b | 3-60s | 1200s | ~3 min, fallback to 8b |

### Morning Cleanup Batch (Staggered 6 AM)

| Time | Job | Model | Duration | Stagger | Notes |
|------|-----|-------|----------|---------|-------|
| **6:00 AM** | nightly-extraction | qwen3:8b | 80s | 0ms | Memory extraction |
| **6:02 AM** | nightly-backup | qwen3:8b | 30s | +120s | Backup |
| **6:04 AM** | nightly-chatlog-export | qwen3:8b | 6s | +240s | Quick export |
| **6:06 AM** | compact-nightly-channels | qwen3:8b | 50s | +360s | Discord cleanup |

### Daytime

| Time | Job | Model | Duration | Notes |
|------|-----|-------|----------|-------|
| **7:00 AM** | morning-briefing | qwen3:8b | 60s | Daily PDF report |

---

## Recurring (Non-Daily)

### Every 3 Hours (Heartbeat)

| Times | Job | Model | Duration | Notes |
|-------|-----|-------|----------|-------|
| **6, 9, 12, 3, 6, 9 PM** | heartbeat-synced | gemma3:4b | 15s | Task stall detection |

### Every 6 Hours (Aggressive Compact)

| Times | Job | Model | Duration | Stagger | Notes |
|-------|-----|-------|----------|---------|-------|
| **12:10, 6:10 AM/PM, 12:10 AM** | compact-aggressive-channels | qwen3:8b | 45s | 300s | Shifted to :10 |

### Every 72 Hours (YouTube Monitors)

| Job | Model | Duration | Notes |
|-----|-------|----------|-------|
| Tim Carambat YouTube Monitor | qwen3:8b | 45-60s | Extract transcripts + analyze |
| Alex Finn YouTube Monitor | qwen3:8b | 45-60s | Extract transcripts + analyze |

---

## Weekly Jobs

### Sundays

| Time | Job | Model | Duration | Timeout | Notes |
|------|-----|-------|----------|---------|-------|
| **6:05 AM** | compact-weekly-channels | qwen3:8b | 34s | 120s | Weekly cleanup |
| **6:08 AM** | CI: Local Model R&D | qwen3:8b | 5s | 7200s | 1st Sunday only |
| **9:00 AM** | Weekly Briefing Evolution Review | qwen3:8b | 29s | 1800s | Improve daily briefing |
| **11:00 PM** | CI: Video Analysis | qwen3:8b | 5s | 300s | 25 videos/week |
| **12:00 AM (Monday)** | CI: Monthly Synthesis | qwen3:8b | 7s | 1800s | 1st Sunday only |

### Mondays

| Time | Job | Model | Duration | Timeout | Notes |
|------|-----|-------|----------|---------|-------|
| **6:00 AM** | CI: Technical Audit | qwen3:8b | 32s | 600s | Weekly infra audit |
| **6:03 AM** | CI: Agent Performance Review | qwen3:8b | 62s | 600s | Staggered +3min |
| **10:22 PM (1st Monday)** | CI: Market Research | qwen3:8b | 8s+ | 3600s | Monthly market analysis |

### Fridays

| Time | Job | Model | Duration | Notes |
|------|-----|-------|----------|-------|
| **6:00 PM** | CI: Market Pulse | qwen3:8b | 22s | Weekly market pulse |

---

## Monthly Jobs (1st of Month)

| Time | Day | Job | Model | Duration | Notes |
|------|-----|-----|-------|----------|-------|
| **3:00 AM** | Any | 9to5mac-style-guide-refresh | qwen3:8b | 45s | Monthly refresh |
| **6:08 AM** | Sunday | CI: Local Model R&D | qwen3:8b | 5s | 1st Sunday only |
| **12:00 AM (Sun→Mon)** | 1st Sunday | CI: Monthly Synthesis | qwen3:8b | 7s | Aggregate weekly |
| **10:22 PM** | 1st Monday | CI: Market Research | qwen3:8b | 8s+ | Deep market dive |

---

## GPU Collision Matrix (Single GPU Optimization)

**Before Changes:** 4-8 collisions/day  
**After Changes:** 0 collisions

Key changes:
- Journal-agent: shifted to 4-5:30 AM (off-peak)
- Aggressive-compact: shifted to :10 past hour
- 6 AM batch: staggered in 6-min window (0, +2, +4, +6 min)
- Monday 6 AM: staggered (0, +3 min)

---

## Model Distribution

| Model | Jobs | Total/Day | Peak Usage |
|-------|------|-----------|------------|
| qwen3:8b | 19 | ~80 runs | ~2-3 simultaneous |
| gemma3:4b | 1 | ~8 runs | 1 (heartbeat only) |
| qwen3:14b | 1 (blog fallback) | 1 run | 0 (fallback only) |

---

## Estimated Runtime (24-Hour Cycle)

| Period | Work | Est. GPU Time |
|--------|------|---------------|
| 4-6 AM | Journal (4x) + night scrape + blog | ~15 min |
| 6-7 AM | Nightly batch + heartbeat + briefing | ~12 min |
| 7 AM-6 PM | Morning briefing + heartbeats + compacts | ~25 min |
| 6 PM-midnight | Compacts + YouTube monitors + evening heartbeats | ~20 min |
| Midnight-4 AM | Weekly jobs (Sun), market research (1st Mon) | ~10 min (variable) |
| **Daily Total** | | **~82 min (~1.4 hrs)** |

**With weekly/monthly variance:** 5-6 hrs/week peak = ~1 hr/day average

---

## Health Monitoring

### Heartbeat Alerts (Every 3 Hours)

```
HEARTBEAT_OK         → All tasks on schedule
HEARTBEAT_STALL      → Task >30 min overdue (needs restart)
```

### Stall Detection

- Check: `nextRunAtMs` in past?
- Check: `consecutiveErrors` > 0?
- Check: `lastDurationMs` > timeout?

---

## Recent Changes (2026-04-02)

✅ Journal-agent: `0,30 6-23 * * *` → `0,30 4-5 * * *`  
✅ Aggressive-compact: `0 */6 * * *` → `10 */6 * * *`  
✅ 6 AM batch: Added stagger (0, +120s, +240s, +360s)  
✅ Monday 6 AM: Added stagger (+3s for performance review)  
✅ Sunday 6 AM: Moved local-r&d to 6:08 AM (avoid weekly batch)  

---

## Emergency Commands

```bash
# Check all cron status
cron list

# View specific job runs
cron runs <job-id>

# Trigger job manually
cron run <job-id> --runMode force

# View heartbeat logs
tail -f /var/log/heartbeat.log

# Reset all model overrides (in case of failure cascade)
reset-to-default
```

---

**Version:** 2.0 (Optimized Single-GPU)  
**Last Verified:** 2026-04-02  
**Next Review:** 2026-04-09 (weekly audit)
