# Security Assessment — mem0ai/mem0
**Verdict: 🟡 LOW-MODERATE RISK (telemetry on by default; otherwise solid)**
Audited 2026-06-12 · Last upstream commit: 2026-06-11 (very active) · 1,663 files · Python + TS

## What it is
Memory layer for AI agents: extracts facts from conversations into a vector store and retrieves them instead of replaying history. Two modes: **OSS/local** (your own vector DB + LLM keys) and **hosted platform** (`MemoryClient` → mem0 cloud).

## Findings

### 🟠 F1 — PostHog telemetry enabled by default (OSS mode)
`mem0/memory/telemetry.py`: every Memory instance reports usage events to `https://us.i.posthog.com` with a hardcoded project key.
- **On by default**; disable with `MEM0_TELEMETRY=false`.
- Identity is a random UUID stored locally (`mem0/memory/setup.py`) — no PII, and captured properties are event metadata plus a host fingerprint (OS, OS version, processor, machine type, Python version — `telemetry.py:100-110`), **not memory content** (verified in `capture` call sites; the `api_key` handled near `main.py:385` configures a local vector-store client and is not transmitted).
- Sampled via `MEM0_TELEMETRY_SAMPLE_RATE`; hosted-client events are never sampled.
Not malicious, but default-on phone-home from a *memory* library is a legitimate enterprise-policy concern.

### 🟡 F2 — Hosted mode sends your memories to mem0's cloud
Using `MemoryClient` (platform mode) stores extracted conversation facts on mem0's infrastructure — by design, with an API key. Choose OSS mode for sensitive data.

### 🟡 F3 — Memory content itself is sensitive data at rest
In OSS mode, extracted facts land in your configured vector store unencrypted by default. The library's value (persistent recall of what you said) is also its risk: it concentrates conversation-derived data. Protect the store like you'd protect chat logs.

### 🟢 Clean areas
- No install hooks (`prepare` in mem0-ts is dev-only).
- No pickle/eval in the memory path.
- Network calls beyond telemetry go only to providers **you** configure (LLM, embedder, vector DB).
- Very active (commits daily), VC-backed company, large community — strong review pressure.

## What you expose yourself to
- Default telemetry until you set `MEM0_TELEMETRY=false`.
- A growing local (or cloud) database of distilled facts about your conversations.

## Recommendation
Fine to adopt in OSS mode with `MEM0_TELEMETRY=false` set before first import, a locally-controlled vector store, and normal at-rest protection. Use platform mode only if you accept mem0's cloud holding your memory data.
