-- Tindak Pidana TA 2026 reporting foundation.
-- Source item number and exact monthly category label are both retained because
-- category labels vary across source months. The operational workbook facts
-- are imported separately; only stable reference categories are seeded here.

ALTER TABLE public.report_imports
  DROP CONSTRAINT report_imports_dataset_code_check;
ALTER TABLE public.report_imports
  ADD CONSTRAINT report_imports_dataset_code_check
  CHECK (dataset_code IN ('pelanggaran','sim','laka_lalin','k9','provos','tindak_pidana'));

CREATE TABLE public.tindak_pidana_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL UNIQUE,
  description text,
  display_order integer NOT NULL CHECK (display_order > 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT tindak_pidana_categories_code_check CHECK (code ~ '^TP[0-9]{3}$')
);
COMMENT ON TABLE public.tindak_pidana_categories IS
  'Master kategori tindak pidana menurut label sumber workbook; variasi label dipertahankan, tidak digabung tanpa konfirmasi.';

INSERT INTO public.tindak_pidana_categories(code,name,display_order) VALUES
('TP001','Asusila',1),
('TP002','Bunuh Diri',2),
('TP003','Desersi',3),
('TP004','THTI',4),
('TP005','Illegal logging',5),
('TP006','Karena lalai orang lain luka/meninggal',6),
('TP007','KDRT/menelantarkan keluarga',7),
('TP008','Kejahatan terhadap ketaatan',8),
('TP009','Kelalaian/Pel terhadap kewajiban dinas',9),
('TP010','Korupsi',10),
('TP011','Merampas kemerdekaan org',11),
('TP012','Main hakim sendiri',12),
('TP013','Melarikan wanita',13),
('TP014','Melawan Atasan/Insubordinasi',14),
('TP015','Mencampuri urusan perdata',15),
('TP016','Mengedarkan uang palsu',16),
('TP017','Meninggalkan Pos',17),
('TP018','Menolak perintah',18),
('TP019','Narkotika/Psykotropika',19),
('TP020','Pel./Kej. terhadap ketertiban umum',20),
('TP021','Pemalsuan',21),
('TP022','Pembunuhan',22),
('TP023','Pemerasan',23),
('TP024','Penadahan',24),
('TP025','Pencemaran lingkungan',25),
('TP026','Penculikan',26),
('TP027','Pencurian',27),
('TP028','Pencabulan',28),
('TP029','Pengancaman',29),
('TP030','Penganiayaan',30),
('TP031','Penggelapan',31),
('TP032','Penghinaan',32),
('TP033','Penghasutan',33),
('TP034','Pengrusakan',34),
('TP035','Penipuan',35),
('TP036','Penyalahgunaan alat perang',36),
('TP037','Penyalahgunaan Migas/BBM',37),
('TP038','Penyalahgunaan Senpi/munisi',38),
('TP039','Penyalahgunaan Wewenang/jabatan',39),
('TP040','Penyelundupan',40),
('TP041','Penyuapan',41),
('TP042','Perampasan',42),
('TP043','Perampokan',43),
('TP044','Perbuatan tidak menyenangkan',44),
('TP045','Perjudian',45),
('TP046','Perkelahian',46),
('TP047','Perkosaan',47),
('TP048','Perzinahan',48),
('TP049','Poligami',49),
('TP050','Pornografi',50),
('TP051','Werfing',51),
('TP052','Kejahatan terhadap kesusilaan',52),
('TP053','Asal usul pernikahan',53),
('TP054','Pelecehan anak dibawah umur',54),
('TP055','Satwa yang dilindungi',55),
('TP056','Menjual aset negara',56),
('TP057','Penambangan liar',57),
('TP058','Senjata tajam',58),
('TP059','Turut serta melakukan kejahatan',59),
('TP060','Kejahatan terhadap kesopanan',60),
('TP061','Kekerasan dimuka umum',61),
('TP062','Kejahatan terhadap jabatan',62),
('TP063','Menghilangkan barang bukti/inventaris',63),
('TP064','Penarikan barang bukti',64),
('TP065','Aborsi',65),
('TP066','Membiarkan orang yang minta tolong',66),
('TP067','Pencemaran nama baik',67),
('TP068','Illegal fishing',68),
('TP069','Jual beli Ransum TNI',69),
('TP070','Penodaan Agama',70),
('TP071','Membahayakan nyawa orang lain',71),
('TP072','Jual beli Kaporlap',72),
('TP073','Pelanggaran IT',73),
('TP074','Percobaan pembunuhan',74),
('TP075','Penyerobotan tanah',75),
('TP076','Intimidasi',76),
('TP077','Tidak melapor atasan',77),
('TP078','Melakukan kekerasan',78),
('TP079','Pengeroyokan',79),
('TP080','Nikah siri',80),
('TP081','Jual Miras',81),
('TP082','Penembakan',82),
('TP083','Pemaksaan',83),
('TP084','Kejahatan terhadap penguasa umum',84),
('TP085','Keterangan Palsu',85),
('TP086','Illegal minning',86),
('TP087','Perlindungan anak',87),
('TP088','Militer yg tidak m''beri tahu pada penguasa',88),
('TP089','Pembiaran terjadinya suatu kejahatan',89),
('TP090','Pencucian uang',90),
('TP091','Atasan memukul bawahan',91),
('TP092','Memberi keterangan palsu',92),
('TP093','Perdagangan illegal',93),
('TP094','Kekerasan dengan tenaga bersama',94),
('TP095','Penyekapan',95),
('TP096','Kepemilikan amunisi illegal',96),
('TP097','Menyembunyikan/melindungi pelaku',97),
('TP098','Pungutan liar',98),
('TP099','Tidak menaati perintah',99),
('TP100','Penyimpangan seksual/LGBT',100),
('TP101','Kepemilikan Senpi dan pengancaman dengan kekerasan',101),
('TP102','Kekerasan yang menyebabkan meninggal dunia',102),
('TP103','Memasuki pekarangan tanpa izin',103),
('TP104','Menjadi Backing',104),
('TP105','Tindak pidana cukai',105),
('TP106','Menolak perintah dinas',106),
('TP107','Penggelapan dan penipuan',107),
('TP108','Penyeludupan',108),
('TP109','Pelecehan seksual',109),
('TP110','Pencurian minyak mentah',110),
('TP111','Fitnah',111),
('TP112','Tidak menaati perintah dinas',112),
('TP113','Menghilangkan alat perang',113);

CREATE TABLE public.tindak_pidana_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  report_period_id uuid NOT NULL REFERENCES public.reporting_periods(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  source_import_id uuid NOT NULL REFERENCES public.report_imports(id) ON DELETE RESTRICT,
  source_sheet text NOT NULL,
  source_header_cell text NOT NULL,
  source_organization_label text NOT NULL,
  source_period_label text NOT NULL,
  data_verification_status text NOT NULL DEFAULT 'verified'
    CHECK (data_verification_status IN ('verified','needs_confirmation')),
  quality_flags jsonb NOT NULL DEFAULT '[]'::jsonb
    CHECK (jsonb_typeof(quality_flags)='array'),
  review_notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT tindak_pidana_reports_period_org_key UNIQUE (report_period_id,organization_id),
  CONSTRAINT tindak_pidana_reports_source_header_key UNIQUE (source_import_id,source_sheet,source_header_cell),
  CONSTRAINT tindak_pidana_reports_source_sheet_check
    CHECK (source_sheet IN ('JAN','FEB','MAR','APR','MEI','JUN','JUL','AGU','SEP','OKT','NOV','DES'))
);
COMMENT ON TABLE public.tindak_pidana_reports IS
  'Header laporan tindak pidana per bulan dan POMDAM. Satu header dibuat dari setiap grup kolom POMDAM pada sheet sumber.';

CREATE TABLE public.tindak_pidana_report_counts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tindak_pidana_report_id uuid NOT NULL REFERENCES public.tindak_pidana_reports(id) ON DELETE CASCADE,
  source_item_no smallint NOT NULL CHECK (source_item_no BETWEEN 1 AND 105),
  tindak_pidana_category_id uuid NOT NULL REFERENCES public.tindak_pidana_categories(id) ON DELETE RESTRICT,
  source_category_label text NOT NULL,
  personnel_category_id uuid NOT NULL REFERENCES public.personnel_categories(id) ON DELETE RESTRICT,
  measure_code text NOT NULL DEFAULT 'jumlah_tercatat' CHECK (measure_code='jumlah_tercatat'),
  reported_count integer,
  source_cell text NOT NULL,
  verification_status text NOT NULL DEFAULT 'verified'
    CHECK (verification_status IN ('verified','source_blank')),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT tindak_pidana_report_counts_value_check CHECK (reported_count IS NULL OR reported_count >= 0),
  CONSTRAINT tindak_pidana_report_counts_blank_status_check CHECK (
    (reported_count IS NULL AND verification_status='source_blank')
    OR (reported_count IS NOT NULL AND verification_status='verified')
  ),
  CONSTRAINT tindak_pidana_report_counts_source_cell_check CHECK (source_cell ~ '^[A-Z]+[0-9]+$'),
  CONSTRAINT tindak_pidana_report_counts_item_rank_key
    UNIQUE (tindak_pidana_report_id,source_item_no,personnel_category_id),
  CONSTRAINT tindak_pidana_report_counts_source_cell_key
    UNIQUE (tindak_pidana_report_id,source_cell)
);
COMMENT ON TABLE public.tindak_pidana_report_counts IS
  'Fakta atomik jumlah tercatat per bulan, POMDAM, nomor item sumber, kategori tindak pidana, dan golongan personel.';
COMMENT ON COLUMN public.tindak_pidana_report_counts.source_item_no IS
  'Nomor item 1-105 pada workbook; dipertahankan karena label pada nomor yang sama berubah antarbulan.';
COMMENT ON COLUMN public.tindak_pidana_report_counts.source_category_label IS
  'Label kategori persis sebagaimana tertulis pada sheet bulanan sumber.';
COMMENT ON COLUMN public.tindak_pidana_report_counts.reported_count IS
  'NULL berarti sel sumber kosong. Nilai nol hanya disimpan jika sel sumber eksplisit berisi 0.';

CREATE INDEX tindak_pidana_reports_org_period_idx
  ON public.tindak_pidana_reports(organization_id,report_period_id);
CREATE INDEX tindak_pidana_reports_import_idx
  ON public.tindak_pidana_reports(source_import_id);
CREATE INDEX tindak_pidana_counts_report_category_idx
  ON public.tindak_pidana_report_counts(tindak_pidana_report_id,tindak_pidana_category_id);
CREATE INDEX tindak_pidana_counts_category_idx
  ON public.tindak_pidana_report_counts(tindak_pidana_category_id);
CREATE INDEX tindak_pidana_counts_personnel_idx
  ON public.tindak_pidana_report_counts(personnel_category_id);

ALTER TABLE public.tindak_pidana_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tindak_pidana_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tindak_pidana_report_counts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authenticated read tindak_pidana_categories"
  ON public.tindak_pidana_categories FOR SELECT TO authenticated USING (true);
CREATE POLICY "authenticated read tindak_pidana_reports"
  ON public.tindak_pidana_reports FOR SELECT TO authenticated USING (true);
CREATE POLICY "authenticated read tindak_pidana_report_counts"
  ON public.tindak_pidana_report_counts FOR SELECT TO authenticated USING (true);

REVOKE ALL ON TABLE public.tindak_pidana_categories FROM PUBLIC,anon,authenticated;
REVOKE ALL ON TABLE public.tindak_pidana_reports FROM PUBLIC,anon,authenticated;
REVOKE ALL ON TABLE public.tindak_pidana_report_counts FROM PUBLIC,anon,authenticated;
GRANT SELECT ON TABLE public.tindak_pidana_categories TO authenticated;
GRANT SELECT ON TABLE public.tindak_pidana_reports TO authenticated;
GRANT SELECT ON TABLE public.tindak_pidana_report_counts TO authenticated;
GRANT ALL ON TABLE public.tindak_pidana_categories TO service_role;
GRANT ALL ON TABLE public.tindak_pidana_reports TO service_role;
GRANT ALL ON TABLE public.tindak_pidana_report_counts TO service_role;
