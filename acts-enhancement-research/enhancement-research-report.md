# Acts Enhancement Research — Candidate Slides for "Make Every Token Count"

**Research date:** June 10, 2026
**Goal:** Find high-value slide topics NOT covered by the current 58-slide structure, valuable to the developer audience.
**Method:** 5 search angles · 23 sources fetched · 113 claims extracted · 25 adversarially fact-checked (3-vote) · 23 confirmed, 2 killed · 13 synthesized candidates. The existing 58-slide inventory was passed as an exclusion list, so every candidate below is additive.

> ⚠️ Acute time-sensitivity: most findings are 1–6 weeks old (several shipped June 3–4, 2026). Re-verify URLs and numbers shortly before the workshop.

---

## Act 3 candidates (billing mechanics)

### C1 · "Cached input is 90% off — but Claude charges to fill the cache" ⭐ HIGH confidence (3-0, 3-0)
**On-slide:** Cached input bills at exactly 10% of the input rate on every model; Anthropic models add a cache-WRITE premium of 1.25× input.
**Evidence:** Live pricing fetch (June 10): GPT-5 mini $0.25/$0.025 · Sonnet 4.x $3.00/$0.30 · Haiku 4.5 $1.00/$0.10 · Opus 4.x $5.00/$0.50 · Gemini 2.5 Pro $1.25/$0.125. Docs: "Anthropic models include a cache write cost in addition to cached input" (Sonnet $3.75/M, Fable 5 $12.50/M).
**Developer payoff:** the single biggest *passive* lever on the quadratic re-send tax — stable prefixes, don't edit early instructions mid-session.
**Value: ★★★★★** — fills a real gap; the deck mentions cached tokens but never teaches the 90%-off mechanic or cache-friendly habits.
**Source:** https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing

### C2 · "The long-context surcharge: cross the threshold, pay double" — HIGH (3-0)
**On-slide:** Above per-model input thresholds (>272K GPT-5.4/5.5, >200K Gemini 3.1 Pro), rates jump ~2× input / 2× cached / 1.5× output (GPT-5.4: $2.50→$5.00 in, $15→$22.50 out).
**Developer payoff:** a hard dollar argument for staying under the threshold; pairs with /clear and lost-in-the-middle.
**Note:** already present as a warning chip on act3 slide 18 — this would upgrade it to a full slide, or leave as-is.
**Value: ★★★☆☆** (as a new slide; the chip may suffice)
**Open question:** whether the surcharge applies to the whole request or only tokens above the threshold — docs are ambiguous.
**Source:** models-and-pricing (verified via two independent fetches)

### C3 · "1M-token windows are here — and they're not free" — HIGH (3-0, 3-0)
**On-slide:** VS Code 1.123 (June 3, 2026) ships opt-in 1M-token windows (Claude Opus 4.7, GPT-5.5), GA across VS Code, Copilot CLI, Copilot app — with GitHub's own cost warning: "Larger context windows may consume more tokens per interaction, which increases AI credits usage." GitHub recommends the default window for everyday tasks.
**Developer payoff:** vendor-stated ammunition for the "bigger window is not the answer" thesis; interacts with the long-context surcharge. Could also live in Act 2 as an update to the token-scale slide.
**Value: ★★★★☆** — extremely timely (7 days old), reinforces the core thesis with GitHub's own words.
**Sources:** https://code.visualstudio.com/updates/v1_123 · github.blog changelog 2026-06-04

### C4 · "The thinking-effort dial: right-size reasoning per request" — HIGH (3-0, 3-0)
**On-slide:** VS Code and JetBrains (June 2, 2026) model pickers now expose thinking effort (low/med/high) per request, vendor-framed as balancing "quality, latency, and cost." Thinking tokens bill as output tokens — the most expensive class.
**Developer payoff:** extends "right-size the model" from *which model* to *how hard it thinks* — a brand-new, directly actionable knob.
**Value: ★★★★★** — new lever in the highest-leverage section (3B), shipped days ago.
**Sources:** github.blog changelog 2026-06-03 (VS Code May releases) · 2026-06-02 (JetBrains) · code.visualstudio.com/docs/agents/concepts/language-models ("Lower effort levels reduce latency and token usage by limiting or skipping the thinking step")

### C5 · "Code review now bills twice: AI Credits + Actions minutes" — HIGH (3-0 ×3)
**On-slide:** Since June 1, 2026, every Copilot code review on a **private** repo bills AI Credits **plus** GitHub Actions minutes from plan entitlement (overage at standard Actions rates). Public repos exempt. Applies to all paid tiers, incl. reviews triggered by non-licensed users on org billing.
**Developer payoff:** auto-review-on-every-push habits now feed a second meter most developers don't watch. Fits Act 3 (billing) or Act 5 (monitoring).
**Value: ★★★★☆** — a genuine "wait, what?" money surprise; carries the private-repo qualifier always.
**Sources:** github.blog changelog 2026-04-27 + 2026-06-01

---

## Act 4 candidates (context engineering)

### C6 · "copilot-instructions.md is a tax on every turn" — HIGH (3-0)
**On-slide:** VS Code applies `.github/copilot-instructions.md` to ALL chat requests in the workspace — its tokens are sent (and billed) every turn. Contrast: path-scoped `.instructions.md` with `applyTo` globs load lazily.
**Developer payoff:** the verified *mechanism* behind the existing "keep instructions tiny" slide (4D) — likely a strengthen/merge rather than a new slide. Footnotes: chat only; on by default; caching may soften the cost to the cached-input rate.
**Value: ★★★★☆** (as an upgrade to the existing 4D slide)
**Source:** code.visualstudio.com/docs/agent-customization/custom-instructions (verbatim quote verified)

### C7 · "Silent compaction: VS Code summarizes your history without asking" — HIGH (3-0)
**On-slide:** When the window fills, VS Code automatically compacts the conversation by summarizing earlier messages — "happens transparently in the background." Long sessions silently lose verbatim history near capacity. Setting: `github.copilot.chat.summarizeAgentConversationHistory.enabled`; manual `/compact`.
**Developer payoff:** explains mid-session amnesia attendees have personally experienced; strengthens new-session-per-task and extends the /compact-caveats slide. Could live in Act 2 (failure modes) or 4A.
**Value: ★★★★★** — high "aha" factor; connects a daily pain to a mechanism.
**Sources:** code.visualstudio.com/docs/copilot/chat/copilot-chat-context · changelog v1.110 · microsoft/vscode#299810

### C8 · "Spec Kit: GitHub's official formalization of research→plan→implement" — HIGH (3-0 ×4; two framings REFUTED)
**On-slide:** github/spec-kit (MIT, ~111K stars, v0.10.x): `/speckit.constitution → /speckit.specify → /speckit.plan → /speckit.tasks → /speckit.implement` (+ optional clarify/analyze/checklist). Works with 30+ agents; **GitHub Copilot is the default integration** (IDE + CLI). Positioning: "predictable outcomes instead of vibe coding."
**CRITICAL framing:** do NOT pitch as a token saver — the README makes zero savings claims, and independent reports suggest SDD uses ~20–40% MORE tokens per feature, offset by fewer wasted cycles. Call it "official GitHub open-source toolkit/experiment," not a supported product. REFUTED 0-3: the old un-namespaced `/specify //plan //tasks` commands, and a GitHub "measurably improves efficacy" quote that doesn't exist.
**Developer payoff:** gives 4B's phased workflow an official, demoable vehicle with a name developers can google.
**Value: ★★★★☆** — one slide in 4B; quality argument, not cost argument.
**Sources:** github.com/github/spec-kit · github.blog launch post (Den Delimarsky) · spec-kit integrations page

### C9 · "Copilot Spaces: curate context once, query it forever" — HIGH (3-0, 3-0)
**On-slide:** Spaces accept repos, code, PRs, issues, notes/transcripts, images, uploads as curated context; GitHub's guidance: add "specific files or folders that are most relevant." Questions in a Space "count as Copilot Chat requests and consume AI credits based on the model used and the number of tokens processed" — what you put in affects what every question costs.
**Caveats:** lives in Copilot Chat on github.com (IDE access via GitHub MCP server); docs don't specify wholesale-send vs selective retrieval — say "affects," not "directly affects."
**Developer payoff:** the github.com-side vehicle for only-relevant-context; good for team/onboarding use cases.
**Value: ★★★☆☆** — solid but github.com-centric; depends how IDE-focused the room is.
**Source:** docs.github.com/en/copilot/concepts/context/spaces (GA since Sept 2025)

### C10 · "Delegate to the cloud agent: zero local context consumed" — HIGH (3-0, 3-0)
**On-slide:** The cloud agent runs in its own ephemeral Actions-powered environment (makes changes, validates, opens a PR) — a delegated task consumes essentially zero local chat context beyond the one-turn hand-off. June 4, 2026: Agent tasks REST API in public preview for Pro/Pro+/Max (Business/Enterprise since May 13).
**Caveat:** saves local *context*, not money — cloud sessions still consume credits + Actions minutes remotely. "Zero local context" is an architecture-derived inference, flagged as such.
**Developer payoff:** a concrete when-to-delegate-async-vs-work-local decision slide; pairs with the sub-agents slide in 4D.
**Value: ★★★☆☆**
**Sources:** github.blog changelog 2026-06-04 · docs.github.com cloud-agent concepts + REST reference

### C11 · "Your terminal output is now auto-compressed" — MEDIUM (2-1)
**On-slide:** VS Code v1.120–1.123 automatically compresses verbose terminal output (tests, builds, linters, Docker, package managers) before it reaches the model, "to optimize token usage and help reduce costs." A banner tells the model which filters fired and how to request raw output.
**Caveat (the dissent):** base compression predates May 2026 (~v1.118); it lives in the Copilot Chat extension, not VS Code core. Present as "expanded recently," not "new."
**Developer payoff:** free automatic savings on the noisiest context source — natural merge into the existing RTK shell-trimming slide (4E).
**Value: ★★★☆☆** (as a merge)
**Sources:** changelog 2026-06-03 · VS Code v1.120 notes · vscode-copilot-chat commit "Compress tool output to reduce token usage"

### C12 · "Stop paying premium rates for housekeeping: utility models" — MEDIUM (2-1)
**On-slide:** Settings `chat.utilityModel` + `chat.utilitySmallModel` route background tasks (titles, summaries, rename suggestions, commit messages, intent detection) to a model you choose; docs recommend "a fast and inexpensive model"; BYOK eligible.
**Caveat (the dissent):** "saves premium credits" is an inference — docs never state default utility calls burn premium credits. Present as a capability, not a measured saving.
**Developer payoff:** power-user knob for 4E.
**Value: ★★☆☆☆**
**Sources:** changelog 2026-06-03 · code.visualstudio.com/docs/agent-customization/language-models

---

## Act 5 candidate (verify & monitor)

### C13 · "The built-in token gauge: VS Code's context window control" — HIGH (3-0)
**On-slide:** VS Code chat ships a shaded fill bar of context in use; hover reveals exact tokens as a fraction of the model's window (e.g. 15K/128K) plus per-category breakdown; the denominator changes with the selected model.
**Developer payoff:** the in-editor complement to the /context CLI slide — attendees can watch their own session fill up live during the talk.
**Value: ★★★★☆** (likely a merge into the existing /context or IDE-ring slide rather than standalone)
**Source:** code.visualstudio.com/docs/copilot/chat/copilot-chat-context (updated 6/3/2026)

---

## Refuted — do not use (transparency)

1. Spec Kit's old un-namespaced `/specify`, `/plan`, `/tasks` slash commands — **0-3**; the current commands are namespaced `/speckit.*`.
2. A GitHub quote that spec-first "measurably improves coding-agent efficacy" — **0-3**; no such claim exists.

## Angles that produced NO verified findings (gaps that remain)

- **Real case-study numbers** from engineering blogs on teams cutting Copilot/LLM spend via context discipline — nothing credible survived verification.
- **Token-efficient edit formats** (apply_patch vs whole-file rewrites) — no verifiable Copilot-specific claims.
- **Vision/screenshot token costs** in Copilot chat — no documented numbers.
- **What busts Copilot's cache prefix** — only the pricing side verified; no official session-habit guidance exists. (This is itself an honest on-stage caveat for candidate C1.)

## Open questions

1. Does the long-context surcharge apply to the whole request or only tokens above the threshold?
2. What preserves vs busts the prompt-cache prefix in practice (mid-session instruction edits, model switches, /compact)?
3. Do default utility-model calls consume billable credits, or only after a user overrides the model?

## Source-quality ledger

Primary (docs.github.com, github.blog, code.visualstudio.com, github/spec-kit, arXiv): 16 of 23. Secondary/blog/forum: kenmuse.com, visualstudiomagazine.com, codacy, kilo.ai, projectdiscovery, olivomarco token-optimization repo, community discussions #188691/#165798, microsoft/vscode#290356/#299810.
