# Security Assessment — BoundaryML/baml
**Verdict: 🟡 LOW-MODERATE RISK**
Audited 2026-06-12 · Last upstream commit: 2026-06-12 (extremely active) · 8,105 files, ~139 MB · Rust core + TS/Python SDKs

## What it is
A DSL + toolchain for defining structured LLM functions, compiled by a Rust engine, with language SDKs, a CLI, and a VS Code extension. By far the largest and most complex codebase in this audit.

## Findings

### 🟡 F1 — Compiled native binaries are the delivery mechanism
The SDKs bridge into a prebuilt Rust engine (`bridge_nodejs/dist`, native wheels). You execute opaque compiled code from BoundaryML's release pipeline. This is normal for native-extension packages, but it means auditing the source ≠ auditing what runs; you trust their build/release infrastructure.

### 🟡 F2 — curl|sh installer
The documented CLI install path is `curl -fsSL https://pkg.boundaryml.com/install.sh | sh`, which installs a wrapper that **downloads further toolchain versions at runtime** (their own design docs in `TASK/` describe a rustup-style wrapper with a "canary" default channel). A canary/rolling channel means you can receive new vendor code without an explicit upgrade action. Prefer pinned package-manager installs (npm/pip with exact versions) over the shell installer.

### 🟡 F3 — Telemetry: inconclusive-to-present in tooling
Scans found telemetry-related code in the VS Code extension and playground packages (`vscode-ext/src`, `playground-common`) and references in the engine. No hardcoded analytics endpoint was confirmed in the core engine source during this audit. Historically Boundary's tooling has used PostHog with an opt-out. **Assume the IDE tooling phones home unless you verify/disable it**; check current docs for `BAML_TELEMETRY`-style env vars before use in sensitive environments.

### 🟢 Clean areas
- No npm `postinstall` hooks (only dev-side `prepare` scripts that don't ship in the published package).
- No pickle/eval patterns; Rust core.
- Daily commit activity, VC-backed company, public CI — strong maintenance signal.

## What you expose yourself to
- Vendor build-pipeline trust (binaries) and, via the shell installer, rolling auto-updated vendor code.
- Possible product telemetry from IDE tooling.
- Your prompts go only to LLM providers you configure.

## Recommendation
Fine for use, but install via pinned package versions (not curl|sh), audit/disable telemetry in the VS Code extension if confidentiality matters, and treat upgrades as supply-chain events.
