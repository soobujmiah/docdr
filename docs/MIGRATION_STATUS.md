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
| Any further RGEN component | BLOCKED | Per the architectural rule, no further slices until slice 1 has implementation + regression tests + security review + migration evidence. Slice 1 now satisfies this. |

### Verification commands

```bash
dart test                                    # 68/68 locally (Dart SDK only)
flutter test --reporter expanded             # CI - NOT yet executed
flutter analyze --fatal-infos                # CI - NOT yet executed
dart analyze --fatal-infos lib/core test/core  # local approximation: no issues
```

**NOT VERIFIED:** `flutter analyze`, `flutter test`, any Android build, and the
Gitleaks workflow. No Flutter SDK or Android toolchain exists in the
environment where this foundation work was performed; CI must confirm these.
