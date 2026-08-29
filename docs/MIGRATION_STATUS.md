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
