# Token-Saving Skills & Tools for GitHub Copilot — Repository Hunt Results

*What I found by mining your 117,814-repo dataset for installable skills/tools that cut GitHub Copilot token usage.*

**Date:** June 2026 · **Input:** `output_2026-06-08.csv` (every repo with >500 stars, ~117.8K repos) · **Method:** local keyword funnel → 6 parallel investigation agents fetching READMEs.

---

## How this was produced (methodology)

1. **Filtered the CSV locally** (130 MB, 117,814 repos) for names/descriptions/topics signalling Copilot/Claude skills or token tooling → **4,406 candidates**.
2. **Refined into categories** (skill collections, copilot-specific, token-optimization, context/MCP/subagent tooling) and picked the **~34 most promising** repos.
3. **Dispatched 6 parallel agents**, each fetching READMEs for a themed batch and extracting: what it is, the token-saving mechanism, claimed savings, **Copilot compatibility**, and a skeptical confidence rating.
4. Synthesized below. *The CSV contains no file contents, so candidate selection relied on metadata; agents then read the actual repos.*

### Legend

| Compatibility | Meaning |
|---|---|
| 🟢 **Copilot-native** | Built for / explicitly supports GitHub Copilot (IDE or CLI). Drop-in. |
| 🟡 **Portable** | Standard `SKILL.md` / instructions / MCP — works with Copilot with manual placement, but authored for another tool. |
| 🔵 **Copilot CLI only** | Works with the Copilot **CLI**, not the IDE extension. |
| 🔴 **Not Copilot** | Claude-Code/OpenCode-specific or a rival agent — listed so you don't waste time. |

| Confidence | Meaning |
|---|---|
| 📊 **Measured** | Benchmark/table with before/after numbers (still usually author-run). |
| 📣 **Claimed** | Author asserts a number, no benchmark shown. |
| 🗣️ **Marketing** | Vague/round claim, no methodology. |

> ⚠️ **Across-the-board caveat:** almost no savings figure here is independently audited. Treat percentages as directional, and note that **most tool integrations target the Copilot CLI, not the IDE extension** (flagged per item).

---

## TL;DR — the shortlist worth your time

| Rank | Repo | What you get | Savings (claimed) | Compat | Conf |
|---|---|---|---|---|---|
| 1 | **github/awesome-copilot** | GitHub's own library: `caveman-mode`, `blueprint-mode`, `context-engineering` instructions/agents | **50–70%** (caveman) | 🟢 | 📣 |
| 2 | **chopratejas/headroom** | Local compression proxy for tool output/logs/files | **73–92%** + accuracy benchmarks | 🔵 | 📊 |
| 3 | **rtk-ai/rtk** | CLI proxy + hook that trims command output | **60–90%** | 🟢 (VS Code) | 📣 |
| 4 | **mksglu/context-mode** | MCP server sandboxing big tool outputs | **94–99%** on tool dumps | 🟡 (VS Code/JetBrains) | 📊 |
| 5 | **mattpocock/skills** + **JuliusBrussee/caveman** | `caveman` output-compression skill (+ `handoff`) | **~75%** output | 🟡 | 📣 |
| 6 | **muratcankoylan/Agent-Skills-for-Context-Engineering** | `context-compression`, `context-optimization`, `filesystem-context` SKILL.md skills | none stated | 🟡 | 📣 |
| 7 | **rohitg00/agentmemory** | Persistent memory (avoid re-explaining context) | **~92%** vs summarization | 🔵 | 📣 |
| 8 | **github/spec-kit** | Spec-driven phase separation (cut rework) | none stated | 🟢 | 📣 |
| 9 | **toon-format/toon** | Compact data format for structured payloads | **~40%** on tabular data | 🟡 | 📊 |
| 10 | **ryoppippi/ccusage** + **junhoyeo/tokscale** | Verify Copilot CLI token usage | n/a (measurement) | 🔵 | 📊 |

---

## Category A — Copilot-native skill & instruction libraries

### ⭐ github/awesome-copilot 🟢 (34.6K★) — https://github.com/github/awesome-copilot
**GitHub's own** curated library of Copilot instructions, agents, skills, hooks, and workflows — the single best place to get **drop-in, Copilot-native** token-saving configs.

Token-relevant entries found:
- **`instructions/caveman-mode.instructions.md`** — terse output: bullets/tables, no prose, drop articles/filler. **Claims 50–70% fewer tokens than normal mode.** 📣
- **`agents/blueprint-mode.agent.md`** — plan→implement→verify workflow with "Spartan" code-only output, **parallel/batched read-only tool calls**, and a scope-tiered selector ("Express" for small tasks). Claims **3–5× speed** (speed, not tokens).
- **`instructions/context-engineering.instructions.md`** — keep only relevant files open, work one file at a time, avoid loading everything.
- **`agents/context-architect.agent.md`**, **`context7`** — context curation / docs auto-fetch to avoid manual context dumping.

**Install:** add `*.instructions.md` to `.github/instructions/`, agents to `.github/agents/`, or use the site's install buttons / `awesome-copilot` MCP. **This is the first repo to mine.**

### anthropics/skills 🟡 (148K★) — https://github.com/anthropics/skills
The **canonical Agent Skills standard** (`SKILL.md` spec + `skill-creator`). No purpose-built token skill, but it defines **progressive disclosure** — a skill's body loads only when triggered (~100 tokens metadata until then), the structural reason skills save tokens. `skill-creator` teaches writing lean skills. **Install:** copy a skill folder into `.github/skills/<name>/SKILL.md`.

### wshobson/agents 🟡→🟢 (36.5K★) — https://github.com/wshobson/agents
Multi-harness marketplace (192 agents / 156 skills) that **explicitly lists Copilot support** and uses progressive-disclosure loading. Token-relevant: **`hads`** (Human-AI Document Standard — semantic Markdown tagging for token-efficient reading) and the progressive-disclosure packaging itself. The Haiku-routing/orchestration pieces are harness-dependent and may not carry to Copilot.

### addyosmani/agent-skills 🟡 (49K★) — https://github.com/addyosmani/agent-skills
23 production-engineering skills. Standout: **`build/context-engineering`** — "context size ≠ attention budget," targets **<2,000 lines of focused context/task**, a 5-tier context hierarchy, history compaction, and packing patterns. No numbers, but the best-articulated context-efficiency skill. Portable `SKILL.md` → `.github/skills/`.

---

## Category B — Output-compression skills (the "caveman" family)

These cut **output tokens** (the most expensive class, ~5–8× input) by forcing terse, code-only responses. Same idea appears in three places; pick one.

### mattpocock/skills — `caveman` (+ `handoff`) 🟡 (121K★) — https://github.com/mattpocock/skills
- **`skills/productivity/caveman/SKILL.md`** — strips articles, pleasantries, hedging, filler; fragments + abbreviations; preserves code. **Claims ~75% reduction.** 📣
- **`skills/productivity/handoff/SKILL.md`** — compacts a conversation into a structured handoff doc that references artifacts by path/URL so a fresh session resumes with minimal reload (a context-reset skill).
- **Install:** copy `skills/productivity/caveman/` into `.github/skills/`.

### JuliusBrussee/caveman 🟡 (70K★) — https://github.com/JuliusBrussee/caveman
Standalone "caveman mode" with levels (lite/full/ultra) + **`caveman-compress`** (compresses memory files like `CLAUDE.md`/instructions to cut recurring **input** tokens). **Claims ~75% output, 65% across 10 prompts (22–87% range), 46% on memory files.** 📣 For Copilot it installs as an **always-on rule file** (`--with-init`), i.e. via custom instructions, not the native skill mechanism. *(This is the same family as the `caveman` skills already in your environment.)*

> **Note:** caveman affects **output/response** tokens only — not the model's hidden reasoning tokens.

---

## Category C — Context-engineering skills (SKILL.md, portable)

### ⭐ muratcankoylan/Agent-Skills-for-Context-Engineering 🟡 (16.4K★) — https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering
~15 `SKILL.md` context-engineering skills — the most on-topic skill set found:
- **`context-compression`** — shrink conversation/tool-output size under pressure while preserving state.
- **`context-optimization`** — compaction, masking, caching, token-budget allocation.
- **`filesystem-context`** — move large/durable context into files with just-in-time retrieval (keeps it out of the window).
- **`latent-briefing`** — KV-cache compaction to share trajectory with workers.

No numbers (principle-based), but real, portable skills. **Install:** copy `SKILL.md` files into `.github/skills/`.

### multica-ai/andrej-karpathy-skills 🟡 (171K★) — https://github.com/multica-ai/andrej-karpathy-skills
A single guidelines file. Only **incidental** token relevance ("Simplicity First," "Surgical Changes" → smaller diffs/output). Usable as `.github/copilot-instructions.md`. Not purpose-built for tokens.

---

## Category D — Tool-output compression (proxies, MCP servers, formats)

This is where the **biggest, most measurable** savings live — they shrink the tool/command output that floods agent context.

### ⭐ chopratejas/headroom 🔵 (18.4K★) — https://github.com/chopratejas/headroom
Local context-compression layer (library / proxy / agent-wrapper / MCP) with specialized compressors (JSON, AST-aware code, KV-cache aligner) and **reversible** compression so originals can be retrieved.
- **Savings (📊):** code search **92% (17,765→1,408 tok)**, SRE debug **92%**, GitHub triage **73%**, codebase exploration **47%** — **with accuracy benchmarks** (SQuAD 97%, BFCL 97%, GSM8K unchanged). Strongest evidence of the lot.
- **Copilot:** supports **Copilot CLI** — `headroom wrap copilot --subscription -- --model gpt-4o`. Install: `pip install "headroom-ai[all]"`.

### ⭐ rtk-ai/rtk 🟢 (60K★) — https://github.com/rtk-ai/rtk
Single-binary CLI proxy that filters/dedupes command output (tests, cat, git diff) before it reaches the agent, via a PreToolUse hook.
- **Savings (📣):** "60–90%"; sample session **~118K→~23.9K tokens (−80%)**; tests −90%, reads −70%. Self-labeled estimates.
- **Copilot:** **explicitly supports GitHub Copilot (VS Code)** — `rtk init -g --copilot`. Install: `brew install rtk`. Among the most directly usable.

### mksglu/context-mode 🟡 (16.7K★) — https://github.com/mksglu/context-mode
MCP server that runs large outputs in a sandbox and indexes them (SQLite FTS5/BM25), returning only matching slices.
- **Savings (📊):** **315 KB → 5.4 KB (98%)**; Playwright snapshot 99%, 20 GH issues 98%, repo research 94%. "Session ~30 min → ~3 hours."
- **Copilot:** works with **VS Code/JetBrains Copilot** surfaces via MCP, but routing compliance is **~60% without hooks vs 98% with**. Configure as an MCP server.

### toon-format/toon 🟡 (24.5K★) — https://github.com/toon-format/toon
**Token-Oriented Object Notation** — a compact, lossless JSON alternative (YAML indentation + CSV-style rows) for structured data.
- **Savings (📊, best-benchmarked):** **JSON 4,587 → TOON 2,759 tok (−40%)**; rigorous tests (209 Qs × 4 LLMs × 11 datasets). ~5.9% overhead vs plain CSV for flat data.
- **Copilot:** agent-agnostic format — only helps when you **feed Copilot structured/tabular data**; encode via `npx @toon-format/cli`. Not a general saver.

### Mining leads (worth a look, not fully vetted)
- **`lean-ctx`** (in *ComposioHQ/awesome-claude-skills*) — MCP runtime: session caching + AST-aware compression + 90+ shell patterns. 🟡 via MCP.
- **`airis-mcp-gateway`** (listed in *VoltAgent/awesome-claude-code-subagents*) — MCP multiplexer collapsing 60+ tools behind 7 meta-tools, **claims 97% context-token reduction** 🗣️. Copilot-compatible via MCP — the highest-leverage *idea* (MCP tool-schema bloat is real).
- **`Entroly`** (listed in *Meirtz/Awesome-Context-Engineering*) — claims **78% fewer tokens** + explicit Copilot support via MCP/HTTP proxy 🗣️. Unverified; investigate directly.

---

## Category E — Persistent memory (avoid re-explaining context)

### rohitg00/agentmemory 🔵 (21.9K★) — https://github.com/rohitg00/agentmemory
Cross-session memory (BM25 + vector + knowledge graph) that injects only relevant retrieved context instead of pasting full history.
- **Savings (📣):** ~**1,900 tokens/session** vs 19.5M/yr for pasting full context; **92% fewer** than LLM-summarized approaches; retrieval 95.2% R@5.
- **Copilot:** **Copilot CLI only** — `agentmemory connect copilot-cli` (MCP) or `copilot plugin install rohitg00/agentmemory:plugin`. The one genuinely Copilot-compatible memory tool found.

*(Skip for Copilot: `thedotmack/claude-mem` — "Copilot" is marketing, no integration; `NevaMind-AI/memU` — build-your-own SDK, no Copilot path.)*

---

## Category F — Workflow frameworks (cut rework = cut tokens)

Failed/iterative runs are a top token sink; these reduce them via spec-driven, phase-separated workflows.

### ⭐ github/spec-kit 🟢 (110K★) — https://github.com/github/spec-kit
GitHub's Spec-Driven Development toolkit — **Copilot is the default integration** (`/speckit.*` slash commands run inside Copilot). Phase separation (specify→plan→tasks→implement) means the agent references stable artifacts instead of re-deriving requirements, and up-front clarification cuts rework. No numbers, but native and sound. Install: `specify init my-project --integration copilot`.

### open-gsd/gsd-core 🟢 (formerly gsd-build/get-shit-done, 64K★) — https://github.com/gsd-build/get-shit-done
Meta-prompting / context-engineering framework that fights context rot by offloading research/planning to **fresh-context subagents** and persisting state in `STATE.md`/`CONTEXT.md`. Lists Copilot among supported runtimes. **Use the current `open-gsd/gsd-core` repo** (original archived). `npx @opengsd/gsd-core@latest`.

*(Concept-only for Copilot: `coleam00/context-engineering-intro` and `davidkimai/Context-Engineering` are Claude-Code-centric methodology — principles transfer, tooling doesn't.)*

---

## Category G — Verify your savings (measurement)

These **read Copilot CLI usage data** so you can prove a technique worked. (Both cover the **CLI, not the IDE extension**.)

- **ryoppippi/ccusage** 🔵 (15.8K★) — `npx ccusage daily`; analyzes local logs from 14+ agents incl. **Copilot CLI**. 📊
- **junhoyeo/tokscale** 🔵 (3.6K★) — `npx tokscale@latest`; explicitly parses Copilot's OTEL logs at **`~/.copilot/otel/*.jsonl`** (input/output/cache/reasoning). 📊

---

## ⚠️ Honest caveats (read before relying on any of this)

1. **CLI vs IDE extension.** Most tool integrations (headroom, agentmemory, ccusage, tokscale) work with the **Copilot CLI, not the IDE extension**. The skill/instruction files (Categories A–C) and spec-kit work in the IDE.
2. **Model-router skills won't work in Copilot.** Skills like `tokenwise` / `credit-optimizer-v5` (in *sickn33/antigravity-awesome-skills*, claiming 30–75%) save by **switching models** — but Copilot's model selection is harness-controlled, so routing won't function the same way. Their *summarization/memory* skills (e.g. `RecallMax`) are more portable.
3. **Numbers are mostly self-reported.** Best-benchmarked: **headroom**, **toon**, **context-mode**. Everything else is author/marketing claims. `caveman`'s 50–75% applies to **output tokens only**, not reasoning tokens.
4. **Progressive disclosure can underdeliver.** A Claude Code bug showed some skills loading their full body (~5.5K tokens) at startup instead of metadata-only — verify your own setup honors lazy loading.

---

## Not worth your time for Copilot token-saving (so you can skip them)

| Repo | Why skip |
|---|---|
| `code-yeongyu/oh-my-openagent` | OpenCode/Codex-only; "tokenmaxxer" branding has no token metrics |
| `can1357/oh-my-pi` | A rival standalone agent, not a Copilot add-on |
| `colbymchenry/codegraph` | Strong (47% fewer tokens) but **no Copilot support** (Claude/Cursor/Codex/etc.) |
| `thedotmack/claude-mem`, `NevaMind-AI/memU` | Not Copilot (marketing mention / build-your-own SDK) |
| `matt1398/claude-devtools` | Claude-Code-only inspector |
| `obra/superpowers`, `Leonxlnx/taste-skill`, `nextlevelbuilder/ui-ux-pro-max-skill` | Copilot-compatible but **not about tokens** (workflow/design quality) |
| `VoltAgent/awesome-openclaw-skills` | OpenClaw/ClawHub ecosystem-locked |

---

## Recommended starter stack for Copilot

**If you use the Copilot IDE extension:**
1. Install **`caveman-mode` + `context-engineering` instructions** and **`blueprint-mode` agent** from **github/awesome-copilot** (native, biggest easy win).
2. Add **`context-compression`/`filesystem-context`** skills from **muratcankoylan/Agent-Skills-for-Context-Engineering**.
3. Adopt **github/spec-kit** for non-trivial features (phase separation cuts rework).

**If you use the Copilot CLI:**
4. Wrap it with **headroom** (`headroom wrap copilot`) or **rtk** for tool-output compression — the largest measured cuts.
5. Add **rohitg00/agentmemory** to avoid re-explaining context across sessions.
6. Verify with **ccusage** / **tokscale** before and after.

---

## Appendix — search funnel detail

- **Input:** `output_2026-06-08.csv`, 117,814 repos (>500★).
- **Keyword candidates:** 4,406 (copilot, skill, claude-code, mcp, agent, token, prompt-engineering, context-engineering, subagent, etc.).
- **Categories surfaced:** "skill" in repo name (405), copilot-specific (190), token-flavored excl. crypto/auth (295), context/MCP/subagent tooling (66).
- **Repos investigated by agents:** 34 (6 themed batches).
- **Genuinely Copilot-usable token savers found:** ~13 (this document).

*Limitation: candidate selection used repo metadata only (the CSV has no file contents), so a skill in a repo with an unrelated name/description could be missed. The investigated set covers the highest-signal candidates by stars + keyword match.*
