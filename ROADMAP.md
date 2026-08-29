# DocDr Product Roadmap

**Tagline:** Your documents, taken care of.

## North-star product

DocDr is a mobile-first, local-first document workspace for reading, scanning, creating, generating, converting, organizing, and sharing everyday documents.

The product should remain useful without a server. Cloud/team features are optional future capabilities, never a prerequisite for the core workflow.

## Phase 0 — Clean foundation

- Establish DocDr identity and package/application naming.
- Migrate only generic, proven RGEN functionality after file-by-file review.
- Remove office-specific templates, logos, seals, signatures, watermarks, labels, records, and product history.
- Replace source-specific examples with neutral demo assets.
- Audit all dependencies, fonts, OCR models, licenses, and redistribution rights.
- Establish architecture, data contracts, coding rules, documentation, and test strategy.
- Preserve RGEN as an untouched reference repository.

**Exit gate:** clean buildable DocDr repository with no office/private content and documented provenance for migrated components.

## Phase 1 — Commercial MVP

### Document workspace
- Recent documents
- folders/categories
- search
- rename, duplicate, delete
- preview
- share and print

### Reader
- reliable PDF viewing
- image viewing
- document metadata/basic navigation
- graceful handoff for unsupported office formats

### Scanner
- camera capture
- multi-page scanning
- edge detection
- perspective correction
- crop/rotate
- image enhancement
- reorder/remove pages
- scan to PDF/image

### OCR
- offline Bengali + English OCR
- selectable/extractable text where technically reliable
- OCR output feeding template fields

### Template Studio
- import PDF/image
- page canvas
- text/multiline text
- image/logo/photo
- signature/stamp
- date/serial
- checkbox
- QR/barcode
- line/rectangle/ellipse
- alignment, resize, rotate, opacity, layers
- reusable local templates

### Generation
- single record generation
- CSV/XLSX import
- data-key mapping
- batch generation
- PDF/PNG/JPG export
- preview before export

**Exit gate:** a new user can scan or import a blank document, create a reusable template, enter data, generate a correct document, and share/export it without developer involvement.

## Phase 2 — Document power tools

- DOCX/XLSX/PPTX viewing where licensing and rendering quality permit
- PDF page operations: merge, split, reorder, rotate, extract
- image/PDF conversion
- document compression
- richer text extraction
- improved OCR correction workflow
- template duplication/import/export
- encrypted portable template packages
- robust undo/redo
- autosave and recovery

**Exit gate:** DocDr becomes a practical everyday document utility, not only a generator.

## Phase 3 — Professional workflows

- advanced formulas and conditional elements
- data validation
- repeatable sections/tables
- numbering rules
- document presets
- print profiles
- organization branding supplied by the user
- template versioning
- audit/history
- protected templates
- role-based local workspace controls

**Exit gate:** small businesses, schools, offices, and service providers can operate repeatable document workflows with minimal manual formatting.

## Phase 4 — Optional collaboration

Only after the offline product is strong:

- optional account/cloud sync
- organization workspace
- shared templates
- controlled template publishing
- device synchronization
- backup/restore
- team permissions

Privacy principle: cloud is opt-in; local documents remain local unless the user explicitly enables synchronization.

## Phase 5 — Ecosystem

Potential future capabilities:

- template marketplace/library
- public template packs created by users or partners
- API/integration layer
- automation hooks
- business subscriptions
- enterprise/self-hosted deployment
- localized template packs

Marketplace content must be separated from the core engine and moderated/licensed appropriately.

## Release strategy

Do not wait for every phase. Ship the smallest trustworthy product first.

Priority order:

1. Clean migration
2. Build/test stability
3. Scanner + reader
4. Template Studio
5. Generation + batch data
6. File workspace
7. Commercial UX polish
8. Release
9. Power tools
10. Collaboration/ecosystem

## Non-goals for MVP

- general-purpose office-suite replacement
- full word processor
- full spreadsheet editor
- full presentation editor
- mandatory cloud backend
- AI features merely for marketing
- hard-coded institutional document packs

## Success metrics

- time from install to first successful document
- scan-to-template completion rate
- template creation success rate
- generation success rate
- batch generation success rate
- export/share success rate
- crash-free sessions
- average document workflow completion time
- retention of users who create at least one reusable template
