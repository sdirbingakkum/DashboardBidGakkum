# Dashboard Bidang Gakkum

Dashboard Sdirbingakkum untuk visualisasi laporan Bidang Gakkum. Data source dianalisis per workbook sebelum dimodelkan dan dimuat ke database.

## Architecture baseline

- GitHub: source code, SQL migrations, tests, and documentation.
- Supabase PostgreSQL: canonical data store, authentication, Row Level Security.
- Cloudflare: application hosting/deployment target (configured in a later implementation step).
- Dashboard is the first application. A separate input application will reuse the same database contract later.

## Locked domain decisions

1. Organization short code/abbreviation is the primary display label throughout the dashboard. The formal name remains available as metadata.
2. POMDAM uses its parent KODAM emblem. Do not create or display a separate POMDAM emblem unless an official requirement is established.
3. Historical report labels/codes remain as aliases; never silently rewrite source nomenclature.
4. Do not assume every KODAM has an active POMDAM.
5. Report counts use the neutral measure `jumlah_tercatat` until the source owner confirms whether a number means incidents, personnel, or another unit.
6. Totals/subtotals should be derived from normalized base data, not stored as duplicate aggregates.
7. Excel import/export must preserve the original report layout and formulas after the relevant workbook format has been fully analyzed.

## Current database foundation

Migration: `20261102093235_create_dashboard_master_foundation`

Master entities:
- organization_types
- organizations
- organization_aliases
- organization_emblems
- personnel_categories
- positions
- position_assignments
- terminology
- master_data_sources
- organization_change_log
- violation_groups
- violation_categories
- reporting_periods
- report_imports
- report_counts

All public tables have RLS enabled. Current policy baseline grants read access to authenticated users only and restricts writes to service-role operations until the authorization roles for operational users are defined.

## Data quality status

- The first analyzed workbook, `Rekap Pelanggaran.xlsx`, is a multi-sheet report, not a flat dataset.
- Its 2026 month/quarter/semester sheets include formula inconsistencies. Store raw source references and validation results during import.
- KODAM candidate directory entries are seeded as `needs_verification`; this is not an assertion that each has a corresponding active POMDAM.
- POMDAM assignments, active status, exact effective dates, and official emblems require unit-by-unit source verification.
- Violation code labels B1-B11 and C1-C6 are provisional source labels and need official wording/legal basis confirmation.

## Next steps

1. Analyze remaining Excel workbooks one at a time.
2. Reconcile authoritative organization structure and POMDAM existence/parent relationships.
3. Confirm report measure semantics and legal basis before accepting report counts.
4. Add migration tests, import validation, and export fidelity tests.
5. Configure application authentication/RLS roles and Cloudflare CI/CD.
