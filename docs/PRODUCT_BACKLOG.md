# DocDr Product Backlog

This backlog converts the roadmap and market research into implementation-sized work. It is intentionally separated from the source RGEN repository.

## P0 — Foundation / migration

- [ ] Establish DocDr Flutter app shell and identifiers.
- [ ] Migrate generic template model.
- [ ] Migrate/adapt local template storage.
- [ ] Migrate/adapt PDF/image template import.
- [ ] Migrate/adapt vector PDF renderer.
- [ ] Migrate generic preview and generation flow.
- [ ] Remove RGEN-specific storage names, paths, branding and sample data.
- [ ] Audit all bundled assets and licenses.
- [ ] Add migration regression fixtures.

## P0 — Golden workflow

- [ ] Import blank PDF/image.
- [ ] Create reusable template.
- [ ] Add text and data fields.
- [ ] Preview generated document.
- [ ] Export valid PDF.
- [ ] Reopen exported PDF in an independent viewer.
- [ ] Persist template and reopen after app restart.

## P1 — Scan + OCR

- [ ] Camera document capture.
- [ ] Multi-page scan.
- [ ] Edge detection/perspective correction.
- [ ] Crop/rotate/enhance.
- [ ] Scan to PDF/image.
- [ ] Offline OCR.
- [ ] Bengali OCR fixture suite.
- [ ] OCR-to-editable-field workflow.

## P1 — Data + batch generation

- [ ] CSV import.
- [ ] XLSX import.
- [ ] Field mapping UI.
- [ ] Single-record generation.
- [ ] Batch generation.
- [ ] Batch error reporting without silent record loss.
- [ ] Generated-file naming rules.

## P1 — Reader / document workspace

- [ ] PDF reader.
- [ ] Image viewer.
- [ ] Recent documents.
- [ ] Search.
- [ ] Rename/duplicate/delete.
- [ ] Folders/categories.
- [ ] Share/print handoff.

## P2 — Everyday PDF tools

- [ ] Merge.
- [ ] Split.
- [ ] Reorder/extract/rotate pages.
- [ ] Compress.
- [ ] Annotate/highlight.
- [ ] Fill and sign.
- [ ] Password protection.
- [ ] Watermark.

## P2 — Office formats

- [ ] Evaluate DOCX rendering options.
- [ ] Evaluate XLSX rendering options.
- [ ] Evaluate PPTX rendering options.
- [ ] Add only when quality and redistribution/licensing are acceptable.

## P2 — Document intelligence

- [ ] Structured field extraction.
- [ ] Document classification.
- [ ] Grounded summary/Q&A.
- [ ] Translation assistance.
- [ ] User-visible extraction confidence/error states.

## P3 — Professional / commercial

- [ ] Template versioning.
- [ ] Protected templates.
- [ ] Advanced formulas/conditional fields.
- [ ] Repeatable table/section elements.
- [ ] Print profiles.
- [ ] Organization branding supplied by users.
- [ ] Audit/history.
- [ ] Backup/restore.

## P3 — Ecosystem

- [ ] Optional sync.
- [ ] Shared templates.
- [ ] Template marketplace.
- [ ] API/integration hooks.
- [ ] Business/enterprise plans.

## Definition of done

A backlog item is not complete because code exists. It is complete when behavior is tested, documentation is updated where needed, privacy/licensing implications are understood, and the repository state provides evidence for the claim.
