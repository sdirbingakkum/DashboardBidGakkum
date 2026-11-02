# Data Model v1 — Dashboard Sdirbingakkum

## Principles

- Canonical identity is a stable UUID. Display labels are short codes.
- Historical naming is captured with aliases and validity dates.
- An organization can change parent or status over time; retain effective dates and change evidence.
- KODAM count must not be equated to active POMDAM count.
- POMDAM displays its parent KODAM emblem. Store emblem assets against the KODAM organization.
- Personnel group PA/BA/TA/PNS is not equivalent to individual rank. Detailed rank master is intentionally deferred until source review.
- Report counts remain `jumlah_tercatat` until reporting semantics are officially settled.
- Period totals and organizational totals are derived from atomic rows.

## Entity map

- `organization_types`: KODAM, POMDAM, POMAD, PUSPOMAD.
- `organizations`: hierarchy and validity.
- `organization_aliases`: historical/variant source labels.
- `organization_emblems`: official emblem asset register; parent Kodam owns the POMDAM display emblem.
- `personnel_categories`: PA, BA, TA, PNS.
- `positions`: stable position definitions.
- `position_assignments`: dated appointment/occupancy for an organization.
- `terminology`: glossary of abbreviations and expanded terms.
- `master_data_sources`: source evidence register.
- `organization_change_log`: auditable changes with source and effective date.
- `violation_groups`, `violation_categories`: source-based category hierarchy B/C and B1-B11/C1-C6.
- `reporting_periods`: month/quarter/semester/year calendar.
- `report_imports`: immutable import provenance and validation summary.
- `report_counts`: normalized source observations, including workbook sheet/cell provenance.

## RLS baseline

All tables in `public` have RLS enabled. Authenticated users receive SELECT only. Writes use trusted server-side/service-role paths until the roles and approval process for operators, reviewers, and leadership have been agreed. The service-role key must never be exposed to a browser.

## Verification flags

`needs_verification` and `unverified` deliberately indicate that candidate directory data is not yet approved for official reporting. Do not promote these automatically.

## First workbook: Rekap Pelanggaran.xlsx (2026)

- 27 KODAM candidates have been staged as `needs_verification` only, based on research of the current 2026 organizational landscape.
- No POMDAM child organizations were auto-created.
- 4 source nomenclature variants from the workbook were preserved as aliases.
- 17 violation labels are captured as provisional source labels.
- 19 periods are seeded: 12 months, 4 quarters, 2 semesters, and 1 year.
- Monthly aggregates noted in the analysis are not loaded into `report_counts` pending workbook-by-workbook semantic and formula reconciliation.

## Open decisions

1. Official confirmation of KODAM/POMDAM organization and parent mapping with effective dates.
2. Exact official wording and legal basis for B1-B11 and C1-C6.
3. Whether each cell represents incidents, individuals, or another reported measure.
4. Role model for operator, verifier, leadership, and auditor.
5. Complete workbook catalogue and output fidelity requirements for Excel exports.
