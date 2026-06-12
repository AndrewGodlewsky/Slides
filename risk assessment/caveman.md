# Security Assessment — juliusbrussee/caveman
**Verdict: 🟠 MODERATE RISK (clean today, but high-trust install model from a single maintainer)**
Audited 2026-06-12 · Last upstream commit: 2026-05-20 · 145 files · JS hooks + Markdown skills + Python scripts

> ⚠️ **Directly relevant to you:** a caveman-derived plugin ("huhhb") is already installed in your Claude Code environment — the skills visible in this session (caveman, caveman-compress, cavecrew, …) come from this codebase or a fork of it.

## What it is
A Claude Code / Copilot / Codex / Gemini plugin that forces terse "caveman" output to cut tokens. It is not just prompts: it installs **hooks** (JS that runs on every prompt/tool event), a **statusline script**, slash commands, optional **MCP middleware** (caveman-shrink), and Python compression scripts.

## Findings — executable code (all call sites traced)

### 🟢 F1 — Hook/MCP/script exec calls are benign in substance
- `src/hooks/caveman-mode-tracker.js` — `execFileSync(process.execPath, …)` only re-invokes **its own** `caveman-stats.js` with a 5s timeout. Writes a mode flag to `~/.claude/.caveman-active`.
- `src/mcp-servers/caveman-shrink/index.js` — `spawn(args[0], …)` launches **the upstream MCP command you put in your own config**, then compresses `description` fields in transit. No network of its own. (Note: as MCP middleware it sees *all* traffic of the wrapped server.)
- `skills/caveman-compress/scripts/compress.py` — `subprocess.run(["claude", "--print"])` or the Anthropic SDK; sends your CLAUDE.md content to the LLM you already use. No third-party endpoints.
- **No telemetry anywhere.** No analytics, no phone-home. Verified by endpoint grep.

### 🟠 F2 — Install model: curl|bash / `irm|iex` from **unpinned `main`**
`install.sh` / `install.ps1` / `caveman-init.js` are documented to be piped from `raw.githubusercontent.com/JuliusBrussee/caveman/main/...`. The installer (`bin/install.js`, ~1,100 lines) also downloads further files from the same `RAW_BASE` at run time and falls back to spawning `curl`. There is **no version pinning and no integrity check**: whatever is on `main` at the moment you run it executes on your machine. A compromised maintainer account = compromised installs, instantly. The installer also edits your `~/.claude/settings.json` to register hooks.

### 🟠 F3 — Hooks are an always-on execution and behavior layer
Once installed, the mode-tracker hook runs on **every user prompt** and the statusline script on every render. They're benign today (F1), but any future update you pull changes code that executes continuously inside your dev environment. Same applies to the SKILL.md files — they are standing instructions to your agent and can be changed upstream.

### 🟡 F4 — Behavioral/quality risk of the skill itself
Terse-mode instructions ("strip explanations, narration") trade away the model's explanatory output. On security-sensitive work, suppressed caveats and skipped explanation can hide problems. The compress skill **rewrites your CLAUDE.md/notes**; it keeps `.original.md` backups (verified in repo tests), but an LLM rewrite of your standing instructions can subtly alter meaning — diff after every compression.

### 🟡 F5 — Single-maintainer project
One primary author (JuliusBrussee), ~3 weeks since last commit. No organization, no co-maintainer review on what lands in `main` — which is exactly what the F2 install model executes.

## What you expose yourself to
1. Future-update supply chain: unpinned main-branch code with hook-level (always-running) placement.
2. MCP middleware position (if you use caveman-shrink): it intercepts the full message stream of wrapped servers.
3. Meaning drift in compressed memory files; degraded explanatory output.

## Recommendation
Usable, but: **install from a cloned, reviewed, pinned commit — never the curl|bash one-liner**; re-review hook JS and SKILL.md after every update; diff CLAUDE.md after each compress; skip caveman-shrink unless you need it. Since a fork of this is already live in your environment, the same review/pinning discipline applies to it.
