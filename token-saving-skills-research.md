# Token-Saving Skills — Community Consensus (2026)

> Deep research compiling the skills, tools, and disciplines the AI/Claude Code
> community broadly agrees help reduce token usage (and therefore cost), with a
> quick explanation of *why* each one saves tokens.

## Key framing

- **"Skills" has two senses** the community uses interchangeably: literal
  **Claude Code Agent Skills** (drop-in `.md`/plugin files that load on demand)
  and **workflow disciplines** that act like skills. Both reduce tokens, at
  different layers.
- **The biggest lever is input tokens, not output.** Re-sent conversation
  history, file reads, and tool schemas dominate the bill. Output-compression
  skills (like caveman) are real but address the *cheapest* part.
- **Token cost grows super-linearly** with conversation length because the whole
  history re-sends every turn ("by message 30 you're paying ~31x message 1"), so
  anything that resets or compacts context pays compounding dividends.

---

## A. Named, installable skills the community widely recommends

### 1. `caveman` — output-compression skill
A drop-in skill that forces terse, filler-free responses. Reported ~65% average
output-token reduction (peaks ~87% on long debugging answers).
**Why it saves:** strips pleasantries, restatements, and step-by-step narration
from responses. **Caveat:** affects only *output* tokens, so real-world bill
savings land around 30–50%. Best as one layer in a stack, not a silver bullet.

### 2. `caveman-compress` — memory/context-file compression
Companion skill that rewrites `CLAUDE.md` and project notes into a denser form
(~46% smaller).
**Why it saves:** memory files reload into *every* session, so a one-time
compression saves input tokens permanently going forward.

### 3. `claude-code-router` / model-routing skills
Classifies each task by difficulty and routes easy work to cheaper models
(Haiku/Sonnet) while reserving Opus for hard reasoning.
**Why it saves:** lowers per-token *price*, not just count. Community tests
credit routing with the single largest jump (30–40% → 60–70%); model routing
broadly is cited as saving 40–70%.

### 4. Output-filtering tools — `rtk`, `repomix`, `mcporter`
Agent-side filters rather than chat skills:
- `rtk` — trims verbose tool/command output before it reaches the model.
- `repomix` — packs a repo into one filtered, AI-friendly file with token counts.
- `mcporter` — calls MCP tools via CLI to dodge the "MCP context tax."

**Why they save:** stop noise from ever entering context.

### 5. `ccusage` / usage-monitor skills
Measurement, not reduction — but the community treats baseline measurement as the
prerequisite skill. `/context` is the built-in equivalent for spotting "quiet
offenders."
**Why it saves:** you can't optimize what you don't measure.

---

## B. Workflow "skills" (disciplines) with the strongest consensus

### 6. Proactive `/compact` at task boundaries
Summarize-and-replace history after each discrete sub-task, *before* the window
bloats. **Why it saves:** cleaner summaries, fewer re-sent tokens.

### 7. `/clear` between unrelated tasks
Full reset avoids dragging finished work into new tasks. Pairs with the "cap
conversations at ~15–20 messages, then restart fresh" rule.
**Why it saves:** counters super-linear history growth.

### 8. Lean `CLAUDE.md` + `.claudeignore`
Stable instructions live once in a small memory file instead of being retyped;
ignore files keep junk directories out of exploration.
**Why it saves:** the memory file loads on every session and turn.

### 9. Precise scoping (exact files + line ranges)
"Refactor `login` in `auth.ts:40-80`" instead of "refactor auth."
**Why it saves:** prevents expensive autonomous exploration — a major hidden sink.

### 10. Subagent delegation for verbose work
Run file-heavy searches/analysis in an isolated context; only the summary returns
to main. **Why it saves:** verbose tool output never enters the main thread.
**Caveat:** subagents carry startup overhead — use only when saved clutter
outweighs it, not for trivial git/shell steps.

### 11. Prompt caching of stable prefixes
Split system prompt / tool defs / `CLAUDE.md` into a cached static prefix
(re-served at ~10% cost) and a dynamic suffix.
**Why it saves:** high impact for agent loops that re-send the same scaffold
every step.

### 12. Effort/thinking control (`/effort` low for routine work)
Lower reasoning effort and disable unused features (web search, connectors,
extended thinking) whose definitions load regardless of use.
**Why it saves:** avoids paying for deep reasoning and idle tool schemas on
cheap tasks.

### 13. Edit-instead-of-correct + batching
Editing an earlier message replaces history from that point rather than stacking
corrective turns; batching independent asks loads context once.
**Why it saves:** fewer redundant turns re-reading the whole history.

---

## C. Emerging / heavier-weight (worth knowing)

- **Anthropic Memory tool + compaction API** — server-side curated memory
  replaces tens of thousands of replayed-history tokens with a compact load per
  session.
- **Prompt compression (LLMLingua)** — compresses long retrieved/RAG chunks up
  to ~20x; mostly relevant for RAG pipelines.
- **`SkillReducer` (research)** — an arXiv approach to automatically optimizing
  agent *skills themselves* for token efficiency.

---

## D. Memory systems (memory palace, knowledge graphs, fact stores)

Memory skills attack a **different and usually bigger** cost driver than
compression. Compression shrinks *what the model says*; memory shrinks *what the
model has to re-read* — replayed conversation history and repeated file scans,
which are typically the largest, most expensive part of a project's token bill.

**The mechanism:** offload recall to an external index (vector DB or knowledge
graph). Instead of "remembering" by re-ingesting everything into the context
window, the system retrieves only the relevant slice. You pay to store tokens
*once*, not on *every* call. This is why memory pairs so well with cheaper
models — the hard part (recall) moves out of the model.

### Measured savings (community-reported)

| System / approach | Reported savings | What it replaces |
|---|---|---|
| **Mem0** (fact extraction → vector store) | ~90% fewer tokens, 91% lower latency | Stuffing whole conversation into context |
| **Memori** (persistent memory layer) | ~1,294 tokens/query (~5% of full context); 20×+ savings | Full-context replay |
| **MemCP** (MCP memory server) | 500 insights = 462 tokens vs 9,380 (20× less); 50K-token doc peeked for 231 tokens (218× less) | Re-reading docs/insights each session |
| **Codebase Memory MCP** (code knowledge graph) | 99.2% reduction (3,400 vs 412,000 tokens for 5 queries) | File-by-file `grep`/read exploration |
| **Structured distillation** (research) | 11× reduction with retrieval preserved | Verbatim memory storage |

### The four mechanisms by which memory saves tokens

1. **Persistence instead of replay** — store facts once, retrieve the relevant
   few, not the whole transcript on every call.
2. **Noise stripping** — 60–70% of raw agent logs are small talk, repetition,
   and transient reasoning; extracting durable facts removes that permanently.
3. **Surviving `/compact`** — a memory store keeps 100% of stored knowledge after
   a compaction, so context isn't re-derived after every reset.
4. **Codebase indexing over re-scanning** — a knowledge graph answers
   "where is X / what calls Y" via sub-ms queries instead of reading dozens of
   files (the single biggest win on coding projects, ~99%).

### The "memory palace" idea specifically

One *organizational* flavor: wings → halls → rooms stored in a vector DB
(e.g. ChromaDB). Its claimed advantage is **keep everything, let semantic search
find it**, rather than having an LLM decide what's "worth remembering" (which
itself costs tokens and can mis-judge). Related structured schemes split memory
into types and match retrieval to task type:

- **Semantic** — facts ("user prefers TypeScript strict mode").
- **Episodic** — what happened, when, under what conditions.
- **Procedural / skill** — reusable learned procedures (the "chunking" effect:
  load one unit instead of re-reasoning the steps).

### Tradeoffs (use deliberately, not blindly)

- **Extraction quality is a hidden cost** — a mis-summarized lesson makes the
  agent re-derive the right insight repeatedly, which can *cost* tokens.
- **Retrieval isn't free** — embedding/query has a small cost plus infra (a
  vector DB or MCP server to run).
- **Procedural memory is the weak spot** — tools handle facts/events well;
  "what this means next time" is largely unsolved. Memory ≠ planning.
- **Setup overhead** — for a short single-session task, setup may exceed savings.
  Memory shines on **long or multi-session projects** where context reloads often.

### Related project-completion levers this surfaced

- **`context-mode` / output sandboxing** — run a big operation, hand back only a
  summary (~98% off the raw output).
- **Enforcement hooks** — e.g. `bash-ban-raw-tools` (blocks `cat`/`grep`/`find`
  so the model uses the memory graph) and a "discovery gate" forbidding file
  reads until codebase memory is consulted. Hooks turn good habits into
  *guaranteed* behavior — often the gap between 50% and 90% savings.
- **API-proxy compression** (e.g. Headroom) — compresses payloads before they
  leave the machine (47–92%), catching everything regardless of skill.

**Bottom line for a project:** the highest-leverage memory move for *coding* work
is a **codebase knowledge-graph MCP** (replaces file re-scanning, ~99%); for
*cross-session continuity* it's a **fact-extraction memory layer**
(Mem0/Memori/MemCP-style, ~90% / 20×). Memory palace is a valid organizational
style of the latter. Layer these *under* the compression/routing stack above.

### Does a memory skill reduce or increase tokens? The break-even

It depends, and the deciding factor is **reuse**. Memory is not free — it's a
*trade*: you swap a **recurring cost** (re-sending history / re-reading files
every turn) for a **one-time cost + a small per-lookup cost**. Whether that wins
is arithmetic: how many times do you reuse the stored thing?

**What memory _adds_ (cost side):**

1. **Standing overhead** — the memory tool's schema/instructions sit in context
   every turn whether used or not (hundreds to low-thousands of tokens).
2. **Write cost** — extracting and storing a fact/file costs tokens once.
3. **Read cost** — each retrieval is a small query plus the returned snippet.

**What memory _removes_ (savings side):**

1. **Replayed history** — stop re-sending the whole transcript every turn.
2. **Repeated file scans** — query an index instead of re-reading files.
3. **Post-`/compact` re-derivation** — knowledge survives resets.

**The break-even:**

```
Total tokens with memory  =  standing overhead
                          +  (write cost × things stored)
                          +  (read cost  × lookups)

Total tokens without it   =  context re-sent × every turn it sticks around
```

Memory **reduces** tokens once the "removes" savings exceed the standing
overhead + write/read costs. That happens when:

- **The session is long** (history balloons super-linearly — "message 30 costs
  ~31× message 1").
- **You reuse the same context many times** (same files/facts across many turns
  or sessions).
- **You'd otherwise re-scan a big codebase** (the lopsided ~99% win).

Memory **increases** tokens when:

- **The session is short** — you pay setup/standing tax but never earn it back.
- **The work is one-pass** — read a file once, edit, done. Nothing to recall.
- **Retrieval is noisy** — pulls back too much or the wrong thing, so you pay for
  junk and may re-derive the right answer.

**Concrete picture** — a 50K-token spec you'd otherwise re-read on 10 turns:

- *Without memory:* ~50K × 10 = ~500K tokens of re-reading.
- *With memory:* ~50K once + (~250 tokens × 10 lookups) + overhead ≈ ~53K.

That ~10× saving only materializes *because* the spec was reused 10 times. Read
it once and memory would have *cost* extra for nothing.

**Rule of thumb:**

- *Single short task, few files, one session* → memory likely **increases**
  tokens slightly. Skip it; scope tightly and use `/clear`.
- *Long or multi-session project, same context revisited* → memory **reduces**
  tokens, often dramatically. Turn it on.
- *Clearest win regardless* → a **codebase knowledge-graph** for any project
  where the model would otherwise re-explore files repeatedly.

Think of memory like a **cache**: overhead if you read something once, a big win
the moment you read it repeatedly. Memory is a cache for context.

---

## The consensus "stack" (priority order)

1. **Measure first** — `ccusage` / `/context`.
2. **Keep context lean** — small `CLAUDE.md`, `/clear`, `/compact`, tight scope.
3. **Route models by difficulty.**
4. **Cache stable prefixes.**
5. **Delegate verbose work to subagents.**
6. **Then** add output compression (caveman) as the final, smallest layer.

Reported cumulative savings: ~30–40% from compression alone, 60–70% adding
routing, 85–92% with the full stack — though those are optimistic ceilings.

---

## Sources

- [7 Practical Ways to Reduce Claude Code Token Usage — KDnuggets](https://www.kdnuggets.com/7-practical-ways-to-reduce-claude-code-token-usage)
- [Token Optimisation 101 — DEV Community](https://dev.to/stevengonsalvez/token-optimisation-101-stop-burning-money-on-ai-coding-agents-4mce)
- [Best practices for Claude Code — Claude Code Docs](https://code.claude.com/docs/en/best-practices)
- [How to Reduce Claude Code Token Usage — Skills That Cut Costs — Agensi](https://www.agensi.io/learn/how-to-reduce-claude-code-token-usage)
- [Claude Code Token: 10 GitHub Repos That Cut Up to 90%](https://pasqualepillitteri.it/en/news/1181/claude-code-token-10-github-repos-savings)
- [caveman skill — GitHub (JuliusBrussee)](https://github.com/juliusbrussee/caveman)
- [Caveman Review — andrew.ooo](https://andrew.ooo/posts/caveman-claude-code-skill-token-savings-review/)
- [LLM Token Optimization Strategies — Token Optimize](https://www.tokenoptimize.dev/guides/llm-token-optimization-strategies)
- [Context Engineering: Reducing Token Usage — Token Optimize](https://www.tokenoptimize.dev/guides/context-engineering-reduce-token-usage)
- [LLM Cost Optimization: 5 Levers — Morph](https://www.morphllm.com/llm-cost-optimization)
- [18 Claude Code Token Management Hacks — MindStudio](https://www.mindstudio.ai/blog/claude-code-token-management-hacks)
- [SkillReducer: Optimizing LLM Agent Skills for Token Efficiency — arXiv](https://arxiv.org/pdf/2603.29919)

### Memory systems (Section D)

- [The Memory Problem in AI Agents Is Half Solved — Data Unlocked](https://medium.com/data-unlocked/the-memory-problem-in-ai-agents-is-half-solved-heres-the-other-half-ebbf218ae4d5)
- [How I Cut Claude Code Token Usage by 90%+ With 5 Tools, Hooks, and Enforcement — Abid Abdul Gafoor](https://medium.com/@abdulgafoorabid/how-i-cut-claude-code-token-usage-by-90-with-4-tools-custom-hooks-and-enforcement-d3f8d2488cd6)
- [Memori: A Persistent Memory Layer for Efficient, Context-Aware LLM Agents — arXiv](https://arxiv.org/pdf/2603.19935)
- [Structured Distillation for Personalized Agent Memory: 11x Token Reduction — arXiv](https://arxiv.org/pdf/2603.13017)
- [The AI Memory Layer Guide — Mem0](https://mem0.ai/blog/ai-memory-layer-guide)
- [Breaking the Context Barrier: How MemPalace Achieved Near-Perfect LLM Recall — ML Hive](https://mlhive.com/2026/04/mempalace-llm-memory-architecture-longmemeval)
- [Codebase Memory MCP — GitHub (DeusData)](https://github.com/DeusData/codebase-memory-mcp)
- [MCP Knowledge Graph memory server — GitHub (shaneholloman)](https://github.com/shaneholloman/mcp-knowledge-graph)
- [Stop Wasting Tokens: Use Workflow Memory — Coding Nexus](https://medium.com/coding-nexus/stop-wasting-tokens-use-workflow-memory-to-make-your-llm-actually-smart-28d327fd076a)
- [Agent Memory: How to Build Agents That Learn and Remember — Letta](https://www.letta.com/blog/agent-memory/)
