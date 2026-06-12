# Security Assessment — simonw/files-to-prompt
**Verdict: ✅ VERY LOW RISK**
Audited 2026-06-12 · Last upstream commit: 2025-02-18 (dormant but feature-complete) · **10 files total** · Python

## What it is
Tiny CLI by Simon Willison (Django co-creator, prolific and highly trusted OSS author) that concatenates selected files into one clean prompt.

## Findings

### 🟢 Clean areas
- The entire package is small enough to read in full. It contains **no network code, no subprocess, no eval/exec, no pickle** — verified by direct scan: zero hits.
- Dependencies: essentially just `click`.
- No install hooks.
- Reputable, security-conscious author with a long public track record.

### 🟡 Notes
- Dormant since Feb 2025 — irrelevant for a ~300-line tool with one dependency; there is nothing to rot.
- Inherent packer caveat applies: it will happily concatenate a committed `.env` if you point it at one. You choose the files, so the control is in your hands.

## What you expose yourself to
Nothing measurable. This is the lowest-risk repository in the audit.

## Recommendation
Safe to adopt without reservation. Just mind what files you select.
