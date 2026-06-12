# Security Assessment — guidance-ai/guidance
**Verdict: ✅ LOW RISK**
Audited 2026-06-12 · Last upstream commit: 2026-05-21 (active) · 323 files · Python + C++ extension

## What it is
Constrained-generation programming framework (originally Microsoft) — interleaves program logic with model generation and enforces grammars at the token level via a compiled parser (llguidance).

## Findings

### 🟢 Clean areas
- **No telemetry/analytics** in library source.
- **No install hooks** beyond standard build of its native extension via mainstream packaging (wheels published to PyPI).
- `trust_remote_code` appears only in `guidance/models/_transformers.py:45` as a **passthrough of a user-supplied kwarg** — it is *not* enabled by default. Correct, safe handling.
- No pickle/`eval` on untrusted data in the generation path.
- Active maintenance and a well-known org (guidance-ai, ex-Microsoft team).

### 🟡 Notes
- Ships a **compiled native parser** — you're trusting prebuilt wheels; standard for the ecosystem (same trust as numpy).
- Local models mean the usual `torch`/`transformers` dependency mass.

## What you expose yourself to
Same baseline as any local-inference library. No data leaves your machine except calls to providers you explicitly configure.

## Recommendation
Safe to adopt. Prefer official PyPI wheels; pin versions.
