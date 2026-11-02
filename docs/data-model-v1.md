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
- `report_counts`, `sim_report_counts`, and `tindak_pidana_report_counts` use neutral `jumlah_tercatat` until the source owner confirms the precise meaning of each source figure.
- Activity-report period and organizational totals are derived from atomic rows. Provos uses point-in-time snapshots and must never be summed across reporting periods.

## Entity map

- `organization_types`: only the POMDAM type.
- `organizations`: the 27 POMDAM units.
- `organization_aliases`: historical/variant source labels.
- `organization_emblems`: one primary emblem/avatar URL per POMDAM, linked directly to the POMDAM record, with source, license/attribution notes, and verification status.
- `personnel_categories`: PA, BA, TA, PNS.
- `positions`: position definitions relevant to POMDAM; currently DANPOMDAM.
- `position_assignments`: dated appointment/occupancy history.
- `terminology`: POMDAM-specific glossary entries.
- `master_data_sources`: source evidence for POMDAM naming, appointments, and emblems.
- `organization_change_log`: auditable POMDAM master changes.
- `violation_groups`, `violation_categories`: official B/C and B1-B11/C1-C6 hierarchy; all 17 labels and codes were confirmed by the project owner on 2026-11-02 and are stored with `verification_status='verified'`.
- `reporting_periods`: month/quarter/semester/year calendar.
- `report_imports`: shared import provenance, validation summary, and `dataset_code` discriminator (`pelanggaran`, `sim`, `laka_lalin`, `provos`, `tindak_pidana`).
- `report_counts`: Pelanggaran facts, including workbook sheet/cell provenance and personnel-group dimension.
- `sim_categories`: reusable SIM category master (A, BI, BII, B II SUS, C), referenced by UUID.
- `sim_report_counts`: SIM facts by month, POMDAM, and SIM category; never mixed into Pelanggaran facts.
- `provos_education_statuses`: reusable Provos education-status master (SUDAH/BELUM).
- `provos_reports`: one personnel-strength snapshot per POMDAM and reporting period, including DSPP and NYATA.
- `provos_rank_counts`: PA/BA/TA detail referencing the shared `personnel_categories` master.
- `provos_education_counts`: SUDAH/BELUM detail referencing `provos_education_statuses`.
- `laka_lalin_accident_types`, `laka_lalin_loss_severities`, `laka_lalin_vehicle_types`, and `laka_lalin_damage_levels`: reusable Laka Lalin reference dimensions.
- `laka_lalin_reports`: monthly report header per POMDAM and period.
- `laka_lalin_report_counts`: atomic Laka Lalin measures by accident type, personnel group, personnel-loss rank/severity, and vehicle damage category.
- `tindak_pidana_categories`: 113 unique source-label entries for the 105 numbered Tindak Pidana items, retaining distinct label variants rather than silently merging them.
- `tindak_pidana_reports`: monthly report header per POMDAM and period, with source POMDAM header coordinate and label.
- `tindak_pidana_report_counts`: atomic count by report, source item number, exact source category label, and shared PA/BA/TA/PNS personnel category.


## RLS baseline

All tables in `public` have RLS enabled. Authenticated users receive SELECT only. Anonymous users have no table privileges. Writes use trusted server-side/service-role paths until operator, verifier, leadership, and auditor roles have been formally defined. The service-role key must never be exposed to a browser.

## POMDAM master state (2026-11-02)

- 27 unique POMDAM records, all active.
- 1 organization type: POMDAM.
- 0 parent organization relationships.
- 8 preserved source/legacy aliases, including the workbook label `XIX/TT` mapped to the canonical POMDAM XIX/TUTAM; aliases retain the original source wording without changing canonical POMDAM identity.
- 27 primary emblem/avatar references, one per POMDAM: 15 linked to files in the official Dinas Sejarah AD Kotama directory and marked verified; 12 newer-unit candidates linked to Wikimedia Commons and explicitly marked unverified pending direct unit confirmation. All 27 have non-empty `asset_url` values.
- 1 position definition: DANPOMDAM.
- 4 personnel categories.
- 2 violation groups and 17 official, verified violation categories (B1-B11 and C1-C6). The codes and labels are kept exactly as confirmed; legal-basis text remains separate and is not invented.
- 19 reporting periods for 2026.
- 12,852 Pelanggaran facts from January–September 2026 are loaded in `report_counts`; total `jumlah_tercatat` = 193.
- 5 reusable SIM category master rows (A, BI, BII, B II SUS, C) and 945 SIM monthly facts from January–September 2026 are loaded; total `jumlah_tercatat` = 7,485. Six POMDAM without source rows remain without facts, not zero.


## POMDAM emblem/avatar register

Every canonical POMDAM has exactly one primary `organization_emblems` record with a non-empty `asset_url`, and a partial unique index prevents more than one primary emblem per POMDAM.

- 15 legacy POMDAM emblems are linked to image files displayed in the official Dinas Sejarah Angkatan Darat Kotama directory. These are stored as `verification_status='verified'`.
- 12 emblems for newer POMDAM XIX–XXX are linked to candidate Wikimedia Commons file pages and marked `unverified`. Source/author/license notes and naming discrepancies are retained. These must be compared with the official unit-provided emblem before being marked verified.
- `asset_url` currently points to the external source host. No logo binary has yet been copied to Supabase Storage; the current database audit shows no Storage bucket or objects. A later asset-hosting step should move only approved files into a project-controlled bucket and update `asset_url` to the managed object URL.
- The old DisjarahAD directory spells Pattimura as XVI/PTM and Hasanuddin as XIV/HSD, and spells Sriwijaya II/SJW. These variants are preserved as aliases. The canonical POMDAM labels remain XV/PTM, XIV/HSN, and II/SWJ; aliases do not alter canonical identity.

This register ensures 27 avatar URLs exist in master data; it does not claim all 27 binary assets are locally hosted or all 27 have been officially re-verified by each unit.

## First workbook: Rekap Pelanggaran.xlsx (2026)

The workbook is a multi-sheet report, not a flat data table. The source uses a historical list of POMDAM labels and has formula inconsistencies in some monthly/period summary sheets. The import process must retain workbook sheet/cell provenance, preserve all original source aliases, and validate totals before accepting facts.

The workbook version analyzed contains report labels for 21 POMDAM units. Its historical source label `XIX/TT` is mapped to POMDAM XIX/TUTAM through `organization_aliases`. The canonical master remains all 27 POMDAM units. Six newer POMDAM units must still appear in normalized dashboard views and standardized exports; where no report has been submitted for a period, show the unit with no reported value/status rather than inventing zero. Preserve the uploaded workbook byte-for-byte as the original source and retain its 21-unit source layout for provenance. The standardized report output uses the full 27-unit master while preserving the workbook's established visual design, section order, formatting, and calculation logic.




## Second workbook: Lam Sim.xlsx (2026)

The SIM report is a separate reporting domain from Pelanggaran. It shares only the canonical POMDAM organization master, organization aliases, reporting calendar, and import-batch registry. SIM categories and SIM facts remain domain-specific.

- `sim_categories` is the reusable master reference for A, BI, BII, B II SUS, and C. Forms and future modules reference the category UUID; they do not retype category labels.
- `sim_report_counts` stores atomic month × POMDAM × SIM-category facts. It does not reuse `report_counts`, violation categories, or personnel categories.
- The January–September 2026 workbook contains 945 atomic facts across 21 POMDAM and five SIM categories. The total is 7,485: A=2,734; BI=1,081; BII=320; B II SUS=118; C=3,232. There are 534 explicit zero values and 411 positive values.
- The monthly sheet totals are JAN=503, FEB=839, MRT=500, APR=689, MEI=606, JUN=1,741, JUL=950, AGU=657, and SEP=1,000.
- TW.1, TW.2, SM-1, and TW.3 are aggregation sheets and are not imported as facts. TW.3 duplicates TW.2 because its formulas still reference April–June; the July–September quarter total must be derived from the monthly records (2,607).
- Two POMDAM-month groups are retained but flagged `unverified` for source-owner review: II/SWJ in June (row total 1,005) and I/BB in September (row total 113). Their source values are not altered.
- The metric meaning remains `jumlah_tercatat`; the workbook does not by itself establish whether the figures mean licenses issued, services performed, or another measure.
- The original workbook binary was not archived at the project owner's instruction. Its SHA-256 fingerprint and all 945 source-cell coordinates are stored with the import batch and facts.



## Third workbook: Rekap Provos.xlsx (2026)

Provos is a point-in-time personnel-strength report, not an additive activity report like Pelanggaran or SIM. Do not sum personnel snapshots across months or semesters to produce an annual headcount.

- The snapshot header stores DSPP and NYATA separately.
- Rank composition is normalized in `provos_rank_counts`, referencing the shared PA/BA/TA rows in `personnel_categories`.
- Education status is normalized in `provos_education_counts`, referencing the dedicated reusable `provos_education_statuses` master containing SUDAH and BELUM.
- Database-level deferred constraints enforce exactly PA/BA/TA and SUDAH/BELUM detail rows, and require both detail sums to equal NYATA at transaction commit.
- The uploaded workbook contains 21 POMDAM in both `BULANAN` and `SMR 1`. The six newer POMDAM remain visible in dashboards without fabricated zero snapshots.
- The `SMR 1` sheet is confirmed as Semester I TA 2026 and is linked to the existing `reporting_periods` semester record. It contains 21 confirmed snapshots: DSPP total 5,505 and NYATA total 5,470.
- The `BULANAN` sheet contains 21 snapshots: DSPP total 6,456 and NYATA total 5,892. Its appendix heading says August 2026 while the main heading says September 2026. The records are stored with `report_period_id=NULL` and `period_resolution_status='needs_confirmation'`; they must not appear under a confirmed month until the source owner resolves the conflict.
- All 42 snapshots passed `PA + BA + TA = NYATA` and `SUDAH + BELUM = NYATA`. The data values are verified separately from the unresolved monthly period label.
- Source row and cell coordinates are retained: header values in columns C/D, rank detail in E/F/G, and education detail in I/J. JML columns are derived and are not stored as independent facts.
- The two monthly records with DSPP greater than NYATA by a notable margin are preserved and flagged for context review: POMDAM XVIII/KSR (330 vs 115) and POMDAM XXII/TB (300 vs 188). DSPP/NYATA differences can represent staffing gaps and are not treated as arithmetic errors.
- The original workbook binary was not archived at the project owner's instruction. Its SHA-256 fingerprint and all source rows/cells are retained in the import batch and data rows.

## Fourth workbook: Statistik Laka Lalin.xlsx (2026)

Laka Lalin is a monthly activity report and has a dedicated model separate from Pelanggaran, SIM, and Provos. It shares only the POMDAM organization master, the 2026 reporting calendar, the personnel-category master, and the import registry.

- Reference dimensions are normalized in `laka_lalin_accident_types` (GANDA, TUNGGAL, TABRAK LARI), `laka_lalin_loss_severities` (MD, LB, LR), `laka_lalin_vehicle_types` (RANDIS, RAN UMUM), and `laka_lalin_damage_levels` (RB, RR). MD/LB/LR and RB/RR are retained as source codes; their expansions are not inferred.
- `laka_lalin_reports` stores the month × POMDAM report header. `laka_lalin_report_counts` stores 18 atomic source cells per report with the source-cell coordinate.
- `measure_code` separates accident-type counts, personnel by rank, personnel loss by rank, personnel loss by severity, and material loss by vehicle/damage level. Personnel loss by rank and by MD/LB/LR are two representations of the same casualty population; their totals must not be added together.
- The 2026 workbook contains 21 POMDAM on each of its 12 monthly sheets. January–September contribute 189 report headers and 3,402 atomic cells. The six newest POMDAM XXV–XXX have no source records and remain visible as no report submitted rather than zero.
- January–September totals are: accident types 106; personnel by rank 104; personnel loss by rank 152; personnel loss by MD/LB/LR 152; material loss by vehicle/damage level 105. The two 152 totals describe the same loss population in different dimensions.
- The imported cell mix is 392 positive, 3,009 explicit zero, and one source blank. The blank cell `MAR!X23` (POMDAM XVII/CEN, Ran Umum–RR) is stored as `NULL` with `verification_status='source_blank'`; it is not changed into zero.
- October, November, and December sheets contain explicit zero in every atomic metric for every listed POMDAM. Because the workbook does not establish whether these are submitted zero reports or unfilled templates, they are excluded from report facts pending source-owner confirmation.
- The quarterly and semester aggregation sheets reconcile with their component monthly sheets and are not imported as independent facts. The `JAN-JUL 2026` sheet has 80 of 378 organization-level atomic cells that do not reconcile with January–July monthly sums; its coincidentally matching grand total is not used. All dashboard totals should be derived from monthly atomic facts.
- The original workbook binary was not archived at the project owner's instruction. Its SHA-256 fingerprint and source sheet/row/cell provenance are stored in the import registry and facts.

## Fifth workbook: Rekap Tindak Pidana TA 2026

The Tindak Pidana workbook is a monthly activity dataset stored separately from Pelanggaran, SIM, Laka Lalin, and Provos. It shares the canonical POMDAM master, reporting calendar, personnel-category master, and import registry.

- `tindak_pidana_categories` contains 113 unique exact source-label entries associated with the 105 numbered category rows. The 105 source item numbers are stable positions in the workbook; the label at some positions changes across monthly sheets. Keep both `source_item_no` and `source_category_label` on every fact and do not merge labels into one canonical category without owner confirmation.
- `tindak_pidana_reports` stores one monthly header per POMDAM. `tindak_pidana_report_counts` stores one fact per source item × personnel group, referencing shared PA/BA/TA/PNS master values.
- January–September 2026 contain 189 report headers (21 POMDAM × 9 months) and 79,380 atomic source cells (105 items × 4 personnel categories × 21 POMDAM × 9 months). The six newer POMDAM XXV–XXX have no source rows; keep them visible as no report submitted, not zero.
- January–September total is 1,006. Monthly totals: JAN=121, FEB=184, MAR=106, APR=112, MEI=101, JUN=81, JUL=92, AGU=88, SEP=121. Personnel-category totals: PA=67, BA=391, TA=546, PNS=2.
- The imported value mix is 664 positive cells, 78,707 explicit zero cells, and 9 source blanks. The nine blanks are PA source cells repeated in JAN, APR, and JUL: AQ50 (POMDAM XII/TPR, item 48 Perzinahan), AV32 (POMDAM XIII/MDK, item 30 Penganiayaan), and AV50 (POMDAM XIII/MDK, item 48 Perzinahan). All are retained as `NULL` with `verification_status='source_blank'`, never changed to zero.
- The source label variations occur at item numbers 18 (Menolak perintah / Menolak perintah dinas), 31 (Penggelapan / Penggelapan dan penipuan), 36 (Penyalahgunaan alat perang / Menghilangkan alat perang), 40 (Penyelundupan / Penyeludupan spelling variant), 54 (Pelecehan anak dibawah umur / Pelecehan seksual), 57 (Penambangan liar / Pencurian minyak mentah), 66 (Membiarkan orang yang minta tolong / Tindak pidana cukai), 76 (Intimidasi / Fitnah), and 99 (Tidak menaati perintah / Tidak menaati perintah dinas). The exact label is stored with every fact. Item 66 and item 105 both carry the label Tindak pidana cukai in some later monthly templates; they remain separate item positions.
- Monthly aggregation sheets TW 1–4, SMT 1–2, and TAH 2026 reconcile to their component month cells and are not imported as facts. Legacy 2020 sheets and blank worksheets are not reporting facts.
- October contains zero-valued atomic cells except for the same three PA blanks seen in January, April, and July. November and December contain explicit zero values. These three months are not imported pending confirmation that the sheets are submitted reports rather than unfilled templates.
- Four source POMDAM headers are preserved as aliases: POMDAM /III → POMDAM III/SLW; POMDAM /IV DIP → POMDAM IV/DIP; POMDAM XVI/PTM → canonical POMDAM XV/PTM; POMDAM XVIII/KAS (annual summary label) → POMDAM XVIII/KSR.
- The metric remains `jumlah_tercatat`; the precise semantic meaning of this count should be confirmed by the source owner before describing it publicly as number of cases or individuals.
- The original workbook binary was not archived at the project owner's instruction. Its SHA-256 fingerprint and source sheet, POMDAM header, item number, and atomic source cell coordinates are retained in the import registry and facts.

## Excel round-trip compatibility contract

The uploaded workbook is the authoritative presentation template. Normalization changes how facts are stored, not the report's visible content or workbook form.

- Retain an immutable, versioned copy of each original workbook when archival is required by the project owner or records policy. If the owner explicitly declines binary archiving, retain the SHA-256 fingerprint, import batch, source worksheet, and source cell, and set `source_file_archived=false` in the batch validation summary.
- Normalize only atomic source observations into `report_counts`. Do not import subtotal, quarter, semester, or grand-total formula outputs as independent facts; those values are derived from the atomic month-level records.
- Export by opening the matching original workbook template and filling only mapped input cells. Do not recreate sheets from scratch or replace formula cells with hard-coded totals.
- Preserve worksheet names and order, merged cells, row/column dimensions, hidden rows/columns, formulas, number formats, styles, print area, page orientation, paper size, margins, headers/footers, and print scaling.
- Recalculate or independently validate formula-driven totals after writing. Compare exported workbook structure and mapped values against the template and approved source data before release.
- Historical months and future months that use the same approved workbook format must use the same template version. When the official workbook format changes, register a new template version; do not silently reshape older exports.
- Standardized dashboards and exports always use all 27 canonical POMDAM units. The six newer units remain visible even where historical periods have no submitted report; missing values are not converted to zero. When the workbook binary is retained, it remains the source template; when archiving is declined, the import hash and cell-level provenance remain stored, while export still uses an approved original template. The managed output template extends its row structure to 27 units without changing the established report design, formatting, or formula behavior.

The export engine and regression tests for full workbook fidelity are still implementation work; this contract defines the acceptance criteria, not a claim that export is already available.

## Open work

1. Verify the 12 newer-unit emblem candidates against direct official unit files; after approval, copy approved binaries to project-controlled Supabase Storage and update `asset_url`.
2. Confirm whether each report count means incidents, individuals, or another measure.
3. Populate legal-basis references only when supplied by an authoritative source; this is separate from the already-confirmed official category nomenclature.
4. Define access roles for operator, verifier, leadership, and auditor.
5. Complete workbook catalogue and Excel export-fidelity requirements.
