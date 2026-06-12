# Security Assessment — coderamp-labs/gitingest
**Verdict: ✅ LOW RISK (CLI) / 🟡 privacy caveat (hosted service)**
Audited 2026-06-12 · Last upstream commit: 2025-08-16 (~10 months quiet) · 125 files · Python

## What it is
Turns a Git repo into a prompt-friendly text digest. Two very different usage modes: a local pip CLI, and the hosted **gitingest.com** site (swap `hub`→`ingest` in a GitHub URL).

## Findings

### 🟡 F1 — The hosted service processes your code on their servers
The repo contains the full server (`src/server/` — FastAPI, S3 utilities, hosting config). Using gitingest.com on a **private** repo (or pasting a token) means your code transits and may be stored on coderamp's infrastructure (S3-backed). For public repos this is moot; for anything private, use the CLI locally instead.

### 🟢 Clean areas (CLI path)
- The `gitingest` Python package itself makes no analytics calls; it shells out to `git clone` for the repo you specify and processes files locally.
- No install hooks; `pyproject`-based packaging.
- No `eval`/`exec`/pickle patterns in the ingestion code.

### 🟡 F2 — Maintenance is slowing
~10 months since last commit. The tool is simple enough that this is tolerable, but dependency patching lags.

### 🟡 F3 — Inherent output risk
Same as all context-packers: the digest is your codebase in one blob, with **no built-in secret scanning** (unlike repomix). `.gitignore`d files are excluded, but committed secrets/configs are not detected.

## What you expose yourself to
- CLI: essentially nothing beyond normal `git`/filesystem trust.
- Hosted site: your repository content on third-party infrastructure.

## Recommendation
Use the **CLI** for anything non-public. Treat gitingest.com as "uploading your code to a stranger's server", because that is mechanically what it is. Prefer repomix where secret-scanning matters.
