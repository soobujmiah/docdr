# Next Migration Slice Analysis — 2026-08-29

**Date:** 2026-08-29 Asia/Dhaka
**Current HEAD:** `3d01e67` (docs: reconcile ledger to canonical HEAD 94c67b3) — CI green 33266322084 (Analyze No issues, Test 135/135, Android APK success), Security 33266322080 success
**Previous code green:** `0615a58` (135/135), docs green `94c67b3`
**Phase completed:** Phase 2 PDF Technology / Licence Gate — VERIFIED

## Audit Summary (Truth Reconciliation)

- GitHub canonical HEAD verified via API: `3d01e67` matches local, previous `94c67b3` and `0615a58` both green
- CI 33266322084 (3d01e67): Analyze success (No issues found! 9.7s), Test success 135/135 (00:18), Android debug build success
- CI 33265391686 (94c67b3): same code green
- CI 33264949642 (0615a58): same code green
- Dependency graph audited: pdfrx 2.4.7 MIT pinned, pdfrx_engine 0.4.6 MIT, pdf 3.13.0 Apache-2.0 (upgraded from 3.11.3 due to image 4.9.2 constraint, CI 17d82e4 failure, fixed b4a6cc7), image 4.9.2 MIT, PDFium BSD-3-Clause + permissive third-party (freetype FTL, libjpeg IJG/BSD, lcms2 MIT, libopenjpeg BSD-2-Clause, zlib, agg, abseil Apache-2.0) — no GPL/AGPL/LGPL/SSPL
- Vendor-neutral boundary intact: DocDrDocument→DocumentRenderer→PdfiumRendererAdapter→engine (all pdfrx_engine types isolated), DocDrTemplate→DocumentGenerator→PdfGeneratorAdapter→pdf (all pdf types isolated)
- Ledger discrepancy fixed in 3d01e67: THIRD_PARTY_NOTICES.md previously claimed no runtime deps at 739c8ba and proposed pin 3.11.3; updated to accurate bundled set at 94c67b3/0615a58/3d01e67 with exact versions, CI evidence, historical note
- MIGRATION_STATUS.md previously listed latest verified HEAD as 0615a58; updated to 94c67b3 docs + 3d01e67 ledger reconciliation, added CI progression row, preserved all historical SHAs

## Candidate Slices — Evaluation Matrix

Scored on: Dependency Readiness (is licence cleared, no new deps needed?), Architectural Dependency (does it unblock other slices?), Security Risk (does it introduce new attack surface, can we bound it?), Migration Value (user-visible value, closes RGEN gap), Testability (can we test on pure Dart VM, deterministic?), Smallest Safe Increment (lines of code, risk of regression)

| Candidate | Dependency Readiness | Arch Dependency | Security Risk | Migration Value | Testability | Size | Notes |
|---|---|---|---|---|---|---|---|
| **PDF/image import boundary** | **READY** — pdfrx 2.4.7, image 4.9.2, pdf 3.13.0 all verified and bundled, no new deps | **High** — unblocks template creation from existing docs, closes deferred item from Slice 4: "PDF/image background import DEFERRED (needs cleared PDF engine)" — now engine cleared | Medium — must enforce file-size (100MB PDF, 32MB image), page-count (2000), dimensions (14400 pts max, render 4000px), decompression bomb via image decode bound, path traversal via DocumentPathPolicy | **High** — core workflow: user has PDF/image, wants overlay fields, RGEN custom_template_store importAsset existed | **High** — temp files, pure Dart validation, renderer can open file to verify, deterministic | Small — 2 methods in TemplateStore (importBackgroundPdf, importBackgroundImage) + validation service, ~120 LOC + tests | **Recommended as Slice 7** |
| **Data mapping (CSV/XLSX)** | READY for CSV (dart:io only), PARTIAL for XLSX (needs archive MIT verified transitive but excel package licence UNKNOWN, defer XLSX) | High — unblocks batch generation from external data, RGEN studio_data_service KEEP | Low — must bound CSV size (8MB manifest already), row count (10k?), column count (100?), header injection, UTF-8 Bengali handling, empty rows | High — batch generation from CSV is core RGEN workflow | High — pure Dart, no native assets, easy fixtures including Bengali headers | Small — CSV parser service ~80 LOC + tests | Second candidate, can be Slice 8 |
| **Generation pipeline enhancement** | READY — pdf 3.13.0 already used, no new deps | Medium — depends on data mapping for full value, but prototype already exists (single/batch) | Low — already has bounds (max pages 100, elements 500, batch 1000, PDF 50MB), deterministic via clock | Medium — improves existing prototype with background rendering, font embedding | Medium — needs PDF generation + rendering round-trip, already has E2E with timeout guards | Medium — enhance PdfGeneratorAdapter to render background image/PDF | Defer until after import boundary |
| **Scanner / import boundary** | NOT READY — camera plugin, file_picker, path_provider licences UNKNOWN, plus Android permissions READ_MEDIA_IMAGES, CAMERA need justification, Play policy risk | Medium — enables capture workflow, but not required for template creation | High — camera permission, storage access, file-size, image dimensions, EXIF | Medium — nice to have, but not P0 | Low — requires device/emulator, not pure Dart | Large — new plugin integration, permission handling | DEFER until permission audit |
| **OCR (Tesseract eng+ben)** | NOT READY — engine Apache-2.0 but traineddata licence UNKNOWN, plus native binary size, plus Noto font bundling needs OFL audit | Low — depends on scanner/import | High — traineddata file size, model loading memory, language detection | Medium — Bengali OCR is differentiator but needs verification | Low — native binary, needs integration test | Large — new dep, model files, FFI | DEFER until licence gate for traineddata |
| **Batch generation (full)** | READY — generator already has batch bound 1000, but needs data mapping + progress + cancellation + error aggregation | Medium — depends on data mapping | Medium — memory bound (RGEN-03 held all PDFs in memory), need streaming or per-file write, bound batch 1000 already | High — core RGEN workflow custom_template_generate batch | Medium — can test with 1000 records, but memory heavy | Medium — batch orchestrator service | Defer until after CSV mapping |
| **Editor UX redesign** | READY — Flutter only, no new deps | Low — UI layer, does not unblock core | Low — UI only | Medium — user-visible but not blocking core migration | Medium — widget tests | Large — redesign, not smallest increment | DEFER — do after core data flows stable |

## Decision — Recommended Slice 7

**Slice 7: PDF/image import boundary**

Rationale per criteria:
1. **Dependency readiness:** All required deps already verified and bundled at HEAD 3d01e67, no new licence gate needed. Uses existing `image` 4.9.2 MIT and `pdfrx` 2.4.7 MIT. No need to introduce `archive` yet (ZIP bomb deferred).
2. **Architectural dependencies:** Closes explicit deferred item from Slice 4 ledger: "PDF/image background import is DEFERRED (needs a cleared PDF engine)" — engine now cleared at 0615a58, so this is natural next step. Builds directly on `DocDrPage.backgroundType` and `backgroundPath` already modelled and validated via `DocumentPathPolicy`, and on `TemplateStore.importAsset` which already has sanitization and containment.
3. **Security risk:** Manageable with existing bounds pattern: file size (100MB PDF, 32MB image via TemplateStoreLimits.maxAssetBytes), page count (2000 via renderer), dimensions (14400 pts PDF spec max, render 4000px), image decode bound (20MB PNG), path traversal (DocumentPathPolicy + symlink escape check already in resolveAssetPath). No new attack surface like MANAGE_EXTERNAL_STORAGE or INTERNET.
4. **Migration value:** High — RGEN's `custom_template_store.dart` had asset import returning template-relative path; DocDr users need to import existing PDFs/images as template background to overlay fields. Without this, template creation is blank-only. This unlocks real-world usage.
5. **Testability:** High — can test with temp directory, small fixture PDF generated via `pdf` package, small PNG via `image` package, Bengali filename sanitization, traversal rejection, oversized rejection, all on pure Dart VM (renderer validation can be skipped in unit test with timeout guard, or mocked).
6. **Smallest safe increment:** ~120 LOC for two methods `importBackgroundPdf` and `importBackgroundImage` in TemplateStore or new service `BackgroundImportService`, plus validation helpers, plus ~10 tests covering: valid PDF, valid image, oversized PDF, oversized image, invalid extension, traversal filename, damaged PDF (page count 0), dimensions exceed, Bengali filename preserved via safeName.

Alternative second choice: **CSV data mapping** as Slice 8, even smaller and pure Dart, but PDF/image import has higher architectural closure value because it directly follows PDF gate and completes Slice 4.

## Implementation Plan for Slice 7 (if approved)

- **Source:** RGEN `custom_template_store.dart` importAsset contract (397 lines) @ 9cd0e02 — preserve sanitizing, containment, but add type-specific validation
- **Target:**
  - `lib/core/storage/template_store.dart` — add methods:
    - `Future<DocDrPage> importBackgroundPdf(DocDrTemplate template, String sourcePath, String pageId)` — validates PDF exists, size <= maxAssetBytes (32MB) and <= 100MB renderer bound, opens via PdfiumRendererAdapter.getPageCount to validate page count <=2000 and dimensions, copies via importAsset, updates page backgroundType=pdf, backgroundPath=relative
    - `Future<DocDrPage> importBackgroundImage(...)` — validates image exists, size <= maxAssetBytes, decodes via `image` package to check dimensions <=4000x4000 and file not empty, copies, updates backgroundType=image
  - Or extract to `lib/core/services/background_import_service.dart` keeping TemplateStore focused
- **Security:**
  - Reuse DocumentPathPolicy for relative path
  - Enforce maxAssetBytes (32MB) already, plus PDF-specific 100MB, PNG 20MB
  - Enforce maxPages 2000, max dimensions 14400 pts, render dimensions 4000px
  - Symlink escape already enforced in resolveAssetPath
  - No absolute paths, no `..`, sanitized filename via _safeName
- **Tests:**
  - `test/core/storage/background_import_test.dart` — 10 tests: valid PDF import sets background, valid image import, oversized PDF rejected, oversized image rejected, invalid extension rejected, traversal in source name sanitized not escaped, damaged PDF (0 bytes) rejected, image decode failure rejected, Bengali filename sanitized but preserved safely, duplicate import creates new copy
- **Licence:** No new deps, uses already verified pdfrx 2.4.7 MIT, image 4.9.2 MIT, pdf 3.13.0 Apache-2.0 — no GPL/AGPL/LGPL
- **Commit:** Small focused commit, push, verify CI green (Analyze No issues, Test 145/145 expected, Android APK success)

## Next after Slice 7

Slice 8: CSV data mapping (pure Dart, no new deps, bounds: max file 8MB, max rows 10000, max cols 100, UTF-8 Bengali support, header sanitization) — enables batch generation from external data, then Slice 9: batch orchestrator with progress/cancellation.

## Open Questions for Owner

- Confirm PDF/image import as next slice, or prefer CSV mapping first (even smaller)?
- Any specific RGEN background import behavior that must be preserved beyond sanitization/containment? (RGEN had no bounds, we add bounds)
- Should background import support multi-page PDF background (one PDF per page) or single background per template? RGEN had per-page backgroundType.

**End of analysis**
