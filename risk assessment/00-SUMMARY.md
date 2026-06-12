# Security Risk Assessment — Token-Reduction Tools
**Audit date:** 2026-06-12 · **Auditor:** Claude Code (Fable 5), junior analyst · **Senior review:** 2026-06-12 (Fable 5, senior) · **Scope:** all 17 repositories linked in `Token-Reduction-Skills-Research.html`

## Methodology
Every repository was shallow-cloned (`clones/` subfolder) and examined for:
1. **Install-time code execution** — npm `preinstall`/`postinstall`/`prepare` hooks, `setup.py` custom commands, curl-pipe-shell installers
2. **Network exfiltration / telemetry** — PostHog, Segment, Sentry, analytics SDKs, hardcoded endpoints, what data leaves your machine
3. **Dangerous code patterns** — `eval`/`exec`, `pickle`/`allow_pickle` deserialization, `subprocess`/`child_process` call sites (each traced to what it actually executes), `trust_remote_code`
4. **Agent attack surface** — SKILL.md/hook/MCP-server content that becomes standing instructions or runs shell code on every AI interaction
5. **Maintenance & provenance** — last-commit recency, maintainer identity, repo anomalies

## Senior review note (2026-06-12)
A senior analyst re-checked every report against the cloned source. The original assessments were directionally sound and the verdicts mostly hold, but several findings were **wrong or incomplete** and have been corrected in the individual reports:
- **LLMLingua** — the report affirmatively claimed "No `eval`/`exec`/pickle in the library code." **False:** `prompt_compressor.py:1201` passes the public `context_budget` parameter straight into `eval()` — an injection sink. Corrected, F2 added.
- **GPTCache** — pickle (F1) and Dolly `trust_remote_code` (F3) confirmed at exact lines; **added F4**: importing optional backends triggers a runtime `subprocess(..., shell=True)` `pip install`, so "fully local" was overstated.
- **github-copilot-token-optimization** — the report said `sync-mesh.sh` had "mkdir/echo/git/jq only." **Missed** `eval curl … "$source"` (line 100) — a shell-injection path driven by `mesh.json` values. F2 upgraded to 🟠.
- **codebase-memory-mcp** — identified as "Go." It is a **C** codebase (115 C source files); the only Go is a one-file installer stub, and the `go install` path is **not** a source build (it downloads the same prebuilt binary). Recommendation and attack surface corrected.
- **memori / mem0** — endpoint/telemetry mechanics tightened (hardcoded anonymous API keys in memori; BYODB still round-trips augmentation incl. system prompt; mem0 sends a host fingerprint). Verdicts unchanged.
- **outlines** — added a note that its local disk cache uses `cloudpickle.loads` (same deserialization class flagged for GPTCache/memcp), for consistency. Verdict stays LOW.

None of the corrections uncovered intentional malice; they close gaps in **code-execution sink coverage** and one **language/build-path** error.

## Verdict table

Two columns: **Safe to use?** = the go/no-go call and the condition that makes it safe. **Key notes** = the one thing to remember, max-compressed.

| Repository | Safe to use? | Key notes |
|---|---|---|
| [microsoft/LLMLingua](LLMLingua.md) | ⚠️ **Yes, with config.** Safe only if you set `trust_remote_code=False` and never feed user input to `context_budget`. | RCE-by-default model loading **+** `eval()` injection sink on a public param. Process your prompts locally; pin model revisions. |
| [567-labs/instructor](instructor.md) | ✅ **Yes.** Adopt freely; pin version, install minimal extras. | Thin LLM-SDK wrapper. No telemetry, no hooks, no new trust beyond your provider. |
| [dottxt-ai/outlines](outlines.md) | ✅ **Yes.** Adopt freely; pin version. | Local constrained generation. Only nit: local disk cache uses `cloudpickle` (exploit needs write access to your `~/.cache`). |
| [guidance-ai/guidance](guidance.md) | ✅ **Yes.** Adopt freely; prefer PyPI wheels, pin version. | Constrained generation; `trust_remote_code` is opt-in passthrough only. Ships a prebuilt native parser (numpy-level trust). |
| [BoundaryML/baml](baml.md) | 🟡 **Yes, with care.** Install pinned npm/pip versions, not the curl\|sh installer. | Runs compiled Rust binaries from vendor pipeline; IDE/playground tooling phones home (PostHog) — disable if sensitive. |
| [zilliztech/GPTCache](GPTCache.md) | ⚠️ **Local experiments only.** Not for production/shared hosts; keep cache dir private. | Pickle cache = code-exec via tampered file; importing backends triggers runtime `pip install`; ~11 mo unmaintained. |
| [yamadashy/repomix](repomix.md) | ✅ **Yes.** Best-engineered packer here; keep its secret scan on. | No CLI telemetry, built-in Secretlint, network only for explicit remote-repo packs. Review output before pasting externally. |
| [coderamp-labs/gitingest](gitingest.md) | ✅ **Yes (CLI).** Use the local CLI; avoid the hosted site for private code. | CLI is local & clean. **gitingest.com = uploading your repo to a third party.** No built-in secret scan. |
| [mufeedvh/code2prompt](code2prompt.md) | ✅ **Yes.** Adopt freely; prefer `cargo install` over prebuilt binaries. | Offline Rust CLI, no HTTP deps. Inherent packer caveat: output blob = your code, no secret scan. |
| [simonw/files-to-prompt](files-to-prompt.md) | ✅ **Yes.** Lowest-risk repo in the audit; adopt without reservation. | ~10 files, zero network/exec/pickle, reputable author. Only mind which files you point it at. |
| [olivomarco/github-copilot-token-optimization](github-copilot-token-optimization.md) | 🟡 **Reading: yes (zero-risk). Adopting the framework: with care.** Never run `sync-mesh.sh` on an untrusted `mesh.json`. | Guide is harmless docs. "Squad" skills = big standing-instruction surface; `sync-mesh.sh` has an `eval curl` shell-injection path. |
| [microsoft/markitdown](markitdown.md) | 🟡 **Yes for your own docs.** Sandbox it if converting files from strangers; leave plugins off. | Parser-CVE surface on untrusted documents. Azure/LLM upload features are opt-in. No telemetry. |
| [juliusbrussee/caveman](caveman.md) | 🟠 **Yes, but not via the one-liner.** Install from a reviewed, pinned commit — not curl\|bash. | Installs always-on hooks; installer pulls from **unpinned `main`**. Exec sites benign today; single maintainer. (A fork is already live in this env.) |
| [mem0ai/mem0](mem0.md) | 🟡 **Yes (OSS mode).** Set `MEM0_TELEMETRY=false` before first import; use a local vector store. | PostHog telemetry on by default (metadata + host fingerprint, **not** memory content). Platform mode = your memories in mem0 cloud. |
| [GibsonAI/memori](memori.md) | 🟠 **Privacy gate.** Do **not** use for client code, secrets, or anything under NDA. | It's a cloud client: full conversation turns (and system prompt) go to memorilabs.ai. Not a local memory layer. |
| [maydali28/memcp](memcp.md) | 🟡 **Yes.** Best local-first memory option here; pin commit, lock down its data dir. | Genuinely local (no net/exec). Minor: `np.load(allow_pickle=True)` on its own store. Single maintainer. |
| [DeusData/codebase-memory-mcp](codebase-memory-mcp.md) | 🟠 **Yes, if you build from C source.** Avoid the prebuilt-binary install paths; don't index untrusted repos. | **C** project (not Go). Every package install downloads an opaque binary w/ non-fatal checksum; `go install` is **not** a source build. |

## Cross-cutting conclusions

1. **No malware found.** Nothing in any of the 17 repos exhibits intentional malice — no obfuscated payloads, no credential harvesting, no covert exfiltration disguised as something else. (Confirmed on senior re-review.)
2. **The biggest *code-execution* risk is LLMLingua's `trust_remote_code=True` default** — a compromised or malicious Hugging Face model repo executes arbitrary Python on your machine the moment the model loads. **Secondary code-exec sinks now documented:** LLMLingua's `eval()` on `context_budget`, GPTCache's pickle cache + runtime `shell=True` pip install, and github-copilot-token-optimization's `eval curl` in `sync-mesh.sh`. All three are **gated** (they need attacker-controlled input, a tampered cache file, or an untrusted `mesh.json`), so none is an unconditional drive-by — but each is a real sink that the first-pass audit either missed or mislabeled, and each should be closed before exposing the tool to untrusted input.
3. **The biggest *privacy* risks are memori (conversations → vendor cloud by design) and mem0 (anonymous telemetry on by default).** Neither is hidden, but neither is obvious from the marketing either.
4. **The biggest *supply-chain* risks are the two small-maintainer MCP/agent tools** (codebase-memory-mcp's postinstall binary download, caveman's unpinned curl|bash installer + always-on hooks). Both audited clean *today*, but you are trusting a single individual's GitHub account security going forward — pin versions and review updates.
5. **Context-packers (repomix, gitingest, code2prompt, files-to-prompt) carry an inherent secret-leakage risk** regardless of their own code quality: they bundle your codebase into a single paste-able blob. Only repomix actively scans for secrets before output.
6. **Anything installed as a Claude/Copilot skill or hook is a standing prompt-injection/behavior surface.** A skill update you auto-pull can silently change what your agent does. Pin versions; re-read skill files after updates.
