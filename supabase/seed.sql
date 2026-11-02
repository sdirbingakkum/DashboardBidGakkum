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
select g.id,v.code,v.name,v.code,v.ord,'needs_verification'
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
set name=excluded.name,source_label=excluded.source_label,display_order=excluded.display_order;

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
