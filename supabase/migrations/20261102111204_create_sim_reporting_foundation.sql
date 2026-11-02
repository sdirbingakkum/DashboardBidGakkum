-- SIM reporting foundation: dedicated reference master + fact table.
-- Shared dimensions remain public.organizations and public.reporting_periods.

ALTER TABLE public.report_imports
  ADD COLUMN dataset_code text NOT NULL DEFAULT 'pelanggaran';

ALTER TABLE public.report_imports
  ADD CONSTRAINT report_imports_dataset_code_check
  CHECK (dataset_code IN ('pelanggaran', 'sim', 'laka_lalin', 'k9', 'provos'));

CREATE TABLE public.sim_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  display_order integer NOT NULL CHECK (display_order > 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT sim_categories_code_check
    CHECK (code ~ '^[A-Z][A-Z0-9_]*$')
);

COMMENT ON TABLE public.sim_categories IS
  'Master referensi golongan SIM TNI. Dipakai lintas form, laporan, dan integrasi.';
COMMENT ON COLUMN public.sim_categories.code IS
  'Kode stabil untuk referensi aplikasi; tidak berubah ketika nama tampilan berubah.';
COMMENT ON COLUMN public.sim_categories.name IS
  'Nama kategori sesuai nomenklatur sumber laporan.';

INSERT INTO public.sim_categories (code, name, description, display_order)
VALUES
  ('A', 'A', 'Golongan SIM A', 1),
  ('BI', 'BI', 'Golongan SIM BI', 2),
  ('BII', 'BII', 'Golongan SIM BII', 3),
  ('BII_SUS', 'B II SUS', 'Golongan SIM B II SUS', 4),
  ('C', 'C', 'Golongan SIM C', 5);

CREATE TABLE public.sim_report_counts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  report_period_id uuid NOT NULL
    REFERENCES public.reporting_periods(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL
    REFERENCES public.organizations(id) ON DELETE RESTRICT,
  sim_category_id uuid NOT NULL
    REFERENCES public.sim_categories(id) ON DELETE RESTRICT,
  reported_count integer NOT NULL CHECK (reported_count >= 0),
  measure_code text NOT NULL DEFAULT 'jumlah_tercatat'
    CHECK (measure_code IN ('jumlah_tercatat', 'incident_count', 'personnel_count', 'other')),
  source_import_id uuid NOT NULL
    REFERENCES public.report_imports(id) ON DELETE RESTRICT,
  source_sheet text NOT NULL,
  source_cell text NOT NULL,
  verification_status text NOT NULL DEFAULT 'unverified'
    CHECK (verification_status IN ('unverified', 'verified', 'disputed', 'rejected')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT sim_report_counts_dimension_key
    UNIQUE (report_period_id, organization_id, sim_category_id, measure_code),
  CONSTRAINT sim_report_counts_source_cell_key
    UNIQUE (source_import_id, source_sheet, source_cell)
);

COMMENT ON TABLE public.sim_report_counts IS
  'Fakta bulanan penyelenggaraan SIM TNI per POMDAM dan golongan SIM. Tidak mencampur data Pelanggaran.';
COMMENT ON COLUMN public.sim_report_counts.measure_code IS
  'Menggunakan jumlah_tercatat sampai makna metrik angka dikonfirmasi pemilik data.';
COMMENT ON COLUMN public.sim_report_counts.source_cell IS
  'Koordinat sel sumber Excel untuk audit trail.';

CREATE INDEX sim_report_counts_period_org_idx
  ON public.sim_report_counts (report_period_id, organization_id);
CREATE INDEX sim_report_counts_category_period_idx
  ON public.sim_report_counts (sim_category_id, report_period_id);
CREATE INDEX sim_report_counts_source_import_idx
  ON public.sim_report_counts (source_import_id);

ALTER TABLE public.sim_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sim_report_counts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authenticated read sim_categories"
  ON public.sim_categories
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "authenticated read sim_report_counts"
  ON public.sim_report_counts
  FOR SELECT TO authenticated
  USING (true);

REVOKE ALL ON TABLE public.sim_categories FROM PUBLIC, anon;
REVOKE ALL ON TABLE public.sim_report_counts FROM PUBLIC, anon;
GRANT SELECT ON TABLE public.sim_categories TO authenticated;
GRANT SELECT ON TABLE public.sim_report_counts TO authenticated;
GRANT ALL ON TABLE public.sim_categories TO service_role;
GRANT ALL ON TABLE public.sim_report_counts TO service_role;
