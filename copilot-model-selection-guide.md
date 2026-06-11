# GitHub Copilot Model Selection Guide — Task × Surface Edition

> **Date-stamped:** June 10, 2026 · **Roster:** 21 models (OpenAI, Anthropic, Google, Microsoft, GitHub)
> **Companions:** `copilot-available-models.md` (roster + pricing) · `copilot-model-comparison-guide.md` (deep per-model narratives, cost math, benchmarks). This document adds the **per-surface dimension** — the same task often wants a different model in chat than in the cloud agent — and the capability × task matrix. It deliberately does not repeat the long-form model narratives; each profile links back.
> **Method:** inline deep-research pass (org spend limit blocked the multi-agent workflow — see research note at end). All ✅ facts fetched live from GitHub primary docs June 10, 2026; recommendation-driving claims cross-checked against a second source where available.

**Confidence tiers** (same as the rest of the workshop materials): ✅ documented (primary docs, fetched live) · 🔷 established (reputable third-party) · 🧪 practitioner/anecdotal — *never quoted as benchmark fact* · ⚠️ stale or conflicting.

> ⚠️ **Preview models can change or vanish without notice**: Gemini 3 Flash, Gemini 3.1 Pro, Raptor mini, Claude Opus 4.6 (fast mode), and the code-review tier system are all public preview as of today. ✅

---

## 1 · The six surfaces — and how model choice actually works on each ✅

Model selection is not one decision; each Copilot surface has its own picker, its own Auto pool, and its own billing quirks.

| Surface | Can you pick the model? | Pool / default | Billing notes |
|---|---|---|---|
| **Inline completions** | Limited. A separate ["Change Completions Model" picker](https://docs.github.com/en/copilot/how-tos/use-ai-models/change-the-completion-model) exists, but lists only completion-tuned models — often just one. Default is GitHub's [custom fine-tuned FIM model](https://github.blog/ai-and-ml/github-copilot/the-road-to-better-completions-building-a-faster-smarter-github-copilot-with-a-new-custom-model/). | Custom GitHub model; Raptor mini (preview) is the suggestion-tuned alternative | **Never consumes AI credits** — completions and Next Edit Suggestions are unlimited on all paid plans ✅ |
| **IDE chat — Ask / Edit** | Yes, full picker. Every roster model **except GPT-5.4 nano** ✅ | [Auto pool](https://docs.github.com/en/copilot/reference/ai-models/supported-models): GPT-5 mini, GPT-5.3-Codex, GPT-5.4, GPT-5.4 mini, Haiku 4.5, Sonnet 4.6, MAI-Code-1-Flash, Raptor mini | Credits per token at model rate |
| **Agent mode (IDE)** | Yes, full picker (same exclusion: no GPT-5.4 nano) ✅ | Same chat Auto pool | Credits; agent loops re-send context every turn — caching matters most here |
| **Copilot CLI** | Yes — `/model` or `--model` ✅ | Auto pool: GPT-5 mini, GPT-5.3-Codex, GPT-5.4, GPT-5.4 mini, Haiku 4.5, Sonnet 4.6. **Raptor mini is not available in CLI** ✅ ([pool list](https://docs.github.com/en/copilot/reference/ai-models/supported-models), [community #186154](https://github.com/orgs/community/discussions/186154)) | Credits; 1M-context & reasoning-effort dials available here (and VS Code) — heavier settings consume more ✅ |
| **Cloud agent** | Yes, when delegating ✅ | Auto pool: GPT-5.3-Codex, GPT-5.4, Sonnet 4.6; plus Haiku 4.5 & GPT-5.4 mini added "for straightforward changes" ([May 18 changelog](https://github.blog/changelog/2026-05-18-copilot-cloud-agent-fast-cost-efficient-models-for-simple-tasks/)) | Credits **plus GitHub Actions minutes** ✅ ([about-coding-agent](https://docs.github.com/copilot/concepts/agents/coding-agent/about-coding-agent)) |
| **Copilot code review** | **No.** Model is auto-selected and undisclosed ✅ ([code-review concepts](https://docs.github.com/en/copilot/concepts/agents/code-review)). The only lever is the per-repo **Low / Medium analysis tier** set by admins — Medium "routes pull requests to a higher-reasoning model" (public preview, [June 2 changelog](https://github.blog/changelog/2026-06-02-shape-copilot-code-review-around-your-team/)) | Credits **plus Actions minutes** since June 1 ([Apr 27 changelog](https://github.blog/changelog/2026-04-27-github-copilot-code-review-will-start-consuming-github-actions-minutes-on-june-1-2026/)); Medium tier costs more than Low ✅ |

Two cross-surface facts worth pinning:

- **Extended capabilities (1M-token context + configurable reasoning effort)** are available on **Claude Sonnet 4.6, Opus 4.6/4.7/4.8, Fable 5, GPT-5.3-Codex, GPT-5.4, and GPT-5.5** — in **VS Code and Copilot CLI only**. ✅ ([supported-models](https://docs.github.com/en/copilot/reference/ai-models/supported-models)) *Correction to our earlier roster file, which credited only the Claude line with 1M context.*
- **Auto model selection got smarter on May 20, 2026**: it now [routes based on your task](https://github.blog/changelog/2026-05-20-auto-model-selection-now-routes-based-on-your-task-in-vs-code/) (reasoning need, codegen complexity, bug-diagnosis difficulty, tool orchestration) plus real-time model health, and bills at the selected model's rate. Critiques of Auto written before that date (e.g., [Visual Studio Magazine, Feb 2026](https://visualstudiomagazine.com/articles/2026/02/06/why-copilots-auto-mode-for-ai-models-ignores-your-actual-task.aspx)) describe the old availability-only router. ✅

---

## 2 · Capability × task matrix

Ratings: ★★★ best-in-roster · ★★ strong · ★ adequate · · weak (works, don't) · ✗ unavailable on chat/agent surfaces. Cost tier = list input price: ¢ ≤ $0.75 · ¢¢ $1–2 · ¢¢¢ $2.50–3 · ¢¢¢¢ $5 · ¢¢¢¢¢ $10 per 1M input. "Agent refactor ≈ cr" = a typical agent-mode refactor (~200K cumulative input / 10K output, uncached) at official rates ✅.

Capability ratings synthesize GitHub's own [model-comparison categories](https://docs.github.com/en/copilot/reference/ai-models/model-comparison) ✅ with the benchmark table in `copilot-model-comparison-guide.md` §3 🔷; treat single-star differences as judgment calls, not measurements.

| Model | Status | Cost | Quick Q&A | Multi-file refactor | Greenfield scaffold | Debugging | Code review (IDE) | Docs / writing | Long-context (>200K) | Agent refactor ≈ cr |
|---|---|---|---|---|---|---|---|---|---|---:|
| GPT-5.4 nano | GA | ¢ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | n/a |
| GPT-5 mini | GA | ¢ | ★★★ | · | ★ | ★ | ★ | ★★ | · | 7 |
| Raptor mini ⚠️preview | preview | ¢ | ★★★ | · | ★ | ★ | ★ | ★★ | · | 7 |
| GPT-5.4 mini | GA | ¢ | ★★ | ★ | ★★ | ★ | ★ | ★★ | · | 20 |
| MAI-Code-1-Flash | GA | ¢ | ★★ | ★ | ★★ | ★ | ★ | ★★ | · | 20 |
| Gemini 3 Flash ⚠️preview | preview | ¢ | ★★ | · | ★ | ★ | ★ | ★ | · | 13 |
| Claude Haiku 4.5 | GA | ¢¢ | ★★ | ★ | ★★ | ★ | ★★ | ★★★ | ✗ (std ctx) | 25 |
| Gemini 3.5 Flash | GA | ¢¢ | ★★ | · | ★ | ★ | ★ | ★★ | · | 39 |
| Gemini 2.5 Pro | GA | ¢¢ | ★ | ★ | ★★ | ★★ | ★★ | ★★ | · | 35 |
| GPT-5.3-Codex | GA | ¢¢ | ★★ | ★★ | ★★★ | ★★ | ★★★ | ★ | ★★ (1M) | 49 |
| Gemini 3.1 Pro ⚠️preview | preview | ¢¢¢ | ★ | ★★ | ★★ | ★★ | ★★ | ★★ | ★★ (cliff at 200K) | 52 |
| GPT-5.4 | GA | ¢¢¢ | ★ | ★★ | ★★ | ★★★ | ★★ | ★★ | ★★ (1M) | 65 |
| Claude Sonnet 4.5 | GA | ¢¢¢ | ★ | ★★ | ★★ | ★★ | ★★ | ★★ | · | 75 |
| Claude Sonnet 4.6 | GA | ¢¢¢ | ★ | ★★★ | ★★★ | ★★ | ★★★ | ★★★ | ★★★ (1M) | 75 |
| Claude Opus 4.5 | GA | ¢¢¢¢ | · | ★★ | ★★ | ★★★ | ★★ | ★★ | · | 125 |
| Claude Opus 4.6 (+fast ⚠️) | GA / preview | ¢¢¢¢ | · | ★★ | ★★ | ★★★ | ★★ | ★★ | ★★ (1M) | 125 |
| Claude Opus 4.7 | GA | ¢¢¢¢ | · | ★★ | ★★ | ★★★ | ★★★ | ★★ | ★★ (1M) | 125 |
| Claude Opus 4.8 | GA | ¢¢¢¢ | · | ★★★ | ★★ | ★★★ | ★★★ | ★★ | ★★★ (1M) | 125 |
| GPT-5.5 | GA | ¢¢¢¢ | · | ★★ | ★★ | ★★★ | ★★ | ★★ | ★★ (1M, cliff at 272K) | 130 |
| Claude Fable 5 | GA (gated) | ¢¢¢¢¢ | · | ★★★ | ★★ | ★★★ | ★★ | ★ | ★★★ (1M) | 250 |

Reading the matrix: the ★★★ column winners are *narrow* on purpose. GPT-5 mini wins Q&A because nothing about a simple question rewards a 30× price premium; Sonnet 4.6 wins refactors on vague-prompt interpretation 🔷; Codex wins greenfield-from-spec on token economy 🔷; Fable 5's stars come from SWE-bench Pro–style long-horizon reliability 🔷 (all sourced in the comparison guide §3–4).

---

## 3 · Per-surface availability matrix ✅

✓ = selectable · A = also in that surface's Auto pool · ✗ = not available. Sources: [supported-models](https://docs.github.com/en/copilot/reference/ai-models/supported-models) modes table + Auto pools, [May 18 cloud-agent changelog](https://github.blog/changelog/2026-05-18-copilot-cloud-agent-fast-cost-efficient-models-for-simple-tasks/), fetched live June 10, 2026.

| Model | Completions | Ask | Edit | Agent mode | CLI | Cloud agent | Code review |
|---|---|---|---|---|---|---|---|
| Custom FIM model (default) | ✓ (default) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| GPT-5.4 nano | ~ (completion-style surfaces only) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Raptor mini ⚠️ | ✓ (suggestion-tuned) | ✓A | ✓ | ✓ | **✗** | ✗ | ✗ |
| GPT-5 mini | ✗ | ✓A | ✓ | ✓ | ✓A | ✗ | ✗ |
| GPT-5.4 mini | ✗ | ✓A | ✓ | ✓ | ✓A | ✓ (simple-task tier) | ✗ |
| GPT-5.3-Codex | ✗ | ✓A | ✓ | ✓ | ✓A | ✓A | ✗ |
| GPT-5.4 | ✗ | ✓A | ✓ | ✓ | ✓A | ✓A | ✗ |
| GPT-5.5 | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ |
| Claude Haiku 4.5 | ✗ | ✓A | ✓ | ✓ | ✓A | ✓ (simple-task tier) | ✗ |
| Claude Sonnet 4.5 / 4.6 | ✗ | ✓ / ✓A | ✓ | ✓ | ✓ / ✓A | ✓ / ✓A | ✗ |
| Claude Opus 4.5–4.8 (+4.6 fast ⚠️) | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ |
| Claude Fable 5 (plan-gated) | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ |
| Gemini 2.5 Pro / 3 Flash ⚠️ / 3.5 Flash / 3.1 Pro ⚠️ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ |
| MAI-Code-1-Flash | ✗ | ✓A | ✓ | ✓ | ✓ | ✓ | ✗ |
| *Code review (undisclosed mix)* | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ (Low/Medium tier ⚠️preview) |

Reminders that gate this table further (detail in comparison guide §8): **plan** (Fable 5 needs Pro+/Max/Business/Enterprise + admin opt-in ✅), **client** (1M ctx & reasoning dials: VS Code + CLI only ✅), and **org admin policy**. On github.com, the third-party **Claude and Codex agents** have their own model pickers (Anthropic models for Claude, OpenAI for Codex — [Apr 14 changelog](https://github.blog/changelog/2026-04-14-model-selection-for-claude-and-codex-agents-on-github-com/)) ✅.

---

## 4 · Per-model profiles — surface-aware do / don't

Compact by design; full strengths/weaknesses narratives live in `copilot-model-comparison-guide.md` §4. Prices = input/output per 1M ✅. "≈ cr" figures use the §2 reference task.

### OpenAI

**GPT-5.4 nano** — *GA · $0.20/$1.25 · surfaces: completion-style only* ✅
- ✔ Bulk mechanical transforms on completion surfaces — cheapest tokens in the roster.
- ✔ High-volume boilerplate where a human reviews every line anyway.
- ✘ Anything in chat/agent/CLI — **not selectable there at all** ✅.
- ✘ Commit messages via chat — you can't reach it; use GPT-5 mini (≈0.3 cr each).

**GPT-5 mini** — *GA · $0.25/$2.00 · all chat surfaces + CLI · chat & CLI Auto pools · multimodal* ✅
- ✔ Quick Q&A, "explain this error," docstrings, commit messages (≈0.3 cr per exchange).
- ✔ Screenshot-to-snippet — cheapest multimodal seat ✅.
- ✘ Multi-file refactors — shallow long-horizon coherence 🧪; agent run ≈7 cr but expect retries.
- ✘ Architecture questions — confident-but-generic answers 🧪.

**GPT-5.4 mini** — *GA · $0.75/$4.50 · all chat surfaces + CLI + cloud agent simple-task tier* ✅ — *mode correction: our roster file said "Chat and Edit"; the live modes table shows Agent ✓ too* ✅
- ✔ "Where is X handled?" repo exploration — GitHub calls out its grep-style tool use ✅.
- ✔ Cloud-agent runs on straightforward changes (the 0.33×-legacy pairing with Haiku) ✅.
- ✘ Architecture or gnarly debugging — exploration ≠ synthesis.
- ✘ Long-context work — no 1M option.

**GPT-5.3-Codex** — *GA · $1.75/$14 · everywhere except completions/code review · all three Auto pools · 1M ctx + reasoning dial (VS Code/CLI)* ✅
- ✔ Well-specified feature work, tests, IDE-side review passes — best $/quality for clear specs; 2–4× fewer output tokens than Sonnet-class 🔷.
- ✔ CLI agent sessions — concise diff-focused output suits terminal iteration 🔷.
- ✔ Mid-complexity cloud-agent tasks (in its Auto pool) ✅.
- ✘ Vague "make it better" asks — measurably worse intent interpretation than Sonnet 4.6 🔷.
- ✘ Onboarding docs — terse output 🔷.

**GPT-5.4** — *GA · $2.50/$15, ~2× above 272K · everywhere except completions/code review · all three Auto pools · 1M ctx* ✅
- ✔ Strong default for everyday agent-mode work 🧪 ([practitioner guide](https://tossitt.com/github-copilot-guide-2026/)); mid-to-hard debugging.
- ✔ Org-prefers-OpenAI multi-file edits.
- ✘ Simple Q&A — 10× overpay vs GPT-5 mini.
- ✘ Workloads hovering just above 272K — the long-context surcharge doubles input ✅.

**GPT-5.5** — *GA · $5/$30, ~2× above 272K · everywhere except completions/code review · 1M ctx* ✅
- ✔ Terminal/infra automation — best-in-roster Terminal-Bench 🔷; hard debugging; decision memos.
- ✔ CLI-heavy DevOps agent runs (fast + cheap *realized* cost vs Opus on some harnesses 🔷).
- ✘ Hours-long autonomous runs — SWE-bench Pro 58.6% vs Fable 5's 80.3% 🔷.
- ✘ Anything above 272K context you could trim — steepest surcharge in the roster ($10/$45) ✅.

### Anthropic *(cache-write fee = 1.25× input on all; cached reads 10× cheaper)*

**Claude Haiku 4.5** — *GA · $1/$5 · all chat surfaces + CLI + cloud agent simple-task tier · chat & CLI Auto pools* ✅
- ✔ Docs, comments, unit tests (≈1 cr per chat exchange; ≈25 cr agent refactor).
- ✔ Cheap cloud-agent runs on well-scoped issues ✅.
- ✘ Whole-repo analysis — standard context only ✅.
- ✘ Deep chain-of-thought debugging — no reasoning dial 🔷.

**Claude Sonnet 4.5** — *GA · $3/$15 · standard context* — same price as 4.6 with fewer capabilities; pick it only when policy pins you ✅.

**Claude Sonnet 4.6** — *GA · $3/$15 · everywhere except completions/code review · all three Auto pools · 1M ctx + reasoning dial · multimodal* ✅
- ✔ Multi-file refactors and legacy modernization — best vague-prompt interpretation 🔷; "nuanced refactoring and prose-heavy code" per practitioner reports 🧪.
- ✔ Cheapest 1M-context seat ($3 input vs Opus $5 / Fable $10) ✅ — the default long-context pick.
- ✔ Cloud-agent default for non-trivial delegated work (in its Auto pool) ✅.
- ✘ High-volume simple tasks — 2–4× output verbosity erodes the sticker price 🔷.
- ✘ Constantly-churning context — cache-write fees punish unstable prefixes ✅.

**Claude Opus 4.5 / 4.6 / 4.7 / 4.8** — *GA · $5/$25 · everywhere except completions/code review · 4.6+ have 1M ctx + reasoning dial; 4.6 fast mode ⚠️ preview* ✅
- ✔ Planning/architecture sessions whose output feeds cheaper executors; hard debugging (races, memory).
- ✔ Compliance-sensitive frontier reasoning — strongest model line under Zero Data Retention ✅.
- ✔ Within the line, default to **4.8** (same price, best scores 🔷); 4.6 fast mode ⚠️ for latency-sensitive chat.
- ✘ Spec execution — second-guesses settled decisions 🧪; quick answers (over-deliberates).
- ✘ Token-metered high-volume agent fleets — ~2.9× output verbosity vs GPT-5.5 in one head-to-head 🔷.

**Claude Fable 5** — *GA June 9, 2026 · $10/$50 · everywhere except completions/code review · 1M ctx, 128K out · **Pro+/Max/Business/Enterprise only, org admin opt-in, no ZDR (30-day retention)*** ✅
- ✔ Long-horizon autonomous agent runs where retries are the real cost — SWE-bench Pro ~80% 🔷, ≈250 cr/run but often 1 attempt vs 3 (worked math: comparison guide §7).
- ✔ The bug nothing else cracks; plan authoring for plan-then-execute pipelines.
- ✘ Anything routine — 30× a GPT-5 mini chat exchange.
- ✘ Strict zero-retention compliance environments — the only Claude in Copilot without ZDR ✅.

### Google

**Gemini 3 Flash ⚠️ preview** — *$0.50/$3* — ✔ cheap quick lookups; ✘ anything you'll demo or automate (preview churn) ✅.

**Gemini 3.5 Flash** — *GA · $1.50/$9* — ✔ the only roster model taking **video/audio/PDF** input 🔷 — multimodal pipelines; ✘ primary coding duty (Haiku 4.5 is cheaper *and* scores higher on coding evals 🔷).

**Gemini 2.5 Pro** — *GA · $1.25/$10* — ✔ budget deep-reasoning when credits are tight (cheapest Powerful-tier seat ✅); ✘ frontier-difficulty debugging or long-context (standard ctx in Copilot).

**Gemini 3.1 Pro ⚠️ preview** — *$2/$12, ~2× above 200K* ✅
- ✔ Disciplined edit-then-test loops — GitHub's own wording on its tool precision ✅; scientific/technical analysis; diagram-driven work.
- ✔ Budget long-document reasoning *below* 200K.
- ✘ Hardest long-horizon agent runs (SWE-bench Pro 54.2% 🔷).
- ✘ Workloads sitting just above 200K — its surcharge cliff comes 72K tokens earlier than OpenAI's ✅.

### Microsoft & GitHub

**MAI-Code-1-Flash** — *GA · $0.75/$4.50 · chat Auto pool* ✅ — ✔ quick interactive tasks with strict instruction-following ✅; ✘ reproducibility-sensitive workflows — GitHub warns checkpoints evolve continuously ✅.

**Raptor mini ⚠️ preview** — *$0.25/$2 · chat Auto pool · **not in CLI*** ✅ — ✔ snappy inline-suggestion-style chat help (it's a GPT-5 mini fine-tuned for exactly that ✅, ~264K ctx / 64K out 🔷); ✘ agent runs or refactors — beyond its suggestion-shaped lane; ✘ terminal workflows — unavailable there ✅.

---

## 5 · The cheat sheet — task × surface → model

*Pin this. Fallback in parentheses. "Auto" = let the router choose — it's task-aware since May 20, 2026 ✅.*

**Inline completions** → default custom model; try **Raptor mini** ⚠️ if offered. Free either way — never spend thought here. ✅

**IDE chat (Ask)**
- Quick Q&A / explain error → **GPT-5 mini** (Raptor mini ⚠️)
- Docs, commit messages, comments → **Haiku 4.5** (GPT-5 mini)
- Hard conceptual debugging → **Opus 4.8** (GPT-5.5)
- Screenshot/diagram question → **GPT-5 mini**; escalate to **Sonnet 4.6** if reasoning-heavy
- Don't care → **Auto**

**IDE Edit mode**
- Single-file edit from clear instruction → **GPT-5.3-Codex** (GPT-5.4 mini)
- Vague "clean this up" → **Sonnet 4.6** (GPT-5.4)

**Agent mode (IDE)**
- Spec-driven implementation → **GPT-5.3-Codex** (GPT-5.4 mini)
- Multi-file refactor / modernization → **Sonnet 4.6** (GPT-5.4; escalate Opus 4.8)
- Greenfield scaffold → **GPT-5.3-Codex** (Sonnet 4.6)
- Whole-repo analysis → **Sonnet 4.6 @ 1M** (GPT-5.4 @ 1M; mind surcharges)
- Long-horizon, retries expensive → **Fable 5** (Opus 4.8) — plan-gated ✅

**Copilot CLI** *(no Raptor mini here ✅)*
- Terminal/infra automation → **GPT-5.5** (GPT-5.3-Codex)
- Everyday CLI session → **GPT-5.3-Codex** (Haiku 4.5)
- Quick shell one-liners → **GPT-5 mini** (Haiku 4.5)

**Cloud agent** *(bills credits + Actions minutes ✅)*
- Straightforward issue → **Haiku 4.5** or **GPT-5.4 mini** ✅
- Standard delegated task → **Sonnet 4.6** (GPT-5.3-Codex)
- Hard/critical delegated task → **Fable 5** if enabled (Opus 4.8)

**Code review** → no model choice ✅. Set repo tier: **Low** for docs/small repos, **Medium** for security-sensitive or cross-service code ⚠️ preview. IDE-side pre-review with **GPT-5.3-Codex** or **Opus 4.7/4.8** is the workaround when you want a *chosen* model reviewing.

---

## 6 · Rules of thumb

1. **Choose the surface first, then the model.** Half the roster is unreachable on any given surface; the §3 matrix prunes your menu before taste enters into it. ✅
2. **Plan powerful, execute cheap.** The 50× input spread ($0.20→$10) is the biggest lever in Copilot; a Fable/Opus plan feeding Codex/Haiku executors beats one mid-tier model doing both. ✅ (math: comparison guide §7)
3. **Escalate on failure shape, not task size.** Cheap model wrong twice in a row → jump two tiers, don't crawl one. A 7-credit retry loop costs more than one 65-credit success. 🧪
4. **For agent runs, quality is the budget item.** Retries multiply *cumulative* context cost; SWE-bench-Pro-strong models (Fable 5, Opus 4.8) win on $/completed-task even at 2–5× sticker price for genuinely hard work. For routine work the cheap model also lands first-try — then it's just 10× cheaper. 🔷
5. **Caching changes the math when your prefix is stable.** Cached input is ~10× cheaper everywhere ✅; long agent sessions on a stable repo snapshot effectively cost ~40% less than the §2 estimates. Anthropic's cache-*write* fee means unstable, churning context is *worse* on Claude than the sticker suggests. ✅
6. **Know your surcharge cliffs:** Gemini 3.1 Pro doubles at **200K**, GPT-5.4/5.5 at **272K** ✅. If a repo analysis lands near a cliff, trim context or switch to flat-priced Sonnet 4.6.
7. **Auto is now a real option** for chat/CLI (post-May 20 task-aware routing ✅) — but its pools skew lightweight-to-mid; explicitly escalate for frontier-difficulty work.
8. **Preview models: use, don't depend.** Gemini 3.1 Pro and Raptor mini are good *today*; don't wire them into scripts, demos, or team docs without a GA fallback. ✅
9. **Completions are free — exploit them.** On paid plans, completions/NES never touch your credit budget ✅; lean on them for mechanical typing and save chat invocations for questions worth a model's time.

---

## 7 · Traps & corrections (new since the comparison guide)

1. **"Goldeneye" is a rumor, not a roster model.** ⚠️ Leak-style blogs ([Medium](https://medium.com/@greekofai/github-copilots-secret-goldeneye-model-just-leaked-and-it-s-a-monster-400k-context-128k-b8c59c9cb63d), [TokenCost](https://tokencost.app/blog/github-copilot-metered-billing-2026)) describe a GitHub fine-tune with 400K context and even quote prices ($1.25/$10). It appears in **no official pricing or supported-models page** we fetched today, and the [HN thread](https://news.ycombinator.com/item?id=47257494) notes the absence of any official announcement. Don't cite it.
2. **1M-context list corrected:** GPT-5.3-Codex, GPT-5.4, and GPT-5.5 support the 1M window alongside the Claude line ✅ — `copilot-available-models.md` undersells this.
3. **GPT-5.4 mini modes corrected:** the live modes table shows Agent ✓ ([supported-models](https://docs.github.com/en/copilot/reference/ai-models/supported-models)); our roster file's "Chat and Edit modes" note is stale. ✅
4. **Aider polyglot hasn't caught up to this roster.** The [public leaderboard](https://aider.chat/docs/leaderboards/)'s top entries are GPT-5-era (88.0%) ⚠️ — don't quote Aider numbers for Opus 4.8 / GPT-5.5 / Fable 5; use the SWE-bench data in the comparison guide §3 instead.
5. **GPT-5.2 and GPT-5.2-Codex are being deprecated** ([May 1 changelog](https://github.blog/changelog/2026-05-01-upcoming-deprecation-of-gpt-5-2-and-gpt-5-2-codex/)) — purge them from any saved prompts, pinned configs, or the github.com Codex agent picker where 5.2-Codex still lingers. ⚠️
6. **Code review billing is two-channel now**: AI credits *and* Actions minutes ✅. Estimating review cost from token math alone undercounts.
7. All the §9 traps in `copilot-model-comparison-guide.md` still stand (stale GPT-4.1 docs, legacy multipliers, the unverified Fable 5 free-promo claim, Fable 5's ZDR break).

---

## 8 · Sources

**Primary (fetched live June 10, 2026):** [Supported AI models](https://docs.github.com/en/copilot/reference/ai-models/supported-models) (modes table, Auto pools, 1M-ctx list) · [Models & pricing](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing) · [Model comparison](https://docs.github.com/en/copilot/reference/ai-models/model-comparison) · [Change the completions model](https://docs.github.com/en/copilot/how-tos/use-ai-models/change-the-completion-model) · [Change the chat model](https://docs.github.com/en/copilot/how-tos/use-ai-models/change-the-chat-model) · [About code review](https://docs.github.com/en/copilot/concepts/agents/code-review) · [About cloud agent](https://docs.github.com/copilot/concepts/agents/coding-agent/about-coding-agent) · [About Copilot CLI](https://docs.github.com/copilot/concepts/agents/about-copilot-cli) · Changelogs: [code-review tiers (Jun 2)](https://github.blog/changelog/2026-06-02-shape-copilot-code-review-around-your-team/) · [code review × Actions minutes (Apr 27)](https://github.blog/changelog/2026-04-27-github-copilot-code-review-will-start-consuming-github-actions-minutes-on-june-1-2026/) · [cloud-agent cheap models (May 18)](https://github.blog/changelog/2026-05-18-copilot-cloud-agent-fast-cost-efficient-models-for-simple-tasks/) · [task-aware Auto (May 20)](https://github.blog/changelog/2026-05-20-auto-model-selection-now-routes-based-on-your-task-in-vs-code/) · [Claude/Codex agent model selection (Apr 14)](https://github.blog/changelog/2026-04-14-model-selection-for-claude-and-codex-agents-on-github-com/) · [GPT-5.2 deprecation (May 1)](https://github.blog/changelog/2026-05-01-upcoming-deprecation-of-gpt-5-2-and-gpt-5-2-codex/) · [Raptor mini preview (Nov 10, 2025)](https://github.blog/changelog/2025-11-10-raptor-mini-is-rolling-out-in-public-preview-for-github-copilot/) · [custom completions model blog](https://github.blog/ai-and-ml/github-copilot/the-road-to-better-completions-building-a-faster-smarter-github-copilot-with-a-new-custom-model/)

**Benchmarks 🔷 / community 🧪:** see `copilot-model-comparison-guide.md` §10 (shared evidence base) · [Aider leaderboard](https://aider.chat/docs/leaderboards/) ⚠️ stale for this roster · [VS Mag on pre-May Auto](https://visualstudiomagazine.com/articles/2026/02/06/why-copilots-auto-mode-for-ai-models-ignores-your-actual-task.aspx) · [Raptor-mini-in-CLI discussion #186154](https://github.com/orgs/community/discussions/186154) · [tossitt agent-mode guide](https://tossitt.com/github-copilot-guide-2026/) 🧪

---

*Research note (June 10, 2026): produced by an inline deep-research pass — the multi-agent workflow was unavailable (org monthly spend limit; see `copilot-model-comparison-guide.md` research note). Per-surface availability facts (§1, §3) were each verified against the primary GitHub doc directly; the supported-models modes table was fetched twice with consistent results. The 🧪 surface-preference anecdotes (GPT-5.4 as agent-mode default, Sonnet 4.6 for prose-heavy refactors) are single-source and should get 3-vote verification when workflow capacity returns.*
