# DocDr 0.1 Release Scope

## Goal

Ship a small, reliable commercial MVP around everyday document work rather than attempting to reproduce the entire RGEN/GGEN surface area.

## MVP workflow

1. Import PDF/image.
2. Browse a local document library.
3. Open a document in a canvas-first workspace.
4. Zoom, pan, rotate and flip without leaving the document view.
5. Create/edit a generic template.
6. Map fields from CSV/XLSX data.
7. Generate a PDF.
8. Save/share the result.

## MVP non-goals

- Office-specific templates.
- Institutional branding or sample records.
- Cloud account dependency.
- AI features that are not necessary for the core workflow.
- Full parity with every RGEN editor feature before first release.

## Quality gates

- No source-specific/private data copied from RGEN.
- Core model serialization round-trips.
- Local storage survives restart.
- Unsupported/empty imports fail safely.
- Generated PDF is readable at normal page scale.
- Editor keeps the document canvas prominent while tools remain accessible.
- CI/build verification must be recorded before release claims.
