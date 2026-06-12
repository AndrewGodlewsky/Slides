# Security Assessment — GibsonAI/memori
**Verdict: 🟠 MODERATE RISK (privacy) — it is a cloud service client, not a local memory layer**
Audited 2026-06-12 · Last upstream commit: 2026-06-10 (active) · 670 files · Python + TS

## What it is
The HTML report describes Memori as a "persistent memory layer that loads a compact slice per query." Mechanically, this repo is the **client SDK for Memori Cloud (memorilabs.ai)**: it requires a `MEMORI_API_KEY`, and memory processing/augmentation happens on their servers.

## Findings

### 🟠 F1 — Full conversation turns are sent to api/collector.memorilabs.ai
`memori/agent.py:capture_turn()` (lines 116-149) builds payloads containing the **complete user and assistant message text** plus session/project metadata and POSTs them to the vendor API: `agent/conversation/turn` to `api.memorilabs.ai` (required to succeed), then `agent/augmentation` to `collector.memorilabs.ai` (best-effort). The endpoints are constructed in `memori/_network.py:54` (`https://{api|collector}.memorilabs.ai`, overridable via `MEMORI_API_URL_BASE`); the SDK ships **hardcoded anonymous-tier API keys** baked into the source (`_network.py:49,53`) so it phones the vendor even with no account. (A legacy `memori/memory/_collector.py` class with a fire-and-forget-plus-stack-trace retry exists but has no callers in the current SDK; the live path is the `Api` class above.)
This is the product working as designed — but it means **everything your agent says and hears is stored and processed on a third-party cloud**. The HTML's framing ("loads a compact slice per query") is true but omits that the slices live on someone else's servers. The "BYODB" mode moves *storage* to your database; augmentation/processing still round-trips through Memori's API — the augmentation payload includes conversation messages, the running summary, **and your system prompt** (`memori/memory/augmentation/augmentations/memori/_augmentation.py:148-159` → `sdk/augmentation`).

### 🟡 F2 — Quota/identification
Unauthenticated use is rate-limited **by IP** (README), i.e., the service observes and keys usage to your IP before you even register; full use requires an account/API key.

### 🟢 Clean areas
- No covert telemetry beyond the documented cloud architecture — the data flow *is* the product, and it's disclosed in their docs.
- No install hooks, no pickle/eval, no suspicious exec.
- Other network calls are to embedding backends/DB provisioning you explicitly configure (`_tei.py` for a TEI server you point it at; `tidb_zero.py` provisions a TiDB instance via API).
- Active maintenance by GibsonAI (funded company); responsive repo.

## What you expose yourself to
- **Data residency:** conversation content, summaries, and derived memories held by Memori Labs, governed by their ToS/retention — not by you.
- Vendor lock and availability: your agent's memory works only while their API does.
- An API key that, if leaked, exposes your stored memories.

## Recommendation
Only adopt if you're comfortable with a cloud vendor holding full conversation history. **Do not use for client code, secrets-adjacent work, or anything under confidentiality obligations.** If you want local-first memory, mem0-OSS fits that requirement; memori does not.
