insert into public.organization_types(code,name,description) values
 ('KODAM','Komando Daerah Militer','Komando wilayah TNI Angkatan Darat.'),
 ('POMDAM','Polisi Militer Kodam','Unsur Polisi Militer pada tingkat Kodam; relasi induk harus diverifikasi per satuan.'),
 ('POMAD','Polisi Militer Angkatan Darat','Organisasi Polisi Militer tingkat TNI Angkatan Darat.'),
 ('PUSPOMAD','Pusat Polisi Militer Angkatan Darat','Unsur pusat Polisi Militer TNI Angkatan Darat.')
on conflict(code) do update set name=excluded.name,description=excluded.description;
insert into public.personnel_categories(code,name,description,category_type,display_order) values
 ('PA','Perwira','Kelompok golongan personel Perwira.','personnel_group',1),
 ('BA','Bintara','Kelompok golongan personel Bintara.','personnel_group',2),
 ('TA','Tamtama','Kelompok golongan personel Tamtama.','personnel_group',3),
 ('PNS','Pegawai Negeri Sipil','Kelompok personel Pegawai Negeri Sipil; bukan pangkat militer.','civil_service_group',4)
on conflict(code) do update set name=excluded.name,description=excluded.description,category_type=excluded.category_type,display_order=excluded.display_order;
insert into public.violation_groups(code,name,description,display_order) values
 ('B','Pelanggaran disiplin/ketertiban kategori B','Kelompok kategori B sebagaimana label di workbook Rekap Pelanggaran.',1),
 ('C','Pelanggaran lalu lintas kategori C','Kelompok kategori C sebagaimana label di workbook Rekap Pelanggaran.',2)
on conflict(code) do update set name=excluded.name,description=excluded.description,display_order=excluded.display_order;
insert into public.terminology(term,expansion,domain,verification_status,notes) values
 ('TNI','Tentara Nasional Indonesia','organisasi','verified',null),
 ('TNI AD','Tentara Nasional Indonesia Angkatan Darat','organisasi','verified',null),
 ('POMAD','Polisi Militer Angkatan Darat','organisasi','verified',null),
 ('PUSPOMAD','Pusat Polisi Militer Angkatan Darat','organisasi','verified',null),
 ('KODAM','Komando Daerah Militer','organisasi','verified',null),
 ('POMDAM','Polisi Militer Kodam','organisasi','needs_verification','Keberadaan satuan aktif diverifikasi satu per satu, tidak diasumsikan sama dengan jumlah Kodam.'),
 ('KOREM','Komando Resor Militer','organisasi','verified',null),
 ('KODIM','Komando Distrik Militer','organisasi','verified',null),
 ('KORAMIL','Komando Rayon Militer','organisasi','verified',null),
 ('DENPOM','Detasemen Polisi Militer','organisasi','needs_verification',null),
 ('SUBDENPOM','Sub Detasemen Polisi Militer','organisasi','needs_verification',null),
 ('KASAD','Kepala Staf Angkatan Darat','jabatan','verified',null),
 ('WAKASAD','Wakil Kepala Staf Angkatan Darat','jabatan','verified',null),
 ('PANGDAM','Panglima Komando Daerah Militer','jabatan','verified',null),
 ('DANPOMDAM','Komandan Polisi Militer Kodam','jabatan','verified',null),
 ('KASDAM','Kepala Staf Kodam','jabatan','verified',null),
 ('DANDENPOM','Komandan Detasemen Polisi Militer','jabatan','needs_verification',null),
 ('BALAKDAM','Badan Pelaksana Kodam','organisasi','needs_verification',null),
 ('KODAL','Komando Pengendalian','organisasi','needs_verification','Makna dapat bergantung konteks; jangan digunakan sebagai nama satuan tanpa sumber.')
on conflict(term) do update set expansion=excluded.expansion,domain=excluded.domain,verification_status=excluded.verification_status,notes=excluded.notes;
insert into public.master_data_sources(source_name,source_url,source_type,publisher,reliability,notes) values
 ('Daftar Satuan TNI AD','https://tniad.mil.id/link-satuan/','official_directory','TNI AD','primary_official','Rujukan struktur/satuan; daftar satuan dan nomenklatur dapat berubah.'),
 ('Peresmian enam Kodam baru pada HUT ke-81 TNI','https://tniad.mil.id/hut-ke-81-tni-kasad-saksikan-peresmian-enam-kodam-baru/','official_release','TNI AD','primary_official','Rujukan pengumuman enam Kodam baru pada 5 Oktober 2026; perlu cocokkan ke daftar satuan terkini.'),
 ('Presiden resmikan 204 satuan baru TNI','https://www.setneg.go.id/baca/index/presiden_prabowo_resmikan_204_satuan_baru_tni_pada_peringatan_hut_ke_81_tni','official_release','Sekretariat Negara RI','primary_official','Rujukan struktur satuan pada 5 Oktober 2026.'),
 ('Logo Kodam Iskandar Muda','https://ppid.tniad.mil.id/index.php/i/339/logo-kodam-im-terbaru','official_asset_reference','PPID TNI AD','primary_official','Contoh sumber lambang Kodam; setiap aset perlu diverifikasi satu per satu.')
on conflict do nothing;
insert into public.organizations(organization_type_id,code,short_name,official_name,status,display_order,metadata)
select t.id,v.code,v.short_name,v.official_name,'needs_verification',v.ord,
 jsonb_build_object('dataset_scope','kodam_directory_research_2026','verification_note','Kodam directory candidate; verify current official formation/name and effective date before operational use.')
from public.organization_types t
cross join (values
 ('IM','KODAM IM','Komando Daerah Militer Iskandar Muda',1),
 ('I','KODAM I/BB','Komando Daerah Militer I/Bukit Barisan',2),
 ('II','KODAM II/SWJ','Komando Daerah Militer II/Sriwijaya',3),
 ('III','KODAM III/SLW','Komando Daerah Militer III/Siliwangi',4),
 ('IV','KODAM IV/DIP','Komando Daerah Militer IV/Diponegoro',5),
 ('V','KODAM V/BRW','Komando Daerah Militer V/Brawijaya',6),
 ('VI','KODAM VI/MLW','Komando Daerah Militer VI/Mulawarman',7),
 ('IX','KODAM IX/UDY','Komando Daerah Militer IX/Udayana',8),
 ('XII','KODAM XII/TPR','Komando Daerah Militer XII/Tanjungpura',9),
 ('XIII','KODAM XIII/MDK','Komando Daerah Militer XIII/Merdeka',10),
 ('XIV','KODAM XIV/HSN','Komando Daerah Militer XIV/Hasanuddin',11),
 ('XV','KODAM XV/PTM','Komando Daerah Militer XV/Pattimura',12),
 ('XVII','KODAM XVII/CEN','Komando Daerah Militer XVII/Cenderawasih',13),
 ('XVIII','KODAM XVIII/KSR','Komando Daerah Militer XVIII/Kasuari',14),
 ('XIX','KODAM XIX/TUTAM','Komando Daerah Militer XIX/Tuanku Tambusai',15),
 ('XX','KODAM XX/TIB','Komando Daerah Militer XX/Tuanku Imam Bonjol',16),
 ('XXI','KODAM XXI/RI','Komando Daerah Militer XXI/Radin Inten',17),
 ('XXII','KODAM XXII/TB','Komando Daerah Militer XXII/Tambun Bungai',18),
 ('XXIII','KODAM XXIII/PW','Komando Daerah Militer XXIII/Palaka Wira',19),
 ('XXIV','KODAM XXIV/MT','Komando Daerah Militer XXIV/Mandala Trikora',20),
 ('XXV','KODAM XXV/SMRS','Komando Daerah Militer XXV/Sultan Mahmud Riayat Syah',21),
 ('XXVI','KODAM XXVI/MTM','Komando Daerah Militer XXVI/Mataram',22),
 ('XXVII','KODAM XXVII/SS','Komando Daerah Militer XXVII/Sobe Sonbai',23),
 ('XXVIII','KODAM XXVIII/MKR','Komando Daerah Militer XXVIII/Moloku Kie Raha',24),
 ('XXIX','KODAM XXIX/MMB','Komando Daerah Militer XXIX/Mambruk',25),
 ('XXX','KODAM XXX/RNB','Komando Daerah Militer XXX/Rinambora',26),
 ('JAYA','KODAM JAYA','Komando Daerah Militer Jayakarta',27)
) as v(code,short_name,official_name,ord)
where t.code='KODAM'
on conflict (code,valid_from) do update set short_name=excluded.short_name,official_name=excluded.official_name,metadata=excluded.metadata,status='needs_verification'
where organizations.organization_type_id = excluded.organization_type_id;
insert into public.organizations(organization_type_id,code,short_name,official_name,status,display_order,metadata)
select t.id,'POMAD','POMAD','Polisi Militer Angkatan Darat','needs_verification',1,
 jsonb_build_object('dataset_scope','central_organization','verification_note','Include as master unit; verify exact current chain of command.')
from public.organization_types t where t.code='POMAD'
on conflict (code,valid_from) do nothing;
insert into public.organization_aliases(organization_id,alias,alias_type,source_reference,notes)
select o.id,v.alias,v.alias_type,'Rekap Pelanggaran.xlsx (2026)',
 'Alias dipertahankan sebagai label historis/sumber; belum dikoreksi tanpa bukti nomenklatur resmi.'
from (values
 ('XV','XV/PTM','legacy_code','Workbook includes variant XV/PTM versus current candidate KODAM XV/PTM.'),
 ('XXIV','XIV/MT','spelling_variant','Workbook contains XIV/MT; possible ordinal/code typo.'),
 ('XXII','XX/TB','legacy_code','Workbook contains XX/TB; possible missing ordinal digit.'),
 ('XXII','XXII/TB','source_label','Workbook code variant.')
) v(code,alias,alias_type,notes)
join public.organizations o on o.code=v.code
on conflict do nothing;
insert into public.positions(code,short_name,official_name,organization_type_id,description) values
 ('PANGDAM','PANGDAM','Panglima Komando Daerah Militer',(select id from public.organization_types where code='KODAM'),'Pimpinan Kodam.'),
 ('KASDAM','KASDAM','Kepala Staf Kodam',(select id from public.organization_types where code='KODAM'),'Kepala staf Kodam.'),
 ('IRDAM','IRDAM','Inspektur Kodam',(select id from public.organization_types where code='KODAM'),'Inspektur Kodam.'),
 ('KAPOKSAHLI','KAPOKSAHLI','Kepala Kelompok Staf Ahli',(select id from public.organization_types where code='KODAM'),'Jabatan staf ahli Kodam.'),
 ('ASRENDAM','ASRENDAM','Asisten Perencanaan Kodam',(select id from public.organization_types where code='KODAM'),'Asisten perencanaan.'),
 ('ASINTEL','ASINTEL','Asisten Intelijen',(select id from public.organization_types where code='KODAM'),'Asisten intelijen.'),
 ('ASOPS','ASOPS','Asisten Operasi',(select id from public.organization_types where code='KODAM'),'Asisten operasi.'),
 ('ASPERS','ASPERS','Asisten Personel',(select id from public.organization_types where code='KODAM'),'Asisten personel.'),
 ('ASLOG','ASLOG','Asisten Logistik',(select id from public.organization_types where code='KODAM'),'Asisten logistik.'),
 ('ASTER','ASTER','Asisten Teritorial',(select id from public.organization_types where code='KODAM'),'Asisten teritorial.'),
 ('KAPENDAM','KAPENDAM','Kepala Penerangan Kodam',(select id from public.organization_types where code='KODAM'),'Kepala penerangan Kodam.'),
 ('DANPOMDAM','DANPOMDAM','Komandan Polisi Militer Kodam',(select id from public.organization_types where code='POMDAM'),'Komandan Pomdam; jabatan tidak otomatis mengasumsikan unit Pomdam aktif di semua Kodam.'),
 ('KAAJENDAM','KAAJENDAM','Kepala Ajudan Jenderal Kodam',(select id from public.organization_types where code='KODAM'),'Kepala Ajudan Jenderal Kodam.'),
 ('DANRINDAM','DANRINDAM','Komandan Resimen Induk Daerah Militer',(select id from public.organization_types where code='KODAM'),'Komandan Rindam.'),
 ('DANREM','DANREM','Komandan Resor Militer',null,'Komandan Korem.'),
 ('DANDIM','DANDIM','Komandan Distrik Militer',null,'Komandan Kodim.'),
 ('DANRAMIL','DANRAMIL','Komandan Rayon Militer',null,'Komandan Koramil.')
on conflict(code) do update set short_name=excluded.short_name,official_name=excluded.official_name,organization_type_id=excluded.organization_type_id,description=excluded.description;
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
on conflict(code) do update set name=excluded.name,source_label=excluded.source_label,display_order=excluded.display_order;
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