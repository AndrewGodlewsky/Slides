# Security Assessment — yamadashy/repomix
**Verdict: ✅ LOW RISK**
Audited 2026-06-12 · Last upstream commit: 2026-06-08 (very active) · 1,122 files · TypeScript (npm CLI + MCP server)

## What it is
Packs a repository into one AI-friendly file with Tree-sitter–based `--compress`; also runs as an MCP server. 25k+ stars.

## Findings

### 🟢 Clean areas
- **No telemetry in the CLI/library.** All analytics hits in the scan were confined to `repomix/website/` (their docs site), which never runs on your machine.
- **No install-time hooks** in the published package (`prepare: npm run build` is dev-only and does not execute on consumer installs).
- **Network access is opt-in and narrow:** only `https://codeload.github.com/...` when you explicitly ask it to pack a *remote* repo (`src/core/git/gitHubArchive.ts`). Local packing makes no network calls.
- **Built-in secret scanning:** `src/core/security/securityCheck.ts` runs Secretlint over files before output and excludes suspicious files — the only context-packer in this audit that actively mitigates the secret-leakage failure mode.
- Very active maintenance, large community, MIT license.

### 🟡 Notes (inherent, not code flaws)
- **The output file is the risk.** A packed repo is a single blob of your source — paste it into the wrong chat/tool and you've shipped your codebase (and anything Secretlint missed: internal URLs, business logic, weak secrets in odd formats).
- As an **MCP server** it grants the connected agent read access to repos and writes output files; its tool surface (`packRemoteRepositoryTool` etc.) can fetch arbitrary public GitHub repos on the agent's request. Scope it to the directories you intend.

## What you expose yourself to
Mainly self-inflicted data leakage via the packed output, not the tool itself.

## Recommendation
Safe to adopt — the best-engineered tool in this audit from a security standpoint. Review packed output before pasting it anywhere external; keep its default security check enabled (don't run `--no-security-check` out of habit).
