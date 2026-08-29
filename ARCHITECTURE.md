# DocDr Architecture Contract

## Purpose

DocDr is a local-first Android document workspace. Its primary abstraction is a user-owned document/template workflow, not a fixed collection of institutional forms.

## Layers

```text
Presentation
  ↓
Document Workspace / Scanner / Template Studio / Generator
  ↓
Application Services
  ↓
Template Model + Data Mapping + OCR + Rendering + Storage
  ↓
Platform / Flutter / Android
```

## Template contract

A template defines:

- page geometry/background
- editable elements
- normalized coordinates
- data keys
- formatting/style
- serial/formula rules
- optional metadata

A template must not require a hard-coded organization or document type.

## Data contract

Generation consumes a record map, for example:

```text
student_name -> Rahim
roll -> 1001
issue_date -> 2026-08-29
```

CSV and XLSX adapters map columns into those keys. Single-entry UI produces the same logical record structure.

## Rendering contract

Preserve the proven RGEN behavior where it is generic: vector backgrounds and vector overlays, embedded fonts where appropriate, deterministic page geometry, preview-before-export, and PDF/PNG/JPG output.

## Privacy contract

Local documents remain local by default. No network upload is required for scanning, OCR, template editing, or generation.

## Commercial cleanliness

No office-specific content belongs in the generic engine. User-created templates and documents live in application storage and are never bundled into the public repository.

## Migration principle

RGEN is a technical reference. DocDr owns its own architecture and product identity. Migration should preserve working functionality while removing accidental coupling and obsolete product-specific code.
