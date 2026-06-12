# Security Assessment — 567-labs/instructor
**Verdict: ✅ LOW RISK**
Audited 2026-06-12 · Last upstream commit: 2026-06-05 (active) · 941 files · Python (+TS/Go/Rust ports)

## What it is
A thin wrapper around LLM provider SDKs (OpenAI, Anthropic, etc.) that validates model output against Pydantic schemas and retries until the output parses. Pure client-side library.

## Findings

### 🟢 Clean areas
- **No telemetry or analytics** in the library code (grep for PostHog/Segment/Amplitude/Sentry across `*.py`: zero hits outside docs).
- **No install hooks** — modern `pyproject.toml` packaging, no `setup.py` custom commands.
- **No `eval`/`exec`/pickle** in the request/response path; structured parsing is Pydantic-based (schema-constrained construction — exactly the safe pattern).
- Network traffic goes **only to the LLM provider you configure** with your own API key. Instructor adds no endpoints of its own.
- Very active maintenance (commits within the last week), large contributor base, 13k+ stars — strong review pressure.

### 🟡 Notes (not vulnerabilities)
- Your prompts/data go to whatever LLM provider you wire it to — that's your existing exposure, unchanged by instructor.
- Moderately large optional dependency surface (provider SDKs); install only the extras you need (`instructor[anthropic]` etc.).

## What you expose yourself to
Essentially the same risk as using the underlying provider SDK directly. No new trust relationships introduced.

## Recommendation
Safe to adopt. Standard hygiene: pin the version, install minimal extras.
