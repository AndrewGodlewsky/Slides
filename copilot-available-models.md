# GitHub Copilot — Available AI Models

> **As of:** June 10, 2026
> **Sources:** [Supported AI models in GitHub Copilot](https://docs.github.com/en/copilot/reference/ai-models/supported-models) · [Models and pricing](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing) · [Legacy model multipliers](https://docs.github.com/en/copilot/reference/copilot-billing/request-based-billing-legacy/model-multipliers-for-annual-plans)

GitHub Copilot offers models from **OpenAI**, **Anthropic**, **Google**, **Microsoft**, and GitHub itself. Which models you see depends on your plan (Free, Pro, Pro+, Business, Enterprise) and client (VS Code, Visual Studio, JetBrains, github.com, Copilot CLI, mobile).

On **June 1, 2026**, GitHub moved to **usage-based billing** (AI credits, where 1 credit = $0.01 USD). The older "premium request multipliers" now apply only to legacy annual Pro/Pro+ plans. Code completions remain unlimited on all paid plans.

---

## OpenAI Models

| Model | Status | Tier | Notes |
|---|---|---|---|
| GPT-5.5 | GA | Powerful | Latest flagship; long-context pricing tier above 272K tokens |
| GPT-5.4 | GA | Versatile | All modes (Ask, Edit, Agent); long-context tier above 272K tokens |
| GPT-5.4 mini | GA | Lightweight | Chat and Edit modes |
| GPT-5.4 nano | GA | Lightweight | Limited modes (not Agent/Edit) |
| GPT-5.3-Codex | GA | Powerful | Code-specialized; all modes |
| GPT-5 mini | GA | Lightweight | Fast, cost-efficient; Ask, Edit, and Agent modes |

## Anthropic Models

| Model | Status | Tier | Notes |
|---|---|---|---|
| Claude Fable 5 | GA | Frontier | Requires explicit enablement on Business/Enterprise |
| Claude Opus 4.8 | GA | Powerful | Advanced reasoning |
| Claude Opus 4.7 | GA | Powerful | Advanced reasoning |
| Claude Opus 4.6 | GA | Powerful | Advanced reasoning |
| Claude Opus 4.6 (fast mode) | Preview | Powerful | Speed-optimized variant |
| Claude Opus 4.5 | GA | Powerful | Advanced reasoning |
| Claude Sonnet 4.6 | GA | Mid-tier | Balanced speed/capability |
| Claude Sonnet 4.5 | GA | Mid-tier | Balanced speed/capability |
| Claude Haiku 4.5 | GA | Lightweight | Fast, low-cost |

## Google Models

| Model | Status | Tier | Notes |
|---|---|---|---|
| Gemini 3.5 Flash | GA | Mid-tier | Fast |
| Gemini 3.1 Pro | Public preview | Powerful | Long-context pricing tier available |
| Gemini 3 Flash | Public preview | Lightweight | |
| Gemini 2.5 Pro | GA | Powerful | |

## Microsoft & GitHub Models

| Model | Status | Provider | Notes |
|---|---|---|---|
| MAI-Code-1-Flash | GA | Microsoft | Code-focused |
| Raptor mini | Public preview | GitHub | Fine-tuned GPT-5 mini variant |

---

## Pricing (Usage-Based Billing, per 1M tokens)

1 AI credit = $0.01 USD. Rates below are USD per million tokens.

| Model | Input | Cached Input | Output |
|---|---|---|---|
| GPT-5 mini | $0.25 | $0.025 | $2.00 |
| GPT-5.3-Codex | $1.75 | $0.175 | $14.00 |
| GPT-5.4 (≤272K) | $2.50 | $0.25 | $15.00 |
| GPT-5.4 (>272K) | $5.00 | $0.50 | $22.50 |
| GPT-5.4 mini | $0.75 | $0.075 | $4.50 |
| GPT-5.4 nano | $0.20 | $0.02 | $1.25 |
| GPT-5.5 (≤272K) | $5.00 | $0.50 | $30.00 |
| GPT-5.5 (>272K) | $10.00 | $1.00 | $45.00 |
| Claude Haiku 4.5 | $1.00 | $0.10 | $5.00 |
| Claude Sonnet 4 / 4.5 / 4.6 | $3.00 | $0.30 | $15.00 |
| Claude Opus 4.5 / 4.6 / 4.7 / 4.8 | $5.00 | $0.50 | $25.00 |
| Claude Fable 5 | $10.00 | $1.00 | $50.00 |
| Gemini 2.5 Pro | $1.25 | $0.125 | $10.00 |
| Gemini 3 Flash | $0.50 | $0.05 | $3.00 |
| Gemini 3.1 Pro (standard / long-context) | $2.00 / $4.00 | $0.20 / $0.40 | $12.00 / $18.00 |
| Gemini 3.5 Flash | $1.50 | $0.15 | $9.00 |
| Raptor mini | $0.25 | $0.025 | $2.00 |
| MAI-Code-1-Flash | $0.75 | $0.075 | $4.50 |

*Anthropic models also bill cache writes: Haiku 4.5 $1.25, Sonnet $3.75, Opus $6.25, Fable 5 $12.50 per 1M tokens.*

---

## Legacy Premium-Request Multipliers (annual Pro/Pro+ plans only)

These apply only to subscribers who stayed on legacy request-based billing after June 1, 2026:

- **0.33×** — Claude Haiku 4.5, GPT-5.4 mini
- **6×** — Gemini 3.1 Pro, GPT-5.3-Codex (raised from 1×)
- **27×** — Claude Opus 4.7 (raised from 7.5×)
- **13×** — Copilot code review (per review)

---

## Extended Capabilities

- Select models support **1M-token context windows** and **configurable reasoning levels** (VS Code and Copilot CLI); heavier usage consumes more AI credits.
- The **Copilot cloud agent** can route simple tasks to fast, cost-efficient models ([changelog, May 18, 2026](https://github.blog/changelog/2026-05-18-copilot-cloud-agent-fast-cost-efficient-models-for-simple-tasks/)).
- Model availability varies by client; preview models can change or be removed without notice. Check **Settings → Copilot → Models** (or your IDE's model picker) for what's enabled in your org.
