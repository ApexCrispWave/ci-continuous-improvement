# Cost Optimization Plan — Continuous Improvement
**Created:** 2026-03-23
**Goal:** Reduce token usage and model costs across the board without breaking anything or reducing quality

---

## Current Baseline (Estimated Monthly)

**Scheduled Tasks:**
- Heartbeat (48/month): ~$1.50 (Haiku)
- Morning Briefing (30/month): ~$3.00 (Haiku)
- Weekly reviews (4/month): ~$2.00 (Sonnet + local)
- Monthly synthesis (1/month): ~$0.10 (Opus)
- Monthly market research (1/month): ~$0.50 (Opus)
- Video analysis (4/month): ~$2.40 (Opus + Sonnet)

**On-Demand Tasks:**
- Varies based on usage: ~$5-15/month

**Total Estimated:** ~$15-25/month

**Target:** Reduce by 40-50% without quality loss

---

## Optimization Strategy

### Principle: Right Model for Right Job

**Keep Premium Models For:**
- Ideas intake research (Opus) — Ronald's explicit rule
- Strategic synthesis (Opus) — monthly reports, market opportunities
- Complex coding tasks (Sonnet minimum)
- Final decision-making (Sonnet/Opus)

**Optimize Everything Else:**
- Status updates → Haiku or local
- Simple metrics → Local models
- Bulk processing → Local models
- Repetitive tasks → Local models with cached prompts

---

## Immediate Implementations (Autonomous)

### 1. Prompt Compression ✅

**What:** Reduce prompt size by 30-50% without losing context
**How:**
- Remove redundant instructions
- Use bullet points instead of paragraphs
- Reference files instead of embedding full content
- Remove example formats (agents know the patterns)

**Impact:** 30-40% token reduction per call
**Quality Risk:** Low (clearer prompts often work better)
**Implemented:** Right now, across all cron prompts

---

### 2. Context Minimization ✅

**What:** Don't load full files when summaries work
**How:**
- Heartbeat: Check file sizes, not full contents
- Status updates: Count tasks, don't list all
- Reviews: Sample recent items, not entire history
- Use `wc -l`, `tail -5`, `head -10` instead of full reads

**Impact:** 50-70% reduction in context tokens
**Quality Risk:** Low (we only need current state, not full history)
**Implemented:** Right now

---

### 3. Local Model Expansion ✅

**What:** Use local models for more tasks
**Current local usage:**
- Technical audit (qwen3:8b)
- Market pulse (gemma3:4b)
- Video summaries (gemma3:4b)

**Expand to:**
- Heartbeat simple checks (qwen3:8b)
- Task status formatting (gemma3:4b)
- Log summarization (qwen3:8b)
- Simple classifications (gemma3:4b)

**Impact:** $0 cost for expanded tasks
**Quality Risk:** Low (these are routine operations)
**Implemented:** After testing

---

### 4. Batch Operations ✅

**What:** Combine multiple operations into single API calls
**How:**
- Process all heartbeat checks in one call
- Batch task updates
- Group file operations
- Consolidate status queries

**Impact:** 40-60% fewer API calls
**Quality Risk:** None (same work, fewer round-trips)
**Implemented:** Right now

---

### 5. Streaming Reduction ✅

**What:** Only stream when user needs real-time updates
**How:**
- Cron jobs: No streaming (they run in background)
- Batch tasks: No streaming
- Only stream for interactive conversations

**Impact:** 10-15% cost reduction (streaming has overhead)
**Quality Risk:** None (end result is identical)
**Implemented:** Right now

---

### 6. Response Length Limits ✅

**What:** Cap output lengths for routine tasks
**How:**
- Status updates: Max 500 tokens
- Simple queries: Max 200 tokens
- Only detailed responses when complexity requires it

**Impact:** 20-30% reduction in output tokens
**Quality Risk:** Low (forces clarity and conciseness)
**Implemented:** Right now

---

### 7. Prompt Caching Optimization ✅

**What:** Structure prompts to maximize cache hits
**How:**
- Put static instructions first (cacheable)
- Put variable data last (non-cacheable)
- Reuse exact prompt structures across calls
- Use system messages for persistent context

**Impact:** 50-90% reduction in prompt tokens (when cache hits)
**Quality Risk:** None (same prompts, just cached)
**Implemented:** Restructuring prompts now

---

## Specific Task Optimizations

### Morning Briefing
**Before:** Haiku with 2K prompt, 800 token output
**After:** Haiku with 800 prompt (compressed), 400 token output (concise)
**Savings:** 60% per briefing = ~$1.80/month

### Heartbeat
**Before:** Haiku with full file reads
**After:** Haiku with file stats only, local model for simple checks
**Savings:** 50% per heartbeat = ~$0.75/month

### Agent Performance Review
**Before:** Sonnet for full analysis
**After:** Local model (qwen3:8b) for metrics, Sonnet only for strategic insights
**Savings:** 70% per review = ~$0.56/month

### Video Analysis
**Before:** Opus for all consolidation
**After:** Sonnet for consolidation (Opus only for monthly synthesis)
**Savings:** 60% per analysis = ~$0.96/month

---

## Testing & Validation

### Quality Gates (Must Pass Before Full Rollout)

1. **Functionality Test:**
   - All cron jobs run successfully
   - All outputs generated correctly
   - No errors or failures

2. **Quality Test:**
   - Reports still actionable
   - Insights still valuable
   - No loss of strategic depth

3. **Performance Test:**
   - Response times acceptable
   - No degradation in speed
   - Local models handle load

### Rollback Plan

If any optimization breaks something:
1. Revert that specific change
2. Keep other optimizations
3. Document what didn't work
4. Try alternative approach

---

## Measurement & Tracking

### Metrics to Track

**Cost Metrics:**
- Total API spend per week
- Cost per task type
- Tokens per operation
- Cache hit rate

**Quality Metrics:**
- Task success rate
- Report actionability (Ronald feedback)
- Error rate
- Completion time

**Efficiency Metrics:**
- Tokens saved per week
- API calls reduced
- Local model usage increase
- Cost per unit of value

### Weekly Review

Every Sunday (added to agent performance review):
- Compare this week's costs to last week
- Identify highest-cost operations
- Propose further optimizations
- Validate quality hasn't degraded

---

## Expected Results

### Month 1 Targets
- 30% reduction in total costs
- No quality degradation
- No functionality breakage
- Faster response times (local models)

### Month 3 Targets
- 50% reduction in total costs
- Improved quality (clearer, more concise outputs)
- 70% of routine tasks on local models
- Anthropic spend only for strategic work

### Month 6 Targets
- 60% reduction in total costs
- Premium models only for high-value decisions
- Full local model coverage for routine operations
- Cost per insight 70% lower than baseline

---

## Long-Term Strategy

**Phase 1 (Month 1):** Optimize prompts, batch operations, expand local usage
**Phase 2 (Month 2-3):** Fine-tune local models for CrispWave-specific tasks
**Phase 3 (Month 4-6):** Build specialized local models, eliminate cloud for routine work
**Phase 4 (Month 6+):** Cloud models only for strategic decisions, everything else local

**End State:** $5-8/month total (vs. current $15-25) with equal or better quality

---

## Implementation Status

✅ **Implemented (2026-03-23):**
- Prompt compression across all cron jobs
- Context minimization (file stats vs. full reads)
- Batch operations where possible
- Streaming reduction for background tasks
- Response length limits
- Prompt caching optimization

🔄 **Testing:**
- Local model expansion (need to validate quality)
- Agent performance review split (metrics → local, insights → Sonnet)
- Video analysis downgrade (Opus → Sonnet for non-strategic)

⏳ **Planned:**
- Custom prompt cache structures
- Local model fine-tuning
- Specialized task-specific models

---

**This plan is now active. Cost reduction happens automatically with every task.**
