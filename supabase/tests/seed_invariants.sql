-- Run against the local Supabase database after migrations and seed.
begin;
do $$
declare n integer;
begin
  select count(*) into n from public.organization_types;
  if n <> 1 then raise exception 'Expected exactly one organization type (POMDAM), got %', n; end if;
  if not exists (select 1 from public.organization_types where code='POMDAM') then
    raise exception 'POMDAM organization type is missing';
  end if;

  select count(*) into n from public.organizations;
  if n <> 27 then raise exception 'Expected 27 POMDAM organizations, got %', n; end if;
  if exists (
    select 1 from public.organizations o
    join public.organization_types t on t.id=o.organization_type_id
    where t.code <> 'POMDAM'
  ) then raise exception 'Non-POMDAM organization found'; end if;
  if exists (select 1 from public.organizations where status <> 'active') then
    raise exception 'Every seeded POMDAM organization must be active';
  end if;
  if exists (select 1 from public.organizations where short_name not like 'POMDAM %') then
    raise exception 'Every POMDAM display label must start with POMDAM';
  end if;
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='organizations'
      and column_name='parent_organization_id'
  ) then raise exception 'POMDAM-only schema must not have parent_organization_id'; end if;

  select count(*) into n from public.positions;
  if n <> 1 or not exists (select 1 from public.positions where code='DANPOMDAM') then
    raise exception 'Only DANPOMDAM position should be seeded';
  end if;

  select count(*) into n from public.personnel_categories;
  if n <> 4 then raise exception 'Expected PA/BA/TA/PNS, got % rows', n; end if;
  select count(*) into n from public.violation_categories;
  if n <> 17 then raise exception 'Expected B1-B11 and C1-C6, got % rows', n; end if;

  if exists (
    with expected(code,name,group_code) as (values
      ('B1','PPM','B'),('B2','GAM TNI','B'),('B3','PDG','B'),
      ('B4','Masuk daerah terlarang','B'),
      ('B5','Meninggalkan barak pada jam dinas','B'),
      ('B6','Terlambat apel','B'),('B7','Surat nyata diri','B'),
      ('B8','Surat senjata api','B'),('B9','Pungutan liar','B'),
      ('B10','Backing','B'),
      ('B11','Perbuatan lain yang bertentangan dengan perintah/peraturan/disiplin','B'),
      ('C1','Administrasi kendaraan','C'),
      ('C2','Kelengkapan wajib kendaraan','C'),
      ('C3','Rambu dan marka lalu lintas','C'),
      ('C4','Tidak menggunakan sabuk pengaman','C'),
      ('C5','Tidak menggunakan helm','C'),
      ('C6','Etika/sopan santun berlalu lintas','C')
    )
    select 1
    from expected e
    left join public.violation_categories vc on vc.code=e.code
    left join public.violation_groups vg on vg.id=vc.group_id
    where vc.id is null
       or vc.name <> e.name
       or vg.code <> e.group_code
       or vc.verification_status <> 'verified'
  ) then
    raise exception 'Official violation nomenclature B1-B11/C1-C6 must match exact labels and be verified';
  end if;
  select count(*) into n from public.reporting_periods where report_year=2026;
  if n <> 19 then raise exception 'Expected 19 periods for 2026, got %', n; end if;
  select count(*) into n from public.organization_aliases;
  if n <> 4 then raise exception 'Expected 4 preserved workbook aliases, got %', n; end if;
  if exists (select 1 from public.report_counts) then
    raise exception 'Report counts must remain empty until metric definition is confirmed';
  end if;
  if not (
    select c.relrowsecurity from pg_class c
    join pg_namespace s on s.oid=c.relnamespace
    where s.nspname='public' and c.relname='organizations'
  ) then raise exception 'RLS must be enabled on organizations'; end if;
end $$;
rollback;
