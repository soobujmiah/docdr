# Third-party notices and redistribution status

**Status date:** 2026-08-29 (Licence Gate Audit — PDF Stack)
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

Apache-2.0 additionally carries an express patent grant and requires
preserving `NOTICE` files; where a dependency ships a `NOTICE` file, its
contents must be reproduced in this file or alongside the distributed
application.

---

## Currently bundled at HEAD 94c67b3 (code green 0615a58) — P2 PDF gate

At P1 HEAD `739c8ba`, `pubspec.yaml` declared **no third-party runtime dependencies** — only Flutter/Dart SDK and dev-only test tooling. That was intentional for the licence gate: verification precedes introduction.

At P2 HEAD `0615a58` (docs update `94c67b3`), the verified PDF stack **is now bundled** in `pubspec.yaml`:

| Dependency | Exact pinned version at HEAD 94c67b3 | Scope | Licence | Evidence | Status |
|---|---|---|---|---|---|
| `pdfrx` | `2.4.7` | runtime | MIT | https://pub.dev/packages/pdfrx/license + GitHub LICENSE | VERIFIED |
| `pdfrx_engine` | `0.4.6` (transitive via pdfrx 2.4.7) | runtime | MIT | https://pub.dev/packages/pdfrx_engine/license | VERIFIED |
| `pdf` | `3.13.0` (upgraded from 3.11.3 due to image 4.9.2 constraint, same Apache-2.0) | runtime | Apache-2.0 | https://pub.dev/packages/pdf/license + GitHub LICENSE commit 421183a 2019-02-03 | VERIFIED |
| `image` | `4.9.2` (required by pdfrx_engine 0.4.6) | runtime | MIT | https://pub.dev/packages/image/license | VERIFIED |
| Flutter / Dart SDK | SDK | runtime | BSD-3-Clause (with components under other permissive licences) | well-known | UNVERIFIED (to be confirmed before public release, does not ship as third-party) |
| `package:test` | `^1.25.0` | dev | BSD-3-Clause | well-known | UNVERIFIED (dev only) |
| `flutter_lints` | `^5.0.0` | dev | BSD-3-Clause | well-known | UNVERIFIED (dev only) |

> `UNVERIFIED` for SDK/dev means "very likely permissive and well known, but not confirmed in writing during this session". Confirm before first public release; dev deps do not ship in the APK.

**Historical note:** At HEAD `739c8ba`, the note said "PDF stack VERIFIED but NOT yet added". That became outdated at `37536c3` (first prototype) and was resolved at `0615a58` which is CI green with the stack bundled. Current HEAD `94c67b3` is a docs-only update on top of `0615a58` and inherits the same bundled set.

**CI verification for this bundled set:**
- CI `33264949642` (HEAD `0615a58`): Analyze `No issues found!`, Test `135/135 All tests passed!`, Android debug APK built 82 MB
- CI `33265391686` (HEAD `94c67b3`): Analyze success, Test success, Android debug build success
- Security `33264949590` and `33265391713`: success (gitleaks)

---

## VERIFIED: PDF Technology Stack — 2026-08-29 Licence Gate

**Audit date:** 2026-08-29 Asia/Dhaka
**Auditor:** Agent Mode
**Evaluation doc:** `docs/PDF_TECHNOLOGY_EVALUATION.md` (full evidence log)
**Exact versions audited:**
- `pdfrx` 2.5.0 (published 2026-08-27, latest) and 2.4.7 (2026-07-09, proposed pin)
- `pdfrx_engine` 0.5.0 (2026-08-27)
- `pdfium_dart` 0.2.5 (2026-06-13)
- `pdfium_flutter` 0.2.3 (2026-07-09)
- `pdf` 3.13.0 (2026-06-16, latest) and 3.11.3 (2025-02-12, proposed conservative pin)

**Method:** Fetched actual LICENSE file from `https://pub.dev/packages/<pkg>/license` and GitHub repo LICENSE, not just pub.dev metadata. Transitive deps fetched similarly. Evidence logged in evaluation doc.

### Decision: ACCEPTED with attribution

All licences are permissive MIT, BSD-3-Clause, or Apache-2.0. No GPL/AGPL/LGPL/SSPL detected. Compatible with proprietary closed-source commercial distribution provided attribution notices are preserved.

| Package | Version | Licence | Evidence Source | Direct/Transitive | Redistribution Requirement | Commercial | Status |
|---|---|---|---|---|---|---|---|
| pdfrx | 2.4.7 (proposed) / 2.5.0 audited | MIT | https://pub.dev/packages/pdfrx/license + GitHub LICENSE | Direct (proposed) | Include MIT notice | Permissive ACCEPT | VERIFIED |
| pdfrx_engine | 0.5.0 / 0.4.6 | MIT | https://pub.dev/packages/pdfrx_engine/license | Transitive | MIT attribution | ACCEPT | VERIFIED |
| pdfium_dart | 0.2.5 | MIT | https://pub.dev/packages/pdfium_dart/license | Transitive | MIT attribution | ACCEPT | VERIFIED |
| pdfium_flutter | 0.2.3 | MIT | https://pub.dev/packages/pdfium_flutter/license | Transitive | MIT attribution | ACCEPT | VERIFIED |
| PDFium binary | rolling via native assets | BSD-3-Clause + permissive third-party | https://pdfium.googlesource.com/pdfium/+/main/LICENSE (BSD-style) + pypdfium2 licensing + Mozilla bug 1368948 | Transitive native | Must ship PDFium LICENSE + third-party notices (freetype, libjpeg, lcms2, libopenjpeg, zlib, agg, abseil, etc.) | ACCEPT with attribution | VERIFIED |
| pdf | 3.11.3 / 3.13.0 | Apache-2.0 | https://pub.dev/packages/pdf/license + GitHub LICENSE commit 421183a 2019-02-03 | Direct (proposed) | Preserve Apache-2.0 LICENSE, NOTICE if present | ACCEPT | VERIFIED |
| archive | 4.2.0 | MIT | https://pub.dev/packages/archive/license | Transitive | MIT attribution | ACCEPT | VERIFIED |
| image | 4.9.2 | MIT | https://pub.dev/packages/image/license | Transitive | MIT attribution | ACCEPT | VERIFIED |
| crypto | 3.0.7 | BSD-3-Clause | https://pub.dev/packages/crypto/license | Transitive | BSD attribution | ACCEPT | VERIFIED |
| barcode | 2.2.9 | Apache-2.0 | https://pub.dev/packages/barcode/license | Transitive | Apache attribution | ACCEPT | VERIFIED |
| bidi | 2.0.13 | MIT | https://pub.dev/packages/bidi/license | Transitive | MIT attribution | ACCEPT | VERIFIED |
| xml | 7.0.1 | MIT | https://pub.dev/packages/xml/license | Transitive | MIT attribution | ACCEPT | VERIFIED |
| path_parsing | 1.1.0 | MIT | https://pub.dev/packages/path_parsing/license | Transitive | MIT attribution | ACCEPT | VERIFIED |
| vector_math | 2.4.2 | BSD-3-Clause | https://pub.dev/packages/vector_math/license | Transitive | BSD attribution | ACCEPT | VERIFIED |
| meta | 1.19.0 | BSD-3-Clause | https://pub.dev/packages/meta/license | Transitive | BSD attribution | ACCEPT | VERIFIED |
| collection | 1.19.1 | BSD-3-Clause | https://pub.dev/packages/collection/license | Transitive | BSD attribution | ACCEPT | VERIFIED |
| path | 1.9.1 | BSD-3-Clause | https://pub.dev/packages/path/license | Transitive | BSD attribution | ACCEPT | VERIFIED |
| ffi | 2.2.0 | BSD-3-Clause | https://pub.dev/packages/ffi/license | Transitive | BSD attribution | ACCEPT | VERIFIED |
| http | 1.6.0 | BSD-3-Clause | https://pub.dev/packages/http/license | Transitive | BSD attribution | ACCEPT | VERIFIED |
| yaml | 3.1.4 | MIT | https://pub.dev/packages/yaml/license | Transitive | MIT attribution | ACCEPT | VERIFIED |
| rxdart | 0.28.0 | Apache-2.0 | https://pub.dev/packages/rxdart/license | Transitive | Apache attribution | ACCEPT | VERIFIED |
| synchronized | 3.4.1+2 | MIT | https://pub.dev/packages/synchronized/license | Transitive | MIT attribution | ACCEPT | VERIFIED |
| web | 1.1.1 | BSD-3-Clause | https://pub.dev/packages/web/license | Transitive | BSD attribution | ACCEPT | VERIFIED |
| url_launcher | 6.3.2 | BSD-3-Clause | https://pub.dev/packages/url_launcher/license | Transitive | BSD attribution | ACCEPT | VERIFIED |
| path_provider | 2.1.6 | BSD-3-Clause | https://pub.dev/packages/path_provider/license | Transitive | BSD attribution | ACCEPT | VERIFIED |
| petitparser | 7.0.2 | MIT | https://pub.dev/packages/petitparser/license | Transitive | MIT attribution | ACCEPT | VERIFIED |
| posix | 6.5.2 | MIT | https://pub.dev/packages/posix/license | Transitive | MIT attribution | ACCEPT | VERIFIED |

**GPL/AGPL/LGPL/SSPL check:** None found. Hard rejection NOT triggered.

**Unresolved / Requires follow-up before pinning latest:**
- `material_ui: ^1.0.0` introduced in pdfrx 2.5.0 — licence not fetched in this audit; must verify before upgrading. Recommendation: pin `pdfrx: ^2.4.7` which does NOT depend on material_ui.
- PDFium third-party licence list is version-dependent; must extract LICENSES from built binary or from pdfium_dart repo at integration time and include in final app About screen and in this file's appendix.
- Bengali font for generation (e.g., Noto Sans Bengali) requires separate OFL-1.1 audit before bundling. Do NOT bundle proprietary fonts.

**Actual minimal pin at HEAD 94c67b3 / 0615a58 (after this doc) — verified green:**
```yaml
dependencies:
  pdfrx: 2.4.7         # MIT, avoids material_ui dep, includes pdfium_flutter 0.2.3 / pdfium_dart 0.2.5 / PDFium BSD-3-Clause
  pdfrx_engine: 0.4.6  # MIT, transitive, pinned exact to avoid material_ui
  pdf: 3.13.0          # Apache-2.0 — upgraded from 3.11.3 because 3.11.3 requires image <4.6.0 incompatible with image 4.9.2 needed by pdfrx_engine 0.4.6; 3.13.0 supports image ^4.8.0+, same licence
  image: 4.9.2         # MIT, required by pdfrx_engine
```

Historical proposal at gate docs time was `pdf: ^3.11.3` conservative; CI failure `17d82e4` revealed incompatibility with `image 4.9.2`, so bumped to `3.13.0` in `b4a6cc7`, verified green at `0615a58` and `94c67b3`.

### Licence Texts (summarized, full texts in upstream)

**MIT (pdfrx, pdfrx_engine, pdfium_dart, pdfium_flutter, archive, image, bidi, xml, path_parsing, yaml, synchronized, petitparser, posix):**
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

Full text fetched from respective `/license` URLs — see evaluation doc evidence log.

**BSD-3-Clause (crypto, collection, path, ffi, vector_math, meta, web, url_launcher, path_provider, http, etc. — Dart/Flutter team packages):**
> Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. * Neither the name of Google LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

**Apache-2.0 (pdf, barcode, rxdart):**
> Licensed under the Apache License, Version 2.0. You may not use this file except in compliance with the License. You may obtain a copy at http://www.apache.org/licenses/LICENSE-2.0. Requires preservation of LICENSE and NOTICE, patent grant, and stating changes.

**PDFium:**
> Use of this source code is governed by a BSD-style license that can be found in the LICENSE file. (Chromium PDFium LICENSE)
> Third-party: FreeType (FTL), libjpeg (IJG/BSD), libopenjpeg (BSD-2-Clause), lcms2 (MIT), zlib (zlib), agg23 (Anti-Grain Geometry), abseil (Apache-2.0), etc. All permissive, but must be shipped with binary distribution per pypdfium2 licensing note: "PDFium's license as well as dependency licenses have to be shipped with binary distributions."

**Action:** When APK includes libpdfium.so, include PDFium BSD notice + third-party notices in app's About / licences screen and reproduce here in appendix before first public release.

---

## Gate: dependencies awaiting verification before introduction (remaining)

| Component | Needed for | Known concern | Status |
|---|---|---|---|
| **Syncfusion Flutter PDF** | vector PDF rendering/generation | Commercial licence. Community/free tier may exist subject to revenue/headcount eligibility, which must be confirmed directly with Syncfusion and is not self-certifying. Bundling without licence is violation. | **UNKNOWN** — not needed after PDFium+pdf acceptance, but keep as alternative evaluation |
| **Tesseract / traineddata `eng` + `ben`** | offline Bengali + English OCR | Engine Apache-2.0; traineddata files from separate upstream repo whose licence must be confirmed for exact commit. Do not assume same licence. | **UNKNOWN** |
| **Noto / Bengali-capable fonts** | Bengali typography | Commonly OFL-1.1, permits bundling but imposes attribution and reserved-name rules. Confirm specific family. | **UNKNOWN** |
| **Lucida fonts** | *not needed* | **PROPRIETARY.** Present in RGEN (RGEN-07) with no redistribution licence. **Explicitly excluded — do not migrate.** | **EXCLUDED** |
| **RGEN institutional assets** (templates, logos, seals, signatures, watermarks) | *not needed* | Office-specific and potentially authorisation-restricted. | **EXCLUDED** |
| **Camera / storage plugins** | scanner, file access | Usually permissive, but each carries Android permissions that must be justified per feature. | **UNKNOWN** |
| **`cryptography`** (AES-GCM, PBKDF2) | encrypted portable packages | RGEN-09 requires format governance: version, KDF params, password policy. Licence to be verified before introduction. | **UNKNOWN** |
| **`printing`** | PDF rasterisation, printing | Unconfirmed, but likely BSD-3-Clause (Flutter community). Verify before adding. | **UNKNOWN** |

**Note:** `archive` and `path_provider` and `image` moved to VERIFIED as transitive of PDF stack, but their direct use for ZIP packages still requires RGEN-01 bounds implementation when introduced as direct feature.

---

## Android permissions

`android/app/src/main/AndroidManifest.xml` declares **no permissions** at P0/P1 stage. This is deliberate and pre-empts RGEN finding **RGEN-05**, which recorded `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `MANAGE_EXTERNAL_STORAGE` and `INTERNET` in RGEN.

Rules:

- Request only permission an active feature actually needs.
- **Never** request `MANAGE_EXTERNAL_STORAGE`. Play policy barrier.
- **Never** request `INTERNET` without documented user-visible feature. DocDr is local-first.

---

## Adding a dependency — checklist

1. Identify licence, version, upstream URL.
2. Confirm redistribution rights **for a distributed mobile application**, not merely dev use.
3. Record in this file with status `VERIFIED` and evidence (URL, licence file, purchase reference).
4. Add licence text to this file or `licences/` directory if attribution required.
5. Only then add to `pubspec.yaml` or `assets/`.

If verification impossible or unclear, defer feature, not diligence.

---

## Appendix: Evidence Log for PDF Gate (2026-08-29)

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
- fetch_page https://pub.dev/packages/rxdart/license — Apache-2.0 (first chunk)
- fetch_page https://pub.dev/packages/synchronized/license — MIT
- fetch_page https://pub.dev/packages/http/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/yaml/license — MIT
- fetch_page https://pub.dev/packages/path_parsing/license — MIT
- fetch_page https://pub.dev/packages/web/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/url_launcher/license — BSD-3-Clause
- fetch_page https://pub.dev/packages/petitparser/license — MIT
- fetch_page https://pub.dev/packages/posix/license — MIT
- web_search PDFium licence BSD 3 clause — confirms BSD-3-Clause permissive
- web_search PDFium third party licenses — lists agg23, base, bigint, freetype, lcms2, libjpeg, libopenjpeg, zlib etc.
- GitHub https://github.com/DavBfr/dart_pdf LICENSE history — Apache-2.0 since 2019-02-03
- GitHub https://github.com/espresso3389/pdfrx LICENSE — MIT

All fetched 2026-08-29 via fetch_page/web_search. No pub.dev metadata used as sole source. Full evaluation in docs/PDF_TECHNOLOGY_EVALUATION.md.
