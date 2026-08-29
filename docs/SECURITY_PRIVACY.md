# DocDr Security & Privacy Contract

## Default posture

DocDr is local-first. Core document workflows should work without an account or server.

## Sensitive data

Treat the following as sensitive user content:

- scanned pages
- PDF/image documents
- OCR text
- signatures/stamps/photos
- CSV/XLSX datasets
- generated documents
- templates containing personal/business information

## Rules

- Never include real user/office documents in source control.
- Never log document contents, OCR text, passwords, or cryptographic keys.
- Request only the Android permissions required by the active feature.
- Do not upload document contents without an explicit user-controlled feature and disclosure.
- Share/export must be an explicit user action.
- Temporary processing files must have a defined lifecycle and cleanup path.
- Encryption claims require implementation and security review before release marketing.

## Threat areas

- accidental source-control leakage;
- insecure temporary files;
- path traversal during portable template import;
- malicious or malformed PDFs/images;
- untrusted OCR input;
- batch data leakage between records;
- weak password/key handling;
- unintended cloud/telemetry transmission.

## Commercial release requirement

Security-sensitive changes require tests and documented evidence. Unknown behavior is recorded as a limitation rather than marketed as protection.
