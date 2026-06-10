# Deep Research — "Make Every Token Count"

**Produced:** June 9, 2026 · **Method:** 5 parallel deep-research workflows (one per presentation act), each: 5–6 search angles → 20–28 sources fetched → 100–138 claims extracted → 3-vote adversarial verification → synthesis.
**Scale:** ~533 agents, ~11.2M tokens, 122 sources fetched, 607 claims extracted across the five runs.

## Files

| File | Covers | Slides |
|---|---|---|
| `act1-quality-vs-cost.md` | Retry economics, compounding error, METR time horizons, agent growth | 1–8 |
| `act2-foundations.md` | Statelessness, tokenization, Lost in the Middle, context rot, RULER/NoLiMa | 9–16 |
| `act3-billing-model.md` | June 2026 AI Credits, pricing table, allowances, community reaction | 17–26 |
| `act4-context-engineering.md` | Compaction, phased workflows, guardrails, configs, MCP/CLI benchmarks | 27–47 |
| `act5-verify-monitor.md` | /context, /usage, debug views, dashboards, REST APIs, log analyzers | 48–58 |
| `examples-bank.md` | **The best presentation-ready examples, ranked, mapped to slides** | all |

## ⚠️ Verification status — read this first

The runs hit the Claude **session limit** (resets 11pm ET June 9) partway through verification, so vote coverage is uneven:

| Act | Verified claims | Notes |
|---|---|---|
| 1 | 5 confirmed (METR cluster) | Retry-economics & case-study pillars extracted but unvoted |
| 2 | 0 voted | **All 25 claims unvoted (0-0)** — the workflow's "refuted" label is an artifact; claims carry verbatim primary-source quotes |
| 3 | 11 confirmed | Community anecdotes extracted but unvoted |
| 4 | 7 confirmed | Scalekit/GitHub-blog numbers extracted but unvoted |
| 5 | 16 confirmed | REST endpoint details extracted but unvoted |

**Tier legend used in all files:**
- ✅ **VERIFIED** — survived 3-vote adversarial check this run (vote shown)
- 📄 **EXTRACTED** — verbatim-quoted from the named primary source, but votes never ran (session limit). Quote the *source*, spot-check before presenting as fact
- ⚠️ **REFUTED** — actual refute votes (0-3, 0-2, 1-2). Do not present as fact

**To finish verification later:** each workflow can be resumed after the limit resets — completed agents return cached results; only the failed verify/synthesize steps re-run. Run IDs: Act 1 `wf_75a1d2aa-254`, Act 2 `wf_5049972d-5e4`, Act 3 `wf_77edcabd-f71`, Act 4 `wf_ea442b91-6e1`, Act 5 `wf_7b25108a-1e3` (script paths in the session workflows directory). Ask Claude to "resume the five deep-research workflows."

## Headline discoveries (vs. the existing research files)

1. **METR time-horizon research** is the missing academic backbone for Act 1's compounding-error story (✅ verified, 4 findings).
2. **Slide 21/40 nuance:** GitHub's own gh-aw issue #27112 *projects* "~50–60K tokens/turn" savings from MCP toolset narrowing (✅ 3-0) — the figure your earlier research refuted as a *measured per-schema* number is real as a *GitHub-authored projection*. Distinguish carefully on stage.
3. **Scalekit benchmark correction (📄):** the repo's actual numbers are 1,365 vs **27,313** (~20×) for "Get repo info" — the 44,026 figure isn't in the repo README. Worst case: "Summarize PRs by contributor" CLI 4,998 vs MCP **400,013** (~80×).
4. **Copilot CLI has more built-ins than the talk assumed (✅):** `/usage` (session metrics), `/diagnose`, `/collect-debug-logs` exist alongside `/context` and `/chronicle`.
5. **Real credit-burn anecdotes (📄)** from GitHub community threads: 822 credits on one agent request (54% of a monthly quota), 85% of a Pro+ allowance in one afternoon, $1.50 for one small UI bug fix.
6. **Visual Studio label correction (⚠️→✅):** the menu item is now **"Copilot Usage"** — "Copilot Consumptions" is the *older* versions' label (slide 49 wording).
