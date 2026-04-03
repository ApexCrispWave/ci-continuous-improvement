# CI Model Strategy

**Last Updated:** 2026-04-02  
**Owner:** APEX (CrispWave CEO)  
**Purpose:** Defines which AI model handles each CI job and when to escalate

---

## Model Roles

| Model | Role | Latency | Cost | Use When |
|-------|------|---------|------|----------|
| `gemma3:4b` | Ultra-fast triage / heartbeat | 1–2s | ~$0 (local) | Health checks, quick classification, watchdog alerts |
| `qwen3:8b` | Default CI worker | 5–30s | ~$0 (local) | Scanning, data extraction, markdown generation, implementation tasks |
| `qwen3:14b` | Extended context | 30–90s | ~$0 (local) | Blog generation with large CI context, complex local analysis |
| `qwen3.5:9b` | Vision / extended context | 20–60s | ~$0 (local) | Market pulse with mixed media, complex long-form generation |
| `anthropic/claude-opus-4-1` | Strategic analysis | 10–30s | ~$0.10–0.30 | Strategy, tradeoffs, architecture decisions, long-term planning |

---

## Escalation Rules

### When to Escalate to Opus

Escalate from `qwen3:8b` → `claude-opus-4-1` when:
- Health rating is **NEEDS_WORK** or **CRITICAL**
- Findings involve **architecture decisions** or **systemic patterns**
- **Strategic tradeoffs** need to be weighed (build vs buy, prioritization)
- **Long-term planning** (roadmap, resource allocation, major pivots)
- Critical issue count > 0 in any CI scan

### When NOT to Escalate

Do NOT use Opus for:
- Routine status checks (use `gemma3:4b`)
- File reads, writes, formatting (use `qwen3:8b`)
- Simple data extraction (use `qwen3:8b`)
- Heartbeat/ping checks (use `gemma3:4b`)
- Any task estimated < 2 minutes of reasoning

---

## Escalation Flow

```
CI Scan Starts
      │
      ▼
gemma3:4b OR qwen3:8b (fast local scan)
      │
      ▼
Findings analysis
      │
   ┌──┴──┐
   │     │
GOOD   NEEDS_WORK / CRITICAL / has_strategy
   │     │
   │     ▼
   │  ci-escalate-to-opus.sh
   │     │
   │     ▼
   │  claude-opus-4-1
   │  "What are strategic implications? Recommend next steps."
   │     │
   │     ▼
   │  Opus returns P1/P2/P3 action plan
   │     │
   └──┬──┘
      │
      ▼
qwen3:8b implements fixes (if any)
      │
      ▼
Output written to disk
      │
      ▼
research-db ingest (auto)
```

---

## Per-Job Model Assignments

| CI Job | Primary Model | Escalation Trigger | Fallback |
|--------|--------------|-------------------|----------|
| Heartbeat / health check | `gemma3:4b` | Never | `qwen3:8b` |
| Market Pulse Daily | `gemma3:4b` | Never | `qwen3:8b` |
| Market Pulse Weekly | `qwen3.5:9b` | Significant market shift | `qwen3:8b` |
| Video Analysis | `qwen3:8b` | Strategic narrative found | `gemma3:4b` |
| Technical Audit | `qwen3:8b` | CRITICAL findings | `gemma3:4b` |
| Agent Performance Review | `qwen3:8b` | Systemic failures | `gemma3:4b` |
| **GitHub Repo Audit** | `qwen3:8b` | NEEDS_WORK / CRITICAL | `gemma3:4b` |
| Blog Generation | `qwen3:14b` | Content strategy question | `qwen3:8b` |
| Morning Briefing | `qwen3:8b` | High-stakes decision | `gemma3:4b` |

---

## Cost Model

```
Typical weekly CI run (no escalation):
  - All local models: ~$0.00
  - Total: $0/week

With escalation (1-2 Opus calls/week):
  - Local scans: ~$0.00
  - Opus escalations: $0.10-0.30 each
  - Total: ~$0.20-0.60/week

Monthly estimate: ~$1-3 for escalations
Budget: $5/day, $150/month → escalations are trivial cost
```

---

## Using the Escalation Helper

```bash
# Escalate any CI scan result to Opus
OPUS_RECS=$(bash scripts/ci-escalate-to-opus.sh "$SCAN_RESULT" "github-audit")

# Check if escalation is needed before calling
if [ "$HEALTH_RATING" != "GOOD" ]; then
  OPUS_RECS=$(bash scripts/ci-escalate-to-opus.sh "$SCAN_RESULT" "$TASK_NAME")
fi
```

The helper (`scripts/ci-escalate-to-opus.sh`):
1. Accepts findings JSON/text from any scan agent
2. Sends structured prompt to Opus
3. Returns markdown recommendations (P1/P2/P3 action plan)
4. Falls back to `qwen3:14b` if Opus is unavailable
5. Logs all escalation events to health-logs/

---

## Research DB Integration

All CI outputs must ingest to `research-db/` as typed sources:

| CI Job | Source Type |
|--------|------------|
| Market Pulse | `ci-market` |
| Video Analysis | `ci-video` |
| Technical Audit | `ci-technical` |
| Agent Performance | `ci-agent` |
| CI Aggregator | `ci-aggregate` |
| **GitHub Audit** | `ci-github` |

Query GitHub audit data:
```bash
bash scripts/ci-research-query.sh --type github --recent 7
```

---

## Adding New CI Jobs

When creating a new CI cron:

1. Pick the right primary model (default: `qwen3:8b`)
2. Define escalation trigger (what health rating / finding type)
3. Add ingest call at end: `python3 research-db/ingest.py --file $OUTPUT_FILE`
4. Add source type to `ci-research-query.sh` type map
5. Document in this file under "Per-Job Model Assignments"
6. Add to `CI-AUTONOMOUS-LOOP.md`

---

_Model strategy evolves as new local models are added. Review quarterly or when a new Ollama model is benchmarked._
