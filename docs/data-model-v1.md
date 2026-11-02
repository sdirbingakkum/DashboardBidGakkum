# Data Model v1 — Dashboard Sdirbingakkum

## Scope

This application manages **POMDAM only**. The canonical organization list contains 27 POMDAM units. No separate organization master or hierarchy for another unit type is used by the dashboard, filters, reports, or input application.

## Locked rules

- Canonical identity is a stable UUID; the primary display label is the POMDAM short name.
- Display labels use the `POMDAM` prefix, e.g. `POMDAM I/BB`, `POMDAM XIX/TUTAM`, and `POMDAM JAYA`.
- Each POMDAM emblem must exactly match the emblem paired with the identical territorial name. Store the asset directly against the POMDAM organization row.
- Do not model parent-organization relationships. The old `parent_organization_id` column has been removed.
- The project owner confirmed all 27 POMDAM units exist. The current 27 master rows are therefore active.
- Historical workbook labels remain in `organization_aliases`; retain source labels exactly for import reconciliation.
- PA/BA/TA/PNS are personnel reporting categories, not individual rank records.
- Report counts stay `jumlah_tercatat` until the source owner confirms whether the number means incidents, personnel, or another measure.
- Period and organizational totals are derived from atomic rows.

## Entity map

- `organization_types`: only the POMDAM type.
- `organizations`: the 27 POMDAM units.
- `organization_aliases`: historical/variant source labels.
- `organization_emblems`: official emblem references/assets attached directly to each POMDAM.
- `personnel_categories`: PA, BA, TA, PNS.
- `positions`: position definitions relevant to POMDAM; currently DANPOMDAM.
- `position_assignments`: dated appointment/occupancy history.
- `terminology`: POMDAM-specific glossary entries.
- `master_data_sources`: source evidence for POMDAM naming, appointments, and emblems.
- `organization_change_log`: auditable POMDAM master changes.
- `violation_groups`, `violation_categories`: source-based B/C and B1-B11/C1-C6 hierarchy.
- `reporting_periods`: month/quarter/semester/year calendar.
- `report_imports`: import provenance and validation summary.
- `report_counts`: normalized source observations, including workbook sheet/cell provenance.

## RLS baseline

All tables in `public` have RLS enabled. Authenticated users receive SELECT only. Anonymous users have no table privileges. Writes use trusted server-side/service-role paths until operator, verifier, leadership, and auditor roles have been formally defined. The service-role key must never be exposed to a browser.

## POMDAM master state (2026-11-02)

- 27 unique POMDAM records, all active.
- 1 organization type: POMDAM.
- 0 parent organization relationships.
- 4 source-label aliases from `Rekap Pelanggaran.xlsx`.
- 1 official emblem reference recorded for POMDAM IM; the final image asset register for all POMDAM units remains to be completed from official sources.
- 1 position definition: DANPOMDAM.
- 4 personnel categories.
- 2 violation groups and 17 provisional violation categories.
- 19 reporting periods for 2026.
- 0 report count facts imported until the workbook reconciliation and measure definition are complete.

## First workbook: Rekap Pelanggaran.xlsx (2026)

The workbook is a multi-sheet report, not a flat data table. The source uses a historical list of POMDAM labels and has formula inconsistencies in some monthly/period summary sheets. The import process must retain workbook sheet/cell provenance, preserve all original source aliases, and validate totals before accepting facts.

The workbook's 21 organization labels are not a reason to create 21-only master data or to treat the other six POMDAM units as zero. Only values actually present in the workbook should be imported.

## Open work

1. Complete official emblem assets for the 27 POMDAM units.
2. Confirm whether each report count means incidents, individuals, or another measure.
3. Confirm official wording/legal basis for B1-B11 and C1-C6.
4. Define access roles for operator, verifier, leadership, and auditor.
5. Complete workbook catalogue and Excel export-fidelity requirements.
