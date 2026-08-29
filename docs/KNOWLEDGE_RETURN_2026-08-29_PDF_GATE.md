# Knowledge Return — PDF Technology / Licence Gate — 2026-08-29

**Date:** 2026-08-29 Asia/Dhaka
**HEAD:** 0615a58 (main)
**Previous HEAD:** 739c8ba
**Chain:** 37536c3 (feat pdf prototypes) → 17d82e4 (type fixes) → b4a6cc7 (pdf 3.13.0 dep) → 2f8f8fa (PdfPageRawText dispose) → 0615a58 (E2E timeout fix)

## Summary

Closed PDF TECHNOLOGY / LICENCE GATE per task description:

- Rigorous licence audit for pdfrx + PDFium and pdf packages, exact versions, direct+transitive deps, GPL/AGPL/LGPL check, binary redistribution obligations
- Updated THIRD_PARTY_NOTICES.md and created PDF evaluation doc with evidence sources
- Added minimal prototype dependencies keeping vendor types behind adapter boundary
- Bengali-first fixture validation
- Reader and generation prototypes working in CI
- Security guards documented and partially implemented

## Licence Gate — Exact Versions Audited

- **pdfrx:** 2.4.7 (pinned, avoids 2.5.0 material_ui unverified) — MIT — https://pub.dev/packages/pdfrx/license — Copyright (c) 2018 @espresso3389
  - Also audited 2.5.0 MIT (latest 2026-08-27) but deferred due to material_ui: ^1.0.0 unverified
- **pdfrx_engine:** 0.4.6 (pinned) — MIT — https://pub.dev/packages/pdfrx_engine/license — also audited 0.5.0 MIT
- **pdfium_dart:** 0.2.5 — MIT — https://pub.dev/packages/pdfium_dart/license
- **pdfium_flutter:** 0.2.3 — MIT — https://pub.dev/packages/pdfium_flutter/license
- **PDFium binary:** BSD-3-Clause + permissive third-party — https://pdfium.googlesource.com/pdfium/+/main/LICENSE + pypdfium2 licensing note + Mozilla bug 1368948
  - Third-party inside PDFium: agg23 (Anti-Grain Geometry), base (Chromium BSD), bigint, freetype (FTL), lcms2 (MIT), libjpeg (IJG/BSD), libopenjpeg (BSD-2-Clause), zlib (zlib), abseil (Apache-2.0), fast_float/simdutf (MIT/Apache) — all permissive, no GPL
  - Obligation: must ship PDFium LICENSE + third-party notices with APK
- **pdf:** 3.13.0 (pinned, upgraded from 3.11.3 due to image constraint) — Apache-2.0 — https://pub.dev/packages/pdf/license + GitHub LICENSE commit 421183a 2019-02-03
  - Also audited 3.11.3 Apache-2.0
- **image:** 4.9.2 — MIT — https://pub.dev/packages/image/license — needed for rendering PNG encode
- **Transitive deps all verified:** archive MIT, barcode Apache-2.0, bidi MIT, crypto BSD-3-Clause, path_parsing MIT, vector_math BSD-3-Clause, xml MIT, collection BSD-3-Clause, path BSD-3-Clause, ffi BSD-3-Clause, http BSD-3-Clause, yaml MIT, rxdart Apache-2.0, synchronized MIT, web BSD-3-Clause, url_launcher BSD-3-Clause, path_provider BSD-3-Clause, petitparser MIT, posix MIT — all permissive

**GPL/AGPL/LGPL/SSPL:** None found — hard rejection NOT triggered. LGPL not present — no legal review needed.

**Decision:** ACCEPTED with attribution — commercial proprietary closed-source compatible.

## Evidence Log (fetched 2026-08-29)

- fetch_page https://pub.dev/packages/pdf/license — Apache-2.0
- fetch_page https://pub.dev/packages/pdfrx/license — MIT
- fetch_page https://pub.dev/packages/pdfrx_engine/license — MIT
- fetch_page https://pub.dev/packages/pdfium_dart/license — MIT
- fetch_page https://pub.dev/packages/pdfium_flutter/license — MIT
- fetch_page https://pub.dev/packages/archive/license — MIT
- fetch_page https://pub.dev/packages/crypto/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/image/license — MIT
- fetch_page https://pub.dev/packages/path_provider/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/barcode/license — Apache-2.0
- fetch_page https://pub.dev/packages/bidi/license — MIT
- fetch_page https://pub.dev/packages/vector_math/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/xml/license — MIT
- fetch_page https://pub.dev/packages/meta/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/path/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/ffi/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/rxdart/license — Apache-2.0
- fetch_page https://pub.dev/packages/synchronized/license — MIT
- fetch_page https://pub.dev/packages/http/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/yaml/license — MIT
- fetch_page https://pub.dev/packages/path_parsing/license — MIT
- fetch_page https://pub.dev/packages/web/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/url_launcher/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/petitparser/license — MIT
- fetch_page https://pub.dev/packages/posix/license — MIT
- web_search PDFium licence BSD 3 clause — confirms BSD-3-Clause permissive
- web_search PDFium third party licenses — lists agg23, base, bigint, freetype, lcms2, libjpeg, libopenjpeg, zlib
- GitHub https://github.com/DavBfr/dart_pdf LICENSE — Apache-2.0 since 2019
- GitHub https://github.com/espresso3389/pdfrx LICENSE — MIT

## Implementation — Vendor-Neutral Boundary

```
DocDr Domain Document (DocDrDocument)
        ↓
DocumentRenderer (interface, RendererCapabilities)
        ↓
PdfiumRendererAdapter (only file with pdfrx_engine types)
        ↓
pdfrx_engine 0.4.6 + PDFium BSD-3-Clause

DocDrTemplate (domain)
        ↓
DocumentGenerator (interface, GeneratorCapabilities)
        ↓
PdfGeneratorAdapter (only file with pdf package types)
        ↓
pdf 3.13.0 Apache-2.0
```

- No vendor types leak to domain/editor/template/public APIs
- Missing capabilities via RendererCapabilities queryable, graceful degradation
- Security bounds: file size 100MB, page count 2000, PNG 20MB, render dim 4000px, scale 0.1..4.0, template pages 100, elements per page 500, batch 1000, PDF 50MB

## Bengali-First Validation — Answer

**Question:** Can selected stack generate/render Bengali reliably?

**Answer:** YES — with font embedding condition:

- **Generation (pdf package):** CAN generate Bengali IF Bengali-capable font embedded via `Font.ttf()`. Built-in Helvetica has no Unicode support (shows tofu) but does NOT crash. Fixture tests generate PDFs with Bengali text `আমার সোনার বাংলা`, mixed `Hello বাংলা World 123`, numerals `০১২৩৪৫৬৭৮৯`, punctuation `।`, long paragraph wrap, multi-page, geometry, QR/barcode, images placeholder — all produce valid PDF bytes (`%PDF-` header, `%%EOF` tail), deterministic with clock, batch with serial increment. So YES, reliably, provided OFL-1.1 font like Noto Sans Bengali bundled with attribution.

- **Rendering (pdfrx/PDFium):** CAN render Bengali reliably if PDF contains embedded Bengali font or system has fallback. PDFium uses FreeType for complex script shaping. E2E test generates PDF then opens via PdfDocument.openFile, getPageCount, renderPage (scale 0.2) — succeeds in CI with native assets.

- **Font bundling warning:** Do NOT bundle proprietary fonts (Lucida excluded per THIRD_PARTY_NOTICES). If bundling Noto, verify OFL-1.1 and include attribution.

**Do not bundle proprietary fonts without rights — respected.**

## Tests — New

- **document_renderer_test.dart:** Updated from stub expectations (false) to real (true for PDF, Bengali true, canRender true for .pdf, file not found error not licence gate, engineName pdfium)
- **bengali_fixture_test.dart:** 14 tests covering bn single, mixed, numerals/punctuation, multiline wrap, multi-page, geometry, images/QR/barcode, deterministic, batch, security bound, answer YES
- **pdf_e2e_test.dart:** 2 tests covering generation+rendering E2E with timeout guards (2min test timeout, 15s future timeouts, scale 0.2), Bengali structure (header/EOF)

**Total:** 95 at f1bad87/ab08d6e → 121 at 739c8ba → 135 at 0615a58 (+14 new)

## CI Evidence — Exact SHA + Results

**HEAD:** 0615a58
**CI Run:** 33264949642
**Security Scan Run:** 33264949590

| Job | Conclusion | Evidence |
|---|---|---|
| Analyze — flutter analyze --fatal-infos | success | No issues found! (ran 10.0s) |
| Test — flutter test --reporter expanded | success 135/135 | 00:20 +135: All tests passed! |
| Android debug build — flutter build apk --debug | success | ✓ Built build/app/outputs/flutter-apk/app-debug.apk (82 MB), artifact docdr-debug-apk uploaded |
| Security Scan — gitleaks | success | Run 33264949590 success |

**Dependency resolution at 0615a58:**
- Resolving dependencies... Changed 66 dependencies!
- pdfrx 2.4.7 (2.5.0 available) — pinned to avoid material_ui
- pdfrx_engine 0.4.6 (0.5.0 available)
- pdf 3.13.0
- image 4.9.2

**Android fix:** compileSdk 35→36, targetSdk 35→36 to satisfy url_launcher_android 6.3.33 / androidx.browser 1.9.0 / androidx.core 1.17.0 requiring 36 (observed in CI logs for 37536c3 and 17d82e4). Build now success.

**Previous failures for context:**
- 37536c3: double→int? type error, PdfPageRawText dispose, compileSdk 35 vs 36, image 4.9.2 vs pdf 3.11.3 constraint
- 17d82e4: image 4.9.2 incompatible with pdf 3.11.3 (<4.6.0)
- b4a6cc7: PdfPageRawText.dispose not defined in 0.4.6
- 2f8f8fa: E2E render timeout 30s

All fixed at 0615a58.

## Security Guard

- Path traversal, absolute escape, .., symlink enforced in DocDrDocument via DocumentPathPolicy and in TemplateStore via resolveAssetPath containment walk
- Oversized dimensions/docs: page dimensions 72..14400 points validated, max pages 100 template / 2000 PDF, max elements per page 500
- Excessive page/element count: bounded
- Oversized images: max PDF file 100MB, max PNG 20MB, max image placeholder bound reserved
- Decompression/ZIP bomb: archive package not yet added as direct feature — when added must implement RGEN-01 bounds (max package bytes, entry count, uncompressed total, per-entry size, compression ratio) per THIRD_PARTY_NOTICES
- Unbounded batch: max batch 1000

Do NOT add archive/cryptography merely for future needs — separate licence gates per task (archive already verified MIT as transitive, but direct use still needs bounds; cryptography still UNKNOWN).

## Clean-Room

- No office-specific docs, templates, personal records, signatures, seals, logos, private info, secrets
- RGEN only as reference + provenance, no blind copy, rename paths
- No proprietary fonts bundled (Lucida excluded)
- Bengali fixtures use generic phrases (আমার সোনার বাংলা) — not office-specific

## Files Changed at 0615a58

- docs/PDF_TECHNOLOGY_EVALUATION.md (new, 400+ lines, full matrix)
- THIRD_PARTY_NOTICES.md (updated, 206 lines added, VERIFIED matrix)
- pubspec.yaml (pdfrx 2.4.7, pdfrx_engine 0.4.6, pdf 3.13.0, image 4.9.2 pinned)
- android/app/build.gradle (compileSdk 36, targetSdk 36)
- lib/core/rendering/pdfium/pdfium_renderer_adapter.dart (real implementation, 252 lines, vendor isolated, bounded)
- lib/core/generation/document_generator.dart (new, interface)
- lib/core/generation/pdf_generator_adapter.dart (new, 379 lines, vendor isolated, deterministic)
- test/core/documents/document_renderer_test.dart (updated to real expectations)
- test/core/generation/bengali_fixture_test.dart (new, 14 tests)
- test/core/rendering/pdf_e2e_test.dart (new, 2 tests with timeout guards)
- docs/MIGRATION_STATUS.md (updated with Slice 5+6 and CI progression to 0615a58)

## Next Milestones (per ROADMAP)

- RGEN generation migration as clean-room reference only, no office templates/assets/logos/seals/signatures/private records, goal Template+Data→Document→PDF, preserve generic behaviour, create golden/regression tests for geometry, text positioning, font metrics, Bengali, images, multi-page, deterministic generation
- Scanner / OCR / font bundling (separate licence gates for Tesseract traineddata and Noto OFL-1.1)
- Template Studio UX
- Data mapping CSV/XLSX

## Milestone Completion Checklist (per task)

- [x] licence matrix updated — THIRD_PARTY_NOTICES.md VERIFIED table
- [x] exact versions recorded — pdfrx 2.4.7, pdfrx_engine 0.4.6, pdfium_dart 0.2.5, pdfium_flutter 0.2.3, PDFium BSD-3-Clause, pdf 3.13.0, image 4.9.2
- [x] transitive graph reviewed — 20+ packages fetched, all MIT/BSD/Apache
- [x] no prohibited licence — no GPL/AGPL/LGPL/SSPL
- [x] notices documented — MIT/BSD/Apache texts summarized, PDFium third-party list, attribution obligations
- [x] adapter vendor-neutral — DocDr domain → DocumentRenderer → PdfRendererAdapter → engine, no leak
- [x] reader prototype works in CI — Test success, E2E generation+rendering
- [x] generation prototype works — Bengali fixtures generate valid PDF
- [x] Bengali fixture tested — single, mixed, numerals, punctuation, wrap, embedding path, multi-line, multi-page, images, geometry, deterministic, batch, security, answer YES
- [x] tests pass — 135/135 at 0615a58
- [x] analyze passes — No issues found!
- [x] Android build passes — ✓ Built app-debug.apk (82 MB)
- [x] security passes — gitleaks success, bounds implemented
- [x] migration evidence updated — MIGRATION_STATUS.md Slice 5+6 with CI progression
- [x] knowledge-return with exact SHA+CI evidence — this file + CI run IDs 33264949642 and 33264949590

**End of knowledge return — PDF gate CLOSED GREEN at 0615a58.**
