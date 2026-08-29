# Third-party notices and redistribution status

**Status date:** 2026-08-29
**Project licence:** PROPRIETARY - all rights reserved (see `LICENSE`).
**Rule:** nothing enters this repository until its redistribution terms are
verified. Unknown stays `UNKNOWN`. `UNKNOWN` is never silently treated as
approved.

## Consequence of the proprietary licence

DocDr is closed-source, so the dependency gate is **stricter than for an
open-source project**:

| Licence class | May it be bundled? |
|---|---|
| Permissive (MIT, BSD-2/3, Apache-2.0, ISC) | Yes, subject to attribution where required |
| Weak copyleft (LGPL, MPL-2.0) | Only with dynamic linking and full compliance; **legal review required before introduction** |
| Strong copyleft (GPL-2.0/3.0, AGPL) | **NO - never** |

This is why the Syncfusion question matters so much: Syncfusion Flutter PDF is
commercial, and commercial licences for closed-source distribution are
typically available but **must be purchased or eligibility confirmed**. Do not
ship it on an assumption.

Apache-2.0 additionally carries an express patent grant and requires
preserving `NOTICE` files; where a dependency ships a `NOTICE` file, its
contents must be reproduced in this file or alongside the distributed
application.

---

## Currently bundled: nothing

DocDr's `pubspec.yaml` deliberately declares **no third-party runtime
dependencies** — no PDF engine, no OCR engine, no bundled fonts, no bundled
models. The only dependencies are the Flutter/Dart SDK and dev-only test
tooling.

This is intentional. RGEN finding **RGEN-07** recorded unresolved licensing
and provenance for exactly the categories DocDr will eventually need. Those
components are held at the gate below until each is verified.

| Dependency | Scope | Licence | Status |
|---|---|---|---|
| Flutter / Dart SDK | runtime | BSD-3-Clause (with components under other permissive licences) | UNVERIFIED |
| `package:test` | dev | Permissive (BSD-family) | UNVERIFIED |
| `flutter_lints` | dev | BSD-3-Clause | UNVERIFIED |

> `UNVERIFIED` here means "very likely permissive and well known, but not
> confirmed in writing during this session". Confirm before the first public
> release; these are dev/build dependencies and do not ship in the APK.

---

## Gate: dependencies awaiting verification before introduction

Each row must be resolved to `VERIFIED` — with the licence text, the source
commit or version, and any attribution or fee requirements recorded — before
the dependency is added to `pubspec.yaml`, `assets/`, or `android/`.

| Component | Needed for | Known concern | Status |
|---|---|---|---|
| **Syncfusion Flutter PDF** | vector PDF rendering/generation | Commercial licence. A community/free tier may exist subject to revenue and headcount eligibility, which **must be confirmed directly with Syncfusion** and is not self-certifying. Bundling it without a licence is a redistribution violation. | **UNKNOWN** |
| **Tesseract / traineddata `eng` + `ben`** | offline Bengali + English OCR | The engine is Apache-2.0; the traineddata files come from a separate upstream repository whose licence must be confirmed for the exact commit used. Do not assume they share the engine's licence. | **UNKNOWN** |
| **Noto / Bengali-capable fonts** | Bengali typography | Commonly SIL Open Font License 1.1, which permits bundling but imposes attribution and reserved-name rules. Confirm the specific family. | **UNKNOWN** |
| **Lucida fonts** | *not needed* | **PROPRIETARY.** Present in RGEN (finding RGEN-07) with no redistribution licence found. **Explicitly excluded — do not migrate under any circumstances.** | **EXCLUDED** |
| **RGEN institutional assets** (certificate/routine/testimonial templates, logos, seals, signatures, watermarks) | *not needed* | Office-specific and potentially authorisation-restricted, not merely copyright-restricted. | **EXCLUDED** |
| **Camera / storage plugins** | scanner, file access | Usually permissive, but each carries Android permissions that must be justified per feature (see below). | **UNKNOWN** |
| **`archive`** (ZIP read/write) | portable `.docdr` template packages | Permissive in practice but unconfirmed. **When this lands it must implement the RGEN-01 bounds**: max package bytes, max entry count, max uncompressed total, max per-entry size and max compression ratio. | **UNKNOWN** |
| **`cryptography`** (AES-GCM, PBKDF2) | encrypted portable packages | Same status. RGEN-09 also requires format governance: encoded version and KDF parameters, and a password policy. | **UNKNOWN** |
| **`path_provider`** | app documents directory | Flutter team plugin, permissive, but unconfirmed. Needed only at the application layer. | **UNKNOWN** |
| **`printing`** / **`image`** | PDF rasterisation, image decode | Unconfirmed. | **UNKNOWN** |

---

## Android permissions

`android/app/src/main/AndroidManifest.xml` declares **no permissions** at the
P0 stage. This is deliberate and pre-empts RGEN finding **RGEN-05**, which
recorded `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`,
`MANAGE_EXTERNAL_STORAGE` and `INTERNET` in RGEN.

Rules for this repository:

- Request only the permission an active feature actually needs.
- **Never** request `MANAGE_EXTERNAL_STORAGE`. It is a Play policy barrier and
  unnecessary for a modern document app; use the Storage Access Framework or
  MediaStore.
- **Never** request `INTERNET` without a documented, user-visible feature that
  needs it. DocDr markets itself as local-first; an unexplained network
  permission contradicts that claim.

---

## Adding a dependency — checklist

1. Identify licence, version, and upstream source URL.
2. Confirm redistribution rights **for a distributed mobile application**,
   not merely for development use.
3. Record it in this file with status `VERIFIED` and the evidence for that
   verdict (URL, licence file, purchase or registration reference).
4. Add the licence text to this file or a `licences/` directory if the licence
   requires attribution.
5. Only then add it to `pubspec.yaml` or `assets/`.

If verification is impossible or unclear, the answer is **defer the feature,
not the diligence**.
