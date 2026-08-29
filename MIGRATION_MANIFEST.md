# DocDr Migration Manifest

Source reference: `soobujmiah/rgen`, main tree at source commit `9cd0e0263c80e41b19229932e1f0f57a3f2ed231`.

## Preserve / migrate

The following proven implementation areas are intended for migration after review:

- Flutter Android application foundation
- PDF rendering/preview and printing
- image export
- file picking and local storage
- custom template model/store/editor/generator
- template PDF composition
- OCR services and bundled Bengali/English OCR models, subject to redistribution/license review
- camera scanner integration
- CSV/XLSX import and field mapping
- QR/barcode elements
- encrypted portable template package support
- existing automated tests that cover generic functionality
- CI/build/security patterns after product-specific cleanup

The source repository documents the Custom Template Studio as supporting PDF/image import, camera scanning, offline `eng+ben` OCR, visual field editing, reusable `.rgen` templates, CSV/XLSX batch generation, and local PDF/image export.

## Explicitly exclude

Do **not** migrate the following source-specific assets or functionality into the public DocDr product:

- `assets/certificate_template.pdf`
- `assets/routine_template.pdf`
- `assets/testimonial_template.pdf`
- institutional/government logos and seals
- real signatures
- institutional watermarks/borders
- office-specific sample records
- office-specific document names, labels, defaults, reference numbers, or identities
- certificate/routine/testimonial engines when they exist solely to reproduce those specific office documents
- RGEN/SKB personal knowledge-return material
- unrelated project history or project-specific instructions

Source paths that require explicit asset review include `assets/images/*`, `android_app/assets/images/*`, and `assets/fonts/Lucida-*` before redistribution.

## Required cleanup before release

1. Replace RGEN branding/package identifiers with DocDr branding.
2. Remove all office-specific assets and screens.
3. Remove office-specific models/services/tests and replace them with generic template examples.
4. Verify every bundled font/model/license before commercial redistribution.
5. Rework README and developer documentation around DocDr, not RGEN.
6. Establish a clean test suite for generic document workflows.
7. Keep source RGEN unchanged; DocDr is a separate product repository.

## Safety rule

No source file should be copied merely because it exists in RGEN. Migration is based on demonstrated generic functionality and dependency analysis. Every migrated component must have a documented purpose in DocDr.
