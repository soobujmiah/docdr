# DocDr

**Your documents, taken care of.**

DocDr is a mobile-first document workspace built around a simple idea: reading, scanning, creating, organizing, and generating documents should be easy and reliable on-device.

## Product direction

DocDr is the clean commercial successor to the working document-generation functionality proven in the RGEN project. RGEN is the implementation reference only; DocDr is a fresh product and repository.

### Core capabilities to preserve

- PDF/image viewing and preview
- Camera document scanning with multi-page capture
- edge detection, perspective correction, crop and enhancement
- offline Bengali + English OCR
- visual custom-template creation
- reusable templates with normalized page coordinates
- text, multiline text, date, serial, image/logo, photo, signature/stamp, checkbox, QR, Code 128 barcode, line, rectangle and ellipse elements
- data keys and placeholder/formula patterns
- CSV/XLSX data mapping
- single and batch document generation
- vector PDF output and PNG/JPG export
- local document/template storage
- sharing and printing
- optional encrypted portable template packages

## Clean-room product rule

DocDr must contain **no office-specific documents, institutional identities, real signatures, seals, watermarks, government logos, private records, sample personal data, or unrelated project knowledge**.

Generic demo assets are allowed only when they are newly created or clearly redistributable.

## Architecture principle

The application is template-agnostic. A template is user data, not application code.

```text
DocDr
├── Document workspace
├── Scanner
├── OCR
├── Template Studio
├── Data mapping
├── Generation engine
├── Preview/export
└── Local storage
```

Specific organizations and document types must never become hard-coded product dependencies.

## Development rule

Preserve working behavior first. Refactor only where needed to remove product-specific coupling, improve reliability, or create a clean commercial UX. Do not rewrite proven engines merely for stylistic reasons.

## Privacy

The default product direction is local-first/offline. Documents, scans, signatures, spreadsheets, OCR text, and templates should not leave the device unless a future feature explicitly requires user-controlled synchronization.

## Status

The repository is being bootstrapped from the proven RGEN functionality and will then be redesigned and polished for commercial release.
