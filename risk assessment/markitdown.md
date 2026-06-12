# Security Assessment — microsoft/markitdown
**Verdict: 🟡 LOW-MODERATE RISK (document-parsing attack surface)**
Audited 2026-06-12 · Last upstream commit: 2026-05-26 (active) · 163 files · Python · Microsoft

## What it is
Converts office documents (.docx/.pdf/.pptx/.xlsx), HTML, images, audio, etc. to Markdown for LLM consumption.

## Findings

### 🟡 F1 — Its job is parsing untrusted files
Document converters are a classic exploit surface: markitdown delegates to a stack of third-party parsers (pdfminer, mammoth, openpyxl, BeautifulSoup, etc.). A **maliciously crafted document** from an untrusted source could exploit a parser bug (historically: zip bombs, XXE in office XML, decompression bugs). Microsoft maintains it actively, but the transitive parser tree is where the CVEs live.
**Mitigation:** keep it updated; convert untrusted documents in a sandbox/container if you handle attacker-supplied files routinely.

### 🟡 F2 — Optional cloud features send content off-machine
- The Azure **Document Intelligence** integration uploads documents to Azure for OCR/conversion (explicit opt-in via endpoint config).
- LLM-based image description sends images to your configured LLM provider.
Both off by default; just be aware that enabling them moves your documents to the cloud.

### 🟡 F3 — Third-party plugin system
`markitdown` loads converter plugins via entry points when `enable_plugins=True`. A plugin is arbitrary Python — only install plugins you trust. Off by default.

### 🟢 Clean areas
- **No telemetry**; no analytics endpoints in the package source.
- **No `eval`/`exec`/pickle** in the conversion paths (verified by scan).
- No install hooks. URL-fetching converters exist but only fetch URLs you pass.
- The one external-process call (`converters/_exiftool.py`) shells out to ExifTool **only if you supply `exiftool_path`** (opt-in), uses **array args (no `shell=True`)** so it's injection-safe, and explicitly **refuses ExifTool < 12.24 to avoid CVE-2021-22204** — a security-conscious detail that reinforces the active-maintenance signal.
- Microsoft provenance, active maintenance, prompt CVE handling history.

## What you expose yourself to
- Parser exploitation only if you feed it malicious documents.
- Data residency only if you enable Azure/LLM features.

## Recommendation
Safe for converting **your own** documents (the HTML report's use case — preprocessing your .docx/.pdf for Copilot). Sandbox it if processing files from strangers; leave plugins disabled.
