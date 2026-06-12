# Security Assessment — DeusData/codebase-memory-mcp
**Verdict: 🟠 MODERATE RISK (opaque-binary install paths from a small maintainer; source itself audits clean)**
Audited 2026-06-12 · Reviewed by senior analyst 2026-06-12 (language ID, install-path and attack-surface corrections) · Last upstream commit: 2026-06-12 (active, same-day) · 1,661 files, 1.2 GB clone · **C core (115 source files) + vendored C libraries; Go appears only as a 1-file installer wrapper**

## What it is
An MCP server that builds a code knowledge graph ("what calls X / where is Y") so the agent queries instead of re-reading files. The server is a **single static binary compiled from C** (custom store, Cypher-style query engine, tree-sitter parsing, zstd compression — all in `src/` and `internal/cbm/vendored/`). Distributed as prebuilt binaries via npm, PyPI, Homebrew, Scoop, winget, AUR, a curl|bash script — and a Go wrapper that *looks like* a source install but is not (F2).

> **Correction from first-pass audit:** the original assessment identified this as a Go project. It is not — `src/` is 115 C files and the only `.go` file in the repo is `pkg/go/cmd/codebase-memory-mcp/main.go`, an installer stub. This changes both the recommended build-from-source path and the attack-surface analysis below.

## Findings

### 🟠 F1 — Every packaged install path downloads a prebuilt binary; checksum failure can be silent
- **npm:** `pkg/npm/package.json` runs `node install.js` on `postinstall`, downloading a platform binary from GitHub Releases. The script is competently written (HTTPS-only, redirect cap, tar-slip path check, `execFileSync` with array args), **but** SHA-256 verification is *non-fatal*: if `checksums.txt` is missing or unfetchable, the binary installs **unverified** (`install.js:75,89` — explicitly "non-fatal").
- **curl|bash:** the root `install.sh` (documented one-liner from `raw.githubusercontent.com/.../main/install.sh`) pulls from `releases/latest` — unpinned — with the **same skip-on-unavailable checksum pattern** (`install.sh:128-146`: verification only runs `if curl ... checksums.txt` succeeds).
- In all cases the checksums come from the same release as the binary, so they authenticate transport, not the publisher. No reproducible-build attestations.

Net effect: installing executes an opaque compiled binary published by a small unknown entity ("DeusData"). You audit the source it *claims* to be built from, not what runs.

### 🟠 F2 — The `go install` path is **not** a source build (corrected finding)
`go install github.com/DeusData/codebase-memory-mcp/pkg/go/cmd/...@latest` compiles only a ~340-line wrapper that, on first run, **downloads the same prebuilt binary** from GitHub Releases and `exec`s it (`main.go:46-55,112-174`). Same non-fatal checksum handling (`main.go:137-144`: if `checksums.txt` is unreachable *or the archive isn't listed in it*, execution proceeds unverified). It is also hardcoded to `version = "0.6.0"` while npm ships 0.8.0 — so this path silently runs an **older** release. Do not mistake it for the audited-source option.

### 🟢 F3 — C server source contains no outbound networking or telemetry (verified, scope corrected)
Grep across the C source for sockets/HTTP/telemetry: the **only** network code is `src/ui/httpd.c` — a minimal HTTP server for the optional `--ui` graph-visualization variant, hardcoded to bind `127.0.0.1` (`httpd.c:141`, "single-threaded, localhost-only"). No outbound connections, no analytics, no phone-home anywhere in server source. As written, the standard server is a local stdio MCP process.

### 🟡 F4 — Memory-unsafe parser stack over untrusted input (new finding)
The server is custom C that parses whatever you index: tree-sitter grammars (mature, widely fuzzed) plus **bespoke C** for the graph store, Cypher-style queries, YAML config, simhash, etc. If you index untrusted third-party repositories, a malicious source file exploiting a parser bug is a code-execution path that wouldn't exist in a memory-safe implementation. Mitigating signals: `.clang-tidy`/`.cppcheck` configs, fuzzing referenced in SECURITY.md/CONTRIBUTING.md, active maintenance. Risk is low for indexing your own code, real for indexing arbitrary repos.

### 🟡 F5 — Indexed data includes environment/config values (new, minor)
`src/pipeline/pass_envscan.c` deliberately scans `.env`, Dockerfile, YAML, TOML, Terraform and `.properties` files for env-var assignments whose value is a URL, storing them in the local graph DB. It filters obvious secret files/keys, but URLs themselves can embed credentials (`https://user:pass@host`) and internal endpoints. The local store therefore holds somewhat more than "code structure" — protect it accordingly.

### 🟡 F6 — Repo anomaly: 1.2 GB working tree
`internal/cbm/vendored/grammars/` vendors dozens of tree-sitter grammars as giant generated `parser.c` files (lean, systemverilog 50 MB+ each). Explains the size — bloat, not malice — but vendored generated C is effectively unauditable by eye and compiles into the binary you run.

### 🟡 F7 — Trust profile
Active (commits today) but a single small organization, low external review, and full read access to every codebase you index. Indexed data stays in a local store (see F5 for what it contains). Engineering hygiene is above average for the niche (SECURITY.md, gitleaks config, static-analysis configs, many install channels maintained in-repo).

## What you expose yourself to
1. Running an unauditable native binary with read access to your source trees, auto-fetched at install time — via *every* convenience install path, including `go install`.
2. Publisher-account compromise = malicious release; the checksum design wouldn't catch it.
3. Parser-level code execution if you index hostile third-party code (C memory-safety surface).
4. Local graph DB of your codebase — including env-var URLs from config files — on disk.

## Recommendation
If the capability is worth it, **build from source with the C toolchain** — the README's "Build from Source" section (gcc/clang + `Makefile.cbm`) is the only true source path; `go install` is **not** it (F2). Pin an exact release version (avoid `releases/latest` and the npm postinstall), run it scoped to specific project directories, and don't index untrusted third-party repos. Avoid on machines holding code you're contractually required to protect until the project earns more track record.
