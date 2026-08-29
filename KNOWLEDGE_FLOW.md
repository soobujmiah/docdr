# DocDr Knowledge Flow & Knowledge Return Contract

## Purpose

DocDr development must remain compatible with the user's knowledge-base governance. Engineering knowledge discovered while building DocDr must be returned to the appropriate knowledge system instead of becoming undocumented tribal knowledge.

## Source-of-truth hierarchy

1. Current DocDr repository state and tests
2. Explicit DocDr documentation/contracts
3. Verified source-project findings used for migration
4. External references/documentation
5. Agent assumptions — never treated as fact

Never invent commit SHAs, test results, compatibility claims, licenses, or completed work.

## Knowledge boundaries

DocDr may inherit technical lessons from RGEN when they are relevant and verified. It must not import unrelated project history, personal knowledge, private records, SKB content, Self AI content, or family/personal information.

RGEN is a technical source/reference only. GGEN, SKB, Self AI, LAI, and other projects remain separate knowledge domains unless an explicit integration contract says otherwise.

## Knowledge return event

After a meaningful milestone, return knowledge with:

- what changed
- why it changed
- verified behavior
- tests/evidence
- architectural decisions
- rejected alternatives when useful
- known limitations
- follow-up work
- exact commit/PR references when available

## Documentation destinations

- `README.md`: product identity and user-facing overview
- `ROADMAP.md`: product phases and release gates
- `ARCHITECTURE.md`: stable architectural contracts
- `MIGRATION_MANIFEST.md`: RGEN-to-DocDr provenance and exclusions
- `docs/`: detailed technical/product documentation
- commit messages: atomic implementation history
- tests: executable behavioral knowledge

## Agent operating rules

Before modifying code, inspect repository truth and relevant documentation.

After modifying code:

1. run the smallest relevant tests;
2. inspect the diff/state;
3. update documentation when behavior or contracts changed;
4. report exact evidence;
5. record unresolved issues rather than hiding them.

Do not copy files in bulk merely because they exist in RGEN. Each migrated component needs a purpose and must pass the cleanliness rules.

## Knowledge return to broader KB

When DocDr reaches a significant milestone, a concise knowledge-return record should be prepared for the user's broader knowledge base. The record should reference DocDr artifacts rather than duplicating large bodies of implementation knowledge.

The canonical project repository remains the detailed technical source. The broader knowledge base stores durable lessons, decisions, relationships, and milestone summaries.

## Anti-duplication rule

Do not maintain the same detailed fact independently in multiple repositories. Link/reference the canonical source where possible. If a fact changes, update the canonical owner first and then return only the necessary summary to dependent knowledge systems.
