update public.organizations
set metadata =
  (coalesce(metadata,'{}'::jsonb) - 'dataset_scope' - 'verification_note') ||
  jsonb_build_object(
    'application_scope','POMDAM_ONLY',
    'unit_exists','confirmed_by_user',
    'emblem_rule','exact_same_emblem_as_the_matching_unit_name',
    'legacy_source_code',coalesce(metadata->>'legacy_source_code',regexp_replace(code,'^POMDAM-',''))
  ),
  status='active',
  updated_at=now()
where code like 'POMDAM-%';

delete from public.master_data_sources
where source_url not in (
  'https://ppid.tniad.mil.id/index.php/i/339/logo-kodam-im-terbaru',
  'https://tniad.mil.id/jabatan-danpomdam-dan-kaajendam-vbrawijaya-diserah-terimakan/',
  'https://tniad.mil.id/pangdam-ibb-pimpin-sertijab-danpomdam-ibb-dan-dandeninteldam-ibb/',
  'https://tniad.mil.id/sertijab-kapendam-srendam-dan-pomdam/'
);

with ranked as (
  select id,row_number() over(partition by source_url order by created_at,id) rn
  from public.master_data_sources
  where source_url is not null
)
delete from public.master_data_sources s
using ranked r
where s.id=r.id and r.rn>1;

create unique index if not exists master_data_sources_source_url_uidx
  on public.master_data_sources(source_url)
  where source_url is not null;

update public.master_data_sources
set source_name='Rujukan lambang POMDAM IM',
    source_type='pomdam_emblem_reference',
    notes='Rujukan aset lambang untuk POMDAM IM. Gunakan lambang yang identik dengan satuan teritorial bernama sama; file aset belum diekstrak ke Storage.'
where source_url='https://ppid.tniad.mil.id/index.php/i/339/logo-kodam-im-terbaru';

insert into public.master_data_sources(source_name,source_url,source_type,publisher,reliability,notes)
values
 ('Serah terima jabatan DANPOMDAM V/Brawijaya','https://tniad.mil.id/jabatan-danpomdam-dan-kaajendam-vbrawijaya-diserah-terimakan/','pomdam_official_reference','TNI AD','primary_official','Rujukan nomenklatur dan jabatan satuan POMDAM V/Brawijaya.'),
 ('Serah terima jabatan DANPOMDAM I/BB','https://tniad.mil.id/pangdam-ibb-pimpin-sertijab-danpomdam-ibb-dan-dandeninteldam-ibb/','pomdam_official_reference','TNI AD','primary_official','Rujukan nomenklatur dan jabatan satuan POMDAM I/BB.'),
 ('Serah terima jabatan POMDAM','https://tniad.mil.id/sertijab-kapendam-srendam-dan-pomdam/','pomdam_official_reference','TNI AD','primary_official','Rujukan istilah POMDAM dalam rilis resmi TNI AD.')
on conflict (source_url) where source_url is not null do nothing;

insert into public.organization_emblems(organization_id,asset_url,source_url,file_format,verification_status,license_notes,is_primary)
select o.id,null,'https://ppid.tniad.mil.id/index.php/i/339/logo-kodam-im-terbaru',null,'unverified',
 'Sumber resmi untuk verifikasi lambang POMDAM IM. Aturan aplikasi: emblem POMDAM harus identik dengan lambang unit teritorial bernama sama. File final belum diekstrak.',
 true
from public.organizations o
where o.code='POMDAM-IM'
and not exists (
  select 1 from public.organization_emblems e
  where e.organization_id=o.id and e.source_url='https://ppid.tniad.mil.id/index.php/i/339/logo-kodam-im-terbaru'
);
