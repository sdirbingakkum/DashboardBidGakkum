-- Idempotent seed for the POMDAM-only Dashboard Sdirbingakkum.
insert into public.organization_types(code,name,description) values
 ('POMDAM','POMDAM','Satuan Polisi Militer wilayah; satu-satunya jenis organisasi yang dikelola aplikasi.')
on conflict(code) do update set name=excluded.name,description=excluded.description;

insert into public.organizations(organization_type_id,code,short_name,official_name,status,display_order,metadata)
select t.id,v.code,v.short_name,v.official_name,'active',v.ord,
 jsonb_build_object(
   'application_scope','POMDAM_ONLY',
   'unit_exists','confirmed_by_user',
   'emblem_rule','exact_same_emblem_as_the_matching_unit_name',
   'legacy_source_code',v.legacy_code
 )
from public.organization_types t
cross join (values
 ('POMDAM-IM','POMDAM IM','Polisi Militer Kodam Iskandar Muda','IM',1),
 ('POMDAM-I','POMDAM I/BB','Polisi Militer Kodam I/Bukit Barisan','I',2),
 ('POMDAM-II','POMDAM II/SWJ','Polisi Militer Kodam II/Sriwijaya','II',3),
 ('POMDAM-III','POMDAM III/SLW','Polisi Militer Kodam III/Siliwangi','III',4),
 ('POMDAM-IV','POMDAM IV/DIP','Polisi Militer Kodam IV/Diponegoro','IV',5),
 ('POMDAM-V','POMDAM V/BRW','Polisi Militer Kodam V/Brawijaya','V',6),
 ('POMDAM-VI','POMDAM VI/MLW','Polisi Militer Kodam VI/Mulawarman','VI',7),
 ('POMDAM-IX','POMDAM IX/UDY','Polisi Militer Kodam IX/Udayana','IX',8),
 ('POMDAM-XII','POMDAM XII/TPR','Polisi Militer Kodam XII/Tanjungpura','XII',9),
 ('POMDAM-XIII','POMDAM XIII/MDK','Polisi Militer Kodam XIII/Merdeka','XIII',10),
 ('POMDAM-XIV','POMDAM XIV/HSN','Polisi Militer Kodam XIV/Hasanuddin','XIV',11),
 ('POMDAM-XV','POMDAM XV/PTM','Polisi Militer Kodam XV/Pattimura','XV',12),
 ('POMDAM-XVII','POMDAM XVII/CEN','Polisi Militer Kodam XVII/Cenderawasih','XVII',13),
 ('POMDAM-XVIII','POMDAM XVIII/KSR','Polisi Militer Kodam XVIII/Kasuari','XVIII',14),
 ('POMDAM-XIX','POMDAM XIX/TUTAM','Polisi Militer Kodam XIX/Tuanku Tambusai','XIX',15),
 ('POMDAM-XX','POMDAM XX/TIB','Polisi Militer Kodam XX/Tuanku Imam Bonjol','XX',16),
 ('POMDAM-XXI','POMDAM XXI/RI','Polisi Militer Kodam XXI/Radin Inten','XXI',17),
 ('POMDAM-XXII','POMDAM XXII/TB','Polisi Militer Kodam XXII/Tambun Bungai','XXII',18),
 ('POMDAM-XXIII','POMDAM XXIII/PW','Polisi Militer Kodam XXIII/Palaka Wira','XXIII',19),
 ('POMDAM-XXIV','POMDAM XXIV/MT','Polisi Militer Kodam XXIV/Mandala Trikora','XXIV',20),
 ('POMDAM-XXV','POMDAM XXV/SMRS','Polisi Militer Kodam XXV/Sultan Mahmud Riayat Syah','XXV',21),
 ('POMDAM-XXVI','POMDAM XXVI/MTM','Polisi Militer Kodam XXVI/Mataram','XXVI',22),
 ('POMDAM-XXVII','POMDAM XXVII/SS','Polisi Militer Kodam XXVII/Sobe Sonbai','XXVII',23),
 ('POMDAM-XXVIII','POMDAM XXVIII/MKR','Polisi Militer Kodam XXVIII/Moloku Kie Raha','XXVIII',24),
 ('POMDAM-XXIX','POMDAM XXIX/MMB','Polisi Militer Kodam XXIX/Mambruk','XXIX',25),
 ('POMDAM-XXX','POMDAM XXX/RNB','Polisi Militer Kodam XXX/Rinambora','XXX',26),
 ('POMDAM-JAYA','POMDAM JAYA','Polisi Militer Kodam Jayakarta','JAYA',27)
) as v(code,short_name,official_name,legacy_code,ord)
where t.code='POMDAM'
on conflict (code,valid_from) do update
set short_name=excluded.short_name,
    official_name=excluded.official_name,
    status='active',
    display_order=excluded.display_order,
    metadata=excluded.metadata,
    updated_at=now();

insert into public.personnel_categories(code,name,description,category_type,display_order) values
 ('PA','Perwira','Kelompok golongan personel Perwira.','personnel_group',1),
 ('BA','Bintara','Kelompok golongan personel Bintara.','personnel_group',2),
 ('TA','Tamtama','Kelompok golongan personel Tamtama.','personnel_group',3),
 ('PNS','Pegawai Negeri Sipil','Kelompok personel Pegawai Negeri Sipil; bukan pangkat militer.','civil_service_group',4)
on conflict(code) do update
set name=excluded.name,description=excluded.description,category_type=excluded.category_type,display_order=excluded.display_order;

insert into public.sim_categories(code,name,description,display_order) values
 ('A','A','Golongan SIM A',1),
 ('BI','BI','Golongan SIM BI',2),
 ('BII','BII','Golongan SIM BII',3),
 ('BII_SUS','B II SUS','Golongan SIM B II SUS',4),
 ('C','C','Golongan SIM C',5)
on conflict(code) do update
set name=excluded.name,description=excluded.description,display_order=excluded.display_order,is_active=true;

insert into public.provos_education_statuses(code,name,description,display_order) values
 ('SUDAH','SUDAH','Sudah mengikuti pendidikan Provos sesuai label sumber.',1),
 ('BELUM','BELUM','Belum mengikuti pendidikan Provos sesuai label sumber.',2)
on conflict(code) do update
set name=excluded.name,description=excluded.description,display_order=excluded.display_order,is_active=true;

insert into public.positions(code,short_name,official_name,organization_type_id,description) values
 ('DANPOMDAM','DANPOMDAM','Komandan POMDAM',(select id from public.organization_types where code='POMDAM'),'Jabatan komandan satuan POMDAM.')
on conflict(code) do update
set short_name=excluded.short_name,official_name=excluded.official_name,
    organization_type_id=excluded.organization_type_id,description=excluded.description;

insert into public.terminology(term,expansion,domain,verification_status,notes) values
 ('POMDAM','Polisi Militer Kodam','satuan','verified','Satu-satunya jenis organisasi yang dikelola dalam Dashboard Sdirbingakkum.'),
 ('DANPOMDAM','Komandan POMDAM','jabatan','verified','Jabatan komandan satuan POMDAM.')
on conflict(term) do update
set expansion=excluded.expansion,domain=excluded.domain,
    verification_status=excluded.verification_status,notes=excluded.notes;

insert into public.violation_groups(code,name,description,display_order) values
 ('B','Pelanggaran kategori B','Kelompok kategori B sebagaimana label pada workbook sumber.',1),
 ('C','Pelanggaran lalu lintas kategori C','Kelompok kategori C sebagaimana label pada workbook sumber.',2)
on conflict(code) do update
set name=excluded.name,description=excluded.description,display_order=excluded.display_order;

insert into public.violation_categories(group_id,code,name,source_label,display_order,verification_status)
select g.id,v.code,v.name,v.code,v.ord,'verified'
from public.violation_groups g
join (values
 ('B','B1','PPM',1),('B','B2','GAM TNI',2),('B','B3','PDG',3),
 ('B','B4','Masuk daerah terlarang',4),('B','B5','Meninggalkan barak pada jam dinas',5),
 ('B','B6','Terlambat apel',6),('B','B7','Surat nyata diri',7),('B','B8','Surat senjata api',8),
 ('B','B9','Pungutan liar',9),('B','B10','Backing',10),
 ('B','B11','Perbuatan lain yang bertentangan dengan perintah/peraturan/disiplin',11),
 ('C','C1','Administrasi kendaraan',1),('C','C2','Kelengkapan wajib kendaraan',2),
 ('C','C3','Rambu dan marka lalu lintas',3),('C','C4','Tidak menggunakan sabuk pengaman',4),
 ('C','C5','Tidak menggunakan helm',5),('C','C6','Etika/sopan santun berlalu lintas',6)
) as v(group_code,code,name,ord) on g.code=v.group_code
on conflict(code) do update
set group_id=excluded.group_id,
    name=excluded.name,
    source_label=excluded.source_label,
    display_order=excluded.display_order,
    verification_status=excluded.verification_status;

insert into public.reporting_periods(report_year,period_type,period_number,period_label,starts_on,ends_on)
select 2026,'month',m,upper(to_char(make_date(2026,m,1),'TMMonth')),
 make_date(2026,m,1),(make_date(2026,m,1)+interval '1 month - 1 day')::date
from generate_series(1,12) as m
on conflict(report_year,period_type,period_number) do nothing;

insert into public.reporting_periods(report_year,period_type,period_number,period_label,starts_on,ends_on) values
 (2026,'quarter',1,'TW 1','2026-01-01','2026-03-31'),
 (2026,'quarter',2,'TW 2','2026-04-01','2026-06-30'),
 (2026,'quarter',3,'TW 3','2026-07-01','2026-09-30'),
 (2026,'quarter',4,'TW 4','2026-10-01','2026-12-31'),
 (2026,'semester',1,'SMTR 1','2026-01-01','2026-06-30'),
 (2026,'semester',2,'SMTR 2','2026-07-01','2026-12-31'),
 (2026,'year',1,'TAHUN 2026','2026-01-01','2026-12-31')
on conflict(report_year,period_type,period_number) do nothing;

insert into public.organization_aliases(organization_id,alias,alias_type,source_reference,notes)
select o.id,v.alias,v.alias_type,'Rekap Pelanggaran.xlsx (2026)',
 'Label alias sebagaimana tertulis di workbook; dipertahankan untuk rekonsiliasi impor.'
from (values
 ('POMDAM-XV','XV/PTM','legacy_code'),
 ('POMDAM-XXIV','XIV/MT','spelling_variant'),
 ('POMDAM-XXII','XX/TB','legacy_code'),
 ('POMDAM-XXII','XXII/TB','source_label')
) v(code,alias,alias_type)
join public.organizations o on o.code=v.code
on conflict (organization_id,alias,alias_type,valid_from) do nothing;

insert into public.master_data_sources(source_name,source_url,source_type,publisher,reliability,notes)
values
 ('Rujukan lambang POMDAM IM','https://ppid.tniad.mil.id/index.php/i/339/logo-kodam-im-terbaru','pomdam_emblem_reference','PPID TNI AD','primary_official','Rujukan verifikasi lambang POMDAM IM; file final belum diekstrak ke Storage.'),
 ('Serah terima jabatan DANPOMDAM V/Brawijaya','https://tniad.mil.id/jabatan-danpomdam-dan-kaajendam-vbrawijaya-diserah-terimakan/','pomdam_official_reference','TNI AD','primary_official','Rujukan nomenklatur dan jabatan satuan POMDAM V/Brawijaya.'),
 ('Serah terima jabatan DANPOMDAM I/BB','https://tniad.mil.id/pangdam-ibb-pimpin-sertijab-danpomdam-ibb-dan-dandeninteldam-ibb/','pomdam_official_reference','TNI AD','primary_official','Rujukan nomenklatur dan jabatan satuan POMDAM I/BB.'),
 ('Serah terima jabatan POMDAM','https://tniad.mil.id/sertijab-kapendam-srendam-dan-pomdam/','pomdam_official_reference','TNI AD','primary_official','Rujukan istilah POMDAM dalam rilis resmi TNI AD.')
on conflict (source_url) where source_url is not null do nothing;


-- Primary POMDAM emblems. Each URL is directly tied to its canonical POMDAM record.
-- Official Dinas Sejarah AD directory assets are verified; newer Commons candidates stay unverified.
do $$
declare
  r record;
  v_org_id uuid;
  v_emblem_id uuid;
begin
  for r in
    select * from (values
      ('POMDAM-IM','https://disjarah.tni-ad.mil.id/asset/lambang/dam%20im.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM IM dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-I','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Bukit_Barisan.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM I/BB dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-II','https://disjarah.tni-ad.mil.id/asset/lambang/dam%20swj.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM II/SWJ; sumber resmi menulis variasi II/SJW.'),
      ('POMDAM-III','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Siliwangi.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM III/SLW dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-IV','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Diponegoro.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM IV/DIP dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-V','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Brawijaya.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM V/BRW dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-VI','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Mulawarman.svg.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM VI/MLW dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-IX','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Udayana.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM IX/UDY dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-XII','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Tanjungpura.svg.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM XII/TPR dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-XIII','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Merdeka.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM XIII/MDK dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-XIV','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Hasanuddin.svg.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM XIV/HSN; sumber lama menulis XIV/HSD.'),
      ('POMDAM-XV','https://disjarah.tni-ad.mil.id/asset/lambang/dam%20ptm.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Lambang Pattimura dari direktori resmi Dinas Sejarah AD; page lama menulis XVI/PTM, tetapi master kanonik aplikasi tetap XV/PTM.'),
      ('POMDAM-XVII','https://disjarah.tni-ad.mil.id/asset/lambang/dam%20cen.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM XVII/CEN dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-XVIII','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Kasuari.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM XVIII/KSR dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-JAYA','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Jaya.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Logo POMDAM JAYA dari direktori resmi Dinas Sejarah AD.'),
      ('POMDAM-XIX','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Kodam_Tuanku_Tambusai.png','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Tuanku_Tambusai.png','unverified','PNG','Kandidat Wikimedia Commons; vectorized from photo; bukan file langsung dari situs resmi unit.'),
      ('POMDAM-XX','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Kodam_Tuanku_Imam_Bonjol.png','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Tuanku_Imam_Bonjol.png','unverified','PNG','Kandidat Wikimedia Commons oleh kontributor; belum diverifikasi terhadap file resmi unit.'),
      ('POMDAM-XXI','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Komando_Daerah_Militer_Radin_Inten.png','https://commons.wikimedia.org/wiki/File:Lambang_Komando_Daerah_Militer_Radin_Inten.png','unverified','PNG','Metadata file Commons mengatribusikan sumber/pembuat kepada Kodam XXI/Radin Inten; belum diverifikasi terhadap file resmi langsung.'),
      ('POMDAM-XXII','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Kodam_XXII_Tambun_Bungai_%282025%29.png','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_XXII_Tambun_Bungai_(2025).png','unverified','PNG','Metadata file Commons menyebut foto dari Kodam XXII/Tambun Bungai; verifikasi visual resmi masih diperlukan.'),
      ('POMDAM-XXIII','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Kodam_Palaka_Wira.png','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Palaka_Wira.png','unverified','PNG','Kandidat Wikimedia Commons oleh kontributor; belum diverifikasi terhadap file resmi langsung.'),
      ('POMDAM-XXIV','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Kodam_XXIII_Mandala_Trikora.png','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_XXIII_Mandala_Trikora.png','unverified','PNG','Caption file Commons menyebut XXIV/Mandala Trikora, tetapi filename memakai XXIII dan sumber file menyebut Scribd; perlu tinjauan.'),
      ('POMDAM-XXV','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXV_SMR.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXV_SMR.png','unverified','PNG','Rekreasi desain oleh Kur3115; file page menyebut CC BY-SA 4.0; simpan atribusi jika digunakan.'),
      ('POMDAM-XXVI','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXVI_MATARAM.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVI_MATARAM.png','unverified','PNG','Rekreasi desain oleh Kur3115; verifikasi terhadap aset resmi unit diperlukan.'),
      ('POMDAM-XXVII','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXVII_SOBE_SONBAI.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVII_SOBE_SONBAI.png','unverified','PNG','Kandidat Wikimedia Commons oleh Kur3115, CC0; verifikasi unit tetap diperlukan.'),
      ('POMDAM-XXVIII','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXVII_MOLOKU_KIE_RAHA.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVII_MOLOKU_KIE_RAHA.png','unverified','PNG','Caption menyebut XXVIII/Moloku Kie Raha tetapi filename berisi XXVII; perlu verifikasi visual.'),
      ('POMDAM-XXIX','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXIX_MAMBRUK.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXIX_MAMBRUK.png','unverified','PNG','Rekreasi desain oleh Kur3115; belum dibandingkan dengan aset resmi unit.'),
      ('POMDAM-XXX','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXX_RINAMBORA.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXX_RINAMBORA.png','unverified','PNG','Kandidat rekreasi; caption Commons menyebut Tinambora sedangkan nomenklatur resmi Rinambora; perlu konfirmasi visual.')
    ) as v(org_code,asset_url,source_url,verification_status,file_format,license_notes)
  loop
    select o.id into v_org_id
    from public.organizations o
    where o.code=r.org_code
    order by o.valid_from desc nulls first
    limit 1;
    if v_org_id is null then
      raise exception 'Missing POMDAM organization master row for %', r.org_code;
    end if;

    select e.id into v_emblem_id
    from public.organization_emblems e
    where e.organization_id=v_org_id and e.is_primary=true
    order by e.created_at
    limit 1;

    if v_emblem_id is null then
      insert into public.organization_emblems(
        organization_id,asset_url,source_url,file_format,
        verification_status,license_notes,is_primary
      ) values (
        v_org_id,r.asset_url,r.source_url,r.file_format,
        r.verification_status,r.license_notes,true
      );
    else
      update public.organization_emblems
      set asset_url=r.asset_url,source_url=r.source_url,
          file_format=r.file_format,verification_status=r.verification_status,
          license_notes=r.license_notes,is_primary=true
      where id=v_emblem_id;
    end if;
  end loop;
end $$;

insert into public.organization_aliases(
  organization_id,alias,alias_type,source_reference,notes
)
select o.id,v.alias,v.alias_type,
 'https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama',v.notes
from (values
 ('POMDAM-XV','XVI/PTM','historical_name','Kode lama di direktori Dinas Sejarah AD; master kanonik tetap XV/PTM.'),
 ('POMDAM-II','II/SJW','source_label','Variasi singkatan pada direktori Dinas Sejarah AD; master kanonik tetap II/SWJ.'),
 ('POMDAM-XIV','XIV/HSD','source_label','Variasi singkatan pada direktori Dinas Sejarah AD; master kanonik tetap XIV/HSN.')
 ,('POMDAM-XIX','XIX/TT','source_label','Label pada workbook Rekap Pelanggaran.xlsx; master kanonik POMDAM XIX/TUTAM.')
) as v(org_code,alias,alias_type,notes)
join public.organizations o on o.code=v.org_code
where not exists(
  select 1 from public.organization_aliases a
  where a.organization_id=o.id and a.alias=v.alias and a.alias_type=v.alias_type
);

insert into public.master_data_sources(source_name,source_url,source_type,publisher,reliability,notes)
values
 ('Direktori lambang Kotama TNI AD','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','pomdam_emblem_catalog','Dinas Sejarah Angkatan Darat','primary_official','Memuat gambar lambang dan tautan satuan untuk 15 unit lama. Aset dilekatkan langsung ke record POMDAM sesuai aturan aplikasi.'),
 ('Daftar Kodam TNI AD 2026 — Potret TMMD ke-127','https://tniad.mil.id/konten/unggahan/2026/04/POTRET-TMMD-KE-127.pdf','pomdam_nomenclature','TNI Angkatan Darat','primary_official','Rujukan nomenklatur satuan 2026, termasuk XV/Pattimura dan enam satuan XIX–XXIV.'),
 ('Peresmian enam Kodam baru 2025','https://tniad.mil.id/presiden-resmikan-6-kodam-baru-dan-satuan-teritorial-pembangunan-perkuat-pertahanan-dukung-kesejahteraan-rakyat/','pomdam_nomenclature','TNI Angkatan Darat','primary_official','Rujukan pembentukan dan penamaan enam satuan XIX–XXIV pada 10 Agustus 2025.'),
 ('Peresmian enam Kodam baru 2026','https://tniad.mil.id/hut-ke-81-tni-kasad-saksikan-peresmian-enam-kodam-baru/','pomdam_nomenclature','TNI Angkatan Darat','primary_official','Rujukan pembentukan dan penamaan enam satuan XXV–XXX pada 5 Oktober 2026.'),
 ('Konfirmasi nama dan lambang Kodam XIX/Tuanku Tambusai','https://mediacenter.riau.go.id/arsip/93266','pomdam_emblem_context','Media Center Riau','official_secondary','Menjelaskan bahwa lambang XIX/Tuanku Tambusai dirancang dengan arahan LAMR dan digunakan secara resmi.'),
 ('Logo POMDAM XIX — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Tuanku_Tambusai.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat logo; atribusi dan sumber gambar tercatat pada halaman file. Belum diverifikasi langsung.'),
 ('Logo POMDAM XX — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Tuanku_Imam_Bonjol.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat logo; belum diverifikasi terhadap aset resmi langsung.'),
 ('Logo POMDAM XXI — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Komando_Daerah_Militer_Radin_Inten.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Metadata file mengatribusikan sumber/pembuat kepada Kodam XXI/Radin Inten; tetap menunggu verifikasi langsung.'),
 ('Logo POMDAM XXII — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_XXII_Tambun_Bungai_(2025).png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Metadata file mengatribusikan foto kepada Kodam XXII/Tambun Bungai; tetap menunggu verifikasi langsung.'),
 ('Logo POMDAM XXIII — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Palaka_Wira.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat logo oleh kontributor Commons; belum diverifikasi langsung.'),
 ('Logo POMDAM XXIV — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_XXIII_Mandala_Trikora.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Filename dan caption berbeda angka Romawi; kandidat wajib ditinjau.'),
 ('Logo POMDAM XXV — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXV_SMR.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat rekreasi desain, CC BY-SA 4.0; atribusi harus dipertahankan.'),
 ('Logo POMDAM XXVI — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVI_MATARAM.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat rekreasi desain; belum diverifikasi langsung.'),
 ('Logo POMDAM XXVII — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVII_SOBE_SONBAI.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat komunitas CC0; belum diverifikasi langsung.'),
 ('Logo POMDAM XXVIII — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVII_MOLOKU_KIE_RAHA.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Caption menyebut XXVIII tetapi filename XXVII; perlu diperiksa.'),
 ('Logo POMDAM XXIX — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXIX_MAMBRUK.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat rekreasi desain; belum diverifikasi langsung.'),
 ('Logo POMDAM XXX — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXX_RINAMBORA.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Caption file menyebut Tinambora, sedangkan nomenklatur resmi Rinambora; perlu diperiksa.')
on conflict (source_url) where source_url is not null do update
set source_name=excluded.source_name,source_type=excluded.source_type,
    publisher=excluded.publisher,reliability=excluded.reliability,notes=excluded.notes;


-- Reusable Laka Lalin reference masters. Operational workbook facts are not seeded.
insert into public.laka_lalin_accident_types(code,name,description,display_order) values
 ('GANDA','GANDA','Label kategori sesuai header workbook.',1),
 ('TUNGGAL','TUNGGAL','Label kategori sesuai header workbook.',2),
 ('TABRAK_LARI','TABRAK LARI','Label gabungan header TABRAK dan subheader LARI pada workbook.',3)
on conflict(code) do update
set name=excluded.name,description=excluded.description,display_order=excluded.display_order,is_active=true;

insert into public.laka_lalin_loss_severities(code,name,description,display_order) values
 ('MD','MD','Kode jenis kerugian personel sesuai workbook; kepanjangan tidak diasumsikan.',1),
 ('LB','LB','Kode jenis kerugian personel sesuai workbook; kepanjangan tidak diasumsikan.',2),
 ('LR','LR','Kode jenis kerugian personel sesuai workbook; kepanjangan tidak diasumsikan.',3)
on conflict(code) do update
set name=excluded.name,description=excluded.description,display_order=excluded.display_order,is_active=true;

insert into public.laka_lalin_vehicle_types(code,name,description,display_order) values
 ('RANDIS','RANDIS','Kategori kendaraan sesuai header workbook.',1),
 ('RAN_UMUM','RAN UMUM','Kategori kendaraan sesuai header workbook.',2)
on conflict(code) do update
set name=excluded.name,description=excluded.description,display_order=excluded.display_order,is_active=true;

insert into public.laka_lalin_damage_levels(code,name,description,display_order) values
 ('RB','RB','Kode tingkat kerusakan sesuai workbook; kepanjangan tidak diasumsikan.',1),
 ('RR','RR','Kode tingkat kerusakan sesuai workbook; kepanjangan tidak diasumsikan.',2)
on conflict(code) do update
set name=excluded.name,description=excluded.description,display_order=excluded.display_order,is_active=true;


-- Reusable Tindak Pidana categories. Operational workbook facts stay out of seed.sql.
insert into public.tindak_pidana_categories(code,name,display_order) values
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
 ('TP113','Menghilangkan alat perang',113)
on conflict(code) do update
set name=excluded.name,display_order=excluded.display_order,is_active=true;

-- Keep source POMDAM header labels as aliases while retaining canonical 27-POMDAM identity.
insert into public.organization_aliases(organization_id,alias,alias_type,source_reference,notes)
select o.id,v.alias,'source_label','6. REKAPTINDAK PIDANA TA 2026.xlsx',v.notes
from (values
 ('POMDAM-III','POMDAM /III','Shortened source header; matched to the POMDAM-III block position.'),
 ('POMDAM-IV','POMDAM /IV DIP','Shortened source header; matched to the POMDAM-IV block position.'),
 ('POMDAM-XV','POMDAM XVI/PTM','Workbook historical label maps to canonical POMDAM XV/PTM.'),
 ('POMDAM-XVIII','POMDAM XVIII/KAS','Alternative annual-summary label; monthly sheets use KSR.')
) v(code,alias,notes)
join public.organizations o on o.code=v.code
on conflict do nothing;
