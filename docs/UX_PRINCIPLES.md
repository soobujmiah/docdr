# DocDr UX Principles

## Product promise

**Your documents, taken care of.**

The interface should make the next useful document action obvious without requiring users to understand templates, OCR, PDF internals, or data schemas.

## Primary navigation

- Documents
- Scan
- Templates
- Create
- Recent

## Golden path

For repeatable documents:

**Scan/Import → Clean → Template → Data → Preview → Generate → Share**

For ordinary documents:

**Open → Read → Organize → Act**

## Rules

1. Prefer task language over engineering terminology.
2. Show destructive actions only with clear confirmation/recovery.
3. Preserve user work automatically where practical.
4. Keep batch operations visible and explain failures per record.
5. Make offline/local behavior understandable.
6. Never silently upload document contents.
7. Keep templates portable and user-owned.
8. Avoid hard-coded institutional examples.
9. Optimize the first successful document workflow before adding advanced features.
10. Accessibility and Bengali typography are first-class considerations.

## Commercial polish checklist

- Consistent typography and spacing.
- Empty states explain the next action.
- Loading states identify what is being processed.
- Errors explain what the user can do next.
- Preview is available before irreversible export/share actions.
- Long-running scans/OCR/generation show progress.
- Large batch jobs remain cancellable where technically safe.
- Generated output names are predictable.
