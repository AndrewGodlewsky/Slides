# Security Assessment — dottxt-ai/outlines
**Verdict: ✅ LOW RISK (one local-cache deserialization note added on review)**
Audited 2026-06-12 · Reviewed by senior analyst 2026-06-12 (added F1 on review) · Last upstream commit: 2026-05-18 (active) · 293 files · Python

## What it is
Structured/constrained text generation: compiles JSON schemas and grammars into token-level constraints applied during local model inference (or via provider APIs).

## Findings

### 🟡 F1 — `cloudpickle` deserialization in the local disk cache (added on review)
`outlines/caching.py:17-39` defines a `diskcache`-backed cache whose `get`/`fetch` methods call `cloudpickle.loads(data)` on stored entries (cache dir defaults to `~/.cache/outlines`, overridable via `OUTLINES_CACHE_DIR`). This turns "attacker can write to your cache directory" into "code execution on next cache read." **Low practical severity** — the cache is outlines' own local artifact under your home dir, so exploitation requires an attacker who can already write files as you — but it's the same deserialization pattern flagged elsewhere in this audit, so it's recorded here for consistency. The original report's "no pickle in the *generation path*" is technically correct (this is the caching path), but the unqualified clean-area phrasing understated it.

### 🟢 Clean areas
- **No telemetry/analytics** in library code.
- **No install hooks**; `pyproject`-based packaging.
- No `eval`/`exec` on untrusted data; the only deserialization is the local cache in F1.
- `trust_remote_code` is **not** defaulted on anywhere in `outlines/` (unlike LLMLingua) — model loading honors what you pass.
- Active maintenance, backed by a company (.txt / dottxt), healthy contributor base.

### 🟡 Notes
- Loading local models pulls `transformers`/`vllm`-class dependencies — large mainstream supply chain; keep patched.
- Grammar/regex compilation of *attacker-supplied schemas* could in theory be a DoS vector (pathological grammars), but for your own schemas this is irrelevant.

## What you expose yourself to
Local inference stays local; API backends send prompts to your chosen provider only. No new trust relationships.

## Recommendation
Safe to adopt. Pin versions; don't compile schemas/grammars from untrusted third parties.
