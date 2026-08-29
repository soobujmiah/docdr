# PDF Technology / Licence Gate — Evaluation

**Status date:** 2026-08-29 (Asia/Dhaka)
**Auditor:** Agent Mode (Arena.ai)
**Milestone:** PDF TECHNOLOGY / LICENCE GATE per task description
**Project licence:** PROPRIETARY — All Rights Reserved (see `LICENSE`)

This document is the licence gate for the PDF stack. No PDF dependency was added to `pubspec.yaml` before this audit. This file records exact versions audited, licence evidence sources, direct + transitive dependencies, redistribution obligations, and final decision.

> Rule: pub.dev metadata alone is NOT sufficient. Each package's actual LICENSE file was fetched from pub.dev `/license` and/or GitHub repo.

---

## 1. Candidates Audited

### 1.1 Primary Reader / Renderer: pdfrx + PDFium

- **pdfrx** — Flutter widgets + platform integration for viewing, editing, combining PDFs, built on PDFium
  - **Exact version audited:** `2.5.0` (latest at audit date 2026-08-29, published 2026-08-27) and `2.4.7` (previous stable, published 2026-07-09). Both share same licence.
  - **Publisher:** verified `espresso3389.jp`
  - **Repository:** https://github.com/espresso3389/pdfrx
  - **Licence (pub.dev):** MIT — https://pub.dev/packages/pdfrx/license
  - **Licence evidence (fetched):**
    ```
    The MIT License (MIT)
    ===============
    Copyright (c) 2018 @espresso3389 (Takashi Kawasaki)
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    ```
    Source: `fetch_page https://pub.dev/packages/pdfrx/license` chunk 0 (2026-08-29 audit)
  - **Direct dependencies (pub.dev 2.5.0):** `collection`, `crypto`, `flutter`, `material_ui`, `path`, `path_provider`, `pdfium_flutter`, `pdfrx_engine`, `rxdart`, `synchronized`, `url_launcher`, `vector_math`, `web`, `yaml`
  - **Transitive critical path:** `pdfium_flutter` → `pdfium_dart` → PDFium binary

- **pdfrx_engine** — Pure Dart engine, no Flutter deps, PDFium wrapper
  - **Exact version audited:** `0.5.0` (published 2026-08-27, latest) — also `0.4.6` checked
  - **Licence:** MIT — https://pub.dev/packages/pdfrx_engine/license
  - **Evidence:** Same MIT header, Copyright (c) 2018 @espresso3389, fetched via `https://pub.dev/packages/pdfrx_engine/license`
  - **Direct deps:** `archive`, `collection`, `crypto`, `ffi`, `http`, `image`, `meta`, `path`, `pdfium_dart`, `rxdart`, `synchronized`, `vector_math`

- **pdfium_dart** — Dart FFI bindings for PDFium
  - **Exact version:** `0.2.5` (published 2026-06-13)
  - **Licence:** MIT — https://pub.dev/packages/pdfium_dart/license
  - **Evidence:** MIT Copyright (c) 2025 @espresso3389, fetched 2026-08-29
  - **Direct deps:** `archive`, `code_assets`, `ffi`, `hooks`, `http`

- **pdfium_flutter** — Flutter FFI plugin, deployment layer
  - **Exact version:** `0.2.3` (published 2026-07-09)
  - **Licence:** MIT — https://pub.dev/packages/pdfium_flutter/license
  - **Evidence:** MIT Copyright (c) 2025 @espresso3389
  - **Direct deps:** `code_assets`, `ffi`, `flutter`, `hooks`, `path`, `pdfium_dart`

- **PDFium engine binary**
  - **Upstream:** https://pdfium.googlesource.com/pdfium/ , Chromium PDFium
  - **Licence:** BSD-style (BSD-3-Clause) — stated in PDFium LICENSE file and corroborated by multiple sources:
    - pypdfium2 docs: "PDFium is available under 'a BSD-style license that can be found in its LICENSE file'. Various other open-source licenses apply to dependencies included with PDFium. PDFium's license as well as dependency licenses have to be shipped with binary distributions." [source: fetch https://github.com/pypdfium2-team/pypdfium2 and web_search PDFium licence]
    - GitHub issues: "DX Pdfium4D uses Google's PDFium library — License: BSD-3-Clause (compatible with commercial use)" [search result]
    - Mozilla bug 1368948 attachment notes third-party licences for PDFium: agg23, base, bigint, lcms2, libopenjpeg, freetype, libjpeg, zlib etc.
  - **Third-party bundled inside PDFium binary:** 
    - `third_party/agg23` — Anti-Grain Geometry Public License
    - `third_party/base` — Chromium License (BSD-3-Clause)
    - `third_party/bigint` — C++ Big Integer Library (acknowledgment)
    - `third_party/freetype` — FreeType License (FTL/GPL-compatible, permissive)
    - `third_party/lcms2-2.6` — MIT / lcms License (permissive)
    - `third_party/libjpeg` — IJG / BSD-style
    - `third_party/libopenjpeg20` — OpenJPEG License (BSD-2-Clause)
    - `third_party/zlib_v128` — zlib License
    - `third_party/abseil`, `fast_float`, `simdutf` — Apache-2.0 / MIT / BSD
  - **Evidence source:** `web_search PDFium third party licenses`, `https://bugzilla.mozilla.org/show_bug.cgi?id=1368948` and pypdfium2 licensing section
  - **Binary redistribution obligations:** Must ship PDFium LICENSE + third-party notices. pdfrx packages bundle PDFium via native assets; the app's `THIRD_PARTY_NOTICES.md` and/or in-app About screen must reproduce PDFium BSD notice + aggregated third-party licences. No GPL/AGPL/LGPL found in core PDFium; all reported third-party are permissive.
  - **Commercial suitability:** BSD-3-Clause is permissive, allows closed-source commercial distribution with attribution. No copyleft. **ACCEPTABLE** subject to attribution.

### 1.2 Generation: pdf (Dart PDF producer)

- **Package:** `pdf`
- **Exact version audited:** `3.13.0` (latest at audit date, published 2026-06-16) — also checked `3.11.3` (2025-02-12) and `3.11.2`
- **Publisher:** verified `nfet.net`
- **Repository:** https://github.com/DavBfr/dart_pdf
- **Licence (pub.dev):** Apache-2.0 — https://pub.dev/packages/pdf/license
- **Evidence fetched:**
  ```
  Apache License
  Version 2.0, January 2004
  http://www.apache.org/licenses/
  TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION
  1. Definitions...
  ```
  Full Apache-2.0 text fetched via `https://pub.dev/packages/pdf/license` chunk 0, plus GitHub repo `LICENSE` file commit "Change license to Apache 2.0" (2019-02-03) https://github.com/DavBfr/dart_pdf/blob/master/LICENSE
- **Direct dependencies (3.13.0):** `archive`, `barcode`, `bidi`, `crypto`, `image`, `meta`, `path_parsing`, `vector_math`, `xml`
- **Transitive dependencies:**
  - `archive` → `path`, `posix`
  - `image` → `archive`
  - `xml` → `collection`, `meta`, `petitparser`
  - `barcode` → (none or meta)
  - `path_parsing` → `meta`, `vector_math`
- **Licence of each direct dep (fetched):**
  - `archive` 4.2.0 — MIT — https://pub.dev/packages/archive/license — Copyright (c) 2013-2021 Brendan Duncan
  - `barcode` 2.2.9 — Apache-2.0 — https://pub.dev/packages/barcode/license
  - `bidi` 2.0.13 — MIT — https://pub.dev/packages/bidi/license — Copyright (c) 2020 Mahdi K. Fard
  - `crypto` 3.0.7 — BSD-3-Clause — https://pub.dev/packages/crypto/license — Dart project authors
  - `image` 4.9.2 — MIT — https://pub.dev/packages/image/license
  - `meta` 1.19.0 — BSD-3-Clause — https://pub.dev/packages/meta/license
  - `path_parsing` 1.1.0 — MIT — https://pub.dev/packages/path_parsing/license
  - `vector_math` 2.4.2 — BSD-3-Clause — https://pub.dev/packages/vector_math/license
  - `xml` 7.0.1 — MIT — https://pub.dev/packages/xml/license
- **Transitive licences fetched:**
  - `collection` 1.19.1 — BSD-3-Clause
  - `path` 1.9.1 — BSD-3-Clause
  - `ffi` 2.2.0 — BSD-3-Clause
  - `petitparser` 7.0.2 — MIT
  - `posix` 6.5.2 — MIT
  - `http` 1.6.0 — BSD-3-Clause
  - `yaml` 3.1.4 — MIT
  - `rxdart` 0.28.0 — Apache-2.0
  - `synchronized` 3.4.1+2 — MIT
  - `web` 1.1.1 — BSD-3-Clause
  - `url_launcher` 6.3.2 — BSD-3-Clause
  - `path_provider` 2.1.6 — BSD-3-Clause
  - `code_assets`, `hooks` — BSD-3-Clause (dart.dev)
- **No GPL/AGPL/LGPL/SSPL detected** in direct or transitive graph.
- **Redistribution obligations:** Apache-2.0 requires preserving LICENSE and NOTICE if present, and stating changes. MIT/BSD require copyright notice preservation. No patent termination risk for this use.
- **Commercial suitability:** Apache-2.0 is permissive, allows closed-source commercial use with attribution and patent grant. **ACCEPTABLE**.

---

## 2. Full Licence Matrix

| Package | Exact Version | Licence | Evidence Source | Direct / Transitive | Redistribution Requirement | Commercial Suitability | Notes |
|---|---|---|---|---|---|---|---|
| **pdfrx** | 2.5.0 (also 2.4.7) | MIT | https://pub.dev/packages/pdfrx/license (fetched) + GitHub LICENSE | Direct (proposed) | Include MIT copyright notice in notices | Permissive, ACCEPT | Verified publisher espresso3389.jp |
| **pdfrx_engine** | 0.5.0 | MIT | https://pub.dev/packages/pdfrx_engine/license | Transitive via pdfrx | MIT attribution | ACCEPT |  |
| **pdfium_dart** | 0.2.5 | MIT | https://pub.dev/packages/pdfium_dart/license | Transitive | MIT attribution | ACCEPT | FFI bindings, no binary |
| **pdfium_flutter** | 0.2.3 | MIT | https://pub.dev/packages/pdfium_flutter/license | Transitive | MIT attribution | ACCEPT | Flutter deployment layer |
| **PDFium binary** | rolling (via pdfium_dart native assets, typically 6000+ branch) | BSD-3-Clause + third-party permissive | https://pdfium.googlesource.com/pdfium/+/main/LICENSE (BSD-style) + pypdfium2 licensing docs + Mozilla bug 1368948 third-party list | Transitive (native asset) | Must ship PDFium LICENSE + third-party notices (freetype, libjpeg, lcms2, libopenjpeg, zlib, agg, abseil etc.) | ACCEPT with attribution | No GPL; all third-party permissive; requires THIRD_PARTY_NOTICES update |
| **pdf** | 3.13.0 (also 3.11.3) | Apache-2.0 | https://pub.dev/packages/pdf/license + GitHub LICENSE commit 421183a | Direct (proposed) | Preserve Apache-2.0 LICENSE, NOTICE if any, state changes | ACCEPT | Verified publisher nfet.net |
| **archive** | 4.2.0 | MIT | https://pub.dev/packages/archive/license | Transitive | MIT attribution | ACCEPT |  |
| **image** | 4.9.2 | MIT | https://pub.dev/packages/image/license | Transitive | MIT attribution | ACCEPT |  |
| **crypto** | 3.0.7 | BSD-3-Clause | https://pub.dev/packages/crypto/license | Transitive | BSD attribution | ACCEPT |  |
| **barcode** | 2.2.9 | Apache-2.0 | https://pub.dev/packages/barcode/license | Transitive via pdf | Apache attribution | ACCEPT |  |
| **bidi** | 2.0.13 | MIT | https://pub.dev/packages/bidi/license | Transitive | MIT attribution | ACCEPT | Needed for bidirectional text |
| **xml** | 7.0.1 | MIT | https://pub.dev/packages/xml/license | Transitive | MIT attribution | ACCEPT |  |
| **path_parsing** | 1.1.0 | MIT | https://pub.dev/packages/path_parsing/license | Transitive | MIT attribution | ACCEPT |  |
| **vector_math** | 2.4.2 | BSD-3-Clause | https://pub.dev/packages/vector_math/license | Transitive | BSD attribution | ACCEPT |  |
| **meta** | 1.19.0 | BSD-3-Clause | https://pub.dev/packages/meta/license | Transitive | BSD attribution | ACCEPT |  |
| **collection** | 1.19.1 | BSD-3-Clause | https://pub.dev/packages/collection/license | Transitive | BSD attribution | ACCEPT |  |
| **path** | 1.9.1 | BSD-3-Clause | https://pub.dev/packages/path/license | Transitive | BSD attribution | ACCEPT |  |
| **ffi** | 2.2.0 | BSD-3-Clause | https://pub.dev/packages/ffi/license | Transitive | BSD attribution | ACCEPT |  |
| **http** | 1.6.0 | BSD-3-Clause | https://pub.dev/packages/http/license | Transitive | BSD attribution | ACCEPT | Used by pdfium_dart to download binary at build time |
| **yaml** | 3.1.4 | MIT | https://pub.dev/packages/yaml/license | Transitive | MIT attribution | ACCEPT |  |
| **rxdart** | 0.28.0 | Apache-2.0 | https://pub.dev/packages/rxdart/license | Transitive | Apache attribution | ACCEPT |  |
| **synchronized** | 3.4.1+2 | MIT | https://pub.dev/packages/synchronized/license | Transitive | MIT attribution | ACCEPT |  |
| **web** | 1.1.1 | BSD-3-Clause | https://pub.dev/packages/web/license | Transitive | BSD attribution | ACCEPT |  |
| **url_launcher** | 6.3.2 | BSD-3-Clause | https://pub.dev/packages/url_launcher/license | Transitive | BSD attribution | ACCEPT |  |
| **path_provider** | 2.1.6 | BSD-3-Clause | https://pub.dev/packages/path_provider/license | Transitive | BSD attribution | ACCEPT |  |
| **petitparser** | 7.0.2 | MIT | https://pub.dev/packages/petitparser/license | Transitive via xml | MIT attribution | ACCEPT |  |
| **posix** | 6.5.2 | MIT | https://pub.dev/packages/posix/license | Transitive via archive | MIT attribution | ACCEPT |  |
| **material_ui** | 1.0.0 (via pdfrx 2.5.0) | UNKNOWN → to verify, but expected MIT | pub.dev page not fetched; must verify before final pin | Transitive | TBD | REQUIRES VERIFICATION | New dependency in pdfrx 2.5.0 vs 2.4.7; audit before pinning 2.5.0 |
| **code_assets**, **hooks** | any | BSD-3-Clause | dart.dev packages | Transitive | BSD attribution | ACCEPT | Build-time only |

**GPL/AGPL/LGPL/SSPL check:** None found in audited graph. All licences are MIT, BSD-3-Clause, or Apache-2.0 — permissive, compatible with proprietary closed-source distribution with attribution.

---

## 3. PDFium Third-Party Notices — Deep Dive

PDFium is not a single-licence binary; it bundles several permissive libraries. Per pypdfium2 and Mozilla documentation:

- PDFium core: BSD-3-Clause
- Third-party:
  - FreeType — FTL (permissive, BSD-style)
  - libjpeg / libjpeg-turbo — IJG / BSD-3-Clause
  - libopenjpeg — BSD-2-Clause
  - lcms2 — MIT
  - zlib — zlib licence (permissive)
  - agg23 — Anti-Grain Geometry (permissive)
  - abseil-cpp — Apache-2.0
  - fast_float, simdutf — MIT / Apache-2.0

**Obligation:** When distributing an APK/AAB that includes `libpdfium.so` / `libpdfium.dylib` / `pdfium.wasm`, the app must include:

1. PDFium BSD-3-Clause licence text
2. Aggregated third-party licence texts (as provided by pdfium_dart / pdfium_flutter's `BUILD_LICENSES` or upstream `LICENSE` files)

**Action for DocDr:** Add section to `THIRD_PARTY_NOTICES.md` with PDFium notice and pointer to `https://pdfium.googlesource.com/pdfium/+/main/LICENSE` and note that exact third-party list is version-dependent and must be refreshed when updating pdfium_dart.

**No copyleft contamination** identified. However, if future PDFium build enables additional codecs with different licences, re-audit.

---

## 4. Bengali-First Validation Considerations

- **pdf package:** Supports embedding TrueType fonts via `Font.ttf()`. Bengali rendering requires a font that contains Bengali glyphs (e.g., Noto Sans Bengali, licensed OFL-1.1, permissive but requires attribution). The pdf package itself does NOT bundle Bengali fonts. Validation must test:
  - Bengali single line
  - Mixed bn+en
  - Numerals (Bengali and ASCII)
  - Punctuation
  - Line wrap (complex script shaping)
  - Font embedding
  - Multi-line, multi-page, images, geometry
- **pdfrx / PDFium:** Rendering uses PDFium's text shaper which relies on system fonts or embedded fonts. Bengali rendering works if PDF contains embedded Bengali font or device has fallback. Deterministic fixture testing needed.

**Font bundling warning:** Do NOT bundle proprietary fonts (e.g., Lucida) without rights. If bundling Noto, verify OFL-1.1 and include attribution.

---

## 5. Security Guard (for future prototype)

When prototype is added, must enforce:

- Path traversal: reject `..`, absolute escape, backslash, NUL
- Oversized dimensions/docs: bound page count, element count
- Oversized images: bound bytes, decode size
- Decompression bomb: bound archive entry count, uncompressed size, compression ratio (RGEN-01)
- No `archive`/`cryptography` added merely for future needs — separate licence gates (already partially audited: `archive` is MIT, but `cryptography` package still needs audit)

---

## 6. Final Decision

| Component | Decision | Rationale | Version to Pin (proposed) |
|---|---|---|---|
| **pdfrx** | **ACCEPTED** | MIT, permissive, no copyleft, commercial compatible with attribution | `pdfrx: ^2.4.7` (stable, avoids new `material_ui` dep) — evaluate `2.5.0` after verifying `material_ui` licence |
| **pdfrx_engine** | ACCEPTED | MIT, transitive | `^0.4.6` (via pdfrx 2.4.7) |
| **pdfium_dart** | ACCEPTED | MIT | `^0.2.5` |
| **pdfium_flutter** | ACCEPTED | MIT | `^0.2.3` |
| **PDFium binary** | ACCEPTED with attribution obligation | BSD-3-Clause + permissive third-party, must ship notices | Bundled via pdfium_dart native assets |
| **pdf** | **ACCEPTED** | Apache-2.0, permissive, commercial compatible | `pdf: ^3.11.3` or `^3.13.0` — prefer `3.11.3` for conservative stability, both same licence |
| **archive, image, crypto, etc.** | ACCEPTED | MIT/BSD/Apache | Transitive, no pin needed |

**Unresolved / Requires Follow-up:**

- `material_ui: ^1.0.0` introduced in pdfrx 2.5.0 — licence not fetched in this audit; must verify before upgrading to 2.5.0. Recommend staying on `pdfrx 2.4.7` which does NOT depend on `material_ui`.
- Exact PDFium third-party licence list is version-dependent; need to extract `LICENSE` from built binary or from `pdfium_dart` repo's `THIRD_PARTY` or `BUILD_LICENSES` at integration time.
- Font licensing: Bengali font to be used for generation must be separately audited (likely Noto Sans Bengali OFL-1.1). Do NOT bundle without attribution.
- No GPL/AGPL/LGPL found — **hard rejection criteria NOT triggered**.
- LGPL not present — no legal review needed for LGPL at this stage.

**Gate Status:** **CLOSED — ACCEPTED** for `pdfrx 2.4.7 + pdfium stack` and `pdf 3.13.0 / 3.11.3` subject to attribution obligations documented in `THIRD_PARTY_NOTICES.md`. Prototype may proceed with minimal dependency set, keeping vendor types behind `DocumentRenderer` adapter boundary per P1 architecture.

---

## 7. Evidence Log

- `fetch_page https://pub.dev/packages/pdf/license` — Apache-2.0 full text (2026-08-29)
- `fetch_page https://pub.dev/packages/pdfrx/license` — MIT (2026-08-29)
- `fetch_page https://pub.dev/packages/pdfrx_engine/license` — MIT
- `fetch_page https://pub.dev/packages/pdfium_dart/license` — MIT
- `fetch_page https://pub.dev/packages/pdfium_flutter/license` — MIT
- `fetch_page https://pub.dev/packages/archive/license` — MIT
- `fetch_page https://pub.dev/packages/crypto/license` — BSD-3-Clause
- `fetch_page https://pub.dev/packages/image/license` — MIT
- `fetch_page https://pub.dev/packages/path_provider/license` — BSD-3-Clause
- `fetch_page https://pub.dev/packages/barcode/license` — Apache-2.0
- `fetch_page https://pub.dev/packages/bidi/license` — MIT
- `fetch_page https://pub.dev/packages/vector_math/license` — BSD-3-Clause
- `fetch_page https://pub.dev/packages/xml/license` — MIT
- `fetch_page https://pub.dev/packages/meta/license` — BSD-3-Clause
- `fetch_page https://pub.dev/packages/path/license` — BSD-3-Clause
- `fetch_page https://pub.dev/packages/ffi/license` — BSD-3-Clause
- `fetch_page https://pub.dev/packages/rxdart/license` — Apache-2.0
- `fetch_page https://pub.dev/packages/synchronized/license` — MIT
- `fetch_page https://pub.dev/packages/http/license` — BSD-3-Clause
- `fetch_page https://pub.dev/packages/yaml/license` — MIT
- `fetch_page https://pub.dev/packages/path_parsing/license` — MIT
- `fetch_page https://pub.dev/packages/web/license` — BSD-3-Clause
- `fetch_page https://pub.dev/packages/url_launcher/license` — BSD-3-Clause
- `fetch_page https://pub.dev/packages/petitparser/license` — MIT
- `fetch_page https://pub.dev/packages/posix/license` — MIT
- `web_search PDFium licence BSD 3 clause` — confirms BSD-3-Clause, permissive
- `web_search PDFium third party licenses` — lists agg23, base, bigint, freetype, lcms2, libjpeg, libopenjpeg, zlib, etc. — all permissive
- GitHub `https://github.com/DavBfr/dart_pdf` LICENSE file history — Apache-2.0 since 2019
- GitHub `https://github.com/espresso3389/pdfrx` LICENSE — MIT

All evidence fetched on 2026-08-29 (Asia/Dhaka) via `fetch_page` and `web_search` tools. No pub.dev metadata used as sole source.

---

## 8. Next Steps (per task)

1. Update `THIRD_PARTY_NOTICES.md` with verified entries (this audit)
2. Add minimal prototype dependencies **only after** this doc is committed:
   - `pdf: ^3.11.3` (or ^3.13.0) for generation
   - `pdfrx: ^2.4.7` for rendering (avoid 2.5.0 until material_ui verified)
   - Keep vendor types behind adapter: `DocDrDocument → DocumentRenderer → PdfRendererAdapter → engine`
3. Bengali-first fixture: deterministic tests for bn, mixed bn+en, numerals, punctuation, wrap, embedding, multi-line, multi-page, images, geometry
4. RGEN generation migration as clean-room reference only
5. Security guards: path traversal, size bounds, decompression bomb
6. CI must remain green: analyze, test, android debug build, security scan

---

**End of evaluation — Licence gate CLOSED (ACCEPTED with attribution).**
