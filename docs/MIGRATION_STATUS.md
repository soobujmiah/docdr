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

### Verification commands

```bash
dart test                                    # 68/68 locally (Dart SDK only)
flutter test --reporter expanded             # CI - NOT yet executed
flutter analyze --fatal-infos                # CI - NOT yet executed
dart analyze --fatal-infos lib/core test/core  # local approximation: no issues
```

### CI result — verified on GitHub Actions

Both workflows were executed on push and passed for `c81ac43`:

| Workflow | Job | Result |
|---|---|---|
| CI | Analyze — `flutter analyze --fatal-infos` | **success** |
| CI | Test — `flutter test --reporter expanded` | **success — `00:00 +68: All tests passed!`** |
| Security Scan | Gitleaks secret scan | **success** |

Run URLs:
- CI: https://github.com/soobujmiah/docdr/actions/runs/33258158299
- Security Scan: https://github.com/soobujmiah/docdr/actions/runs/33258158311

The `flutter analyze` job covers the whole repository including `lib/main.dart`,
which could not be analysed locally.

**STILL NOT VERIFIED:** every Android build. The platform folder remains text
scaffolding with `gradle-wrapper.jar` absent; see `android/README.md`. The
Android build is the only part of the foundation with no passing evidence.
