# Knowledge return — P0 engineering foundation

**Milestone:** DocDr becomes a buildable, testable, evidence-backed repository
**Date:** 2026-08-29
**Commit:** `9f22f91`
**Score:** 68 tests, all passing

This record follows the contract in `KNOWLEDGE_FLOW.md`: after a meaningful
milestone, return what changed, why, verified behaviour, evidence, decisions,
known limitations and follow-up work. It stays **product-specific** — no
personal or cross-project knowledge is copied into DocDr.

---

## 1. What was changed

The repository moved from a specification and migration-planning state to an
engineering foundation.

**Bootstrap**
- Added `pubspec.yaml`, `analysis_options.yaml`, `.gitignore` and the
  `lib/main.dart` application shell, so the project can be resolved, analysed
  and tested.
- Added Android platform scaffolding declaring **zero permissions**.

**Migrated component made verifiable**
- `lib/core/models/custom_template.dart` had been condensed from RGEN's 501
  lines to 50 with **no tests**. Its regression suite now exists
  (`test/core/models/custom_template_test.dart`), porting the behavioural
  contract from `rgen` @ `9cd0e02` and extending it.

**Hardening**
- `lib/core/security/document_path.dart` — one centralized path policy applied
  to `backgroundPath`, `previewPath`, `fontPath` and `assetPath`.
- `schemaVersion` is now read, validated and rejected when unsupported or
  newer; `tryFromJson` handles version mismatch for import UX.
- Page width, height and `sourcePageIndex` are validated and clamped.
- `UndoRedoStack` enforces `maxDepth` in both directions.
- `lib/core/services/clock.dart` — injectable clock replaces a direct
  `DateTime.now()` call inside generation logic.

**Restored behaviour**
- `DocDrElement.create()`, `copy()`, `sampleValue()` and the per-type `label`
  getter were missing from the condensed model. `create()` defines the data-key
  naming convention (`serial_1`, `text_2`) that the Template Studio editor and
  the CSV/XLSX mapping UI depend on, so its absence would have surfaced as a
  design gap during P1 rather than as a test failure.

**Process**
- `.github/workflows/ci.yml` (analyze + test) and `security.yml` (Gitleaks).
- `LICENSE` and `THIRD_PARTY_NOTICES.md`.
- `pubspec.yaml` deliberately declares **no** PDF, OCR or font dependencies —
  they stay behind the licensing gate.

---

## 2. What was verified

| Claim | Evidence | Status |
|---|---|---|
| Core test suite passes | `dart test` → **68/68** | VERIFIED |
| Static analysis clean | `dart analyze --fatal-infos lib/core test/core` → **no issues** | VERIFIED |
| Serial padding, prefix, suffix, batch increment | Ported from `rgen` @ `9cd0e02`; passing | VERIFIED |
| Pattern interpolation incl. unknown-key handling | Passing | VERIFIED |
| JSON round-trip retains pages, layers, styling, order | Passing | VERIFIED |
| Element `create()` defaults (keys, labels, geometry, alignment) | Passing | VERIFIED |
| `schemaVersion` gate: missing / null / newer / unmigratable / unreadable all rejected | Passing | VERIFIED |
| Page geometry: negative, zero, NaN, Infinity rejected; extremes clamped | Passing | VERIFIED |
| Path traversal rejected across all four path fields (15 hostile forms) | Passing | VERIFIED |
| Undo/redo bounded in both directions across 50 mixed cycles | Passing | VERIFIED |
| Deterministic date output under an injected clock | Passing | VERIFIED |
| No credentials or secrets committed | Gitleaks pattern scan of the working tree | VERIFIED |
| `flutter analyze --fatal-infos` passes | GitHub Actions run `33258158299`, Analyze job | VERIFIED |
| `flutter test` passes — **68/68** | GitHub Actions run `33258158299`, Test job: `00:00 +68: All tests passed!` | VERIFIED |
| Gitleaks secret scan passes on full history | GitHub Actions run `33258158311` | VERIFIED |
| `lib/main.dart` passes analysis | Covered by the CI Analyze job (whole repository) | VERIFIED |
| Clean-room rule holds | No office, institutional, signature, seal or personal content | VERIFIED |

**Correction to a prior finding.** DOC-09 originally described the redo stack
as unbounded. Closer analysis during this slice could not construct a
reachable sequence that grows `_redo` beyond `maxDepth`, because every undo
consumes an entry from the already-bounded `_undo` list. The real defect was
that `redo()` added to `_undo` without applying the trim, so the bound held
only as a global property rather than being enforced locally. The fix is
retained and the invariant is now asserted directly; the severity is reduced.

---

## 3. What remains unverified

- **Every Android build.** The platform folder is text scaffolding with the
  `gradle-wrapper.jar` binary absent. Status: **UNVERIFIED**. See
  `android/README.md`. This is the only part of the P0 foundation with no
  passing evidence.
- **Release signing.** Not configured, deliberately. RGEN-06 recorded
  debug-signed release builds; a real keystore is required before any public
  release.

Resolved since the first draft of this record: `flutter analyze`, `flutter
test`, the Gitleaks workflow and analysis of `lib/main.dart` are all now
**verified** on GitHub Actions (runs `33258158299` and `33258158311`) and have
been moved into section 2.

## 4. What was intentionally excluded

- **RGEN's `resolvePath()`** — root cause of RGEN-02. Not reintroduced.
- **All office-specific assets and screens** — clean-room rule.
- **Lucida fonts** — proprietary, no redistribution licence found.
- **Syncfusion Flutter PDF** — licence eligibility UNKNOWN. Deferred.
- **Tesseract `eng`/`ben` traineddata** — redistribution terms UNKNOWN.
  Deferred.
- **RGEN's fourth regression test** (vector renderer → Syncfusion PDF) — cannot
  be ported without the renderer and the licence. It belongs to the renderer
  migration slice.
- **Further RGEN components** — the architectural rule blocks additional slices
  until a component has implementation + regression tests + security review +
  migration evidence. Slice 1 now satisfies this, so the next slice is
  unblocked.
- **A licence grant** — `LICENSE` records the true current position
  (all rights reserved) and the decision the owner must still make. No
  open-source grant has been inferred or implied.

---

## 5. What should happen next

**Immediate — establish the CI gate (do this first, everything else depends on
it)**

1. Run `flutter create --platforms=android .` on a machine with the Flutter
   SDK to canonicalise the Android folder and generate `gradle-wrapper.jar`.
2. Push and let `.github/workflows/ci.yml` run. Confirm `flutter analyze` and
   `flutter test` actually pass. **Until that happens, treat the CI gate as
   unverified.**
3. Add launcher icons, then set `android:icon`.

**Then — the next migration slice, in the order the roadmap sets out**

4. Local template persistence (`custom_template_store.dart` → ADAPT). This is
   where DOC-05's storage-layer half is decided: resolve validated relative
   paths inside the template root, and add the size/entry-count bounds that
   RGEN-01 found missing.
5. PDF/image template import and vector rendering. **Resolve the Syncfusion
   licence question first** — it is the gate on this slice, and the answer may
   change the technical choice.
6. Only then: scanner, OCR, batch generation, editor UI.

**Owner decisions pending**

7. **Licence selection** (blocking for public release). See `LICENSE`.
8. **Publisher identity**: application ID, keystore, and whether DocDr is
   intended for Play distribution.

**Standing discipline**

9. Per-slice evidence records in this file before each migration slice is
   called complete.
10. Never convert an `UNKNOWN` licensing status into a passing assumption.
