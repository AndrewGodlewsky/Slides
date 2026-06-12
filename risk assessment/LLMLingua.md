# Security Assessment — microsoft/LLMLingua
**Verdict: ⚠️ CAUTION — dangerous default model-loading config *and* an unsanitized `eval()` sink**
Audited 2026-06-12 · Reviewed by senior analyst 2026-06-12 (corrected a false "no eval" clean-area claim — see F2) · Last upstream commit: 2025-10-28 · 73 files, ~4.4 MB · Python · Microsoft Research

## What it is
Prompt-compression library: a small local language model scores and strips low-information tokens from prompts before they're sent to a large model.

## Findings

### 🔴 F1 — `trust_remote_code=True` by default (remote code execution surface)
`llmlingua/prompt_compressor.py:121-123`:
```python
trust_remote_code = model_config.get("trust_remote_code", True)
if "trust_remote_code" not in model_config:
    model_config["trust_remote_code"] = trust_remote_code
```
Unless you explicitly pass `trust_remote_code=False`, every model load via Hugging Face `transformers` is allowed to **download and execute arbitrary Python code from the model repository**. Line 1990 also hardcodes `trust_remote_code=True` for the `jinaai/jina-embeddings-v2-base-en` embedding model. If any model repo you load (or a typosquatted name, or a compromised account) ships a malicious `modeling_*.py`, that code runs with your user privileges the moment `PromptCompressor` initializes.

**Mitigation:** always construct with `model_config={"trust_remote_code": False}` and use the default `microsoft/llmlingua-2-*` models (standard architectures that don't need remote code). Pin model revisions with `revision=`.

### 🟠 F2 — Unsanitized `eval()` on the `context_budget` parameter (corrected finding)
**The original audit's clean-area claim "No `eval`/`exec`/pickle in the library code" was wrong.** `llmlingua/prompt_compressor.py:1201`:
```python
target_token = eval("target_token" + context_budget)
```
`context_budget` is a **public parameter of `compress_prompt()`** (declared at lines 232/292/444, default `"+100"`) that flows unsanitized through `control_context_budget()` into `eval()`. With the default it harmlessly computes `target_token+100`. But because `eval` evaluates an *arbitrary expression*, any value reaching this argument is executed as Python — e.g. `context_budget="or __import__('os').system('whoami')"` runs the command (`target_token` is truthy, so chain a `*0 or …` to force evaluation). No allow-list, no numeric cast, no `ast.literal_eval`.

**Reachability / severity:** This is **not** auto-triggered the way F1 is. It is only remote-code-execution if an application passes attacker-influenced data into `context_budget` — plausible if a product exposes a "compression budget/ratio" knob to end users or pulls it from a config/request, otherwise it stays a latent sink. Either way it is a genuine `eval`-injection vulnerability and a poor pattern for a Microsoft-published library.
**Mitigation:** never pass externally-derived values to `context_budget`; treat it as a hardcoded constant. Upstream fix: replace with arithmetic parsing (`int`/`ast.literal_eval`).

*(Note: the `.eval()` calls at lines 1907/1937/1992 are PyTorch `model.eval()` — benign and unrelated.)*

### 🟡 F3 — Model downloads at first use
First run downloads hundreds of MB from the Hugging Face Hub. This is normal for ML libraries but means runtime network access and trust in the HF CDN. No integrity pinning by default.

### 🟢 Clean areas
- No telemetry/analytics of any kind.
- No install-time hooks (`pyproject`-based packaging, no `setup.py` tricks).
- No pickle deserialization; no outbound endpoints other than Hugging Face model downloads.
- ~~No `eval`/`exec` in the library code~~ — **retracted; see F2.** One unsanitized `eval()` sink is present.
- Microsoft Research provenance; signed releases via PyPI.

### 🟡 F4 — Maintenance slowing
Last commit ~7.5 months ago (2025-10). Not abandoned, but slower response to dependency CVEs (it pulls `transformers`/`torch`, both of which have a steady CVE stream — keep them updated yourself).

## What you expose yourself to
- **You run downloaded model code by default** (F1) — the most realistic compromise path, and it's real.
- **An `eval()` injection sink** (F2) if your application ever feeds untrusted data into `context_budget`.
- Heavy transitive dependency tree (`torch`, `transformers`) — large but mainstream supply chain.
- Your prompts are processed **locally**; nothing is sent anywhere except model downloads. Good privacy posture.

## Recommendation
Use it, but: **always set `trust_remote_code=False`**, pin model revisions, keep `transformers`/`torch` patched, do not point it at arbitrary community models, and **never wire user-controlled input to `context_budget`** (keep it a constant). The eval sink is unlikely to be reachable in typical single-tenant use, but must be closed off in any multi-tenant or user-facing deployment.
