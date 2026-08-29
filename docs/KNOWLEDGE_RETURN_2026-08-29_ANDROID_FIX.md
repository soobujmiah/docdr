# Knowledge return — P0 Android build gate repair

**Milestone:** Android debug build becomes green — P0 foundation fully verified
**Date:** 2026-08-29
**HEAD:** `f1bad87` (fix: bump Kotlin to 2.2.20)
**Previous HEAD audited:** `b40a30e` (canonical Android scaffold, but CI failure)
**Score:** 95/95 tests, analyze clean, Android debug APK builds, gitleaks clean
**Licence:** PROPRIETARY - all rights reserved

This record follows `KNOWLEDGE_FLOW.md`: after a meaningful milestone, return what changed, why, verified behaviour, evidence, decisions, known limitations and follow-up.

---

## 1. What was changed — recovery from b40a30e failure

**Context from recovery audit `docs/RECOVERY_AUDIT_2026-08-29.md`:**
- At `b40a30e`, previous agent ran `flutter create --platforms=android .` to replace hand-authored Android scaffold with canonical Flutter one, removed bogus `test/widget_test.dart`, added Android debug build job to CI.
- CI at `b40a30e` (run `33259373333`) failed: `Plugin [id: 'org.jetbrains.kotlin.android', version: '1.10.10', apply: false] was not found` — version `1.10.10` does not exist in Maven Central / Gradle Plugin Portal.
- Agent stopped after push, before fixing toolchain.

**Repair sequence — 5 commits, each small and evidence-driven:**

1. `ae5fd34` — `fix(android): correct Kotlin version and Gradle wrapper for AGP 8.1.0`
   - `settings.gradle`: `1.10.10` -> `2.1.0`
   - `build.gradle`: `ext.kotlin_version` `1.10.10` -> `2.1.0`
   - `gradle-wrapper.properties`: `7.6.3` -> `8.5` (AGP 8.1.0 requires Gradle 8.0+)
   - CI `33260606382` still failed: Gradle 8.5.0 < Flutter minimum 8.14.0

2. `76b61e4` — `fix(android): bump Gradle to 8.14.0 and AGP to 8.7.3`
   - Gradle `8.5` -> `8.14.0`
   - AGP `8.1.0` -> `8.7.3`
   - CI `33260775651` failed: Gradle 8.14.0 artifact 404 — `https://services.gradle.org/distributions/gradle-8.14.0-all.zip` redirects to GitHub `.../v8.14.0/gradle-8.14.0-all.zip` which returns 404. Verified via `curl -I`.

3. `ca5615b` — `fix(android): use Gradle 8.14 distribution (not 8.14.0)`
   - `8.14.0-all.zip` -> `8.14-all.zip`
   - Verified: `curl -L https://services.gradle.org/distributions/gradle-8.14-all.zip` -> 200 via release-assets, while `8.14.0-all.zip` -> 404.
   - CI `33260974022` failed: AGP 8.7.3 < Flutter minimum 8.11.1

4. `8a52a8f` — `fix(android): bump AGP to 8.13.0`
   - AGP `8.7.3` -> `8.13.0` (requires Gradle 8.14+, we have 8.14, satisfies minimum 8.11.1)
   - CI `33261164762` failed: Kotlin 2.1.0 < Flutter minimum 2.2.20

5. `f1bad87` — `fix(android): bump Kotlin to 2.2.20`
   - Kotlin `2.1.0` -> `2.2.20` in both `settings.gradle` and `build.gradle`
   - CI `33261383356` **success** — all three jobs green, Security Scan `33261383445` success.

**Final toolchain at f1bad87 — VERIFIED:**

| Component | Version | Source | Verification |
|---|---|---|---|
| Flutter | `stable-3.47.2-x64` | `subosito/flutter-action@v2` cache key `flutter-linux-stable-3.47.2-x64-...` | CI log |
| Java | Temurin 17.0.20+1 | `actions/setup-java@v4` | CI log |
| Gradle | `8.14-all.zip` | `android/gradle/wrapper/gradle-wrapper.properties` | `curl -L` 200, CI log shows Gradle task assembleDebug runs |
| AGP | `8.13.0` | `android/settings.gradle` | Above Flutter minimum 8.11.1, CI passes |
| Kotlin | `2.2.20` | `android/settings.gradle` + `android/build.gradle` | Above Flutter minimum 2.2.20 (exact), CI passes |
| Android permissions | zero | `android/app/src/main/AndroidManifest.xml` | No permissions declared at P0, pre-empts RGEN-05 |

**No new runtime dependencies introduced** — `pubspec.yaml` still declares only `flutter` SDK, dev deps `flutter_test`, `test`, `flutter_lints`. Licensing gate stays closed per `THIRD_PARTY_NOTICES.md`.

---

## 2. What was verified

| Claim | Evidence | Status |
|---|---|---|
| Recovery audit created at b40a30e | `docs/RECOVERY_AUDIT_2026-08-29.md` — HEAD b40a30e, working tree clean, 95 tests, analyze green, Android failure root cause with logs | VERIFIED |
| Kotlin 1.10.10 does not exist | Maven Central / Gradle Plugin Portal search, CI log `Plugin ... 1.10.10 was not found` | VERIFIED |
| Gradle 7.6.3 incompatible with AGP 8.1.0 | AGP 8.1.0 requires Gradle 8.0+, verified via compatibility matrix | VERIFIED |
| Gradle 8.14.0 artifact 404 | `curl -I https://services.gradle.org/distributions/gradle-8.14.0-all.zip` -> 307 to GitHub -> 404; `8.14-all.zip` -> 200 | VERIFIED |
| Flutter 3.47.2 minimums | CI logs: Gradle minimum 8.14.0, AGP minimum 8.11.1, Kotlin minimum 2.2.20 | VERIFIED |
| Analyze clean at f1bad87 | CI run `33261383356` Analyze job success — `No issues found!` | VERIFIED |
| Tests 95/95 at f1bad87 | CI run `33261383356` Test job — `00:01 +95: All tests passed!` | VERIFIED |
| Android debug APK builds at f1bad87 | CI run `33261383356` Android job success — `Build Android debug APK success`, artifact `docdr-debug-apk` uploaded | VERIFIED |
| Gitleaks clean at f1bad87 | Security Scan run `33261383445` success | VERIFIED |
| No office content, no secrets | Structure inventory + gitleaks + manual review of android/ files | VERIFIED |
| P0 foundation fully green | All four gates (analyze, test, android, security) success at same HEAD f1bad87 | VERIFIED |

**Phase 0 exit gate:** clean buildable DocDr repository with no office/private content and documented provenance — **VERIFIED** at f1bad87.

---

## 3. What remains unverified / open

- **Release signing:** Not configured, deliberately. RGEN-06 recorded debug-signed release builds; a real keystore is required before first release. `buildTypes.release` still uses `signingConfigs.debug`.
- **Launcher icons:** `android:icon` still default Flutter icon, no custom DocDr icon yet.
- **PDF engine:** No PDF rendering/generation dependency yet — licensing gate open, `THIRD_PARTY_NOTICES.md` UNKNOWN for Syncfusion, Tesseract, fonts.
- **Gradle/AGP future deprecation warnings (non-blocking):**
  - `Warning: Flutter support for your project's Gradle version (8.14.0) will soon be dropped. Please upgrade your Gradle version to a version of at least 9.1.0 soon.`
  - `Warning: Flutter support for your project's AGP version (8.13.0) will soon be dropped. Please upgrade your AGP version to at least 9.0.1 soon.`
  - These indicate Flutter 3.47.2 will eventually require Gradle 9.x and AGP 9.x, but current build is green. Defer upgrade until Flutter stable channel actually requires it, to avoid chasing pre-release.

- **RGEN-01, RGEN-03, RGEN-04 (partial), RGEN-07, RGEN-09:** Still open, deferred to appropriate slices per `MIGRATION_STATUS.md`.

---

## 4. What was intentionally excluded

- No PDF, OCR, font, archive, cryptography, image, printing, path_provider dependencies — all remain UNKNOWN/EXCLUDED per `THIRD_PARTY_NOTICES.md`.
- No `gradle-wrapper.jar` or `gradlew` committed — canonical Flutter `.gitignore` ignores them, Flutter tool regenerates on demand. This was verified against scratch project in b40a30e commit message and is correct.
- No office-specific documents, templates, signatures, seals, logos.
- No secrets, API keys, tokens — gitleaks green.

---

## 5. What should happen next — per priority logic

**P0 — Foundation is now DONE:**

- [x] Establish DocDr Flutter app shell and identifiers
- [x] Migrate generic template model (Slice 1)
- [x] Migrate/adapt local template storage (Slice 4)
- [x] Remove RGEN-specific storage names, paths, branding
- [x] Audit bundled assets and licenses (THIRD_PARTY_NOTICES gate established)
- [x] Build/test stability: analyze + test + android debug build + security all green at f1bad87
- [x] Remove bogus widget_test.dart

**P0 — Golden workflow (next):**

- [ ] Import blank PDF/image — requires PDF engine decision (Syncfusion vs pdf vs pdfrx) with licence verification
- [ ] Create reusable template — model exists, UI does not
- [ ] Add text and data fields — model exists, UI does not
- [ ] Preview generated document — requires vendor-neutral rendering architecture
- [ ] Export valid PDF — requires generation pipeline
- [ ] Reopen exported PDF in independent viewer
- [ ] Persist template and reopen after app restart — storage exists, needs app-level integration with path_provider

**P1 — Next logical slices (in roadmap order):**

1. **Vendor-neutral PDF architecture** — Define `Document`, `DocumentRenderer`, `RenderedPage`, `PdfRendererAdapter` interfaces in `lib/core/documents/` and `lib/core/rendering/` per handoff prompt section 13, with no vendor types in domain. This unblocks reader/rendering without yet adding a dependency.
2. **PDF technology evaluation** — Verify exact licence for `pdfrx` (PDFium) and `pdf` package, inspect transitive deps, ensure no GPL/AGPL, record in THIRD_PARTY_NOTICES.md, prototype Bengali text rendering and font handling, establish golden tests.
3. **Generation pipeline** — Port/adapt `custom_pdf_service.dart` from RGEN with clean-room re-implementation, dependency-free core, adapter for PDF engine.
4. **Scanner/import pipeline** — Define platform-neutral scanner service boundary (already exists in migration/rgen-core branch `3eb985d` but not in main — needs clean-room review before porting).

**Owner decisions pending:**

- Publisher identity: applicationId `com.soobujmiah.docdr` is set, but keystore, Play signing, and organization branding still pending.
- PDF engine choice: `pdfrx` vs `pdf` vs Syncfusion — licence and Bengali rendering are gates.
- Theme system and Settings architecture — defined in handoff sections 18, 17 but not yet implemented.

**Standing discipline:**

- Per-slice evidence in `MIGRATION_STATUS.md` before calling slice complete.
- Never convert UNKNOWN licensing to passing assumption.
- GitHub Actions is authoritative for CI verification — do not depend on local VM for heavy builds.

---

## 6. Evidence commands

```bash
git rev-parse HEAD # f1bad87
git log --oneline -10
curl -H "Authorization: token ***" https://api.github.com/repos/soobujmiah/docdr/actions/runs?per_page=10
curl -L -H "Authorization: token ***" .../runs/33259373333/logs -o /tmp/logs.zip
unzip -p /tmp/logs.zip "0_Android debug build.txt" | grep -A2 "What went wrong"
curl -I https://services.gradle.org/distributions/gradle-8.14.0-all.zip
curl -L https://services.gradle.org/distributions/gradle-8.14-all.zip -o /dev/null -w "%{http_code}"
flutter pub get # via CI
flutter analyze --fatal-infos # CI 33261383356 success
flutter test --reporter expanded # CI 33261383356 95/95
flutter build apk --debug # CI 33261383356 success, artifact uploaded
```

All SHA, test results, CI states from direct evidence, not invented.

---

**Knowledge return completed — P0 foundation fully green at f1bad87, ready for P1 PDF architecture.**
