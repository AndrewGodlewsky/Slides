# Security Assessment — zilliztech/GPTCache
**Verdict: ⚠️ CAUTION — pickle persistence + runtime auto-`pip install` + fading maintenance**
Audited 2026-06-12 · Reviewed by senior analyst 2026-06-12 (verified F1/F3; added F4 runtime installer) · Last upstream commit: 2025-07-11 (**~11 months dormant**) · 305 files · Python

## What it is
Semantic cache for LLM calls: embeds requests, stores responses, and serves similar future requests from cache (Zilliz, the Milvus company).

## Findings

### 🔴 F1 — Pickle-based cache persistence (code execution via cache files) — *confirmed*
`gptcache/manager/data_manager.py:118` does `self.data = pickle.load(f)` (paired dump at `:175`). Unpickling executes arbitrary code embedded in the file. Threat model:
- If a cache file is shared between users/machines, restored from an untrusted backup, or writable by a lower-privileged process/container neighbor, **loading the cache = running attacker code**.
- Safe only when the cache directory is private, local, and trusted end-to-end.

### 🟠 F2 — Effectively unmaintained
No commits in ~11 months; issue backlog growing. Dependency CVEs (it integrates many vector stores, ONNX, transformers) will not be patched promptly. For a security-sensitive component sitting on the request path of your LLM traffic, this is a meaningful operational risk.

### 🟡 F3 — Example adapters use `trust_remote_code=True` — *confirmed*
`gptcache/adapter/dolly.py:25,39` hardcodes `trust_remote_code=True` for the Dolly model (also in `examples/integrate/dolly/basic_usage.py:21,45`). Only triggers if you use those specific adapters, but it's the same RCE-by-model-repo pattern flagged for LLMLingua.

### 🟠 F4 — Runtime auto-`pip install` via `subprocess(..., shell=True)` (new finding)
`gptcache/utils/dependency_control.py:16` runs `subprocess.check_call(f"pip install -q {package}", shell=True)`. It's invoked by `_check_library()` (`utils/__init__.py:59`) whenever an optional backend module is imported but missing — so **merely importing certain GPTCache submodules can silently install packages from PyPI at runtime** (running those packages' arbitrary install/setup code). The `package` strings are hardcoded library names (`pymilvus`, `protobuf==3.20.0`, …), **not** user input, so this is not a command-injection vector — but:
- The "fully local unless you configure a remote vector DB" framing is incomplete: first use of a backend can reach out to PyPI and execute install scripts without an explicit, separate `pip install` step.
- `shell=True` with an f-string is a latent footgun (harmless today because the inputs are constants; would become injection if any caller ever passed a dynamic package name).

### 🟢 Clean areas
- No telemetry/analytics; local **except** the runtime PyPI fetch in F4 and any remote vector DB you configure.
- No install-time (packaging) hooks — but note the *runtime* installer in F4.
- Reputable original publisher (Zilliz).

## What you expose yourself to
- Cached **prompts and responses persist unencrypted on disk** — the cache becomes a copy of your conversation data; protect/clean it accordingly.
- Pickle deserialization on the load path (F1).
- A frozen dependency tree from mid-2025.

## Recommendation
Acceptable for local experiments with a private cache directory. **Not recommended for production or shared environments** until/unless maintenance resumes; prefer provider-native prompt caching (which the HTML's own Copilot notes already point to).
