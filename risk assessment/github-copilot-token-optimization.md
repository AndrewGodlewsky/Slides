# Security Assessment — olivomarco/github-copilot-token-optimization
**Verdict: 🟡 LOW-MODERATE RISK (docs are safe; bundled agent framework needs care — sync-mesh.sh finding corrected on review)**
Audited 2026-06-12 · Reviewed by senior analyst 2026-06-12 (corrected the F2 "mkdir/echo/git/jq only" claim — script contains an `eval curl`) · Last upstream commit: 2026-06-08 (active) · 168 files · Markdown + shell/PS scripts

## What it is
Referenced by the HTML as a Copilot token-optimization *guide* — but the repo is actually a full agent-orchestration project ("squad"): 30+ Copilot SKILL.md files, agent definitions, an MCP config, and "distributed mesh" sync scripts. Author is a Microsoft employee (personal project).

## Findings

### 🟢 The guide itself is harmless
Reading the README/docs for optimization advice executes nothing and carries zero risk. This is how the HTML report uses it.

### 🟡 F1 — Adopting the bundled skills = large standing-instruction surface
Each SKILL.md you copy into your own `.copilot/skills/` becomes **persistent instructions your agent obeys on every matching task**. I read the sensitive-sounding ones:
- `secret-handling/SKILL.md` — *defensive*: prohibits reading `.env` files and writing secrets to committed paths.
- `external-comms/SKILL.md` — *gated*: drafts GitHub issue responses but mandates a human review gate; "never posts autonomously".
- `gh-auth-isolation`, `economy-mode`, etc. — process conventions, nothing exfiltrative.
No malicious or covert instructions found. The risk is **volume and drift**: 30+ skills are a lot of agent behavior to vet, and future updates change your agent's behavior if you re-sync without review.

### 🟠 F2 — `distributed-mesh/sync-mesh.sh` fetches remote repos **and uses `eval` on config-derived values** (corrected finding)
The mesh script (`jq` + `git` + `curl`) clones/pulls "squad state" repos listed in your `mesh.json` before agent reads. Two distinct risks:

1. **Indirect prompt injection (as originally noted):** fetched repo/contract content lands in agent-readable `SUMMARY.md` files — a textbook injection channel if you mesh with repos you don't control.

2. **Shell command injection via `eval` (missed in the first pass):** the original report said the script contained "no obfuscated or dangerous commands (reviewed: mkdir/echo/git/jq only)." That is **incorrect** — `.copilot/skills/distributed-mesh/sync-mesh.sh:100` (and the `.squad/templates/` copy) runs:
   ```bash
   eval curl --silent --fail $auth_flag "$source" -o "$target/SUMMARY.md"
   ```
   `$source` and `$target` are read straight from `mesh.json` (lines 89-90). Because the command is wrapped in `eval`, shell metacharacters in those config values are interpreted — a `mesh.json` whose `source`/`sync_to` contains `$(...)`, backticks, or `;` achieves **arbitrary command execution** on the machine running the sync. `set -euo pipefail` does not mitigate this. The `eval` exists only to expand the `$auth_flag` Bearer-token string (line 97); it could be removed with a curl `--config`/array approach. The Zone-2 `git clone "$source"` path (line 82) is comparatively safe (no `eval`, args are positional), though a `--upload-pack`-style malicious `source` is a lesser concern.

   **Net:** adopting the squad mesh and running `sync-mesh.sh` against a `mesh.json` you don't fully control is a direct RCE path, not merely an injection-context path. Treat `mesh.json` as trusted, security-sensitive configuration; never accept one from an untrusted source.

### 🟡 F3 — `.copilot/mcp-config.json`
Ships only a commented EXAMPLE GitHub MCP server using `${GITHUB_TOKEN}` — fine as an example; just understand any MCP server you enable gets that token.

### 🟢 Clean areas
- No install hooks, no binaries, no telemetry. Nothing runs unless you copy it in and run it.

## What you expose yourself to
Nothing, if you just read the guide. If you adopt the squad framework: a wide prompt-instruction surface, mesh repos as injection channels, **and an `eval`-based shell-injection path if you run `sync-mesh.sh` with an untrusted `mesh.json`** (F2).

## Recommendation
Read the guide freely. If you borrow skills, copy them **individually after reading them**, pin to a commit, and don't join meshes with repos outside your control. If you use `sync-mesh.sh`, only run it against a `mesh.json` you authored, or patch out the `eval` on line 100 first. The guide-only use case the HTML relies on remains zero-risk.
