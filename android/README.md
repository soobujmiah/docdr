# Android platform folder - READ BEFORE BUILDING

**Status: UNVERIFIED.** This folder was authored as text scaffolding during the
P0 foundation work in an environment with no Flutter SDK, so it has **not** been
built.

## Known gap

`android/gradle/gradle-wrapper.jar` is a **binary artifact** that cannot be
authored by hand. It is therefore absent, and Gradle builds will fail until it
exists.

## Canonical fix (run once, on a machine with the Flutter SDK)

```bash
flutter create --platforms=android .
```

This regenerates the wrapper, `gradlew`/`gradlew.bat`, and canonicalises every
file in this folder. Prefer its output over anything hand-written here.

## What was intentionally decided here (keep these)

- **Zero Android permissions declared.** This pre-empts RGEN finding RGEN-05.
  Do not add `MANAGE_EXTERNAL_STORAGE` or `INTERNET` without re-reading
  `THIRD_PARTY_NOTICES.md`.
- **Application ID `com.soobujmiah.docdr`** - DocDr branding, not RGEN's.
- **Release signing is explicitly not configured.** RGEN finding RGEN-06
  recorded debug-signed release builds. Configure a real keystore and enable
  minification before any public release; the inline comment in
  `app/build.gradle` marks the spot.
- **No launcher icon.** No `android:icon` is declared because the mipmap assets
  do not exist yet; add them with `flutter_launcher_icons` or by hand, then set
  the attribute.

## Verification required before trusting this folder

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```
