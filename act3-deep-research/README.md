# Act 3 Deep Research

Deep, fact-checked research on **Act 3 — "The Billing Model: What Actually Gets Counted"** (10 slides, ~15 min) of the *Making Every Token Count with GitHub Copilot* workshop.

## Files
- **[act3-research-report.md](./act3-research-report.md)** — the full report. 11 findings mapped to subsections 3A (how billing works) and 3B (the two biggest levers), with primary sources, the live-fetched per-token pricing table, four worked examples (including a per-model agent-session cost table), a 13-item gotchas checklist, the time-sensitive re-verify list, and refuted-claims transparency. Read this for depth.

## Verdict
Act 3's skeleton is sound, but **three draft slides need correction** before the talk:
1. **3A-4 "agent tool calls don't count" is legacy-only.** Under AI Credits (live since June 1, 2026), every token an agent burns is metered — this is *the* behavioral change of the transition and the reason for reported 10×–50× bill jumps. Present as then-vs-now.
2. **3B-10 "0× base-model fallback" is gone.** Exhaustion = hard stop or paid overage budget; only completions/next-edit-suggestions keep working. GitHub: *"There is no automatic fallback to lower-cost models."*
3. **3B-7's "~24×" gap isn't supported.** Live pricing (June 9) puts Opus 4.7 vs GPT-5 mini at ~16× blended (20× input / 12.5× output). Fable 5 vs GPT-5 mini is ~33× if you want the bigger truthful number.

Verified and presentable: the June 1 credits shift (1 credit = $0.01), the credits = tokens × rate formula, both billing systems live concurrently, current allowances (Pro 1,500 / Pro+ 7,000 / **new Max 20,000** / Business 1,900 / Enterprise 3,900, org promos 3,000/7,000 through Sept 1), the legacy multiplier table (Sonnet 4.5 = 6× and Opus 4.5 = 15× confirmed; newer models raised — Opus 4.7 now 27×), and the 10% auto-model-selection discount.

## Method
Deep-research workflow: 6 search angles · 24 sources fetched · 120 claims extracted · 25 adversarially fact-checked (3-vote) · 23 confirmed, 2 killed · 11 synthesized findings — plus a same-day live fetch of the pricing page and a targeted "go rogue" sourcing pass. Run June 9, 2026.

> ⚠️ **Extreme time-sensitivity.** The credits system went live June 1, 2026 — eight days before this research. Docs carry an expires-2026-09-01 marker; flex allotments are explicitly variable; legacy multipliers changed 3× in 60 days. Re-verify all numbers within 48 hours of the talk — see the re-verify section in the full report.
