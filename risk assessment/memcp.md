# Security Assessment — maydali28/memcp
**Verdict: 🟡 LOW-MODERATE RISK (genuinely local; minor deserialization weakness; single-maintainer trust)**
Audited 2026-06-12 · Last upstream commit: 2026-02-19 (~4 months quiet) · 118 files · Python

## What it is
An MCP memory server for Claude Code: SQLite + filesystem hybrid store, local embeddings, knowledge-graph features. Includes optional Claude hooks (auto-save reminder, pre-compact save).

## Findings

### 🟢 F1 — Fully local by design (verified, not just claimed)
The net/exec scan across `src/memcp/` found **zero** `requests`/`httpx`/`urllib`/`socket`/`subprocess`/`eval`/`exec` calls. Embeddings run via `model2vec` or `fastembed` — local models (safetensors-based, no `trust_remote_code`), downloaded once from Hugging Face. No telemetry, no cloud, no API keys. This is the genuinely local memory option among the audited memory tools.

### 🟡 F2 — `np.load(..., allow_pickle=True)` on its own vector store
`src/memcp/core/vecstore.py:47,185` loads its `.npy` store files with pickle enabled. NumPy pickle loading executes arbitrary code if the file is malicious. The files are memcp's own local artifacts, so exploitation requires an attacker who can already write to your memcp data directory — **low practical severity**, but it converts "tampered data file" into "code execution", and is exactly the pattern object-array storage doesn't strictly need.

### 🟡 F3 — Hooks are benign but always-on
`hooks/*.py` (reviewed in full): they read/write a local counter file and print reminders — no subprocess, no network. The suggested `settings.json` wires them to `PreCompact`/`PostToolUse` events. Standard hook caveat: future updates change code that runs automatically.

### 🟡 F4 — Single maintainer, low visibility
One author, modest star count, no organization behind it, last commit ~4 months ago. The engineering hygiene is unusually good for a solo project (ADRs, SECURITY.md, real test suite, CI), but you are trusting one GitHub account for updates.

### 🟢 Other clean areas
- `scripts/install.sh` installs from local source via pip/uv — **no curl-pipe downloads** (verified).
- Docker option available for isolation.
- Stored memory content is local SQLite/files — protect the data dir like chat logs.

## What you expose yourself to
- Local memory DB accumulating distilled conversation/project facts on disk.
- Pickle-on-load if something else on your machine can tamper with its store.
- Solo-maintainer update trust.

## Recommendation
Reasonable choice if you want local-first memory. Pin to a reviewed commit, keep its data directory permissioned to your user, and re-review on update. (Ideal upstream fix: `allow_pickle=False` with structured arrays.)
