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
