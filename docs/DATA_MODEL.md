# DocDr Data Model Contract

## Principle

Templates and documents are user data. They must remain independent from application code and organization-specific assumptions.

## Core entities

### Document

Represents an imported, scanned, generated, or otherwise managed document.

Expected concepts:

- stable local ID
- display name
- source/type
- page count where known
- created/updated timestamps
- local file reference
- optional OCR/text index reference
- optional originating template ID

### Template

Represents a reusable document layout.

Expected concepts:

- stable ID
- user-visible name
- schema/version
- page definitions
- page dimensions
- ordered elements
- data keys
- optional asset references
- creation/update metadata

### Template element

Elements remain generic and extensible. Current proven RGEN element categories include text, multiline text, date, serial, image/logo/photo, signature/stamp, checkbox, QR, Code 128 barcode, line, rectangle and ellipse.

### Dataset / Record

A dataset is a collection of records used for generation. Records may originate from manual entry, CSV, or XLSX.

### Generation job

Represents a single or batch generation operation and should expose success/failure per record where practical.

## Versioning

Persist an explicit schema version for templates and portable packages. Migrations must be deterministic and tested against representative historical fixtures.

## Storage boundary

Application configuration, user documents, templates, generated outputs, caches, and temporary processing files must have separate storage responsibilities. No storage path should contain RGEN-specific names.

## Privacy boundary

Document contents, OCR text, signatures, photos, datasets, and templates are user-controlled data. They must not be bundled into source code, tests, documentation, logs, telemetry, or demo assets unless explicitly synthetic.

## Portability

Portable templates should not depend on absolute device paths. Asset references should be packaged or represented through stable identifiers.

## Security

Sensitive package encryption must use a reviewed standard implementation. Passwords and raw keys must never be persisted in logs or source fixtures.
