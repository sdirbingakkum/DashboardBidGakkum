# Dashboard Sdirbingakkum

Dashboard untuk visualisasi laporan Bidang Gakkum dengan satu domain organisasi: **POMDAM**.

Data sumber dianalisis per workbook sebelum dimodelkan dan dimuat ke Supabase.

## Architecture

- GitHub: source code, SQL migrations, tests, and documentation.
- Supabase PostgreSQL: canonical data store, authentication, and Row Level Security.
- Cloudflare: application hosting/deployment target.
- Dashboard is the first application. A separate input application will reuse the same POMDAM reporting data model later.

## Locked POMDAM rules

1. Dashboard organization scope is POMDAM only. There is no separate master organization, hierarchy, menu, filter, or reporting dimension for another unit type.
2. The 27 POMDAM records are represented directly in `organizations`.
3. Primary display names use POMDAM abbreviations, for example `POMDAM I/BB`, `POMDAM XIX/TUTAM`, and `POMDAM JAYA`.
4. Each POMDAM emblem must be exactly the emblem associated with the identical territorial name. Emblem records are attached directly to the POMDAM record; no parent organization is modeled.
5. Historical report labels/codes remain aliases; never silently rewrite source nomenclature.
6. Personnel categories PA/BA/TA/PNS are reporting groups, not individual ranks.
7. Report counts use the neutral measure `jumlah_tercatat` until the source owner confirms whether a number means incidents, personnel, or another unit.
8. Totals/subtotals are derived from normalized base data, not stored as duplicate aggregates.
9. Excel import/export must preserve the original report content and workbook form. Normalize the stored facts, but export from an immutable, versioned copy of the original template and write only to mapped input cells.
10. Preserve sheet names/order, merged cells, dimensions, styles, formulas, number formats, print settings, page layout, and source-cell mapping. Never replace formulas with hard-coded totals.
11. All 27 canonical POMDAM units must appear in standardized dashboard views and exports. The first analyzed workbook has historical labels for 21 units; the six newer POMDAM units remain included but show no report/no submitted value for periods without data. Preserve the uploaded workbook unchanged as source evidence. Extend the managed output template to 27 POMDAM while retaining the established workbook design, formatting, worksheet organization, and formula behavior. A missing report is never fabricated as zero.

## Current database foundation

The deployed POMDAM-only scope is captured by:

- `20261102094219_scope_master_to_pomdam_only`
- `20261102094326_finalize_pomdam_assets_and_sources`

Master entities:

- `organization_types` — only POMDAM.
- `organizations` — 27 active POMDAM units.
- `organization_aliases` — historical/source labels.
- `organization_emblems` — one primary emblem/avatar URL linked directly to each of the 27 POMDAM units.
- `personnel_categories` — PA, BA, TA, PNS.
- `positions` — POMDAM position definitions; currently DANPOMDAM.
- `position_assignments` — dated incumbent history.
- `terminology` — POMDAM-specific terms.
- `master_data_sources` — primary source evidence for POMDAM names, appointments, and emblems.
- `organization_change_log` — auditable master-data changes.
- `violation_groups`, `violation_categories` — official B/C and B1-B11/C1-C6 categories; all 17 nomenclature records are verified.
- `reporting_periods` — month/quarter/semester/year calendar.
- `report_imports` — import provenance and validation.
- `report_counts` — normalized report facts.

All public tables have RLS enabled. Authenticated users have SELECT only; anonymous users have no table privileges; writes are restricted to trusted service-role/server-side paths until operational roles are approved. The service-role key must never be exposed to a browser.


## Excel compatibility acceptance rule

The database stores normalized, atomic report facts; the uploaded Excel workbook remains the authoritative output template. Exports must preserve the original workbook's visible form and content: worksheets/order, merged cells, dimensions, styles, formulas, number formats, print setup, page layout, and source-specific labels. Only mapped input cells may be written. Summary formulas must remain formulas, with totals validated before release.

Historical and future months using the same official format must export from the same template version. A changed official format receives a new template version. The standardized output always includes all 27 master POMDAM units. The first analyzed workbook contains historical report labels for 21 units; the six newer units stay in the report structure but show no report/no submitted value for periods without data, not fabricated zeros. Keep the uploaded file unchanged as source evidence, and extend the managed output template to 27 POMDAM while retaining the original design, formatting, worksheet organization, and formula behavior.

This is the locked acceptance contract. The import/export engine and its regression tests are not yet implemented.

## POMDAM emblem/avatar register

The live master has 27 primary emblem references, one for every POMDAM. The older 15 are linked to the official Dinas Sejarah AD directory; the 12 newer-unit images are candidate Commons references and remain explicitly unverified. Each record includes a source URL and notes about attribution or discrepancies.

The `asset_url` currently points to the original external source. The live Supabase project has no Storage bucket or uploaded image objects yet, so these image binaries are not self-hosted by the project. Verify the 12 candidates against direct unit-issued files, then copy approved files into project-controlled Storage. Do not silently mark candidates verified.

## Data quality status

- The first analyzed workbook, `Rekap Pelanggaran.xlsx`, is a multi-sheet report, not a flat dataset.
- Its 2026 month/quarter/semester sheets include formula inconsistencies. Keep raw source references and validation results during import.
- 27 POMDAM units are seeded as active based on the domain confirmation supplied by the project owner. All 27 remain in standardized reporting; a unit without a submitted period report is shown as not reported, not zero.
- Eight source/legacy nomenclature aliases are preserved, including `XIX/TT` → POMDAM XIX/TUTAM. Canonical labels remain unchanged.
- All 27 POMDAM records now have a primary `asset_url`: 15 emblem files are referenced from the official Dinas Sejarah AD Kotama directory and marked `verified`; 12 newer-unit candidate files are referenced from Wikimedia Commons and marked `unverified` pending comparison with official unit-issued files. No generic or newly drawn placeholder is used.
- Violation codes and labels B1-B11 and C1-C6 are the official nomenclature confirmed by the project owner; all 17 database records are marked `verified`. Legal-basis references remain a separate field and will only be populated from authoritative sources.
- No report-count facts have been imported. Metric semantics and formula corrections are still being reconciled.

## Next steps

1. Analyze remaining Excel workbooks one at a time.
2. Verify the 12 newer-unit emblem candidates against direct unit-issued files and move approved binaries into project-controlled Supabase Storage.
3. Confirm report measure semantics and legal basis before accepting report counts.
4. Implement immutable/versioned Excel templates, import validation, and full workbook export-fidelity regression tests.
5. Configure application authentication/RLS roles and Cloudflare CI/CD.
