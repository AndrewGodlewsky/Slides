# Security Assessment — mufeedvh/code2prompt
**Verdict: ✅ LOW RISK**
Audited 2026-06-12 · Last upstream commit: 2026-06-09 (active) · 311 files · Rust

## What it is
Rust CLI that converts a codebase into a single LLM prompt with a source tree, token counts, and glob filtering.

## Findings

### 🟢 Clean areas
- **No HTTP client dependencies** found in the workspace `Cargo.toml` manifests (no `reqwest`/`hyper`/`ureq`) — the tool is offline by construction; it cannot phone home.
- No install hooks (cargo/published binaries; pip/npm wrappers are thin).
- Rust memory safety; no dynamic code execution patterns.
- Actively maintained (commits this week).

### 🟡 Notes
- If you install via prebuilt release binaries, you trust the maintainer's release pipeline (single primary maintainer). Installing via `cargo install code2prompt` builds from published source instead — preferable for the cautious.
- Inherent context-packer caveat: output blob contains your code; **no built-in secret scanning** — review before pasting externally.
- Handlebars templating: only renders templates *you* supply; not an untrusted-input surface in normal use.

## What you expose yourself to
Practically nothing beyond the output-handling risk common to all packers.

## Recommendation
Safe to adopt. Prefer `cargo install` over downloaded binaries if provenance matters to you.
