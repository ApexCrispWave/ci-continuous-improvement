# Continuous Improvement System — How-To Guide

**Last Updated:** 2026-03-23

---

## Overview

CrispWave's Continuous Improvement System runs automatically on a weekly and monthly schedule, but can also be triggered on-demand whenever you need immediate intelligence or analysis.

**Two Modes:**
1. **Automatic (scheduled)** — Weekly and monthly reviews run without any input
2. **On-Demand (manual)** — Trigger specific research anytime you need it

---

## Automatic Schedule (No Action Required)

### Weekly Cycles (Every Sunday)

| Time | What Runs | What It Does |
|------|-----------|--------------|
| 9:00 PM PT | Agent Performance Review | APEX self-analysis: task completion, cost, skill gaps |
| 10:00 PM PT | Technical Infrastructure Audit | System health: cron jobs, config, security |
| 11:00 PM PT | Video Analysis (25 videos) | Discovers and analyzes AI/automation tutorials from last 7 days |

**Output:** Reports posted to #continuous-improvement every Sunday night

### Monthly Cycles

| When | What Runs | What It Does |
|------|-----------|--------------|
| 1st Sunday, Midnight | Monthly Synthesis | Aggregates 4 weeks of reports → Top 5 improvements to implement |
| 1st Sunday, 3:00 AM | Local Model R&D | Researches, benchmarks, and optimizes local LLM stack |
| 1st Monday, 10:00 PM | Market Research (Full Portfolio) | Multi-source intelligence across all active sectors |

**Output:** Monthly reports + PDFs saved to `/Users/openclaw/reports/`

### Weekly Pulse

| When | What Runs | What It Does |
|------|-----------|--------------|
| Every Friday, 6:00 PM | Market Pulse Check | Quick scan for breaking news in active sectors (only posts if significant) |

---

## On-Demand Usage

### When to Use On-Demand

Trigger manual research when you need:
- **Idea intake:** Research a new idea before writing feasibility report
- **Strategic decisions:** Need market intel right now, can't wait for monthly cycle
- **Competitive intelligence:** Competitor just launched something, need immediate analysis
- **Sector deep-dive:** Want focused research on one specific sector
- **Video research:** Need to analyze specific videos or topics immediately

### Available On-Demand Tools

#### 1. Market Research (Any Sector, Anytime)

**Command:**
```bash
bash /Users/openclaw/.openclaw/workspace/scripts/market-research-sector.sh [sector-name]
```

**Examples:**

Research all active sectors:
```bash
bash /Users/openclaw/.openclaw/workspace/scripts/market-research-sector.sh all
```

Research specific sector:
```bash
bash /Users/openclaw/.openclaw/workspace/scripts/market-research-sector.sh "MEP CAD tools"
bash /Users/openclaw/.openclaw/workspace/scripts/market-research-sector.sh "wearable devices"
bash /Users/openclaw/.openclaw/workspace/scripts/market-research-sector.sh "AI productivity tools"
```

**What It Does:**
- Multi-source intelligence: web, Reddit, forums, reviews, YouTube, social media, competitors
- Autonomous video discovery and analysis per sector
- Extracts: competitor movement, market trends, customer pain points, opportunity gaps
- Outputs: Markdown report + analysis saved to `research/market/`

**Time:** 45-90 minutes depending on number of sectors

**Cost:** ~$0.30-0.50 (Opus for synthesis, Sonnet for analysis, local models for summaries)

---

#### 2. Video Analysis (Specific Topics, Anytime)

**Command:**
```bash
bash /Users/openclaw/.openclaw/workspace/scripts/video-analysis.sh
```

**What It Does:**
- Searches YouTube for videos published in last 7 days
- Topics: OpenClaw automation, AI workflows, local LLMs, agent orchestration
- Discovers and analyzes 25 most relevant videos
- Hybrid workflow: transcript extraction → local model summary → strategic analysis → synthesis
- Outputs: Consolidated insights report to `research/video-analysis/`

**Time:** 30-60 minutes

**Cost:** ~$0.60 (Opus for consolidation, Sonnet for strategic analysis, local for summaries)

**Custom Topics:**
Edit the `SEARCH_TOPICS` array in the script to focus on different areas.

---

#### 3. Agent Performance Review (Anytime)

**Command:**
```bash
bash /Users/openclaw/.openclaw/workspace/scripts/agent-performance-review.sh
```

**What It Does:**
- Analyzes APEX's performance: task completion rates, cost efficiency, feedback patterns
- Identifies skill gaps and workflow improvements
- Outputs: Performance report to `improvements/agent/`

**Time:** 5-10 minutes

**Cost:** ~$0.10-0.20 (Sonnet)

---

#### 4. Technical Infrastructure Audit (Anytime)

**Command:**
```bash
bash /Users/openclaw/.openclaw/workspace/scripts/technical-audit.sh
```

**What It Does:**
- Checks cron job reliability, model usage patterns, infrastructure health, security
- Identifies optimization opportunities
- Outputs: Technical report to `improvements/technical/`

**Time:** 5-10 minutes

**Cost:** $0 (local model: qwen3:8b)

---

#### 5. Trigger Any Cron Job Manually

**List all cron jobs:**
```bash
openclaw cron list
```

**Run specific job now:**
```bash
openclaw cron run <job-id>
```

**Example — Trigger monthly synthesis early:**
```bash
openclaw cron run aa5a4824-6044-4731-8c55-f0fc785cb283
```

---

## Use Case Examples

### Scenario 1: New Idea Submitted

**Situation:** Ronald posts a new product idea in #ideas-intake

**Action:**
1. Run on-demand market research for that sector:
   ```bash
   bash /Users/openclaw/.openclaw/workspace/scripts/market-research-sector.sh "sector name"
   ```
2. Wait 45-90 min for multi-source intelligence
3. Use findings in feasibility report
4. Generate PDF and post to #ideas-intake

**Result:** Idea gets researched with real-time market data, not month-old intel

---

### Scenario 2: Competitor Launches New Product

**Situation:** Competitor just announced something big, need immediate analysis

**Action:**
1. Run on-demand market research for that sector:
   ```bash
   bash /Users/openclaw/.openclaw/workspace/scripts/market-research-sector.sh "relevant sector"
   ```
2. Review competitive intelligence section
3. Update strategy based on findings

**Result:** React quickly with informed decisions, not wait 30 days for monthly cycle

---

### Scenario 3: Learning New Technique Fast

**Situation:** Need to understand a new tool or workflow immediately

**Action:**
1. Edit video-analysis.sh to add specific search topic
2. Run video analysis:
   ```bash
   bash /Users/openclaw/.openclaw/workspace/scripts/video-analysis.sh
   ```
3. Review consolidated insights in 30-60 min

**Result:** Fast learning from best YouTube tutorials, synthesized and actionable

---

### Scenario 4: Pre-Launch Market Check

**Situation:** About to launch a product, want final competitive check

**Action:**
1. Run market research for that product's sector:
   ```bash
   bash /Users/openclaw/.openclaw/workspace/scripts/market-research-sector.sh "product sector"
   ```
2. Review competitor movement from last 30 days
3. Check for any last-minute threats or opportunities
4. Adjust pricing/positioning if needed

**Result:** Launch with confidence, knowing exactly where you stand in the market

---

### Scenario 5: Cost Optimization Emergency

**Situation:** Cloud API costs spiking, need to optimize now

**Action:**
1. Run technical audit:
   ```bash
   bash /Users/openclaw/.openclaw/workspace/scripts/technical-audit.sh
   ```
2. Review model usage patterns section
3. Identify tasks that can move to cheaper/local models
4. Implement changes immediately

**Result:** Cost under control within hours, not waiting for Sunday review

---

## Output Locations

All reports are saved to the workspace:

**Market Research:**
- Scheduled (monthly): `research/market/YYYY-MM.md`
- On-demand: `research/market/on-demand-YYYY-MM-DD-HHMM.md`

**Video Analysis:**
- Scheduled (weekly): `research/video-analysis/YYYY-WW.md`
- On-demand: `research/video-analysis/on-demand-YYYY-MM-DD-HHMM.md`

**Agent Performance:**
- Scheduled: `improvements/agent/YYYY-WW.md`
- On-demand: `improvements/agent/on-demand-YYYY-MM-DD-HHMM.md`

**Technical Audits:**
- Scheduled: `improvements/technical/YYYY-WW.md`
- On-demand: `improvements/technical/on-demand-YYYY-MM-DD-HHMM.md`

**Monthly Synthesis:**
- `improvements/monthly/YYYY-MM.md`

**PDFs (major reports):**
- `/Users/openclaw/reports/`

---

## Cost Reference

| Task | Model Used | Estimated Cost | Time |
|------|------------|----------------|------|
| Market Research (all sectors) | Opus + Sonnet + local | $0.30-0.50 | 45-90 min |
| Market Research (one sector) | Opus + Sonnet + local | $0.10-0.20 | 20-30 min |
| Video Analysis (25 videos) | Opus + Sonnet + local | $0.60 | 30-60 min |
| Agent Performance Review | Sonnet | $0.10-0.20 | 5-10 min |
| Technical Audit | qwen3:8b (local) | $0 | 5-10 min |
| Monthly Synthesis | Opus | $0.10 | 10-15 min |

**Monthly scheduled cost (all automatic cycles):** ~$5-7/month

**On-demand cost:** Pay only when you trigger it

---

## Best Practices

### When to Use Scheduled vs. On-Demand

**Use Scheduled (wait for automatic):**
- Routine performance tracking
- Regular infrastructure health checks
- Continuous learning from new videos
- Monthly portfolio-wide market pulse

**Use On-Demand (trigger manually):**
- Urgent competitive intelligence
- New idea research
- Pre-launch market validation
- Immediate cost optimization
- Strategic decision-making
- Specific topic deep-dive

### Tips for Effective On-Demand Research

1. **Be specific with sector names** when running market research
   - ✅ Good: "MEP CAD tools for plumbers"
   - ❌ Vague: "software"

2. **Combine multiple sources** — don't just run market research, also check:
   - Recent video analysis reports
   - Technical audit for capability gaps
   - Agent performance for execution capacity

3. **Time it right** — On-demand research takes 30-90 min
   - Don't wait until you need the decision RIGHT NOW
   - Trigger research when you first think of the question

4. **Read the reports** — They're structured for fast scanning:
   - Executive summary at the top
   - Top opportunities ranked
   - Immediate action items at the end

5. **Update ideas/tasks** — After on-demand research:
   - Update ideas.json with new intelligence
   - Create tasks for validated opportunities
   - Archive/park ideas that don't hold up

---

## Troubleshooting

### Script Not Running

**Problem:** `command not found` or permission denied

**Solution:**
```bash
chmod +x /Users/openclaw/.openclaw/workspace/scripts/*.sh
```

### Report Not Generated

**Problem:** Script ran but no output file

**Solution:** Check the script is using correct output path. Reports should save to:
- `research/market/`
- `research/video-analysis/`
- `improvements/agent/`
- `improvements/technical/`

### Cron Job Stuck

**Problem:** Manual cron trigger shows "running" for hours

**Solution:**
```bash
# Check running sessions
openclaw sessions --active 180

# Kill stuck session if needed
# (get session key from sessions list)
```

### High Costs

**Problem:** On-demand research costing more than expected

**Solution:**
- Use technical audit (free) before expensive market research
- Focus on specific sectors, not "all"
- Check recent reports first — might already have the intel

---

## Quick Reference Card

```bash
# Market research (all sectors)
bash /Users/openclaw/.openclaw/workspace/scripts/market-research-sector.sh all

# Market research (one sector)
bash /Users/openclaw/.openclaw/workspace/scripts/market-research-sector.sh "sector name"

# Video analysis
bash /Users/openclaw/.openclaw/workspace/scripts/video-analysis.sh

# Agent performance
bash /Users/openclaw/.openclaw/workspace/scripts/agent-performance-review.sh

# Technical audit (free)
bash /Users/openclaw/.openclaw/workspace/scripts/technical-audit.sh

# List all cron jobs
openclaw cron list

# Run any cron job manually
openclaw cron run <job-id>
```

---

## Summary

The continuous improvement system is designed to run automatically, but gives you full manual control when you need immediate intelligence.

**Key Principle:** Scheduled for routine insights, on-demand for urgent decisions.

**Cost Efficiency:** Only pay for cloud models when you actually need them. Most scheduled tasks use free local models.

**Flexibility:** All research scripts can be edited to focus on specific topics, sectors, or time ranges.

**The machine learns 24/7. You control when you need answers immediately.**

---

**Questions? Ask APEX in any channel.**
