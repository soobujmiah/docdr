# DocDr Engineering Rules

## Repository truth

The repository, current tests, and documented contracts are authoritative. Never invent implementation status, test results, CI status, versions, or commit references.

## Migration

RGEN functionality is migrated selectively. Preserve proven generic behavior; remove accidental coupling to RGEN and all office-specific content.

## Clean product boundary

No private/office documents, institutional logos, real signatures, seals, watermarks, private records, or unrelated project knowledge may enter DocDr.

## Template architecture

Templates are user-owned data. The engine must not require a particular organization, certificate, routine, testimonial, or other fixed document type.

## Testing

Every migrated or changed generic workflow must have appropriate tests. Prefer regression tests before refactoring proven behavior.

## Change discipline

- Make small, reviewable changes.
- Do not perform broad automated formatting over unrelated pre-existing files.
- Do not run parallel edits against the same file.
- Do not rewrite working code without a measurable reason.
- Keep commits focused and descriptive.

## Dependencies

Every dependency must have a documented purpose. Before release, verify version compatibility, Android requirements, license, and redistribution rights for fonts, OCR models, native components, and bundled assets.

## Security/privacy

Treat documents, OCR output, templates, signatures, and imported spreadsheets as user data. Avoid sensitive logging. Validate imported files. Keep encryption boundaries explicit.

## Commercial release gate

Before public release verify:

- no office-specific assets remain;
- no private data remains;
- branding/package identifiers are DocDr;
- licenses are documented;
- release build succeeds;
- core tests pass;
- scanner/OCR/template/generation workflows are regression-tested;
- privacy behavior matches documentation;
- unsupported inputs fail safely.
