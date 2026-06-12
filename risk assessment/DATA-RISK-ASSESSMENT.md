# Data Risk Assessment — Cloned Open-Source Repositories

**Scope:** 17 repositories under `clones/`
**Assessment date:** 2026-06-12
**Method:** Source-level review of each clone (not vendor documentation). Searched for telemetry/analytics SDKs (PostHog, Segment, Sentry, Mixpanel, Amplitude), hardcoded network endpoints, outbound HTTP calls in library/CLI code paths, and hosted-SaaS integration points. Findings below cite the actual files inspected.
**Question answered:** *If our people use these repos, can our data end up somewhere it shouldn't, and does that compromise us from a data perspective?*

---

## Executive Summary

**No repository contains malicious exfiltration.** However, the repos fall into three distinct data-flow categories that require different organizational controls:

1. **Default-on telemetry (action required):** `mem0` ships PostHog telemetry that is **enabled by default** and sends usage events plus machine fingerprinting data to `us.i.posthog.com`. In hosted-client mode it uses the **user's email address** as the tracking identifier. This is the only repo in the set that transmits data outward without explicit configuration.

2. **Opt-in SaaS backends (policy required):** `mem0` (Platform mode), `memori` (cloud mode), `baml` (Boundary Studio tracing), and the hosted web versions of `gitingest`/`repomix` will send **actual content** — memories, prompts/responses, or entire repositories — to vendor servers, but only when an API key is configured or the hosted website is used instead of the CLI.

3. **By-design LLM egress (provider governance, not library risk):** `instructor`, `guidance`, `outlines`, `GPTCache`, `LLMLingua`, `markitdown`, `code2prompt`, `files-to-prompt`, and others either run fully locally or send data only to the LLM provider the developer configures. The risk surface is *which provider endpoint your developers point them at*, not the libraries themselves.

**Bottom line:** Using these repos will not compromise the company **provided** the mitigations in the final section are adopted — chiefly: set `MEM0_TELEMETRY=False` org-wide, prohibit use of the hosted web versions (gitingest.com, repomix.com) and vendor SaaS memory platforms for company code/data, and treat cloned-repo agent instruction files (`CLAUDE.md`, `.agents/`, skills) as untrusted input.

---

## Risk Ratings by Repository

| Repository | Telemetry (default) | Content leaves org? | Risk | Notes |
|---|---|---|---|---|
| **mem0** | **YES — PostHog, on by default** | Only in Platform mode (`api.mem0.ai`) | **HIGH** | See detailed finding #1 |
| **memori** | None found in OSS path | Only with API key (`api.memorilabs.ai`) | **MEDIUM** | See detailed finding #2 |
| **baml** | VS Code ext: PostHog (hardcoded key) | Only with `BOUNDARY_SECRET` (full prompt logs to `app.boundaryml.com`) | **MEDIUM** | See detailed finding #3 |
| **gitingest** | None in Python package/CLI | Only if hosted gitingest.com is used | **MEDIUM** (web) / LOW (CLI) | See detailed finding #4 |
| **repomix** | None in CLI | Only if repomix.com website is used | **LOW** (CLI verified offline) | See detailed finding #5 |
| **codebase-memory-mcp** | Update check → GitHub API | No | **LOW** | Metadata-only egress; see finding #6 |
| **caveman** | None (claim verified in source) | No | **LOW** | Installer fetches from npm/GitHub registries only |
| **GPTCache** | None | LLM provider only (user-configured) | **LOW** | Local cache; clean scan |
| **guidance** | None | LLM provider only (user-configured) | **LOW** | "amplitude" grep hit was an audio-widget false positive |
| **instructor** | None | LLM provider only (user-configured) | **LOW** | Pure client wrapper; clean scan |
| **outlines** | None | LLM provider only (user-configured) | **LOW** | Clean scan |
| **LLMLingua** | None | No — compression runs on local models | **LOW** | Clean scan |
| **markitdown** | None | Only opt-in Azure converter w/ user-supplied endpoint | **LOW** | See finding #7 |
| **code2prompt** | None | No | **LOW** | Local Rust CLI; clean scan |
| **files-to-prompt** | None | No | **LOW** | Local Python CLI; clean scan |
| **memcp** | None | No | **LOW** | Only doc URLs found; fully local |
| **github-copilot-token-optimization** | None | No | **LOW** | Documentation-only repo; no executable analytics |

---

## Detailed Findings

### 1. mem0 — Default-on PostHog telemetry with identity merging (HIGH)

**Evidence:** `clones/mem0/mem0/memory/telemetry.py`

- Telemetry is **enabled unless** `MEM0_TELEMETRY=False` is set (line 14: `os.environ.get("MEM0_TELEMETRY", "True")`).
- Hardcoded PostHog project key, host `https://us.i.posthog.com` (lines 15–16).
- Every event includes a **machine fingerprint**: Python version, OS, OS version/release, processor, machine architecture (lines 100–110).
- OSS events report which vector store, LLM, and embedding model classes you use, collection names, and vector dimensions (lines 200–208) — this reveals internal architecture choices, though not content.
- **Hosted-client telemetry uses `user_email` as the PostHog `distinct_id`** (line 93, line 233), and `capture_identify` explicitly merges the anonymous ID into the email identity (lines 116–131). Employee email addresses of anyone using the mem0 Platform client would be transmitted to PostHog.
- Hot-path events are sampled at 10%, but lifecycle events (`mem0.init`, etc.) **always fire**.

**Separately**, mem0's Platform mode (`MemoryClient`) stores memory *content* — which in practice means extracts of conversations, potentially including company data — on `api.mem0.ai` (vendor SaaS). The repo even ships an OSS→Platform migration script (`scripts/oss-to-platform-migrate.sh`), so drift from local to SaaS storage is one config change away.

**No prompt/memory content is sent via telemetry** — the exposure is metadata, identity, and architecture fingerprinting. The content exposure comes only from choosing Platform mode.

### 2. memori — Clean OSS path, but cloud mode is one API key away (MEDIUM)

**Evidence:** `clones/memori/memori/memory/_collector.py`, `clones/memori/memori/_config.py`

- The `Api` class targets `https://api.memorilabs.ai` (overridable via `MEMORI_API_URL_BASE`), authenticated with a Bearer API key.
- `api_key` defaults to `None` — **no traffic to the vendor occurs in pure OSS/local mode**. No PostHog/analytics SDK found in the library path.
- When an API key is supplied, memory content (derived from agent conversations) is stored on Memori Labs' cloud. Their docs in the clone also promote third-party LLM backends (xAI/Grok, DeepSeek, Nebius) — pointing company data at providers that may not be on our approved list.

### 3. baml — Opt-in full prompt logging to vendor; VS Code extension telemetry (MEDIUM)

**Evidence:** `clones/baml/engine/baml-runtime/src/tracing/api_wrapper/env_setup.rs`, `clones/baml/typescript/apps/vscode-ext/src/telemetryReporter.ts`

- The runtime's tracing publisher defaults to `https://app.boundaryml.com/api`, but `secret` and `project_id` are `Option` types with no default — **tracing to Boundary Studio only activates when `BOUNDARY_SECRET`/`BOUNDARY_PROJECT_ID` are set**. When it is active, it ships **full LLM prompt/response logs** (chunked up to 64 KB; log redaction is `false` by default — line 16–17). It also captures the **machine hostname** by default.
- The VS Code extension contains a **hardcoded PostHog API key** (`telemetryReporter.ts` line 8) — usage telemetry from the IDE plugin, distinct from the runtime.
- No `DO_NOT_TRACK`-style global kill switch was found in the repo.

### 4. gitingest — Package is clean; the hosted website is the risk (MEDIUM if web used)

**Evidence:** `clones/gitingest/src/gitingest/` (clean scan), `clones/gitingest/src/static/js/posthog.js`, `src/server/templates/base.jinja`

- The pip-installable `gitingest` package/CLI makes no telemetry calls.
- The repo also contains the **gitingest.com web application**, which loads PostHog browser analytics. More importantly, anyone who pastes a **private repo URL or token into gitingest.com** is uploading company source code to a third-party server. The convenient "change github.com → gitingest.com in the URL" habit the tool encourages is exactly how private code leaks by accident.

### 5. repomix — CLI verified offline; website uploads to vendor servers (LOW for CLI)

**Evidence:** `clones/repomix/src/` network scan, `clones/repomix/website/client/src/en/guide/privacy.md`

- The CLI's only network code paths are the explicit `--remote` repo-download feature (GitHub archive API) and a manually triggered update check. No telemetry SDK in `src/`. Their privacy policy's claim that the CLI "does not collect, transmit, or store any user data" is **consistent with the source**.
- repomix.com (website) uses Google Analytics and Cloudflare Turnstile, and ZIP/folder uploads are "temporarily stored on our servers." Same policy implication as gitingest: **web version = company code on third-party infrastructure**, with deletion promises we cannot verify.

### 6. codebase-memory-mcp — Update check and release downloads only (LOW)

**Evidence:** `clones/codebase-memory-mcp/src/mcp/mcp.c` (line 4363), `src/cli/cli.c` (lines 2731–3874)

- Calls `api.github.com/.../releases/latest` (update check — leaks only your IP and tool usage to GitHub) and uses `curl` to download its own release binaries. No code or memory content is transmitted. The project ships its own security tooling (`scripts/security-strings.sh`, egress allowlist), which is a positive signal. Note: indexed codebase data is stored locally — see "data at rest" below.

### 7. markitdown — Local converter; Azure path is explicit opt-in (LOW)

**Evidence:** `clones/markitdown/packages/markitdown/src/markitdown/converters/_cu_converter.py`

- Core conversion is local. The Content Understanding converter sends documents to an **Azure endpoint the user must supply themselves** — within our own Azure tenant this is acceptable; the control is making sure developers use a company-owned endpoint.

---

## Cross-Cutting Risks (apply regardless of repo)

1. **By-design LLM egress.** `instructor`, `guidance`, `outlines`, `GPTCache`, `mem0`, `memori`, and `baml` all forward prompts — which will contain whatever company data developers put in them — to the configured LLM provider. Several clones actively document non-mainstream providers (xAI, DeepSeek, Nebius, Sarvam, MiniMax, Baidu vector stores). **The governance question is the provider allowlist, not the library.**

2. **Memory/cache tools create data-at-rest sprawl.** mem0, memori, memcp, codebase-memory-mcp, and GPTCache persist conversation extracts, embeddings, and code indexes into local SQLite/vector stores. That's company data accumulating outside sanctioned data stores — unencrypted, unmanaged retention, and invisible to DLP. Cached LLM responses (GPTCache) can also leak across users if a shared cache backend is misconfigured.

3. **Cloned repos carry live agent instructions.** Several clones include `CLAUDE.md`, `.agents/`, skills, and plugin manifests (mem0, repomix, caveman, github-copilot-token-optimization). Agentic tools (Claude Code, Copilot agents) **auto-load these files** when working inside the clone — this was directly observed during this assessment. That is a prompt-injection / instruction-supply-chain surface: a malicious upstream commit to one of these files would execute as trusted instructions in our developers' agents.

4. **Dependency supply chain.** These are 17 active upstream projects with large lockfiles. Cloning is read-only and safe; `npm install` / `pip install` inside them executes upstream build scripts. Standard controls apply: install only in sandboxes/containers, pin versions, and run dependency scanning before any of these enter a build pipeline.

---

## Recommendations

**Immediate (before anyone uses these tools with company data):**

1. Set `MEM0_TELEMETRY=False` as a standard environment variable in developer images, CI, and onboarding docs. This is the single default-on transmitter in the set.
2. Prohibit pasting company repos into **gitingest.com** and **repomix.com** — mandate the local CLIs (`pip install gitingest`, `npx repomix`), which were verified clean.
3. Do not provision API keys for **mem0 Platform**, **Memori cloud**, or **Boundary Studio** for any workload touching company data until each vendor passes a standard third-party data-processing review (DPA, retention, residency).

**Policy / standing controls:**

4. Maintain an **LLM provider allowlist** and enforce it via egress firewall: these libraries will happily send prompts to any endpoint configured. Recommended egress posture for dev environments running these tools: allow your approved LLM providers + package registries; alert on `*.posthog.com`, `api.mem0.ai`, `api.memorilabs.ai`, `app.boundaryml.com`.
5. If the BAML VS Code extension is adopted, note its hardcoded PostHog telemetry and confirm it honors the IDE-level telemetry-off setting; otherwise block at the network layer.
6. Treat memory stores created by mem0/memori/memcp/codebase-memory-mcp as **company data stores**: define where they may live, encrypt at rest where feasible, and include them in retention/offboarding procedures.
7. When developers open these clones in agentic coding tools, do so with the repo treated as **untrusted**: review `CLAUDE.md`/agent files after every upstream pull, or strip them in our internal forks.
8. Prefer internal forks/mirrors with pinned commits over tracking upstream `main` for anything that enters a build.

**Verdict:** With mitigations 1–3 in place, none of these repositories poses a material data-compromise risk to the organization. Without them, the realistic exposure is (a) usage/identity metadata leaking to PostHog via mem0 by default, and (b) accidental upload of proprietary source code or conversation content to vendor SaaS via the hosted convenience paths.

---

*Assessed by source inspection of the clones as of the assessment date. Upstream code changes after this date are not covered; re-run this assessment after significant version bumps.*
