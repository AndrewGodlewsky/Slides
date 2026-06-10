# Act 1 — "Why Agent Quality Beats Cost": Deep Research Report

> **Scope:** Act 1 only (8 slides, ~12 min) of the *Making Every Token Count with GitHub Copilot* workshop.
> **Method:** Fan-out web research → 22 sources fetched → 106 claims extracted → top 25 adversarially fact-checked (3-vote, needs 2/3 to kill a claim) → 11 synthesized findings. **25 of 25 claims confirmed, 0 refuted.**
> **Date:** June 9, 2026. This is a fast-moving area — see the **Time-Sensitivity** warnings throughout.
> **Confidence convention:** 🟢 High = primary source, verbatim-confirmed · 🟡 Medium = corroborated but framing-sensitive · 🔴 Use-with-care = single/soft source.

---

## TL;DR for the presenter

Act 1's argument is **structurally sound and well-sourced.** Every load-bearing claim survived adversarial verification against primary sources. The thesis — *optimize for agent quality, and lower token spend follows* — is not just rhetoric; it falls out of three independent facts:

1. **The cost incentive really did flip onto the developer.** GitHub Copilot moved from premium-request units (PRUs) to **token-metered "GitHub AI Credits" on June 1, 2026** — and credits are billed on **input + output + cached tokens** at each model's published API rate. Waste is now *your* line item. *(GitHub blog + docs, verbatim)*
2. **The math that makes quality matter is real.** Per-step reliability compounds as `p^N`. 99%-per-step over 50 steps = **60.5%**; 95% = **7.7%**. This is confirmed in two arXiv papers — and reality is *worse* than `p^N` because accuracy degrades over a run (self-conditioning).
3. **Agent cost grows quadratically with task length.** Because every step re-sends the whole conversation, a 20-step loop costs ~**210,000** input tokens, not 20,000. Retrying a lazy prompt restarts that quadratic bill. This is the cost engine behind why the "gambling" pattern survives at a few runs/day but breaks at scale.

**The one-sentence stage version:** *"Cheaper-per-token doesn't save you — a marginally cheaper model still pays the quadratic agentic tax on a bloated, retry-heavy run. Fewer, higher-quality runs that finish in fewer steps is the only structural lever."*

---

## Slide-by-slide grounding

Act 1's 8 slides, each tied to the verified evidence that supports it.

| # | Slide | Core claim | Verified? | Best on-stage number |
|---|-------|-----------|-----------|----------------------|
| 1 | Title & Agenda | "Make every token count" | thesis | — |
| 2 | Why This Matters | Billing → usage-based; cost shifts to you | 🟢 | June 1 2026; 1 credit = $0.01 |
| 3 | The "Gambling" Anti-Pattern | Lazy prompt, little context, retry on fail | 🟢 (cost mechanics) | quadratic agentic tax |
| 4 | Why Gambling Broke | Fine at 2–4/day, breaks at dozens–hundreds | 🟢 | 210K vs 20K tokens |
| 5 | Make Every Token Count | Don't cheapen fuel — send better agents | 🟢 | 1,000× vs code chat |
| 6 | Compounding-Error Problem | 99%⁵⁰=61% vs 95%⁵⁰=8% | 🟢 | 60.5% vs 7.7% |
| 7 | Reducing Context = Both Levers | Bloat re-paid every turn | 🟢 | 20K prompt × 40 steps |
| 8 | The Maturity Spectrum | ~10/day low ROI; AI engineer = every % compounds | 🟢 | METR doubling ~7 mo |

---

## Finding 1 — The billing shift is real, dated, and puts waste on your bill
**🟢 High confidence · merged from 6 verified claims (all 3-0)**

**What changed.** GitHub's official blog states verbatim:

> *"Starting June 1, premium request units (PRUs) will be replaced by GitHub AI Credits."*
> *"Credits will be consumed based on token usage, including input, output, and cached tokens, according to the published API rates for each model."*

GitHub Docs now label the old scheme **"Overview of request-based billing (legacy)"** — it applies only to existing annual Pro/Pro+ subscribers until their plan expires. **1 AI Credit = $0.01.**

**The numbers that didn't change:** Pro $10/mo · Pro+ $39/mo (includes $39 of credits) · Business $19/user/mo · Enterprise $39/user/mo. **Code completions remain unlimited and free.**

**Why this is the load-bearing slide-2 fact:** the "cached tokens" billing line means metering is per-token at published rates. The inference that *bloated context re-sent every turn directly costs you* follows directly — it's no longer a flat per-request fee that hides waste.

**Sources:** [GitHub Blog — moving to usage-based billing](https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/) · [GitHub Docs — premium requests](https://docs.github.com/en/billing/concepts/product-billing/github-copilot-premium-requests) · corroborated by The Register (2026-06-02, *"Angry devs vow to flee GitHub Copilot"*), Visual Studio Magazine, The New Stack.

> ⚠️ **Presenter note:** the per-turn "re-paid" phrasing is technically accurate for stateless LLM mechanics but is *illustrative* — it's not spelled out word-for-word in the billing doc. Frame it as the mechanism, then cite Finding 7 for the hard arithmetic.

---

## Finding 2 — The cost pressure actually started in mid-2025
**🟢 High confidence · merged from 4 verified claims (all 3-0)**

The June 2026 shift wasn't the beginning. **As of June 18, 2025**, GitHub already enforced a **monthly premium-request allowance** across Pro/Pro+/Business/Enterprise:

- A premium request = *"one premium request per user prompt, multiplied by the model's rate."*
- **Multipliers** ranged from **0.33× at the low end to ~57× at the top** (e.g. Gemini 2.0 Flash 0.25×, default GPT-4o/4.1 1×, GPT-4.5 50×).
- Once the allowance is spent, overage is billed **pay-per-request ($0.04/request for Pro/Pro+)** against a spending limit that **defaults to $0**.

**Developer takeaway:** the incentive to not waste requests has existed for a year — June 2026 just made it token-granular and harder to ignore.

**Sources:** [GitHub changelog 2025-06-18](https://github.blog/changelog/2025-06-18-update-to-github-copilot-consumptive-billing-experience/) · [GitHub Docs — model multipliers](https://docs.github.com/en/copilot/reference/copilot-billing/model-multipliers-for-annual-plans)

> ⚠️ **Presenter note:** the 0.33×–57× range drifts as models are added/removed. **Re-verify the exact top multiplier the week of your talk.** This maps to Act 3's multiplier table too.

---

## Finding 3 — GitHub itself blames "escalating, unsustainable" inference cost
**🟢 High confidence (causal core) · 1 claim 2-1**

GitHub's own blog gives the *why* in its own words:

> *"the current premium request model is no longer sustainable"*
> *"GitHub has absorbed much of the escalating inference cost behind that usage"*
> *"a quick chat question and a multi-hour autonomous coding session can cost the user the same amount"* ← **this is the perfect slide-2/slide-3 quote**

That last line *is* the gambling anti-pattern stated by GitHub: under flat billing, a careless multi-hour agent run was priced the same as a one-line question. Usage-based billing exists specifically to end that.

**Sources:** [GitHub Blog](https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/) · [Tom's Hardware](https://www.tomshardware.com/tech-industry/artificial-intelligence/ai-costs-begin-to-bite-as-agents-may-increase-token-demand-by-24-times-says-goldman-sachs-report-uber-and-microsoft-among-companies-feeling-the-bite-of-tokenized-billing)

> 🔴 **Do NOT use on stage:** the sharper *"costs doubled since the start of the year"* figure comes from **a single secondary source** (Ed Zitron / wheresyoured.at citing unnamed internal docs). Use GitHub's own "escalating / unsustainable" wording instead — it's primary and unimpeachable.

---

## Finding 4 — The compounding-error math is formally correct
**🟢 High confidence · merged from 3 verified claims (all 3-0)**

This is the spine of Act 1. A constant per-step success probability `p` over `N` steps yields `p^N` — exponential decay in task success as length grows.

| Per-step accuracy | × 10 steps | × 50 steps | × 100 steps |
|---|---|---|---|
| **99%** | 90.4% | **60.5%** | 36.6% |
| **95%** | 59.9% | **7.7%** | 0.6% |
| **90%** | 34.9% | 0.5% | ~0% |

The workshop's slide (99%⁵⁰ ≈ 61% vs 95%⁵⁰ ≈ 8%) is **exactly right.**

Two primary papers ground it:
- **Toby Ord, *"Is there a half-life for the success rates of AI agents?"*** (arXiv [2505.05115](https://arxiv.org/abs/2505.05115), May 2025): a constant per-minute failure rate *"implies an exponentially declining success rate with the length of the task"* because tasks *"involve increasingly large sets of subtasks where failing any one fails the task."*
- **Sinha et al., *"The Illusion of Diminishing Returns"*** (arXiv [2509.09677](https://arxiv.org/abs/2509.09677), ICLR 2026): formalizes `H_s(p) = ⌈ln(s)/ln(p)⌉` and states *"marginal gains in single-step accuracy can compound into exponential improvements in the length of tasks a model can successfully complete."*

**Developer insight — the flip side is hopeful:** because the relationship is exponential *in both directions*, a tiny per-step quality gain (95% → 99%) doesn't add a few percent — it can **multiply the length of task the agent can finish.** That's the whole ROI case for context discipline.

> ⚠️ **Presenter note:** Ord hedges ("suggestive of"). Frame `p^N` as a *proposed/consistent mechanism*, not a proven law of nature.

---

## Finding 5 — Reality is WORSE than p^N (this strengthens your argument)
**🟢 High confidence · 1 claim (3-0)**

The clean `p^N` curve is *optimistic*. Sinha et al. show per-step accuracy is **not constant** — it **degrades as the run gets longer**:

> *"the per-step accuracy of models degrades as the number of steps increases"*
> *"models become more likely to make mistakes when the context contains their errors from prior turns"* (**self-conditioning**)
> *"scaling model size does not mitigate self-conditioning"*

**Why this is gold for Act 1:** a skeptic might say "99% per step is unrealistically pessimistic — models are better than that." The honest rebuttal is the opposite: the idealized curve is the *best case.* Real agents compound *their own mistakes*, so long, junk-filled context doesn't just cost more — it actively makes the model dumber as it goes. **This is the single strongest argument for `/clear` and fresh sessions (Act 4).**

**Source:** [arXiv 2509.09677](https://arxiv.org/abs/2509.09677) (Cambridge / Stuttgart / Max Planck)

---

## Finding 6 — METR: reliability collapses with task length (real benchmark data)
**🟢 High confidence · merged from 3 verified claims**

[METR's March 2025 study](https://metr.org/blog/2025-03-19-measuring-ai-ability-to-complete-long-tasks/) (170 SWE/cyber/reasoning/ML tasks) gives you concrete, citable numbers:

> *"current models have almost 100% success rate on tasks taking humans less than 4 minutes, but succeed <10% of the time on tasks taking more than around 4 hours."*

And the **killer datapoint** from the [METR time-horizons FAQ](https://metr.org/time-horizons/):

> *"on tasks that take a human expert 90 minutes to 3 hours, a GPT-5 agent (with time horizon of around 2 hours and 17 minutes) succeeds 100% of the time for around one-third of the tasks, fails 100% of the time for around one-third, and sometimes succeeds and sometimes fails on the remaining third."*

**The punchline:** a "2-hour time horizon" does **NOT** mean uniform reliability up to 2 hours. Even within its rated range, GPT-5 only *reliably* finishes a third of tasks. This is the empirical face of compounding error — and it directly justifies splitting big tasks into small, verifiable steps (Act 4).

**Mechanism (METR's own words):** *"AI agents often seem to struggle with stringing together longer sequences of actions more than they lack skills or knowledge needed to solve single steps."* Ord maps METR's **50% time-horizon = the agent's half-life** (e.g. Claude 3.7 Sonnet ≈ **59 minutes**).

> ⚠️ **Presenter note:** METR hedges ("seem to") and notes *some* failures are genuine single-step competence gaps. The half-life model is explicitly bounded to automatically-scorable research-engineering tasks — *"whether this model applies more generally … is unknown."* These figures are model-snapshot-specific (GPT-5 = 2h17m as of Aug 6, 2025).

---

## Finding 7 — Bloated context is structurally re-paid every turn
**🟢 High confidence · 1 claim (3-0) · the most concrete on-stage demo**

Because LLM APIs are **stateless**, every agent step re-sends the *entire* conversation. [ProjectDiscovery's engineering blog](https://projectdiscovery.io/blog/how-we-cut-llm-cost-with-prompt-caching) gives a real, named example:

> *"Each step re-sends the entire conversation: system prompt, tool definitions, and all prior messages."*
> *"System prompts are 2,500+ lines of YAML, over 20K tokens per agent."*
> *"On a 40-step task, you're sending that 20K-token system prompt 40 times."*

**That's 800,000 tokens of system prompt alone — for one task.** This is the literal, dollar-attached meaning of "context re-paid every turn," and it ties straight back to Finding 1's per-token metering.

**Source:** [ProjectDiscovery](https://projectdiscovery.io/blog/how-we-cut-llm-cost-with-prompt-caching) · corroborated by Augment Code, Atlan.

---

## Finding 8 — The "agentic tax": cost grows QUADRATICALLY with task length
**🟢 High confidence · 1 claim (3-0)**

The system prompt is just the fixed term. The *growing-history* term is quadratic:

> ProjectDiscovery: *"The agentic tax: the cost of intelligence compounds quadratically with task complexity. Caching is the only structural fix."* — because step N re-sends steps 1…N-1, total ≈ `1+2+…+N ≈ N²/2`.

**Worked example (Augment Code, verbatim):**
> *"A 20-step loop where each step generates 1,000 tokens produces **210,000** cumulative input tokens rather than the **20,000** a per-step estimate would suggest."*

(That's exactly `N(N+1)/2 × 1000 = 20×21/2×1000 = 210,000`.)

**This is the cost engine behind slide 3–4.** Why is "gambling" survivable at 2–4 agents/day but ruinous at hundreds?
- Each **retry restarts and re-grows** a quadratic context bill.
- A lazy prompt produces a longer, more wandering trajectory → more steps → `N²` not `N`.
- Multiply a quadratic per-run cost by hundreds of runs/day and the curve detaches from your budget.

**Sources:** [ProjectDiscovery](https://projectdiscovery.io/blog/how-we-cut-llm-cost-with-prompt-caching) · [Augment Code](https://www.augmentcode.com/guides/ai-agent-loop-token-cost-context-constraints) · LeanOps · Stevens Institute economics analysis.

---

## Finding 9 — Agents are uniquely token-hungry → the macro case for quality
**🟢 High confidence · merged from 2 verified claims · framing-sensitive**

> **Stanford Digital Economy Lab** (arXiv [2604.22750](https://arxiv.org/abs/2604.22750), *"How Do AI Agents Spend Your Money?"*): *"agentic tasks are uniquely expensive, consuming **1000× more tokens** than code reasoning and code chat, with **input tokens** rather than output tokens driving the overall cost."*

> **Goldman Sachs Research:** agentic AI could drive a **>24× increase in global token demand by 2030** (~120 quadrillion tokens/month).

Together these make the slide-5 thesis structurally inevitable: when input tokens dominate and agents are 1,000× hungrier, the highest-leverage lever is **fewer, better-targeted runs that finish in fewer steps** — *not* a marginally cheaper per-token model that still pays the quadratic tax on every wandering trajectory.

> 🔴 **Presenter precision:** cite the **Stanford arXiv study directly** for the 1,000× figure, and say the baseline is **"code chat,"** not a generic consumer chatbot. The **Goldman 24× is an analyst forecast**, not measured data — present it as a projection.

**Sources:** [Stanford arXiv 2604.22750](https://arxiv.org/abs/2604.22750) · [Tom's Hardware / Goldman Sachs](https://www.tomshardware.com/tech-industry/artificial-intelligence/ai-costs-begin-to-bite-as-agents-may-increase-token-demand-by-24-times-says-goldman-sachs-report-uber-and-microsoft-among-companies-feeling-the-bite-of-tokenized-billing)

---

## Finding 10 — The capability frontier is moving fast (frame the maturity spectrum)
**🟢 High confidence · 1 claim (3-0)**

METR: *"the length of tasks AI agents can complete with 50% reliability **has been doubling approximately every 7 months for the last 6 years.**"* (The 2024–2025 subset shows a steeper ~4-month trend.)

**Use this for slide 8 (the Maturity Spectrum):** agents are getting more capable *fast*, which is exactly why the "AI engineer" running hundreds of async agents is a near-term reality — and why per-run quality, which compounds, is the differentiator. At ~10 agents/day, tuning has low ROI; at hundreds, every percentage point of per-step reliability compounds into massive throughput and cost differences.

**Source:** [METR March 2025](https://metr.org/blog/2025-03-19-measuring-ai-ability-to-complete-long-tasks/) · corroborated by AI Digest ("new Moore's Law"), LessWrong, EA Forum.

---

## The argument as one causal chain (for your own mental model)

```
Billing flipped to per-token (input+output+cached), June 1 2026   [F1, F2]
        │  waste is now YOUR line item
        ▼
Agents re-send the whole conversation every step (stateless)      [F7]
        │  fixed system prompt × N  +  history term ~ N²/2
        ▼
Cost grows QUADRATICALLY with task length — the "agentic tax"     [F8]
        │  20 steps → 210K tokens, not 20K
        ▼
Lazy prompts → longer, wandering trajectories → bigger N²         [F3 gambling]
Retries → restart the quadratic bill from scratch
        │  survivable at 2–4 runs/day, detaches from budget at 100s
        ▼
Meanwhile success = p^N: small per-step quality gains compound    [F4, F5]
        │  99%⁵⁰=61% vs 95%⁵⁰=8%; reality worse (self-conditioning)
        ▼
∴ Fewer, higher-quality, shorter runs is BOTH the quality lever
   AND the cost lever — cheaper-per-token can't escape the N² tax  [F9]
```

---

## What to verify the week of the talk (time-sensitive)

The deep-research run flagged these as volatile as of June 9, 2026:

1. **AI Credits rollout details** — the June 1 change is days old; spending-limit safeguards, grandfathering of annual subscribers, and exact credit inclusions are in flux. Re-check [docs.github.com/billing](https://docs.github.com/en/billing/concepts/product-billing/github-copilot-premium-requests).
2. **Model multipliers / the 0.33×–57× range** — drifts as models are added/removed.
3. **METR / Ord figures are model-snapshot-specific** — GPT-5 = 2h17m (Aug 6, 2025); Claude 3.7 Sonnet ≈ 59 min. Newer frontier models (Opus 4.8, GPT-5.5) likely have longer horizons.

## Open questions the research couldn't fully answer (good "future work" / Q&A prep)

1. **Concrete dollars for one real agent run** under AI Credits — e.g. how many credits does a single 40-step lazy-prompt retry on Opus 4.8 actually burn? (No published worked example yet.)
2. **How much prompt caching offsets the quadratic tax on Copilot specifically** — caching cancels the fixed system-prompt term but *not* the growing-history term; realistic net savings unknown.
3. **Published per-org break-even data** for the gambling anti-pattern — at what runs/day does retry-heavy usage blow the credit allowance? (Only the GS macro forecast exists.)
4. **Measured per-step reliability of *current* (June 2026) frontier coding agents** — so your `p` value in the compounding slide is up to date.

---

## Source quality ledger

| Source | Type | Used for |
|--------|------|----------|
| github.blog — usage-based billing | 🟢 primary | F1, F3 |
| docs.github.com — premium requests / multipliers | 🟢 primary | F1, F2 |
| github.blog changelog 2025-06-18 | 🟢 primary | F2 |
| metr.org blog + time-horizons | 🟢 primary | F6, F10 |
| arXiv 2505.05115 (Ord, half-life) | 🟢 primary | F4, F6 |
| arXiv 2509.09677 (Illusion of Diminishing Returns, ICLR 2026) | 🟢 primary | F4, F5 |
| arXiv 2604.22750 (Stanford, agent spend) | 🟢 primary | F9 |
| projectdiscovery.io (prompt caching) | 🟢 primary (vendor, but reproducible math) | F7, F8 |
| augmentcode.com | 🟡 blog (corroborating) | F8 |
| Tom's Hardware / Goldman Sachs | 🟡 secondary | F3, F9 |
| The Register, VS Magazine, New Stack | 🟡 secondary (corroborating) | F1 |
| Ed Zitron / wheresyoured.at | 🔴 single secondary — **do not use on stage** | (excluded) |

*Generated from a deep-research workflow run: 5 search angles · 22 sources fetched · 106 claims extracted · 25 fact-checked (3-vote) · 25 confirmed · 0 refuted · 11 synthesized findings.*
