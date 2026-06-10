# GitHub Copilot Model Guide — Cheat Sheet & Decision Matrix

*Which model to pick for which task, based on cost vs. capability. A developer-facing companion to "Making Every Token Count with GitHub Copilot."*

**Compiled:** June 10, 2026 · **Scope:** Copilot Chat, Agent mode, Cloud agent, CLI · **Method:** deep-research workflow (5 search angles, 3-vote adversarial verification — partially degraded by an org spend limit) + direct verification against GitHub's live primary docs on June 10, 2026, including a follow-up inline pass the same day that added the per-model profiles (§4) and the Fable 5 GA changelog.

---

## How to read this document

Same confidence tiers as the rest of the workshop materials:

| Tier | Meaning |
|------|---------|
| ✅ **Documented** | Verified against primary GitHub / vendor docs (fetched live June 10, 2026). |
| 🔷 **Established** | From reputable third-party benchmark trackers / engineering sources. Real numbers, but not GitHub-published. |
| 🧪 **Practitioner** | Community / power-user guidance. Plausible, often reported to work, not independently confirmed. |
| ⚠️ **Stale / conflicting** | Found in official-looking sources but contradicted by the current roster — don't quote without re-checking. |

> ⚠️ **Fast-moving area.** The model roster and prices below were fetched June 10, 2026. GitHub notes "model availability is subject to change." Re-verify the week of the talk against the [live pricing page](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing) and [supported-models reference](https://docs.github.com/en/copilot/reference/ai-models/supported-models).

---

## TL;DR — the one-slide cheat sheet

| Your task | First pick | Budget pick | Don't use |
|---|---|---|---|
| Quick Q&A, boilerplate, docstrings | **GPT-5 mini** | GPT-5.4 nano | Any "Powerful"-tier model |
| Writing docs & tests | **Claude Haiku 4.5** | GPT-5 mini | Opus / Fable / GPT-5.5 |
| Routine implementation from a clear spec | **GPT-5.4 mini** or **Haiku 4.5** | GPT-5.4 nano | Frontier reasoning models (they second-guess the spec) |
| Coding-focused agent runs (mid-complexity) | **GPT-5.3-Codex** | GPT-5.4 mini | — |
| Multi-file refactor, cross-language work | **Claude Sonnet 4.6** | GPT-5.4 | — |
| Planning, architecture, hard debugging | **Claude Opus 4.8** or **GPT-5.5** | Sonnet 4.6 | Lightweight models |
| Long-horizon agent task where retries are expensive | **Claude Fable 5** | Opus 4.8 | — |
| Whole-repo / large-context analysis | **Sonnet 4.6 / Opus 4.6+ / Fable 5 (1M ctx)** | Gemini 3.1 Pro (watch the >200K surcharge) | Models without long context |
| Image / diagram / screenshot input | **Fable 5, Sonnet 4.6, or Gemini 3.1 Pro** | GPT-5 mini (multimodal) | — |
| "I don't want to think about it" | **Auto model selection** | — | — |

**The two rules that matter most:**
1. **Plan with a powerful model, execute with a cheap one.** The frontier-to-nano input-price spread is **50×** ($10.00 vs $0.20 per M tokens) — the single biggest cost lever in Copilot. ✅
2. **For agent runs, quality beats price.** One Fable 5 run that lands first-try is often cheaper than three retries on a mid-tier model (worked math in [§7](#7--cost-math-three-worked-examples)). 🔷

> 📝 **Fable 5 gate:** it requires **Pro+/Max/Business/Enterprise** and, for orgs, an explicit admin opt-in acknowledging Anthropic's 30-day data retention — Pro users won't see it at all (§8). ✅

---

## 1 · The billing context (60 seconds)

As of **June 1, 2026**, Copilot bills by **GitHub AI Credits** (1 credit = $0.01) computed from **token consumption at each model's published API rate** — input, output, and cached tokens all count. Code completions and Next Edit Suggestions remain unlimited and never consume credits. ✅
([GitHub blog announcement](https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/), [models & pricing reference](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing))

**Monthly included credits** ✅ (per the GitHub announcement): credits equal to your plan price — Pro $10, Pro+ $39, Business $19/user, Enterprise $39/user — plus transition promos for Business (+$30/mo × 3 months) and Enterprise (+$70/mo).
> ⚠️ **Conflicting figures in the wild:** community articles report different credit counts (e.g., "Pro 1,500 / Pro+ 7,000 credits" at [TokenMix](https://tokenmix.ai/blog/github-copilot-ai-credits-billing-2026)). These may include promos or be wrong — quote the [official announcement](https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/) figures and re-verify before the talk.

Three pricing mechanics shape every recommendation below (full detail in `copilot-token-saving-concepts.md`):
- **Output costs ~5–8× input** on every model.
- **Cached input costs ~1/10 of fresh input** (Anthropic models add a one-time cache-*write* fee).
- **Long-context surcharge:** above ~200–272K tokens, GPT-5.4/5.5 and Gemini 3.1 Pro roughly **double** their rates.

---

## 2 · The full roster & official pricing ✅

Fetched live from [GitHub's models & pricing page](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing), June 10, 2026. All prices **per 1M tokens**; GitHub groups models into **Lightweight / Versatile / Powerful** tiers.

### OpenAI

| Model | Tier | Input | Cached | Output | Notes |
|---|---|---:|---:|---:|---|
| GPT-5.4 nano | Lightweight | $0.20 | $0.02 | $1.25 | Cheapest model in Copilot; not available in Agent/Ask/Edit modes |
| GPT-5 mini | Lightweight | $0.25 | $0.025 | $2.00 | Multimodal; in every Auto-selection pool |
| GPT-5.4 mini | Lightweight | $0.75 | $0.075 | $4.50 | 0.33× legacy multiplier in cloud agent |
| GPT-5.3-Codex | Powerful | $1.75 | $0.175 | $14.00 | Coding-specialized; in all Auto pools incl. cloud agent |
| GPT-5.4 (≤272K) | Versatile | $2.50 | $0.25 | $15.00 | |
| GPT-5.4 (>272K) | Versatile | $5.00 | $0.50 | $22.50 | Long-context surcharge |
| GPT-5.5 (≤272K) | Powerful | $5.00 | $0.50 | $30.00 | OpenAI's frontier reasoning model |
| GPT-5.5 (>272K) | Powerful | $10.00 | $1.00 | $45.00 | Long-context surcharge |

### Anthropic (all add a cache-write fee = 1.25× input)

| Model | Tier | Input | Cached | Cache write | Output | Notes |
|---|---|---:|---:|---:|---:|---|
| Claude Haiku 4.5 | Versatile | $1.00 | $0.10 | $1.25 | $5.00 | 0.33× legacy multiplier in cloud agent |
| Claude Sonnet 4 / 4.5 / 4.6 | Versatile | $3.00 | $0.30 | $3.75 | $15.00 | Sonnet 4.6: 1M context + configurable reasoning |
| Claude Opus 4.5 / 4.6 / 4.7 / 4.8 | Powerful | $5.00 | $0.50 | $6.25 | $25.00 | Opus 4.6+: 1M context + configurable reasoning; 4.6 has a fast-mode preview |
| Claude Fable 5 | Powerful | $10.00 | $1.00 | $12.50 | $50.00 | Anthropic's frontier; 1M context, 128K output, image input; GA June 9, 2026 — Pro+/Max/Business/Enterprise only, org admin opt-in required |

### Google

| Model | Tier | Input | Cached | Output | Notes |
|---|---|---:|---:|---:|---|
| Gemini 3 Flash | Lightweight | $0.50 | $0.05 | $3.00 | Public preview |
| Gemini 2.5 Pro | Powerful | $1.25 | $0.125 | $10.00 | Cheapest "Powerful"-tier model |
| Gemini 3.5 Flash | Lightweight | $1.50 | $0.15 | $9.00 | |
| Gemini 3.1 Pro (≤200K) | Powerful | $2.00 | $0.20 | $12.00 | Public preview; long-context reasoning, visual input |
| Gemini 3.1 Pro (>200K) | Powerful | $4.00 | $0.40 | $18.00 | Long-context surcharge |

### Microsoft & GitHub fine-tunes

| Model | Tier | Input | Cached | Output | Notes |
|---|---|---:|---:|---:|---|
| Raptor mini | Versatile | $0.25 | $0.025 | $2.00 | Fine-tuned GPT-5 mini (public preview); inline-suggestion specialist |
| MAI-Code-1-Flash | Lightweight | $0.75 | $0.075 | $4.50 | Microsoft's code model; strong instruction-following |

**Spreads worth saying out loud on stage:** input $0.20→$10.00 = **50×**; output $1.25→$50.00 = **40×**. Picking the right tier is worth more than every other optimization combined. ✅

> 📝 **Note on Grok:** xAI models are **not** in the native roster — they're reachable only via BYOK (see §8). ✅

---

## 3 · Capability profiles — what each model is actually good at

### What GitHub itself says ✅
From GitHub's [AI model comparison reference](https://docs.github.com/en/copilot/reference/ai-models/model-comparison) (live June 10, 2026):

| Category | Models GitHub lists | GitHub's wording |
|---|---|---|
| General-purpose coding & writing | GPT-5 mini, GPT-5.3-Codex, MAI-Code-1-Flash, Raptor mini | GPT-5 mini: "fast, accurate code completions and explanations"; GPT-5.3-Codex: "higher-quality code on complex engineering tasks"; Raptor mini: "specialized for fast, accurate inline suggestions" |
| Fast / lightweight tasks | Claude Haiku 4.5, Gemini 3 Flash, Gemini 3.5 Flash | "Fast, reliable answers to lightweight coding questions" |
| Deep reasoning & debugging | GPT-5.4, GPT-5.4 mini, GPT-5.5, Claude Opus 4.6–4.8, Claude Sonnet 4.5/4.6, Claude Fable 5, Gemini 2.5 Pro, Gemini 3.1 Pro | GPT-5.5: "complex reasoning, code analysis, and technical decision-making"; Fable 5: "first-attempt correctness through upfront reasoning"; Gemini 3.1 Pro: "advanced reasoning across long contexts" |
| Visual input | GPT-5 mini, Claude Sonnet 4.6, Gemini 3.1 Pro (+ Fable 5 per Anthropic) | Multimodal: screenshots, UML, wireframes |

### Benchmark snapshot 🔷
Third-party trackers, June 2026 — directionally useful, but scores vary by harness and date:

| Model | SWE-bench Verified | SWE-bench Pro | Source |
|---|---:|---:|---|
| Claude Fable 5 | ~95.0% | **80.3%** (≈11 pts ahead of field) | [llm-stats](https://llm-stats.com/blog/research/claude-fable-5-review), [claude5.ai](https://claude5.ai/news/claude-fable-5-benchmarks-swe-bench-pro-80-percent) |
| GPT-5.5 | 88.7% | 58.6% | [marc0.dev leaderboard](https://www.marc0.dev/en/leaderboard) |
| Claude Opus 4.8 | 88.6% | 69.2% | [codeant.ai roundup](https://www.codeant.ai/blogs/swe-bench-scores) |
| Claude Opus 4.7 | 87.6% | — | [DataCamp comparison](https://www.datacamp.com/blog/gpt-5-5-vs-claude-opus-4-7) |
| GPT-5.3-Codex | 85.0% | — | [marc0.dev](https://www.marc0.dev/en/leaderboard) |
| Gemini 3.1 Pro | 80.6% | 54.2% | [evolink](https://evolink.ai/blog/swe-bench-verified-2026-claude-vs-gpt) |

Two readings for the stage:
- **Verified is saturating** (top models within ~1 pt) — at the frontier, pick on *cost, context window, and agentic reliability*, not leaderboard rank. 🔷
- **SWE-bench Pro separates the field**: Fable 5's ~11-point lead shows up specifically on **long-horizon agentic work** — investigate→patch→test→recover loops. That's exactly the workload where retries are most expensive, which is why the priciest model can be the cheapest *per completed task*. 🔷

### Context windows & special capabilities ✅
- **1M-token context + configurable reasoning effort:** Claude Sonnet 4.6, Opus 4.6/4.7/4.8, Fable 5 — *in VS Code and Copilot CLI only*; premium pricing applies to extended-capability usage. ([supported-models](https://docs.github.com/en/copilot/reference/ai-models/supported-models))
- **Fable 5:** 1M input / up to 128K output, text+image. 🔷
- **GPT-5.4 nano** is the only roster model *not* available in Agent/Ask/Edit modes — it's a completion-style workhorse. ✅

---

## 4 · Per-model deep profiles — strengths, weaknesses, do / don't

The matrix in §5 answers "which model for this task." This section answers the reverse: "what is this model actually like to work with." Specs are ✅ (GitHub docs, live June 10, 2026); behavioral notes are 🔷/🧪 as marked. Prices are input/output per 1M tokens.

### OpenAI

#### GPT-5.4 nano — the bulk-completion floor
*Lightweight · $0.20/$1.25 · GA · **not available in Agent/Ask/Edit modes** ✅*
- **Strengths:** Cheapest tokens in the roster by a wide margin; high-throughput completion-style output.
- **Weaknesses:** Locked out of every interactive chat surface; no meaningful multi-step reasoning; standard context only.
- **Use it for:** Bulk mechanical transforms where it's reachable (completion-style surfaces), high-volume boilerplate generation.
- **Don't use it for:** Anything conversational or agentic — you literally can't, and that's by design.

#### GPT-5 mini — the default cheap generalist
*Lightweight · $0.25/$2.00 · GA · all modes · in every Auto-selection pool · multimodal ✅*
- **Strengths:** GitHub's own wording: "fast, accurate code completions and explanations" and "deep reasoning and debugging with faster responses and lower resource usage than GPT-5" ✅. Unusually strong math/logic for its price class (holds up on AIME-style problems 🔷). Cheapest multimodal entry point.
- **Weaknesses:** Shallow on long agentic chains; standard context; will produce plausible-but-generic answers on architecture questions. 🧪
- **Use it for:** Quick Q&A, "explain this error," docstrings, commit messages, regex/one-liner help, screenshot-to-snippet.
- **Don't use it for:** Multi-file refactors, long agent runs, anything where a wrong-but-confident answer is expensive.

#### GPT-5.4 mini — the codebase explorer
*Lightweight · $0.75/$4.50 · GA · 0.33× legacy multiplier in cloud agent ✅*
- **Strengths:** GitHub specifically calls out "codebase exploration… especially effective when using grep-style tools" ✅ — it's tuned for the search-read-summarize loop. One of the two models GitHub added to cloud agent "for straightforward changes" ✅.
- **Weaknesses:** Exploration ≠ synthesis — it finds where things are, but don't trust it to redesign them; standard context.
- **Use it for:** "Where is X handled in this repo?", tracing call paths, executing a written spec, straightforward cloud-agent changes.
- **Don't use it for:** Architecture decisions, gnarly debugging, large coherent rewrites.

#### GPT-5.3-Codex — the coding workhorse
*Powerful · $1.75/$14 · GA · 1M context + configurable reasoning · in all three Auto pools ✅*
- **Strengths:** Coding-specialized: "higher-quality code on complex engineering tasks like features, tests, debugging, refactors, and reviews" ✅. Concise, diff-focused output that uses **2–4× fewer tokens per task** than Sonnet-class models 🔷 — the token economy compounds with the lower price. Snappy interactive feel (~62 tok/s) 🔷. SWE-bench Verified ~85% 🔷.
- **Weaknesses:** Interprets **vague prompts less accurately than Sonnet 4.6**, and misses edge cases Sonnet anticipates in multi-file refactors 🔷. Documentation output tends terse — fine for maintainers, sparse for newcomers 🔷.
- **Use it for:** Well-specified feature work, test suites, code review, terminal-heavy iterative sessions, mid-complexity agent runs — the best $/quality in the roster for *clearly described* coding tasks.
- **Don't use it for:** Underspecified "make it better" asks, big cross-file architecture changes, docs meant for onboarding.

#### GPT-5.4 — the versatile-tier generalist
*Versatile · $2.50/$15 (≈doubles >272K) · GA · 1M context + configurable reasoning ✅*
- **Strengths:** "Multi-step problem solving and architecture-level code analysis" ✅; solid at everything without a specialization premium.
- **Weaknesses:** Squeezed from both sides — Codex beats it on $/coding-task, GPT-5.5 beats it on hard reasoning; long-context surcharge above 272K.
- **Use it for:** Mid-to-hard debugging, design discussions, multi-file edits when org policy prefers OpenAI.
- **Don't use it for:** Simple Q&A (10× overpay vs GPT-5 mini), the very hardest problems (step up to 5.5).

#### GPT-5.5 — the terminal & infra reasoner
*Powerful · $5/$30 (≈doubles >272K) · GA · 1M context + configurable reasoning ✅*
- **Strengths:** "Complex reasoning, code analysis, and technical decision-making" ✅. Best-in-roster on **Terminal-Bench (78.2% vs Opus 4.8's 74.6%)** — the pick for DevOps agents, CLI automation, and infrastructure work 🔷. On DeepSWE-style harnesses it beat Opus 4.8 by ~12 points **at roughly half the realized cost and 2× the speed** (~21 vs ~43 min/task; Opus emitted 2.9× more output tokens) 🔷.
- **Weaknesses:** SWE-bench **Pro** 58.6% — far behind Fable 5 (80.3%) and Opus 4.8 (69.2%) on long-horizon agentic work 🔷. Long-context surcharge is the steepest in the roster ($10/$45 above 272K).
- **Use it for:** Hard debugging, architecture reviews, shell/infra automation agents, technical decision memos.
- **Don't use it for:** Hours-long autonomous agent runs (that's Fable territory), routine implementation.

### Anthropic

*(All Anthropic models add a cache-write fee of 1.25× input; cached reads are 10× cheaper than fresh input.)*

#### Claude Haiku 4.5 — the quality floor for real work
*Versatile · $1/$5 · GA · Auto pools: chat + CLI · 0.33× legacy multiplier in cloud agent ✅*
- **Strengths:** Punches far above its tier: ~73% SWE-bench Verified — roughly Sonnet-4-level coding in a budget body 🔷. Strong instruction-following and reliable agent *sub-steps* (review, diff generation, structured output) 🔷. GitHub's pick for "everyday coding support… writing documentation" ✅.
- **Weaknesses:** Standard context only — no 1M option, so whole-repo work is out ✅. Text+image only; no reasoning-effort dial, so it plateaus on deep chain-of-thought tasks 🔷. For pure trivia, GPT-5 mini is 4× cheaper.
- **Use it for:** Docs, comments, unit tests, code-review sub-tasks, straightforward cloud-agent changes (the 0.33× pairing), batch refactor steps inside a phased workflow.
- **Don't use it for:** Whole-repo analysis, race-condition debugging, anything needing the 1M window.

#### Claude Sonnet 4.5 / 4.6 — the multi-file refactor king
*Versatile · $3/$15 · GA · 4.6: 1M context + configurable reasoning, in all three Auto pools ✅*
- **Strengths (4.6):** The standout skill is **intent interpretation on vague or underspecified prompts** — testers preferred it over 4.5 ~70% of the time, and it "anticipates edge cases that Codex misses" in multi-file refactors 🔷. 1M context at Versatile-tier price is the cheapest big-window seat in the roster ✅. Fast raw generation 🔷. Multimodal ✅.
- **Weaknesses:** More verbose than Codex — 2–4× more tokens per equivalent task 🔷, which erodes the price advantage on high-volume work; cache-write fee penalizes constantly-changing context.
- **Use it for:** Multi-file refactors, cross-language changes, legacy modernization, "I'm not sure exactly what I want" prompts, long-context work on a budget.
- **Don't use it for:** High-volume simple tasks (token verbosity × $3 input adds up); 4.5 specifically — it's the same price as 4.6, so pick 4.6 unless policy pins you.

#### Claude Opus 4.5–4.8 — the deep-reasoning line
*Powerful · $5/$25 · GA (4.6 fast mode: preview, standard context) · 4.6+: 1M context + configurable reasoning ✅*
- **Strengths:** "Complex problem-solving challenges, sophisticated reasoning" ✅; SWE-bench Pro 69.2% (4.8) — second only to Fable 5 🔷. **Zero Data Retention**, unlike Fable 5 — the strongest reasoning you can get under ZDR ✅.
- **Weaknesses:** Verbosity is the hidden cost: ~2.9× more output tokens per task than GPT-5.5 and ~2× slower in one head-to-head, so realized cost can exceed the sticker gap 🔷. Tends to over-deliberate on simple asks.
- **Use it for:** Planning and architecture sessions, hard debugging (memory corruption, races, distributed-systems bugs), design review — especially under ZDR compliance requirements.
- **Don't use it for:** Spec execution (it second-guesses settled decisions 🧪), quick answers, terminal-automation agents (GPT-5.5 wins there).

#### Claude Fable 5 — the long-horizon specialist
*Powerful · $10/$50 · **GA June 9, 2026** · 1M context, 128K output · **Pro+/Max/Business/Enterprise only; org-disabled by default** ✅*
- **Strengths:** SWE-bench **Pro 80.3% — ~11 points clear of the entire field** 🔷; OSWorld-Verified 85% (computer use) 🔷. GitHub's wording: "first-attempt correctness through upfront reasoning, aggressive parallel tool batching, and proactive verification of pre-existing test state" ✅. Anthropic reports it completes equivalent agentic work with *fewer tool calls and lower token consumption* than Opus-tier models 🔷 — the sticker price overstates the per-task cost.
- **Weaknesses:** Highest list price in the roster (2× Opus). **The only Claude model without ZDR**: Anthropic retains prompts/outputs up to 30 days for safety classifiers — admins must explicitly opt in, and some compliance regimes will rule it out entirely ✅. Not available on the Pro plan ✅. Overkill for routine work.
- **Use it for:** Long-horizon autonomous agent runs (hours of investigate→patch→test→recover), the bugs nothing else cracks, plan authoring whose output feeds many cheap execution runs.
- **Don't use it for:** Chat trivia, routine implementation, any workload under strict zero-retention requirements.
- ⚠️ Several blogs claim a "free until June 22" launch promo; **the GitHub changelog says it bills at provider list pricing and mentions no promo** — verify in your own usage dashboard before relying on it.

### Google

#### Gemini 3 Flash — the preview bargain
*Lightweight · $0.50/$3 · public preview ✅*
- **Strengths:** Cheap, fast lightweight Q&A; Flash-line models have a record of surprising coding strength for their size 🔷.
- **Weaknesses:** Preview status — behavior and availability can shift; standard context.
- **Use it for:** Quick lookups and simple repetitive tasks when it's in your roster.
- **Don't use it for:** Anything you'll demo or automate against (preview churn).

#### Gemini 3.5 Flash — the multimodal utility knife
*Lightweight · $1.50/$9 · GA ✅*
- **Strengths:** A *reasoning-capable* flash model; natively processes **video, audio, and PDF** inputs — the only roster model that does 🔷.
- **Weaknesses:** Coding is its weak suit — averaged ~54.5 vs Haiku 4.5's ~73.3 on coding evals 🔷; reasoning mode adds latency and token spend; priced above other lightweights.
- **Use it for:** Multimodal pipelines — design-doc PDFs, screen recordings, audio notes → code or analysis.
- **Don't use it for:** Primary coding duty; Haiku 4.5 is cheaper *and* better there.

#### Gemini 2.5 Pro — the budget reasoner
*Powerful · $1.25/$10 · GA ✅*
- **Strengths:** Cheapest "Powerful"-tier seat ✅; "complex code generation, debugging, and research workflows" ✅.
- **Weaknesses:** A generation behind; standard context in Copilot; outclassed by 3.1 Pro on tool precision.
- **Use it for:** Budget deep-reasoning and research-style questions when credits are tight.
- **Don't use it for:** Frontier-difficulty debugging or agentic work.

#### Gemini 3.1 Pro — the edit-then-test looper
*Powerful · $2/$12 (≈doubles >200K) · public preview ✅*
- **Strengths:** "Effective and efficient edit-then-test loops with high tool precision" and "advanced reasoning across long contexts and scientific or technical analysis" ✅; strong visual input; the cheapest frontier-adjacent long-context option.
- **Weaknesses:** SWE-bench Verified 80.6% / Pro 54.2% — trails the Claude/OpenAI frontier on hard agentic coding 🔷; the long-context surcharge kicks in at **200K** (earlier than OpenAI's 272K) ✅; preview status.
- **Use it for:** Scientific/technical analysis, diagram- and screenshot-driven work, long-document reasoning on a budget, disciplined edit-test-edit loops.
- **Don't use it for:** The hardest long-horizon agent runs; workloads hovering just above 200K context (you'll pay 2× for the overage).

### Microsoft & GitHub fine-tunes

#### MAI-Code-1-Flash — the moving target
*Lightweight · $0.75/$4.50 · GA · Auto pool: chat only ✅*
- **Strengths:** "Strong instruction-following and adaptive reasoning"; "handles quick coding tasks with adaptive efficiency" ✅.
- **Weaknesses:** GitHub's own caveat: "a continuously improving model. Performance and behavior may evolve over time as new checkpoints are released" ✅ — today's behavior is not next month's.
- **Use it for:** Quick interactive coding tasks where instruction fidelity matters.
- **Don't use it for:** Reproducibility-sensitive workflows, anything you benchmark once and trust forever.

#### Raptor mini — the inline-suggestion specialist
*Versatile tier pricing $0.25/$2 · public preview · fine-tuned GPT-5 mini · Auto pool: chat only ✅*
- **Strengths:** "Specialized for fast, accurate inline suggestions and explanations" ✅ — a GPT-5 mini tuned specifically on Copilot's bread-and-butter workload.
- **Weaknesses:** Preview; inherits GPT-5 mini's ceilings on reasoning depth and context.
- **Use it for:** Cheap, snappy chat explanations and suggestion-style help.
- **Don't use it for:** Agent runs, refactors, anything beyond its suggestion-shaped lane.

> 📝 **Qwen2.5** appears in GitHub's [model-comparison reference](https://docs.github.com/en/copilot/reference/ai-models/model-comparison) ("code generation, reasoning, and code repair/debugging") but is **not** in the native pricing roster — it reaches Copilot only via editor-added models / BYOK (§8). ✅

---

## 5 · The decision matrix

Cross your task against your budget posture. Costs shown are list input/output per 1M tokens.

| Task type | 💰 Budget pick | ⚖️ Balanced pick | 🏆 Quality pick | Why |
|---|---|---|---|---|
| **Quick Q&A / explain code** | GPT-5.4 nano ($0.20/$1.25) | GPT-5 mini ($0.25/$2.00) | Haiku 4.5 ($1/$5) | Answer quality plateaus fast on simple questions; pay for latency, not reasoning |
| **Docs, comments, commit messages** | GPT-5 mini | Haiku 4.5 | — | GitHub lists Haiku for "everyday coding support… writing documentation" |
| **Unit/integration tests** | Haiku 4.5 | GPT-5.3-Codex | Sonnet 4.6 | Tests are pattern-heavy; escalate only for tricky mocking/fixtures |
| **Implement from a written spec** | GPT-5.4 mini ($0.75/$4.50) | GPT-5.3-Codex ($1.75/$14) | Sonnet 4.6 | A clear spec needs a faithful executor, not a re-thinker (Reactor talk) 🧪 |
| **Mid-complexity agent run (cloud agent)** | Haiku 4.5 / GPT-5.4 mini (0.33×) | GPT-5.3-Codex | Sonnet 4.6 | GitHub added the 0.33× pair explicitly "for straightforward changes" ✅ |
| **Multi-file refactor / modernization** | GPT-5.4 ($2.50/$15) | Sonnet 4.6 ($3/$15) | Opus 4.8 ($5/$25) | Cross-file coherence needs the versatile tier minimum |
| **Architecture & planning session** | Sonnet 4.6 | Opus 4.8 / GPT-5.5 | Fable 5 ($10/$50) | Plan output feeds many cheap execution runs — quality compounds |
| **Hard debugging (race conditions, memory)** | GPT-5.4 | Opus 4.8 / GPT-5.5 | Fable 5 | Deep-reasoning category per GitHub's own comparison |
| **Long-horizon agent task (hours of steps)** | Sonnet 4.6 | Opus 4.8 | **Fable 5** | SWE-bench *Pro* gap (80.3% vs 58–69%) is the retry-economics story 🔷 |
| **Whole-repo analysis (>200K tokens)** | Gemini 3.1 Pro ($2/$12, doubles >200K) | Sonnet 4.6 (1M ctx) | Opus 4.8 / Fable 5 (1M ctx) | Mind the long-context price cliff on every option |
| **Diagram/screenshot-driven coding** | GPT-5 mini | Gemini 3.1 Pro / Sonnet 4.6 | Fable 5 | All multimodal; match reasoning depth to the task behind the image |
| **Don't want to choose** | — | **Auto model selection** | — | Picks from a per-surface pool; respects plan + admin policy ✅ |

### The phased-workflow pattern (the biggest practical saving) 🧪→🔷
1. **Plan** with Opus 4.8 / GPT-5.5 / Fable 5 → produce a written spec (~$0.10–0.75 for a typical session).
2. **Execute** the spec with GPT-5.4 mini / Haiku 4.5 / GPT-5.3-Codex at 3–40× lower rates.
3. **Review** with a mid-tier model or Copilot code review.

A frontier reasoning model used for step 2 can actively *hurt* — it reopens settled decisions and burns output tokens second-guessing the plan (practitioner observation from the Reactor talk; consistent with GitHub's "pick the right model for the job" cloud-agent guidance ✅).

---

## 6 · Cost-vs-capability map

```
              CAPABILITY (agentic / reasoning) →
  COST ↓      Light tasks          Versatile             Frontier
  ─────────────────────────────────────────────────────────────────
  ¢           GPT-5.4 nano ░
              GPT-5 mini ░
              Raptor mini ░
  ¢¢          Gemini 3 Flash ░     GPT-5.4 mini ▒
              MAI-Code-1-Flash ░   Haiku 4.5 ▒
  ¢¢¢                              GPT-5.3-Codex ▒▒      Gemini 2.5 Pro ▒
                                   Gemini 3.5 Flash ▒    Gemini 3.1 Pro ▒▒
  ¢¢¢¢                             GPT-5.4 ▒▒            Sonnet 4.6 ▒▒
  ¢¢¢¢¢                                                  Opus 4.8 ▓▓  GPT-5.5 ▓▓
  ¢¢¢¢¢¢                                                 Fable 5 ▓▓▓
  ─────────────────────────────────────────────────────────────────
  Sweet spots: GPT-5 mini (cheap floor) · GPT-5.3-Codex (coding $/quality)
               Sonnet 4.6 (1M ctx at Versatile price) · Fable 5 (when retries cost more than tokens)
```

---

## 7 · Cost math — three worked examples

Using official per-1M rates ✅; 1 credit = $0.01.

**Example 1 — a chat question (5K in / 1K out):**
GPT-5 mini ≈ **0.3 credits** · Haiku 4.5 ≈ 1 credit · Opus 4.8 ≈ 5 credits · Fable 5 ≈ **10 credits**.
*Same question, 30× spread. On a Pro plan ($10 = 1,000 credits/mo), that's 3,000 questions vs 100.*

**Example 2 — a one-shot coding task (50K in / 5K out):**
GPT-5.4 nano ≈ 1.6 cr · GPT-5 mini ≈ 2.3 cr · Haiku 4.5 ≈ 7.5 cr · GPT-5.3-Codex ≈ 15.8 cr · Sonnet 4.6 ≈ 22.5 cr · Opus 4.8 ≈ 37.5 cr · GPT-5.5 ≈ 40 cr · Fable 5 ≈ 75 cr.

**Example 3 — the retry-economics punchline (a 20-turn agent run; context re-sent each turn ⇒ ~500K cumulative input / 20K output):**
| Model | Cost/run | If it takes 3 attempts |
|---|---:|---:|
| Haiku 4.5 | ~60 cr | ~180 cr |
| Sonnet 4.6 | ~180 cr | ~540 cr |
| Opus 4.8 | ~300 cr | ~600 cr (2 attempts) |
| **Fable 5** | ~600 cr | **~600 cr (1 attempt)** |

*If the frontier model lands it first try and the mid-tier needs three, the "expensive" model ties or wins — before counting your time.* The break-even is real but task-dependent: for **routine** work the cheap model also lands first-try, and then it's simply 10× cheaper. **Match the model to the failure risk, not the prestige.** 🔷

*(Caching shifts all of this further toward stable-context workflows: cached input is 10× cheaper on every model, so a stable prefix across 20 turns can cut Example 3 dramatically — see the caching section of `copilot-token-saving-concepts.md`.)*

---

## 8 · Availability gates — why your roster may differ ✅

Three independent gates decide which models you actually see *(workflow-verified 2-0 against [configure-access docs](https://docs.github.com/en/copilot/how-tos/copilot-on-github/set-up-copilot/configure-access-to-ai-models))*:
1. **Your plan** (Free/Student plans see a reduced set — a [community thread](https://github.com/orgs/community/discussions/194310) shows a Student account reduced to Haiku 4.5; **Fable 5 needs Pro+/Max/Business/Enterprise** per its [GA changelog](https://github.blog/changelog/2026-06-09-claude-fable-5-is-generally-available-for-github-copilot/)),
2. **Your client** (GitHub.com vs VS Code vs JetBrains vs CLI — e.g., 1M-context and configurable reasoning are VS Code + CLI only),
3. **Org/enterprise admin policy** (admins can restrict specific models; **Fable 5 is disabled by default** for Business/Enterprise until an admin enables its policy, which acknowledges Anthropic's 30-day data retention ✅).

**Auto model selection pools differ per surface** ✅ ([supported-models](https://docs.github.com/en/copilot/reference/ai-models/supported-models)):
- **Chat:** GPT-5 mini, GPT-5.3-Codex, GPT-5.4, GPT-5.4 mini, Haiku 4.5, Sonnet 4.6, MAI-Code-1-Flash, Raptor mini
- **Cloud agent:** GPT-5.3-Codex, GPT-5.4, Sonnet 4.6
- **CLI:** GPT-5 mini, GPT-5.3-Codex, GPT-5.4, GPT-5.4 mini, Haiku 4.5, Sonnet 4.6

**BYOK escape hatch** ✅ *(workflow-verified 3-0)*: orgs/enterprises can add custom models via their own API keys for Anthropic, OpenAI, xAI, Microsoft Foundry, AWS Bedrock, Google AI Studio, and OpenAI-compatible endpoints. **BYOK usage bills to the provider directly — it bypasses AI Credits entirely**, which makes it a budgeting tool, not just a model-choice tool. (Still public-preview on some surfaces.) This is also the only way to get **Grok** or **Gemini variants beyond the native four** into Copilot.

---

## 9 · Stale docs & traps — don't get burned on stage ⚠️

1. **GitHub's task-comparison guide is out of date.** [Comparing AI models using different tasks](https://docs.github.com/copilot/using-github-copilot/ai-models/comparing-ai-models-using-different-tasks) still builds its examples around **GPT-4.1 and GPT-5.2 — neither is in the current roster or pricing table** (adversarial verification refuted "GPT-4.1 is current" 0-3). Its *task framing* is still useful (it inspired the matrix above); its *model names* are not. Cite the [model-comparison reference](https://docs.github.com/en/copilot/reference/ai-models/model-comparison) instead.
2. **Legacy premium-request multipliers still appear in docs** (e.g., code review = 13×, Haiku/GPT-5.4-mini = 0.33×). Post-June-2026 they're relative-cost folklore for most plans — treat as illustrative, never as billing math. ⚠️
3. **Credit-allotment figures conflict across sources** (§1) — use the GitHub announcement's numbers and re-verify.
4. **Benchmark scores disagree by harness and week** (GPT-5.5 88.7% vs Opus 4.8 88.6% flips depending on tracker). Present ranges and trends, not decimals. 🔷
5. **"Powerful tier = better for everything" is false.** For spec execution, lightweight models are *both* cheaper and often more faithful. 🧪
6. **"Fable 5 is free until June 22" — unverified.** Multiple blogs claim a launch promo, but the [GA changelog](https://github.blog/changelog/2026-06-09-claude-fable-5-is-generally-available-for-github-copilot/) says it "is billed at provider list pricing" and mentions no free period. Check your usage dashboard; don't repeat the claim on stage. ⚠️
7. **"All Claude models are zero-retention" is now false.** Fable 5 retains prompts/outputs up to 30 days for safety classifiers; every *other* Claude model in Copilot keeps ZDR. If a team's compliance story assumes ZDR across Claude, Fable 5 broke that assumption on June 9. ✅

---

## 10 · Sources

**Primary (GitHub/vendor) — fetched live June 10, 2026:**
- [Models and pricing for GitHub Copilot](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing) — the per-token pricing table (§2)
- [Supported AI models in Copilot](https://docs.github.com/en/copilot/reference/ai-models/supported-models) — roster, GA/preview status, auto-selection pools, 1M-context notes
- [AI model comparison](https://docs.github.com/en/copilot/reference/ai-models/model-comparison) — GitHub's task-category recommendations
- [Configure access to AI models](https://docs.github.com/en/copilot/how-tos/copilot-on-github/set-up-copilot/configure-access-to-ai-models) — availability gates, BYOK
- [GitHub Copilot is moving to usage-based billing](https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/) — June 1, 2026 announcement, credit allotments
- [Changelog: cloud agent fast, cost-efficient models](https://github.blog/changelog/2026-05-18-copilot-cloud-agent-fast-cost-efficient-models-for-simple-tasks/) — Haiku 4.5 & GPT-5.4-mini at 0.33×
- [Changelog: Claude Fable 5 is generally available](https://github.blog/changelog/2026-06-09-claude-fable-5-is-generally-available-for-github-copilot/) — plans, surfaces, data retention, admin opt-in (§4, §8)
- [Comparing AI models using different tasks](https://docs.github.com/copilot/using-github-copilot/ai-models/comparing-ai-models-using-different-tasks) — ⚠️ stale model names, useful task framing

**Benchmarks & analysis 🔷:**
- [marc0.dev SWE-bench leaderboard](https://www.marc0.dev/en/leaderboard) · [codeant.ai SWE-bench roundup](https://www.codeant.ai/blogs/swe-bench-scores) · [evolink Claude-vs-GPT](https://evolink.ai/blog/swe-bench-verified-2026-claude-vs-gpt)
- [llm-stats Fable 5 review](https://llm-stats.com/blog/research/claude-fable-5-review) · [claude5.ai Fable 5 SWE-bench Pro](https://claude5.ai/news/claude-fable-5-benchmarks-swe-bench-pro-80-percent) · [DataCamp Opus 4.7 vs GPT-5.5](https://www.datacamp.com/blog/gpt-5-5-vs-claude-opus-4-7)
- [codingfleet Opus 4.8 vs GPT-5.5](https://codingfleet.com/blog/claude-opus-4-8-vs-gpt-5-5-comparison/) — DeepSWE, Terminal-Bench, output-token verbosity (§4)
- [nxcode](https://www.nxcode.io/resources/news/gpt-5-3-codex-vs-claude-sonnet-4-6-coding-comparison-2026) / [zbuild](https://www.zbuild.io/resources/news/gpt-5-3-codex-vs-claude-sonnet-4-6-coding-comparison-2026) Codex-vs-Sonnet-4.6 — token economy, vague-prompt handling, speed (§4)
- [evolink Gemini 3.5 Flash vs Haiku 4.5](https://evolink.ai/blog/gemini-3-5-flash-vs-claude-haiku-4-5) · [Respan fast-model comparison](https://www.respan.ai/blog/fast-model-comparison) — lightweight-tier coding scores, multimodal coverage (§4)

**Community & coverage 🧪:**
- [TechCrunch on the billing backlash](https://techcrunch.com/2026/05/30/what-a-joke-github-copilots-new-token-based-billing-spurs-consternation-among-devs/) · [GitHub community discussion #192948](https://github.com/orgs/community/discussions/192948) · [Student-plan roster thread #194310](https://github.com/orgs/community/discussions/194310)
- [Microsoft Community Hub: Choosing the Right Model](https://techcommunity.microsoft.com/blog/azuredevcommunityblog/choosing-the-right-model-in-github-copilot-a-practical-guide-for-developers/4491623) *(fetch blocked — re-pull before the talk)*
- [Dan Cleary: Codex vs Sonnet 4.6 vs Gemini 3.1 vibe-coding test](https://medium.com/codex/i-tested-gpt-5-3-codex-vs-sonnet-4-6-vs-gemini-3-1-for-vibe-coding-heres-who-winner-7310dcf54a9e) · [abhs.in Fable 5 notes](https://www.abhs.in/blog/claude-fable-5-free-until-june-22-github-copilot-bedrock-api-access-2026) *(source of the ⚠️ unverified free-promo claim)*

---

*Research note: the deep-research workflow for this document was degraded by an org monthly spend limit (19 of 21 source fetches and most verification votes failed; 3 claims fully verified: availability gates 2-0, GPT-5.2-visual-tasks 3-0, BYOK 3-0). All ✅ items above were instead verified by direct live fetch of GitHub primary docs on June 10, 2026. Workflow run ID `wf_f375e787-dc5` can be resumed after the limit resets for full 3-vote coverage. A follow-up inline pass later the same day (no subagents) added §4 per-model profiles, the Fable 5 GA changelog facts, and traps #6–7; its 🔷 behavioral claims (verbosity ratios, Terminal-Bench/DeepSWE numbers, vague-prompt handling) are single-source-per-claim and would benefit from the deferred 3-vote verification.*
