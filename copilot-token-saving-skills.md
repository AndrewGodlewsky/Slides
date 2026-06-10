# Token-Saving Skills for GitHub Copilot — A Specific Examples Catalog

*Concrete skill examples, the mechanism behind each, and estimated token savings — with confidence tiers so you can separate measured fact from extrapolation.*

**Compiled:** June 2026 · **Scope:** GitHub Copilot agent skills (shipped Dec 18, 2025), custom agents, MCP, sub-agents · **Method:** multi-angle research → 23 sources → 106 claims → 3-vote adversarial verification (23 confirmed, 2 refuted).

---

## How to read this document

Each savings figure is tagged so you know how much weight it carries:

| Tier | Meaning |
|------|---------|
| 📊 **Measured** | A real before/after number published by GitHub or in a benchmark (3-vote verified). |
| 🏗️ **Mechanism-documented** | The *how-it-saves* is vendor-documented; the *specific %* is a reasonable estimate, not an audited measurement. |
| 🧪 **Illustrative** | A community/blog token-math example. Order-of-magnitude only — no disclosed tokenizer/methodology. |
| ⚠️ **Refuted** | Failed verification — listed only so you *don't* repeat it. |

> **The big caveat up front:** almost every hard number here is **first-party** (GitHub / Anthropic measuring their own products). These are authored engineering posts, not press releases, and several are corroborated by third parties — but they have **not been independently audited end-to-end**. Treat percentages as directional.

---

## Part 1 — Why a "skill" saves tokens at all

A GitHub Copilot **agent skill** is a self-contained folder — a `SKILL.md` file (YAML frontmatter: `name` + `description` required, `license` optional) plus optional scripts and resources — that Copilot loads **only when your prompt matches the skill's description**. This is the cross-tool **SKILL.md standard** shared with Anthropic's Claude Agent Skills. 📊

The token mechanism is **progressive disclosure** — a three-level loading system:

| Level | What loads | When | Token cost |
|-------|-----------|------|-----------|
| **1 · Metadata** | `name` + `description` only | Always, at startup | **~100 tokens / skill** (some sources ~10–20) |
| **2 · Instructions** | The full `SKILL.md` body | Only when the skill is triggered | **Under ~5K tokens** |
| **3 · Resources / scripts** | Bundled files | Only when referenced | **Effectively unlimited** — *scripts execute via bash and their code never enters context; only their output consumes tokens* |

**Source:** Anthropic Agent Skills overview (the shared standard); GitHub/VS Code docs confirm the same lazy-load behavior. 📊

### The headline efficiency numbers

| Comparison | Before | After | Saving | Tier |
|---|---|---|---|---|
| 50-skill library, all-upfront vs. lazy (metadata only) | ~25,000 tok | ~750 tok | **~97%** | 🧪 |
| Anthropic's own example | 150,000 tok | 2,000 tok | **98.7%** | 🏗️ |
| Anthropic Agent Skills SDK general claim | — | — | **85–95%** | 🏗️ |

> **Why this matters:** you can install *dozens* of skills and pay only ~100 tokens each at startup, instead of cramming all that guidance into always-on context (`copilot-instructions.md` / `AGENTS.md`) that is billed **on every single run**.

### Skills vs. the other two primitives

| Primitive | Loading | Token behavior | Best for |
|---|---|---|---|
| **`copilot-instructions.md` / `AGENTS.md`** | Always-on (every run); `AGENTS.md` can be glob/dir-scoped | **Adds tokens to every request** — keep tiny | Short, universal coding standards |
| **Custom agents** | Invoked as a role; `tools:` frontmatter filters available tools | Controls which *tool schemas* load | Constrained workflows, tool restriction |
| **Skills** | Lazy / just-in-time on description match | **~100 tok until triggered**; scripts/resources stay out of context | Detailed, occasional capabilities + bundled scripts |

⚠️ **Do not claim** "GitHub officially frames skills-vs-instructions by token cost" — that specific framing was **refuted** (0-3). The token *behavior* above is documented; the *official positioning* as a cost distinction is not.

---

## Part 2 — The skill catalog (specific examples)

Each entry: **purpose · mechanism · estimated saving · confidence**. The `SKILL.md` sketches are illustrative starting points you can drop into `.github/skills/<name>/SKILL.md` (or your platform's skills directory).

---

### Skill 1 — `gh-cli-over-mcp` (prefer the CLI to the GitHub MCP server) 🔴 top pick
- **Purpose:** Steer the agent to run deterministic `gh` CLI commands for issue/PR/repo operations instead of GitHub MCP tool calls.
- **Mechanism:** An MCP call is a full LLM round-trip that spends tokens on the tool-use JSON schema, the argument block, *and* the response. A `gh` command is a plain HTTP request with **no LLM involvement** — only the (small) result the agent reads back enters context.
- **Estimated saving:** **1,365 tokens (CLI) vs. 44,026 tokens (MCP)** for a single task in an independent benchmark — a **4–32×** reduction. GitHub attributes part of its **up to 62%** workflow reductions to this swap. 📊
- **Confidence:** High (measured: Scalekit benchmark + GitHub Engineering blog).
- **Sketch:**
  ```yaml
  ---
  name: gh-cli-over-mcp
  description: Use for any GitHub issue/PR/repo/label operation. Prefer gh CLI commands over MCP tools.
  ---
  When interacting with GitHub, use `gh` CLI commands (gh issue, gh pr, gh api) run in the
  terminal. Do NOT use GitHub MCP tools. Write results to a workspace file and read back only
  the fields you need.
  ```

---

### Skill 2 — `rest-api-field-filter` (trim API/tool output before it enters context) 🔴
- **Purpose:** Call an API (e.g. GitHub REST) through a bundled script that filters the response to only the needed fields.
- **Mechanism:** The script runs via bash; **its code never loads into context, only its output does**. A raw REST payload (often 10–50 KB) is reduced to a handful of fields.
- **Estimated saving:** **~80–95%** of the raw-payload tokens for that call (payload-dependent). 🏗️ (Mechanism documented by Anthropic; exact % is an estimate.)
- **Confidence:** Medium–High.
- **Sketch:**
  ```yaml
  ---
  name: rest-api-field-filter
  description: Fetch GitHub/REST data with only required fields. Use instead of dumping full API responses.
  ---
  Run scripts/fetch.sh "<endpoint>" "<jq-filter>". It calls the API and pipes through jq so only
  the requested fields return. Never paste full JSON responses into the conversation.
  ```
  `scripts/fetch.sh`: `gh api "$1" | jq "$2"`

---

### Skill 3 — `concise-code-only` (output trimming) 🔴
- **Purpose:** Force terse, code-first responses; suppress restated context, apologies, and filler.
- **Mechanism:** **Output tokens are priced ~5–8× input**, so what the model *writes* is the most expensive class. Cutting prose directly cuts the priciest tokens.
- **Estimated saving:** **~30–70% of output tokens** on verbose tasks (task-dependent). 🏗️ Research cited in GitHub's talk suggests "be concise" barely affects quality.
- **Confidence:** Medium (pricing mechanism is 📊; the % is an estimate).
- **Sketch:**
  ```yaml
  ---
  name: concise-code-only
  description: Apply to all coding tasks. Return code and minimal explanation; no preamble or recap.
  ---
  Respond with the code change only. Omit restating the request, summaries, and pleasantries.
  One sentence of rationale max, only if non-obvious.
  ```

---

### Skill 4 — `scoped-context` (reference specific files, not the whole repo) 🟠
- **Purpose:** Teach the agent to pull `#file:`/`#symbol` references rather than `@workspace` / `#codebase`.
- **Mechanism:** `#codebase` runs a broad semantic search that can inject far more tokens; a named reference sends only the relevant slice and skips discovery.
- **Estimated saving:** Avoids the multi-thousand-token cost of whole-codebase search per query. 🏗️ (Behavior documented; magnitude varies.)
- **Confidence:** Medium.
- **Sketch:**
  ```yaml
  ---
  name: scoped-context
  description: Use when the relevant files are known. Reference exact paths/symbols instead of whole-codebase search.
  ---
  Identify the specific files/symbols involved and reference them directly. Only fall back to a
  codebase-wide search for genuine "where is X?" discovery.
  ```

---

### Skill 5 — `research-plan-implement` (phase separation) 🔴
- **Purpose:** Run a task as three phases — research, plan, implement — with a **fresh session per phase**.
- **Mechanism:** Doing all three in one session lets irrelevant research context accumulate ("context rot"), which inflates tokens every turn and degrades quality. Fresh context per phase keeps each window lean.
- **Estimated saving:** Part of the **19–62%** sustained reductions GitHub measured across five production workflows (see Part 4). 📊 for the workflow outcomes; 🏗️ for attributing it to phasing alone.
- **Confidence:** High (GitHub `optimize-ai-usage` docs + workflow data).
- **Sketch:**
  ```yaml
  ---
  name: research-plan-implement
  description: Use for non-trivial features. Enforce a 3-phase workflow with a new session per phase.
  ---
  Phase 1 (research): gather context, write findings to PLAN.md, then stop.
  Phase 2 (plan): from PLAN.md only, produce a precise task list, then stop.
  Phase 3 (implement): execute the task list in a fresh session, loading only files it names.
  ```

---

### Skill 6 — `verify-before-continue` (deterministic guardrails) 🔴
- **Purpose:** After each change, run tests / linters / scans before proceeding.
- **Mechanism:** A deterministic check creates a tight feedback loop that **stops long chains of incorrect changes** — which GitHub calls *"one of the biggest drivers of token waste."* Naive agent loops re-bill the full history each step (~O(N²)); a 20-step loop can use **10×+** tokens. A failing check resets the compounding error rate.
- **Estimated saving:** Prevents the multiplicative blow-up of retries on inflated context — among the largest *indirect* savings. 📊 (mechanism) / 🏗️ (magnitude).
- **Confidence:** High (GitHub docs; corroborated by Augment Code, Vantage).
- **Sketch:**
  ```yaml
  ---
  name: verify-before-continue
  description: Apply to all multi-step code changes. Run checks after each step; do not proceed on failure.
  ---
  After each change run: tests, linter, type-check. If any fail, fix before the next step.
  Stop when all checks pass — do not add unrequested work.
  ```

---

### Skill 7 — `file-summarizer` (summarize long files before loading) 🟠
- **Purpose:** Replace loading a large file with a bundled script that extracts/summarizes only the relevant sections.
- **Mechanism:** Script output (not the file, not the script) enters context.
- **Estimated saving:** A 10K-token file reduced to a ~500-token extract → **~95%** on that read. 🏗️/🧪 (illustrative arithmetic).
- **Confidence:** Medium.
- **Sketch:**
  ```yaml
  ---
  name: file-summarizer
  description: Use before reading large files (>500 lines). Extract only the relevant region.
  ---
  Run scripts/extract.sh <file> <symbol-or-pattern> to return only the matching region plus a
  one-line file outline, instead of reading the whole file into context.
  ```

---

### Skill 8 — `research-subagent` (offload exploration to a sub-agent) 🟠
- **Purpose:** Send open-ended exploration to a sub-agent that works in its **own** context window and returns a small summary.
- **Mechanism:** The sub-agent may burn **tens of thousands of tokens** exploring but returns only a **~1,000–2,000-token** distilled summary to the main session, keeping the primary window lean.
- **Estimated saving:** Keeps exploration cost *out of* the long-lived main context (which is re-sent every turn). 🏗️ (Anthropic-documented pattern; Copilot-specific numbers are an open question.)
- **Confidence:** Medium–High (mechanism); the Copilot-specific quantification is unverified.
- **Sketch:**
  ```yaml
  ---
  name: research-subagent
  description: Use for broad codebase exploration or doc research. Delegate to a sub-agent; keep only the summary.
  ---
  Spawn a sub-agent to explore and return a <=2K-token summary (key files, signatures, findings).
  Continue the main task from the summary only; discard the exploration transcript.
  ```

---

### Skill 9 — `toolset-narrowing` (custom agent with restricted tools) 🔴
- **Purpose:** A custom agent that exposes **only** the tools a task needs, dropping unused MCP/built-in tool schemas.
- **Mechanism:** A custom agent's `tools:` frontmatter filters available tools — **all** (`["*"]` or omit), a **selective** named list, or **none** (`[]`), plus MCP-level prefixing (`server/tool`, `server/*`). MCP tool schemas are re-sent on **every** stateless request, so unused tools are pure per-turn overhead.
- **Estimated saving:** Removing unused MCP tools saved **8–12 KB per call** (several thousand tokens/run); for a 40-tool GitHub MCP server adding **10–15 KB schema/turn**, 38 tools may be pure overhead. 📊
- **Confidence:** High (GitHub Engineering blog for the MCP removal; `tools:` frontmatter is documented).
- **Sketch:**
  ```yaml
  ---
  name: issue-triager
  description: Triage GitHub issues only.
  tools: ["read", "edit", "github-mcp/issues/*"]   # drop the other ~38 MCP tools
  ---
  Triage incoming issues: label, deduplicate, request missing info. Use only issue tools.
  ```
- **⚠️ Note:** the popular figure *"~2.5–3K tokens per tool schema → 50–60K saved by narrowing"* was **refuted** (0-3). Use the **8–12 KB/call** measured figure instead.

---

### Skill 10 — `pre-aggregate-data` (do data prep outside the LLM loop) 🟠
- **Purpose:** Run `gh`/scripts in a **setup step** that writes results to workspace files; the agent then reads only what it needs.
- **Mechanism:** Moves data-gathering out of the token-billed agent loop entirely; raw fetches never round-trip through the model.
- **Estimated saving:** One of the optimizations targeting the **14.9M-token** baseline run in GitHub's own `gh-aw` workflow (alongside toolset narrowing and ~30% prompt condensing). 📊 (baseline) / 🏗️ (per-technique split).
- **Confidence:** High (GitHub blog explicitly recommends this pattern).
- **Sketch:**
  ```yaml
  ---
  name: pre-aggregate-data
  description: Use when a task needs API/repo data. Fetch in a setup step to files; read selectively.
  ---
  In a setup step, run the needed gh/api calls and write trimmed results to .work/*.json.
  During the task, read only the specific .work files required.
  ```

---

### Skill 11 — `batch-tool-calls` (collapse turns) 🟡
- **Purpose:** Combine multiple operations into one script/call to cut the number of turns.
- **Mechanism:** Every turn re-sends the entire accumulated context; fewer turns = fewer re-sends.
- **Estimated saving:** Turn-count dependent; compounds with context size. 🧪 (extrapolated from statelessness; not separately measured for Copilot).
- **Confidence:** Low–Medium.

---

### Skill 12 — `context-hygiene` (when to /clear vs /compact) 🟠
- **Purpose:** Codify session discipline — start fresh per unrelated task; prefer `/clear` over `/compact` for a bloated session.
- **Mechanism:** A clean window stops re-sending (and re-summarizing) irrelevant history every turn. Compaction reduces tokens but **loses detail** and can cause misses; `/resume` lets you return to a cleared session, so clearing loses nothing.
- **Estimated saving:** Avoids the per-turn re-send of stale context; magnitude grows with session length. 🏗️
- **Confidence:** Medium (CLI/VS Code docs document the mechanics; the policy is a best-practice).

---

## Part 3 — How skills compose to multiply savings

Skills are most effective stacked. The verified composition levers:

1. **Skill + custom-agent tool filtering** — a skill describes the workflow; the agent's `tools:` frontmatter strips unused tool schemas (📊 8–12 KB/call saved).
2. **Skill + `gh` CLI instead of MCP** — bake the CLI-preference into the skill (📊 up to ~32× on the call).
3. **Skill + sub-agent isolation** — the skill delegates exploration; only a ~1–2K summary returns (🏗️).
4. **Skill + phase separation** — the skill enforces fresh context per phase to prevent context rot (📊 via workflow outcomes).
5. **Skill + bundled scripts** — deterministic work runs in bash; only output is billed (📊 mechanism).

---

## Part 4 — The proof: real measured reductions

GitHub published before/after token data for five of its **own** production agentic workflows after applying the techniques above (toolset narrowing, CLI-over-MCP, prompt condensing, pre-aggregation):

| Workflow | Reduction | Notes | Tier |
|---|---|---|---|
| **Auto-Triage Issues** | **62%** | 109 post-fix runs; **~7.8M tokens saved** in aggregate | 📊 |
| **Smoke Claude** | **59%** | | 📊 |
| **Security Guard** | **43%** | | 📊 |
| **Community Attribution** | **37%** | 8 runs | 📊 |
| **Daily Compiler Quality** | **19%** | 12 runs | 📊 |

- **Baseline scale:** the most token-intensive single run measured **14,886,509 tokens (~14.9M)** — the target the optimizations chased. 📊
- **All first-party** (GitHub measuring GitHub); the 7.8M aggregate is hedged as "roughly… assuming the pre-optimization rate."

---

## Part 5 — Real skill libraries & repos to mine

| Resource | What it is |
|---|---|
| **`github/awesome-copilot`** | GitHub's curated library — distinguishes Skills (bundled-asset folders) from Instructions and custom agents; includes a `README.skills.md`. |
| **`olivomarco/github-copilot-token-optimization`** | Community repo focused specifically on token optimization (MCP trimming, etc.). |
| **Anthropic Claude Agent Skills** | The shared `SKILL.md` standard + overview docs with the per-level token figures. |
| **GitHub Docs — `optimize-ai-usage` tutorial** | First-party guidance: phase separation, guardrails, instruction hygiene. |
| **GitHub Engineering blog — "Improving token efficiency in agentic workflows"** | The source of the 8–12 KB/call, CLI-vs-MCP, and 19–62% numbers. |

---

## Part 6 — Myths & refuted claims ⚠️

Do **not** repeat these — both failed verification (0-3):

1. **"GitHub officially distinguishes skills from instructions by token/context cost."** The token *behavior* is real; the *official cost-based framing* is not documented.
2. **"Each GitHub tool schema adds ~2.5–3K tokens; narrowing to one toolset saves ~50–60K tokens/turn."** Refuted. Use the measured **8–12 KB per call** figure for MCP-tool removal instead.

---

## Part 7 — Caveats & open questions

- **First-party data.** Most percentages come from GitHub/Anthropic measuring their own products. Credible engineering posts, partly third-party-corroborated, but **not independently audited**.
- **Illustrative math.** The ~97% / 50-skill example is a blog estimate with no disclosed tokenizer and minor internal inconsistency — order-of-magnitude only.
- **Cross-tool conflation.** The per-skill token figures (~100/skill, <5K body) are from Anthropic's spec, now shared with Copilot. The mechanism transfers, but they are **not a Copilot-specific measurement**.
- **Implementation can fall short.** A Claude Code bug (anthropics/claude-code#14882) reported some plugin skills loading the **full ~5.5K tokens at startup** instead of metadata-only — so real savings can lag the documented architecture. Verify your own setup.
- **Time-sensitivity.** Copilot agent skills shipped **Dec 18, 2025**; the optimization data is dated 2026. Defaults (e.g. number of default GitHub MCP tools) and figures may change.

**Open questions worth tracking:**
- Verified per-tool-schema cost for Copilot's *default* MCP toolset (the 2.5–3K/tool estimate was refuted) and current default tool count.
- Independent (non-vendor) audits of the 19–62% workflow figures.
- Whether Copilot reliably honors metadata-only Level 1 loading at scale.
- Quantified sub-agent summary-offload savings *specifically in Copilot*.

---

## Sources

**Primary — GitHub / Anthropic / VS Code (📊 / 🏗️):**
- GitHub Docs — About agent skills: `docs.github.com/en/copilot/concepts/agents/about-agent-skills`
- GitHub Docs — Add skills: `docs.github.com/.../customize-cloud-agent/add-skills`
- GitHub Docs — Custom agents configuration: `docs.github.com/en/copilot/reference/custom-agents-configuration`
- GitHub Docs — Optimize AI usage tutorial: `docs.github.com/en/copilot/tutorials/optimize-ai-usage`
- GitHub Changelog — Agent skills support (2025-12-18)
- GitHub Engineering Blog — Improving token efficiency in agentic workflows: `github.blog/ai-and-ml/github-copilot/improving-token-efficiency-in-github-agentic-workflows/`
- GitHub `github/awesome-copilot` (+ `docs/README.skills.md`)
- GitHub `github/gh-aw` Issue #27112 (14.9M-token baseline)
- Anthropic — Agent Skills overview: `platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`
- Anthropic — Equipping agents with Agent Skills
- VS Code Docs — Agent skills: `code.visualstudio.com/docs/agent-customization/agent-skills`

**Benchmark / community (📊 / 🧪):**
- Scalekit — gh CLI vs MCP benchmark (1,365 vs 44,026 tokens)
- `boliv.substack.com/p/lazy-skills-a-token-efficient-approach` (50-skill / 97% example)
- `olivomarco/github-copilot-token-optimization`
- InfoQ coverage of GitHub's up-to-62% reductions

*Research method: 6 search angles → 23 sources fetched → 106 claims → top 25 verified by 3-vote adversarial check → 23 confirmed, 2 refuted → synthesized to 13 findings.*
