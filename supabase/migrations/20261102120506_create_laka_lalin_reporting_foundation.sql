-- Laka Lalin reporting foundation: monthly activity facts by POMDAM.
-- Derived subtotal columns and aggregate period sheets are not stored as facts.
-- Source labels MD/LB/LR and RB/RR remain neutral; their expansions are not inferred.

CREATE TABLE public.laka_lalin_accident_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  display_order integer NOT NULL CHECK (display_order > 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT laka_lalin_accident_types_code_check
    CHECK (code IN ('GANDA','TUNGGAL','TABRAK_LARI'))
);
CREATE TABLE public.laka_lalin_loss_severities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  display_order integer NOT NULL CHECK (display_order > 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT laka_lalin_loss_severities_code_check
    CHECK (code IN ('MD','LB','LR'))
);
CREATE TABLE public.laka_lalin_vehicle_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  display_order integer NOT NULL CHECK (display_order > 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT laka_lalin_vehicle_types_code_check
    CHECK (code IN ('RANDIS','RAN_UMUM'))
);
CREATE TABLE public.laka_lalin_damage_levels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  display_order integer NOT NULL CHECK (display_order > 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT laka_lalin_damage_levels_code_check
    CHECK (code IN ('RB','RR'))
);

INSERT INTO public.laka_lalin_accident_types(code,name,description,display_order)
VALUES
  ('GANDA','GANDA','Label kategori sesuai header workbook.',1),
  ('TUNGGAL','TUNGGAL','Label kategori sesuai header workbook.',2),
  ('TABRAK_LARI','TABRAK LARI','Label gabungan header TABRAK dan subheader LARI pada workbook.',3);
INSERT INTO public.laka_lalin_loss_severities(code,name,description,display_order)
VALUES
  ('MD','MD','Kode jenis kerugian personel sesuai workbook; kepanjangan tidak diasumsikan.',1),
  ('LB','LB','Kode jenis kerugian personel sesuai workbook; kepanjangan tidak diasumsikan.',2),
  ('LR','LR','Kode jenis kerugian personel sesuai workbook; kepanjangan tidak diasumsikan.',3);
INSERT INTO public.laka_lalin_vehicle_types(code,name,description,display_order)
VALUES
  ('RANDIS','RANDIS','Kategori kendaraan sesuai header workbook.',1),
  ('RAN_UMUM','RAN UMUM','Kategori kendaraan sesuai header workbook.',2);
INSERT INTO public.laka_lalin_damage_levels(code,name,description,display_order)
VALUES
  ('RB','RB','Kode tingkat kerusakan sesuai workbook; kepanjangan tidak diasumsikan.',1),
  ('RR','RR','Kode tingkat kerusakan sesuai workbook; kepanjangan tidak diasumsikan.',2);

CREATE TABLE public.laka_lalin_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  report_period_id uuid NOT NULL REFERENCES public.reporting_periods(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  source_import_id uuid NOT NULL REFERENCES public.report_imports(id) ON DELETE RESTRICT,
  source_sheet text NOT NULL,
  source_row integer NOT NULL CHECK (source_row > 0),
  source_period_label text NOT NULL,
  data_verification_status text NOT NULL DEFAULT 'verified'
    CHECK (data_verification_status IN ('verified','needs_confirmation')),
  quality_flags jsonb NOT NULL DEFAULT '[]'::jsonb
    CHECK (jsonb_typeof(quality_flags)='array'),
  review_notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT laka_lalin_reports_period_org_key UNIQUE (report_period_id, organization_id),
  CONSTRAINT laka_lalin_reports_source_row_key UNIQUE (source_import_id, source_sheet, source_row),
  CONSTRAINT laka_lalin_reports_source_sheet_check
    CHECK (source_sheet IN ('JAN','FEB','MAR','APR','MEI','JUN','JUL','AGU','SEP','OKT','NOV','DES'))
);
COMMENT ON TABLE public.laka_lalin_reports IS
  'Header laporan aktivitas Laka Lalin per bulan dan POMDAM; rincian atomik disimpan terpisah.';
COMMENT ON COLUMN public.laka_lalin_reports.data_verification_status IS
  'Status validasi isi laporan; lembar nol/template yang belum dikonfirmasi tidak diimpor sebagai fakta terverifikasi.';
COMMENT ON COLUMN public.laka_lalin_reports.source_period_label IS
  'Label periode asli pada sheet sumber.';

CREATE TABLE public.laka_lalin_report_counts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  laka_lalin_report_id uuid NOT NULL
    REFERENCES public.laka_lalin_reports(id) ON DELETE CASCADE,
  measure_code text NOT NULL
    CHECK (measure_code IN (
      'accident_type','personnel_by_rank','personnel_loss_by_rank',
      'personnel_loss_by_severity','material_loss_by_vehicle_damage'
    )),
  accident_type_id uuid REFERENCES public.laka_lalin_accident_types(id) ON DELETE RESTRICT,
  personnel_category_id uuid REFERENCES public.personnel_categories(id) ON DELETE RESTRICT,
  loss_severity_id uuid REFERENCES public.laka_lalin_loss_severities(id) ON DELETE RESTRICT,
  vehicle_type_id uuid REFERENCES public.laka_lalin_vehicle_types(id) ON DELETE RESTRICT,
  damage_level_id uuid REFERENCES public.laka_lalin_damage_levels(id) ON DELETE RESTRICT,
  reported_count integer,
  source_cell text NOT NULL,
  verification_status text NOT NULL DEFAULT 'verified'
    CHECK (verification_status IN ('verified','needs_confirmation','source_blank')),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT laka_lalin_report_counts_value_check
    CHECK (reported_count IS NULL OR reported_count >= 0),
  CONSTRAINT laka_lalin_report_counts_null_status_check
    CHECK (
      (reported_count IS NULL AND verification_status='source_blank')
      OR (reported_count IS NOT NULL AND verification_status<>'source_blank')
    ),
  CONSTRAINT laka_lalin_report_counts_source_cell_check
    CHECK (source_cell ~ '^[A-Z]+[0-9]+$'),
  CONSTRAINT laka_lalin_report_counts_dimension_check
    CHECK (
      (
        measure_code='accident_type' AND accident_type_id IS NOT NULL
        AND personnel_category_id IS NULL AND loss_severity_id IS NULL
        AND vehicle_type_id IS NULL AND damage_level_id IS NULL
      )
      OR (
        measure_code IN ('personnel_by_rank','personnel_loss_by_rank')
        AND personnel_category_id IS NOT NULL
        AND accident_type_id IS NULL AND loss_severity_id IS NULL
        AND vehicle_type_id IS NULL AND damage_level_id IS NULL
      )
      OR (
        measure_code='personnel_loss_by_severity' AND loss_severity_id IS NOT NULL
        AND accident_type_id IS NULL AND personnel_category_id IS NULL
        AND vehicle_type_id IS NULL AND damage_level_id IS NULL
      )
      OR (
        measure_code='material_loss_by_vehicle_damage'
        AND vehicle_type_id IS NOT NULL AND damage_level_id IS NOT NULL
        AND accident_type_id IS NULL AND personnel_category_id IS NULL
        AND loss_severity_id IS NULL
      )
    ),
  CONSTRAINT laka_lalin_report_counts_source_cell_key
    UNIQUE (laka_lalin_report_id, source_cell)
);
COMMENT ON TABLE public.laka_lalin_report_counts IS
  'Fakta atomik Laka Lalin. Personel, kerugian personel, dan kerugian materiil tetap terpisah; kolom jumlah turunan tidak disimpan.';
COMMENT ON COLUMN public.laka_lalin_report_counts.measure_code IS
  'Jenis rincian sesuai kelompok kolom sumber. Kerugian personel menurut pangkat dan menurut MD/LB/LR adalah dua representasi atas populasi yang sama.';
COMMENT ON COLUMN public.laka_lalin_report_counts.reported_count IS
  'NULL berarti sel sumber kosong, bukan nol; angka nol disimpan hanya bila sel sumber eksplisit berisi 0.';
COMMENT ON COLUMN public.laka_lalin_report_counts.source_cell IS
  'Koordinat sel Excel sumber untuk audit trail.';

CREATE INDEX laka_lalin_reports_org_period_idx
  ON public.laka_lalin_reports(organization_id, report_period_id);
CREATE INDEX laka_lalin_reports_import_idx
  ON public.laka_lalin_reports(source_import_id);
CREATE INDEX laka_lalin_counts_report_measure_idx
  ON public.laka_lalin_report_counts(laka_lalin_report_id, measure_code);
CREATE INDEX laka_lalin_counts_accident_type_idx
  ON public.laka_lalin_report_counts(accident_type_id);
CREATE INDEX laka_lalin_counts_personnel_category_idx
  ON public.laka_lalin_report_counts(personnel_category_id);
CREATE INDEX laka_lalin_counts_loss_severity_idx
  ON public.laka_lalin_report_counts(loss_severity_id);
CREATE INDEX laka_lalin_counts_vehicle_damage_idx
  ON public.laka_lalin_report_counts(vehicle_type_id, damage_level_id);

ALTER TABLE public.laka_lalin_accident_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.laka_lalin_loss_severities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.laka_lalin_vehicle_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.laka_lalin_damage_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.laka_lalin_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.laka_lalin_report_counts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authenticated read laka_lalin_accident_types"
  ON public.laka_lalin_accident_types FOR SELECT TO authenticated USING (true);
CREATE POLICY "authenticated read laka_lalin_loss_severities"
  ON public.laka_lalin_loss_severities FOR SELECT TO authenticated USING (true);
CREATE POLICY "authenticated read laka_lalin_vehicle_types"
  ON public.laka_lalin_vehicle_types FOR SELECT TO authenticated USING (true);
CREATE POLICY "authenticated read laka_lalin_damage_levels"
  ON public.laka_lalin_damage_levels FOR SELECT TO authenticated USING (true);
CREATE POLICY "authenticated read laka_lalin_reports"
  ON public.laka_lalin_reports FOR SELECT TO authenticated USING (true);
CREATE POLICY "authenticated read laka_lalin_report_counts"
  ON public.laka_lalin_report_counts FOR SELECT TO authenticated USING (true);

REVOKE ALL ON TABLE public.laka_lalin_accident_types FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.laka_lalin_loss_severities FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.laka_lalin_vehicle_types FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.laka_lalin_damage_levels FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.laka_lalin_reports FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.laka_lalin_report_counts FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.laka_lalin_accident_types TO authenticated;
GRANT SELECT ON TABLE public.laka_lalin_loss_severities TO authenticated;
GRANT SELECT ON TABLE public.laka_lalin_vehicle_types TO authenticated;
GRANT SELECT ON TABLE public.laka_lalin_damage_levels TO authenticated;
GRANT SELECT ON TABLE public.laka_lalin_reports TO authenticated;
GRANT SELECT ON TABLE public.laka_lalin_report_counts TO authenticated;
GRANT ALL ON TABLE public.laka_lalin_accident_types TO service_role;
GRANT ALL ON TABLE public.laka_lalin_loss_severities TO service_role;
GRANT ALL ON TABLE public.laka_lalin_vehicle_types TO service_role;
GRANT ALL ON TABLE public.laka_lalin_damage_levels TO service_role;
GRANT ALL ON TABLE public.laka_lalin_reports TO service_role;
GRANT ALL ON TABLE public.laka_lalin_report_counts TO service_role;
