-- Provos is a personnel-strength snapshot, not an additive activity report.
-- Shared dimensions: organizations, reporting_periods, personnel_categories, report_imports.
-- Monthly source period may remain unresolved until the workbook period label is confirmed.

CREATE TABLE public.provos_education_statuses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  display_order integer NOT NULL CHECK (display_order > 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT provos_education_statuses_code_check CHECK (code IN ('SUDAH','BELUM'))
);

COMMENT ON TABLE public.provos_education_statuses IS
  'Master referensi status pendidikan pada laporan Provos.';

INSERT INTO public.provos_education_statuses(code,name,description,display_order)
VALUES
  ('SUDAH','SUDAH','Sudah mengikuti pendidikan Provos sesuai label sumber.',1),
  ('BELUM','BELUM','Belum mengikuti pendidikan Provos sesuai label sumber.',2);

CREATE TABLE public.provos_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  report_year smallint NOT NULL,
  snapshot_type text NOT NULL CHECK (snapshot_type IN ('monthly','semester')),
  report_period_id uuid REFERENCES public.reporting_periods(id) ON DELETE RESTRICT,
  period_resolution_status text NOT NULL CHECK (period_resolution_status IN ('confirmed','needs_confirmation')),
  source_period_label text NOT NULL,
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  dspp_count integer NOT NULL CHECK (dspp_count >= 0),
  nyata_count integer NOT NULL CHECK (nyata_count >= 0),
  source_import_id uuid NOT NULL REFERENCES public.report_imports(id) ON DELETE RESTRICT,
  source_sheet text NOT NULL,
  source_row integer NOT NULL CHECK (source_row > 0),
  data_verification_status text NOT NULL DEFAULT 'verified' CHECK (data_verification_status IN ('verified','unverified')),
  quality_flags jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(quality_flags)='array'),
  review_notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT provos_reports_period_resolution_check CHECK (
    (period_resolution_status='confirmed' AND report_period_id IS NOT NULL)
    OR (period_resolution_status='needs_confirmation' AND report_period_id IS NULL)
  ),
  CONSTRAINT provos_reports_import_org_snapshot_key UNIQUE (source_import_id, organization_id, snapshot_type),
  CONSTRAINT provos_reports_source_row_key UNIQUE (source_import_id, source_sheet, source_row)
);

COMMENT ON TABLE public.provos_reports IS
  'Satu snapshot kondisi/kekuatan personel Provos per POMDAM dan periode. Nilai snapshot tidak dijumlahkan lintas periode.';
COMMENT ON COLUMN public.provos_reports.dspp_count IS
  'Nilai DSPP sesuai laporan sumber; disimpan terpisah dari jumlah nyata.';
COMMENT ON COLUMN public.provos_reports.nyata_count IS
  'Nilai NYATA sesuai laporan sumber; menjadi pembanding dengan rincian pangkat dan pendidikan.';
COMMENT ON COLUMN public.provos_reports.period_resolution_status IS
  'Needs_confirmation keeps a source snapshot out of confirmed-period reporting until its actual period is resolved.';
COMMENT ON COLUMN public.provos_reports.source_period_label IS
  'Label periode yang tertulis pada sumber, dipertahankan apa adanya.';

CREATE UNIQUE INDEX provos_reports_confirmed_period_org_uidx
  ON public.provos_reports(report_period_id, organization_id)
  WHERE period_resolution_status='confirmed';
CREATE INDEX provos_reports_org_period_idx
  ON public.provos_reports(organization_id, report_period_id);
CREATE INDEX provos_reports_source_import_idx
  ON public.provos_reports(source_import_id);

CREATE TABLE public.provos_rank_counts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  provos_report_id uuid NOT NULL REFERENCES public.provos_reports(id) ON DELETE CASCADE,
  personnel_category_id uuid NOT NULL REFERENCES public.personnel_categories(id) ON DELETE RESTRICT,
  reported_count integer NOT NULL CHECK (reported_count >= 0),
  source_cell text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT provos_rank_counts_report_personnel_key UNIQUE (provos_report_id, personnel_category_id),
  CONSTRAINT provos_rank_counts_source_cell_key UNIQUE (provos_report_id, source_cell)
);

COMMENT ON TABLE public.provos_rank_counts IS
  'Komposisi pangkat Provos per snapshot. Menggunakan master PA, BA, TA yang sudah ada.';
CREATE INDEX provos_rank_counts_personnel_idx ON public.provos_rank_counts(personnel_category_id);

CREATE TABLE public.provos_education_counts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  provos_report_id uuid NOT NULL REFERENCES public.provos_reports(id) ON DELETE CASCADE,
  education_status_id uuid NOT NULL REFERENCES public.provos_education_statuses(id) ON DELETE RESTRICT,
  reported_count integer NOT NULL CHECK (reported_count >= 0),
  source_cell text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT provos_education_counts_report_status_key UNIQUE (provos_report_id, education_status_id),
  CONSTRAINT provos_education_counts_source_cell_key UNIQUE (provos_report_id, source_cell)
);

COMMENT ON TABLE public.provos_education_counts IS
  'Rincian status pendidikan Provos per snapshot. Status menggunakan master SUDAH/BELUM.';
CREATE INDEX provos_education_counts_status_idx ON public.provos_education_counts(education_status_id);

-- Deferred checks guarantee a complete snapshot: PA+BA+TA=NYATA and SUDAH+BELUM=NYATA.
CREATE OR REPLACE FUNCTION public.validate_provos_snapshot_totals()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_report_id uuid;
  v_nyata integer;
  v_rank_sum bigint;
  v_education_sum bigint;
  v_rank_codes text[];
  v_education_codes text[];
BEGIN
  IF TG_TABLE_NAME='provos_reports' THEN
    v_report_id := CASE WHEN TG_OP='DELETE' THEN OLD.id ELSE NEW.id END;
  ELSE
    v_report_id := CASE WHEN TG_OP='DELETE' THEN OLD.provos_report_id ELSE NEW.provos_report_id END;
  END IF;

  SELECT r.nyata_count INTO v_nyata
  FROM public.provos_reports r
  WHERE r.id=v_report_id;

  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  SELECT COALESCE(sum(prc.reported_count),0),
         COALESCE(array_agg(pc.code ORDER BY pc.code),ARRAY[]::text[])
    INTO v_rank_sum,v_rank_codes
  FROM public.provos_rank_counts prc
  JOIN public.personnel_categories pc ON pc.id=prc.personnel_category_id
  WHERE prc.provos_report_id=v_report_id;

  SELECT COALESCE(sum(pec.reported_count),0),
         COALESCE(array_agg(es.code ORDER BY es.code),ARRAY[]::text[])
    INTO v_education_sum,v_education_codes
  FROM public.provos_education_counts pec
  JOIN public.provos_education_statuses es ON es.id=pec.education_status_id
  WHERE pec.provos_report_id=v_report_id;

  IF v_rank_codes <> ARRAY['BA','PA','TA']::text[] THEN
    RAISE EXCEPTION 'Provos snapshot % must have exactly PA, BA, and TA rank details; found %',v_report_id,v_rank_codes;
  END IF;
  IF v_education_codes <> ARRAY['BELUM','SUDAH']::text[] THEN
    RAISE EXCEPTION 'Provos snapshot % must have exactly SUDAH and BELUM education details; found %',v_report_id,v_education_codes;
  END IF;
  IF v_rank_sum <> v_nyata THEN
    RAISE EXCEPTION 'Provos snapshot % rank total % does not equal NYATA %',v_report_id,v_rank_sum,v_nyata;
  END IF;
  IF v_education_sum <> v_nyata THEN
    RAISE EXCEPTION 'Provos snapshot % education total % does not equal NYATA %',v_report_id,v_education_sum,v_nyata;
  END IF;
  RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER provos_reports_totals_check
  AFTER INSERT OR UPDATE ON public.provos_reports
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public.validate_provos_snapshot_totals();
CREATE CONSTRAINT TRIGGER provos_rank_counts_totals_check
  AFTER INSERT OR UPDATE OR DELETE ON public.provos_rank_counts
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public.validate_provos_snapshot_totals();
CREATE CONSTRAINT TRIGGER provos_education_counts_totals_check
  AFTER INSERT OR UPDATE OR DELETE ON public.provos_education_counts
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public.validate_provos_snapshot_totals();

ALTER TABLE public.provos_education_statuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.provos_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.provos_rank_counts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.provos_education_counts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authenticated read provos_education_statuses"
  ON public.provos_education_statuses FOR SELECT TO authenticated USING (true);
CREATE POLICY "authenticated read provos_reports"
  ON public.provos_reports FOR SELECT TO authenticated USING (true);
CREATE POLICY "authenticated read provos_rank_counts"
  ON public.provos_rank_counts FOR SELECT TO authenticated USING (true);
CREATE POLICY "authenticated read provos_education_counts"
  ON public.provos_education_counts FOR SELECT TO authenticated USING (true);

REVOKE ALL ON TABLE public.provos_education_statuses FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.provos_reports FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.provos_rank_counts FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.provos_education_counts FROM PUBLIC, anon, authenticated;

GRANT SELECT ON TABLE public.provos_education_statuses TO authenticated;
GRANT SELECT ON TABLE public.provos_reports TO authenticated;
GRANT SELECT ON TABLE public.provos_rank_counts TO authenticated;
GRANT SELECT ON TABLE public.provos_education_counts TO authenticated;

GRANT ALL ON TABLE public.provos_education_statuses TO service_role;
GRANT ALL ON TABLE public.provos_reports TO service_role;
GRANT ALL ON TABLE public.provos_rank_counts TO service_role;
GRANT ALL ON TABLE public.provos_education_counts TO service_role;

REVOKE ALL ON FUNCTION public.validate_provos_snapshot_totals() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.validate_provos_snapshot_totals() TO service_role;
