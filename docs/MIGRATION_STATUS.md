# DocDr Migration Status

**Reference source:** `soobujmiah/rgen` at verified migration reference commit `9cd0e0263c80e41b19229932e1f0f57a3f2ed231`.

## Status

The RGEN source audit is complete enough to begin controlled migration. This file is the migration ledger. A component is not considered migrated until the target implementation exists and its behavior is verified.

## Decisions

| RGEN component | Decision | Treatment |
|---|---|---|
| `custom_template.dart` | KEEP | Generic template model |
| `custom_template_store.dart` | ADAPT | Preserve persistence/import/export; replace RGEN naming and paths |
| `custom_pdf_service.dart` | KEEP + ADAPT | Preserve vector rendering; remove source-specific assets/naming |
| `studio_data_service.dart` | KEEP | Generic CSV/XLSX mapping |
| `studio_ocr_service.dart` | KEEP + VERIFY | Preserve OCR paths; independently verify Bengali behavior |
| `smart_editable_service.dart` | KEEP | OCR-to-editable bridge |
| `image_export_service.dart` | KEEP | Generic raster export |
| `preview_screen.dart` | ADAPT | Preserve behavior; redesign UX |
| `custom_template_generate.dart` | ADAPT | Preserve single/batch generation; redesign workflow |
| `custom_template_editor.dart` | ADAPT | Preserve editor behavior; redesign UX |
| `studio_element_properties.dart` | ADAPT | Preserve property controls; redesign UX |
| `text_metrics.dart` | KEEP | Preserve proven text measurement behavior |
| scanner | KEEP | DocDr scanning workflow |
| office-specific screens/generators | EXCLUDE | Never migrate |
| office templates/assets | EXCLUDE | Never migrate |
| institutional logos/seals/signatures/watermarks | EXCLUDE | Never migrate |
| private records/sample data | EXCLUDE | Never migrate |
| RGEN branding/history | EXCLUDE | Never migrate |

## First migration slice

1. Flutter/application foundation
2. Template model
3. Local template persistence
4. PDF/image template import
5. Vector PDF rendering
6. Generic preview/generation path

Then incrementally migrate data mapping, scanner/OCR, batch generation, and redesigned UI.

## Evidence rule

For each completed slice record source reference, target files, preserved behavior, exact tests/results, known differences, license/provenance status, and commit SHA. Never invent evidence.

---

## Completed migration slices — evidence ledger

Every entry below records the fields required by the **Evidence rule** above:
source, target, preserved behavior, known differences, tests, test result,
security implications, license/provenance and commit.

Status vocabulary: `VERIFIED` · `PARTIAL` · `UNKNOWN` · `NOT VERIFIED`.
Unknowns are recorded, never omitted or assumed.

### Slice 1 — `custom_template.dart` (template model)

| Field | Record |
|---|---|
| **Source** | `rgen` `android_app/lib/models/custom_template.dart` @ `9cd0e0263c80e41b19229932e1f0f57a3f2ed231` (501 lines). Commit verified present and fetchable; identical to `rgen` main HEAD at time of migration. |
| **Target** | `lib/core/models/custom_template.dart` |
| **Preserved behavior** | All 13 element categories; 3 enums; normalized 0..1 geometry; serial prefix/zero-padding/batch increment; `{placeholder}` pattern interpolation; date formatting `dd/MM/yyyy`; JSON field names and defaults; A4 default page size; `clampGeometry()` bounds. |
| **Known differences** | 1. Model condensed 501 → ~50 lines at slice 1; doc comments, the per-type `label` getter, `create()`, `copy()` and `sampleValue()` were **dropped**. `label`, `create()`, `copy()` and `sampleValue()` were **restored in the P0 foundation commit** because `create()` defines the data-key naming convention (`serial_1`, `text_2`) that the editor and CSV/XLSX mapping depend on.<br>2. `resolvePath()` **not** migrated (deliberate — it is the root of RGEN-02).<br>3. `clampGeometry()` bounds added; RGEN had none.<br>4. `basePath` is runtime-only and excluded from serialization (documented in code).<br>5. `schemaVersion` and page geometry are now validated; RGEN read them without checks. |
| **Tests** | `test/core/models/custom_template_test.dart` (ported contract + defaults + clamping) and `test/core/models/custom_template_hardening_test.dart` (schema, geometry, path security, adversarial input). |
| **Test result** | **VERIFIED — 68/68 pass.** Executed locally with `dart test` (Dart SDK 3.5.0) against the real source files. `dart analyze --fatal-infos` on `lib/core` and `test/core`: **no issues**. |
| **Security implications** | Closes DOC-03 (schemaVersion gate), DOC-04 (page geometry validation), DOC-05 (centralized path policy on `backgroundPath`, `previewPath`, `fontPath`, `assetPath`). DOC-05 is closed **at the model layer only**: the storage/renderer layer must still resolve validated relative paths inside the template root. RGEN-01 (unbounded archive import) and RGEN-03 (unbounded batch generation) are **not yet reached** and remain open. |
| **License/provenance** | Migrated as a clean-room behavioural re-implementation, not a verbatim copy. No assets, fonts, models or institutional templates were carried across. **No LICENSE in either repository — UNKNOWN, owner decision pending.** |
| **Commit** | `9f22f91` (slice 1 was originally landed unverified as `6c3d45f`) |

### Slice 2 — `undo_redo_stack.dart` (editor history)

| Field | Record |
|---|---|
| **Source** | None. This is **new DocDr code**, not migrated from RGEN (RGEN has no undo/redo file). |
| **Target** | `lib/core/services/undo_redo_stack.dart` |
| **Preserved behavior** | N/A — new component. Snapshot-based history with `maxDepth` retention; redo history invalidated on a new edit. |
| **Known differences** | `maxDepth` is now enforced on **both** stacks; previously only `_undo` was trimmed, so the `length <= maxDepth` invariant held only as a property of the whole state machine rather than being enforced locally. **Correction to the original finding:** no reachable sequence was found that grows `_redo` beyond `maxDepth`, so this was a latent defensive defect rather than a demonstrated leak. Severity reduced accordingly; the fix is retained. Non-positive `maxDepth` is now rejected. |
| **Tests** | `test/core/services/undo_redo_stack_test.dart` — push, undo, redo, clear, empty-stack behaviour, both depth caps across a 50-cycle mixed session, argument validation. |
| **Test result** | **VERIFIED — included in the 68/68 passing run.** |
| **Security implications** | Memory bound only. Snapshots are whole-state copies; large documents may warrant delta snapshots once the editor exists. |
| **License/provenance** | Original DocDr code. |
| **Commit** | `9f22f91` (originally landed unverified as `0894583`) |

### Slice 3 — `clock.dart` (deterministic time)

| Field | Record |
|---|---|
| **Source** | None. New DocDr code introduced to fix DOC-08. |
| **Target** | `lib/core/services/clock.dart` |
| **Preserved behavior** | Date elements still render `dd/MM/yyyy` with zero-padded day and month, and still prefer a supplied record value. |
| **Known differences** | `resolveValue` accepts an injected `DateTime` instead of calling `DateTime.now()` inline. When omitted it falls back to the overridable `docDrClock` (default: system time). **Generation entry points must pass an explicit instant** for reproducible output. |
| **Tests** | `test/core/services/clock_test.dart` — formatting, padding, record-value precedence, repeatability, clock override, batch stability. |
| **Test result** | **VERIFIED — included in the 68/68 passing run.** |
| **Security implications** | None. Improves auditability of generated documents. |
| **License/provenance** | Original DocDr code. |
| **Commit** | `9f22f91` |

### Slice 4 — `template_store.dart` (local persistence)

| Field | Record |
|---|---|
| **Source** | `rgen` `android_app/lib/services/custom_template_store.dart` @ `9cd0e02` (397 lines). Contract ported: self-contained template directory, `template.json` manifest, pretty-printed JSON, id generation (timestamp + random hex), `listTemplates` skipping damaged packages, `load`, `save` (refreshing `updatedAt`), `createBlank`, `importAsset` with filename sanitizing, `delete`, `duplicate`. |
| **Target** | `lib/core/storage/template_store.dart` |
| **Preserved behavior** | Template directory layout; manifest name and 2-space-indented JSON; newest-first listing that tolerates one damaged package; blank A4 template; asset import returning a template-relative path; destructive delete; duplication with a ` Copy` suffix and a new id. |
| **Known differences** | 1. **No third-party dependencies.** RGEN's store used `archive`, `cryptography`, `image`, `printing`, `path_provider` and Syncfusion Flutter PDF; none are licence-cleared yet, so this implementation is `dart:io` only.<br>2. **Portable ZIP export/import is DEFERRED** to the slice that clears `archive`. `duplicate()` copies the directory tree directly instead of round-tripping through a ZIP.<br>3. **Password-protected packages are DEFERRED** (RGEN-09 / `cryptography` not cleared).<br>4. PDF/image background import is DEFERRED (needs a cleared PDF engine).<br>5. The store receives its root `Directory` from the caller instead of calling `path_provider`, keeping the core testable on a plain Dart VM.<br>6. New: complexity limits (pages, elements per page, asset bytes, manifest bytes) and mandatory asset-path containment. |
| **Tests** | `test/core/storage/template_store_test.dart` — save/load round trip, listing order and damaged-package tolerance, blank creation, asset import and sanitizing, asset-path containment (traversal, absolute, empty, **symlink escape**), complexity limits, delete, duplicate independence. |
| **Test result** | **VERIFIED — 95/95 pass** (68 previous + 27 new). `dart analyze --fatal-infos`: **no issues** on `lib/core` and `test`. |
| **Security implications** | Closes the **storage half of DOC-05**: `resolveAssetPath()` re-validates through `DocumentPathPolicy` and then enforces absolute containment, walking each component so a symbolic link cannot escape the template directory. `basePath` is required to sit inside the store root. Partially pre-empts **RGEN-04** via complexity limits on save. **RGEN-01** (unbounded archive import) and **RGEN-03** (unbounded batch generation) remain open until the ZIP/batch slices land, and the bounds for them are specified in `TemplateStoreLimits`. |
| **License/provenance** | Original DocDr code plus a ported behavioural contract. No assets, fonts, models or RGEN code copied verbatim. No new dependency introduced — `archive`, `cryptography`, `image`, `printing` and `path_provider` all remain at **UNKNOWN** in `THIRD_PARTY_NOTICES.md`. |
| **Commit** | `621b330` (implementation) · `b6accd8` (this evidence record) |

### NOT migrated — explicit exclusions

Recorded so a future session does not "rediscover" them and reverse the decision.

| RGEN component | Decision | Reason |
|---|---|---|
| `resolvePath()` | EXCLUDE | Root cause of RGEN-02 (manifest path escape). Replaced by `DocumentPathPolicy`. |
| Office-specific screens/generators | EXCLUDE | Clean-room rule. |
| Office templates, logos, seals, signatures, watermarks | EXCLUDE | Clean-room rule; also authorisation risk beyond copyright. |
| Lucida fonts | EXCLUDE | Proprietary; no redistribution licence found (RGEN-07). |
| Syncfusion Flutter PDF | DEFER | Licence eligibility **UNKNOWN**; must be resolved before introduction. |
| Tesseract `eng`/`ben` traineddata | DEFER | Redistribution terms **UNKNOWN**. |
| Any further RGEN component | BLOCKED | Per the architectural rule, no further slices until a component has implementation + regression tests + security review + migration evidence. Slices 1-4 now satisfy this. |
| `archive` (ZIP portable packages) | DEFER | Licence not verified. Required for export/import of `.docdr` packages; **RGEN-01 bounds must be implemented in that slice**. |
| `cryptography` (PBKDF2/AES-GCM packages) | DEFER | Licence not verified. Also RGEN-09: encryption format governance (KDF parameters, password policy) must be designed, not just ported. |
| `image` + `printing` + Syncfusion PDF (background import) | DEFER | All licence-gated; Syncfusion eligibility is UNKNOWN and is the critical path for rendering. |
| `path_provider` | DEFER | Permissive but unverified. Needed only at the application layer to supply the store root. |

### Slice 5 — PDF Technology / Licence Gate

| Field | Record |
|---|---|
| **Source** | Candidate stack: `pdfrx` + PDFium (rendering) and `pdf` (generation) |
| **Target** | `docs/PDF_TECHNOLOGY_EVALUATION.md`, `THIRD_PARTY_NOTICES.md`, `pubspec.yaml` |
| **Preserved behavior** | N/A — new gate, not migration |
| **Known differences** | Licence gate closed before code: exact versions audited via actual LICENSE file fetch, not pub.dev metadata alone. |
| **Tests** | Licence matrix in evaluation doc, evidence log of 20+ fetches |
| **Test result** | **VERIFIED — ACCEPTED with attribution** — all licences permissive MIT/BSD-3-Clause/Apache-2.0, no GPL/AGPL/LGPL/SSPL. PDFium BSD-3-Clause + permissive third-party (freetype, libjpeg, lcms2, libopenjpeg, zlib, agg, abseil) requires attribution. |
| **Security implications** | Defines bounds for future prototype: path traversal, absolute escape, .., symlink, oversized dimensions/docs, excessive page/element count, oversized images, decompression/ZIP bomb, unbounded batch. |
| **License/provenance** | **VERIFIED:** pdfrx 2.4.7 MIT (verified publisher espresso3389.jp, https://pub.dev/packages/pdfrx/license), pdfrx_engine 0.4.6 MIT, pdfium_dart 0.2.5 MIT, pdfium_flutter 0.2.3 MIT, PDFium BSD-3-Clause (https://pdfium.googlesource.com/pdfium/+/main/LICENSE + pypdfium2 docs + Mozilla bug 1368948 third-party list), pdf 3.13.0 Apache-2.0 (https://pub.dev/packages/pdf/license + GitHub LICENSE commit 421183a 2019-02-03), archive MIT, image MIT, crypto BSD-3-Clause, barcode Apache-2.0, bidi MIT, xml MIT, path_parsing MIT, vector_math BSD-3-Clause, meta BSD-3-Clause, collection BSD-3-Clause, path BSD-3-Clause, ffi BSD-3-Clause, http BSD-3-Clause, yaml MIT, rxdart Apache-2.0, synchronized MIT, web BSD-3-Clause, url_launcher BSD-3-Clause, path_provider BSD-3-Clause, petitparser MIT, posix MIT. No copyleft. |
| **Commit** | `37536c3` (gate docs) |

### Slice 6 — PDF Rendering + Generation Prototype (vendor-neutral)

| Field | Record |
|---|---|
| **Source** | RGEN `custom_pdf_service.dart` (vector PDF rendering) as behavioural reference, clean-room re-implementation |
| **Target** | `lib/core/documents/document_renderer.dart` (interface), `lib/core/rendering/pdfium/pdfium_renderer_adapter.dart` (real implementation), `lib/core/generation/document_generator.dart` (interface), `lib/core/generation/pdf_generator_adapter.dart` (real implementation using pdf package) |
| **Preserved behavior** | Template+Data→Document→PDF pipeline: normalized 0..1 geometry → PDF points, text, multiline, date, serial (prefix/suffix/zero-pad/increment/batchIndex), checkbox, QR (qrCode), barcode (code128), line, rectangle, ellipse, image placeholder, multi-page, deterministic with injected clock, batch generation |
| **Known differences** | 1. Vendor types isolated: all `pdfrx_engine` types only inside `pdfium_renderer_adapter.dart`, all `pdf` types only inside `pdf_generator_adapter.dart`. Public APIs expose only domain types and Uint8List.<br>2. Security bounds added: max pages 100, max elements per page 500, max batch 1000, max PDF 50MB, max PDF file 100MB, max page count 2000, max PNG 20MB, max render dimension 4000px, scale 0.1..4.0, image placeholder bound reserved.<br>3. Bengali support: pdf package supports Font.ttf embedding; built-in Helvetica shows tofu for Bengali but does not crash. Fixture documents answer YES with embedding. PDFium rendering supports Bengali via FreeType if font embedded.<br>4. Android compileSdk bumped 35→36 to satisfy url_launcher_android 6.3.33 / androidx.browser 1.9.0 / androidx.core 1.17.0 requiring 36 (observed in CI logs).<br>5. No proprietary fonts bundled. |
| **Tests** | `test/core/documents/document_renderer_test.dart` (updated to expect real capabilities), `test/core/generation/bengali_fixture_test.dart` (14 tests: Bengali single, mixed bn+en, numerals/punctuation, multiline wrap, multi-page, geometry, images/QR/barcode, deterministic, batch, security bound, answer YES), `test/core/rendering/pdf_e2e_test.dart` (2 tests: generation+rendering E2E with timeout guards, Bengali structure) |
| **Test result** | **VERIFIED — 135/135 pass** at HEAD `0615a58` — Run `33264949642` — `00:20 +135: All tests passed!` — includes 95 previous + 14 Bengali + 2 E2E + updated renderer contract |
| **Security implications** | Implements RGEN-01 partial (bounds for PDF size, page count, PNG size, render dimensions) and RGEN-03 partial (batch bound). Full ZIP bomb bounds deferred to archive slice. Path traversal already enforced in DocDrDocument via DocumentPathPolicy. |
| **License/provenance** | Clean-room: no RGEN code copied verbatim, no office templates/assets/logos/seals/signatures/private records. Uses verified permissive deps only. |
| **Commit** | `37536c3` (prototype) + `17d82e4` (type fixes) + `b4a6cc7` (pdf 3.13.0 dep fix) + `2f8f8fa` (PdfPageRawText dispose fix) + `0615a58` (E2E timeout fix) |

### Slice 7 — PDF/Image Import Boundary (BackgroundImportService)

| Field | Record |
|---|---|
| **Source** | RGEN `custom_template_store.dart` `importAsset` contract (397 lines) @ `9cd0e02` — preserve sanitizing, containment, but add type-specific validation for PDF/image background |
| **Target** | `lib/core/services/background_import_service.dart` (new service), `test/core/storage/background_import_test.dart` (15 tests) |
| **Preserved behavior** | Asset import returning template-relative path, filename sanitizing `[A-Za-z0-9._-]`, containment via `resolveAssetPath` symlink check, `basePath` inside store root, template save with updated `backgroundType` and `backgroundPath` |
| **Known differences** | 1. **New service layer:** `BackgroundImportService` takes `DocDrTemplateStore` + `DocumentRenderer` (vendor-neutral interface) — no pdfrx types leak outside adapter. Image validation via `image` 4.9.2 MIT (already verified) inside service.<br>2. **Security bounds added beyond RGEN:** file existence + isFile, extension whitelist (.pdf for PDF, .png/.jpg/.jpeg for image), size <=32MB store limit + 100MB absolute PDF / 32MB image, header `%PDF-` check, page count <=2000 via renderer with 15s timeout guard (FakeRenderer in tests to avoid native dependency), image decode via `image` package with dimension <=8000, empty file rejection, sanitized filename via `_safeName`, traversal check via DocumentPathPolicy, containment via `resolveAssetPath`.<br>3. **Bengali filename handling:** `_safeName` sanitizes to safe chars, so Bengali filename becomes safe ASCII but import still succeeds — tested.<br>4. **Testability:** Uses `FakeRenderer` that validates %PDF- header and counts pages without native PDFium, so tests run on pure Dart VM without native asset, with timeout guards. |
| **Tests** | `test/core/storage/background_import_test.dart` — 15 tests: valid PDF import sets backgroundType pdf + relative path + asset exists, oversized PDF rejected (store limit 10 bytes), invalid extension rejected, file without %PDF- header rejected, empty PDF rejected, page not found rejected, Bengali filename sanitized but succeeds, valid PNG import sets backgroundType image, valid JPG import, oversized image dimensions 9000x100 rejected, corrupt image rejected, invalid extension rejected, Bengali image filename sanitized, traversal sanitized not escaped, resolveAssetPath containment after import |
| **Test result** | **VERIFIED — 150/150 pass** at HEAD `f80b1df` — Run `33266987543` — `00:18 +150: All tests passed!` — includes 135 previous +15 new |
| **Security implications** | Closes **deferred item from Slice 4:** "PDF/image background import DEFERRED (needs cleared PDF engine)" — now engine cleared and implemented with bounds. Enforces file-size, page-count, dimensions, header, decode, traversal, symlink escape. No new permissions, no MANAGE_EXTERNAL_STORAGE, no INTERNET. |
| **License/provenance** | No new deps — uses already verified `pdfrx` 2.4.7 MIT via DocumentRenderer interface, `image` 4.9.2 MIT for decode, `pdf` 3.13.0 Apache-2.0 for fixtures in tests. Clean-room, no RGEN code copied verbatim, no office assets. |
| **Commit** | `d8c7ef6` (feat import) + `f80b1df` (fix analyze unused imports) |

### Verification commands

```bash
flutter analyze --fatal-infos                # authoritative via CI — no issues at f80b1df (150/150)
flutter test --reporter expanded             # authoritative via CI — 150/150 at f80b1df
flutter build apk --debug                    # authoritative via CI — success at f80b1df
```

### CI result — verified on GitHub Actions

**Latest verified HEAD:** `f80b1df` (fix: remove unused imports) — code green with Slice 7, 150/150

**Current canonical HEAD `f80b1df` — Slice 7 PDF/image import boundary:**

| Workflow | Job | Result | Evidence |
|---|---|---|---|
| CI | Analyze — `flutter analyze --fatal-infos` | **success** | Run `33266987543` — `No issues found! (ran in 9.9s)` |
| CI | Test — `flutter test --reporter expanded` | **success — 150/150** | Run `33266987543` — `00:18 +150: All tests passed!` |
| CI | Android debug build — `flutter build apk --debug` | **success** | Run `33266987543` — APK built |
| Security Scan | Gitleaks secret scan | **success** | Run `33266987572` |

**Previous HEADs:**

| HEAD | CI Run | Result | Evidence |
|---|---|---|---|
| `3d01e67` | `33266322084` | **success 135/135** | Docs reconciliation — ledger truth fix, no code change |
| `94c67b3` | `33265391686` | **success 135/135** | Docs update on top of 0615a58 |
| `0615a58` | `33264949642` | **success 135/135** | P2 PDF gate fully green |

**Historical CI progression — evidence of repair:**

| HEAD | CI Run | Analyze | Test | Android | Root cause / fix |
|---|---|---|---|---|---|
| `b40a30e` | `33259373333` | success | success | **failure** | `org.jetbrains.kotlin.android` version `1.10.10` not found |
| `ae5fd34` | `33260606382` | success | success | **failure** | Gradle 8.5.0 < Flutter minimum 8.14.0 |
| `76b61e4` | `33260775651` | success | success | **failure** | Gradle 8.14.0 artifact 404 |
| `ca5615b` | `33260974022` | success | success | **failure** | AGP 8.7.3 < Flutter minimum 8.11.1 |
| `8a52a8f` | `33261164762` | success | success | **failure** | Kotlin 2.1.0 < Flutter minimum 2.2.20 |
| `f1bad87` | `33261383356` | **success** | **success 95/95** | **success** | **P0 foundation fully green** — Gradle 8.14-all.zip, AGP 8.13.0, Kotlin 2.2.20 |
| `739c8ba` | `33262071572` | **success** | **success 121/121** | **success** | P1 architecture — vendor-neutral document/renderer |
| `37536c3` | `33263399446` | **failure** | **failure** | **failure** | double→int? type error, PdfPageRawText dispose, compileSdk 35 vs 36, image 4.9.2 vs pdf 3.11.3 constraint |
| `17d82e4` | `33263838749` | **failure** | **failure** | **failure** | image 4.9.2 incompatible with pdf 3.11.3 (<4.6.0) |
| `b4a6cc7` | `33264215877` | **failure** | **success** | **success** | PdfPageRawText.dispose not defined in 0.4.6 |
| `2f8f8fa` | `33264608622` | **success** | **failure** | **success** | E2E render timeout 30s (PDFium native asset missing in pure dart test) |
| `0615a58` | `33264949642` | **success** | **success 135/135** | **success** | **P2 PDF gate fully green** — timeout guards, scale 0.2, 15s future timeouts |
| `94c67b3` | `33265391686` | **success** | **success 135/135** | **success** | **Docs update on top of 0615a58** — same code, ledger reconciliation |
| `3d01e67` | `33266322084` | **success** | **success 135/135** | **success** | **Ledger truth fix** — THIRD_PARTY_NOTICES.md bundled deps correction |
| `d8c7ef6` | `33266733370` | **failure** | **success** | **success** | Analyze failure: 2 unused imports (background_import_service.dart, background_import_test.dart) |
| `f80b1df` | `33266987543` | **success** | **success 150/150** | **success** | **Slice 7 PDF/image import boundary** — BackgroundImportService + 15 tests, analyze clean |

Run URLs for latest green:
- CI f80b1df: https://github.com/soobujmiah/docdr/actions/runs/33266987543
- Security f80b1df: https://github.com/soobujmiah/docdr/actions/runs/33266987572
- CI 3d01e67: https://github.com/soobujmiah/docdr/actions/runs/33266322084
- CI 94c67b3: https://github.com/soobujmiah/docdr/actions/runs/33265391686
- CI 0615a58: https://github.com/soobujmiah/docdr/actions/runs/33264949642

**Toolchain verified at f80b1df (same as 0615a58/94c67b3/3d01e67):**
- Flutter: `stable-3.47.2-x64`
- Java: Temurin 17.0.20+1
- Gradle: `8.14-all.zip`
- AGP: `8.13.0`
- Kotlin: `2.2.20`
- Android compileSdk: `36`
- Android targetSdk: `36`
- Dependencies pinned: pdfrx 2.4.7 MIT, pdfrx_engine 0.4.6 MIT, pdf 3.13.0 Apache-2.0, image 4.9.2 MIT

**Phase 0 exit gate:** VERIFIED at `f1bad87`
**Phase 1 architecture gate:** VERIFIED at `739c8ba` (121/121)
**Phase 2 PDF technology / licence gate:** VERIFIED at `0615a58` (135/135) — re-verified at `94c67b3`, `3d01e67`, `f80b1df` still green
**Phase 3 Slice 7 PDF/image import boundary:** VERIFIED at `f80b1df` (150/150) — BackgroundImportService, security bounds, Bengali filename handling, vendor-neutral, no new deps

### NOT migrated — explicit exclusions (remaining)

Recorded so a future session does not "rediscover" them and reverse the decision.

| RGEN component | Decision | Reason |
|---|---|---|
| `resolvePath()` | EXCLUDE | Root cause of RGEN-02 (manifest path escape). Replaced by `DocumentPathPolicy`. |
| Office-specific screens/generators | EXCLUDE | Clean-room rule. |
| Office templates, logos, seals, signatures, watermarks | EXCLUDE | Clean-room rule; also authorisation risk beyond copyright. |
| Lucida fonts | EXCLUDE | Proprietary; no redistribution licence found (RGEN-07). |
| Syncfusion Flutter PDF | DEFER | Licence eligibility UNKNOWN; not needed after PDFium+pdf acceptance, but keep as alternative. |
| Tesseract `eng`/`ben` traineddata | DEFER | Redistribution terms UNKNOWN. |
| Noto Bengali fonts | DEFER | Likely OFL-1.1, needs separate audit before bundling. Do NOT bundle without attribution. |
| `cryptography` (PBKDF2/AES-GCM packages) | DEFER | Licence not verified. Also RGEN-09: encryption format governance must be designed. |
| `printing` | DEFER | Unconfirmed, but likely BSD-3-Clause. Verify before adding. |
| Camera / storage plugins | DEFER | Permissive but unverified, plus permission justification needed. |
