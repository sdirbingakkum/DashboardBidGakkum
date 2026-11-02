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

  select count(*) into n from public.provos_education_statuses;
  if n <> 2 then raise exception 'Expected Provos education statuses SUDAH/BELUM, got %', n; end if;
  if exists (
    with expected(code,ord) as (values ('SUDAH',1),('BELUM',2))
    select 1 from expected e
    left join public.provos_education_statuses s on s.code=e.code
    where s.id is null or s.display_order<>e.ord or not s.is_active
  ) then raise exception 'Provos education status master must contain SUDAH and BELUM'; end if;
  if exists (
    select 1 from public.provos_reports
  ) or exists (select 1 from public.provos_rank_counts)
    or exists (select 1 from public.provos_education_counts) then
    raise exception 'Operational Provos snapshots must be imported through validated batches, not seed.sql';
  end if;
  if exists (
    select 1 from pg_class c join pg_namespace nsp on nsp.oid=c.relnamespace
    where nsp.nspname='public'
      and c.relname in ('provos_education_statuses','provos_reports','provos_rank_counts','provos_education_counts')
      and not c.relrowsecurity
  ) then raise exception 'RLS must be enabled on all Provos tables'; end if;
  select count(*) into n from public.sim_categories;
  if n <> 5 then raise exception 'Expected 5 SIM category master rows, got %', n; end if;
  if exists (
    with expected(code,name,ord) as (values
      ('A','A',1),('BI','BI',2),('BII','BII',3),
      ('BII_SUS','B II SUS',4),('C','C',5)
    )
    select 1 from expected e
    left join public.sim_categories sc on sc.code=e.code
    where sc.id is null or sc.name<>e.name or sc.display_order<>e.ord or not sc.is_active
  ) then raise exception 'SIM category master must contain A, BI, BII, B II SUS, C in canonical order'; end if;
  if not exists (
    select 1 from pg_class c join pg_namespace nsp on nsp.oid=c.relnamespace
    where nsp.nspname='public' and c.relname='sim_categories' and c.relrowsecurity
  ) then raise exception 'RLS must be enabled on sim_categories'; end if;
  if not exists (
    select 1 from pg_class c join pg_namespace nsp on nsp.oid=c.relnamespace
    where nsp.nspname='public' and c.relname='sim_report_counts' and c.relrowsecurity
  ) then raise exception 'RLS must be enabled on sim_report_counts'; end if;
  if exists (select 1 from public.sim_report_counts) then
    raise exception 'Workbook facts are imported operational data and must not be preloaded by seed.sql';
  end if;
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
  if n < 8 then raise exception 'Expected at least 8 preserved workbook/source aliases, got %', n; end if;
  if not exists (
    select 1 from public.organization_aliases a
    join public.organizations o on o.id=a.organization_id
    where o.code='POMDAM-XIX' and a.alias='XIX/TT'
  ) then raise exception 'Workbook alias XIX/TT must map to POMDAM XIX/TUTAM'; end if;

  select count(*) into n from public.organization_emblems where is_primary=true;
  if n <> 27 then raise exception 'Expected one primary emblem for each of 27 POMDAM units, got %', n; end if;
  if exists (
    select 1 from public.organizations o
    where not exists (
      select 1 from public.organization_emblems e
      where e.organization_id=o.id
        and e.is_primary=true
        and nullif(btrim(e.asset_url),'') is not null
    )
  ) then raise exception 'Every POMDAM must have a non-empty primary emblem asset URL'; end if;
  if exists (
    select 1 from public.organization_emblems
    where is_primary=true
      and verification_status not in ('verified','unverified')
  ) then raise exception 'Every primary emblem must have an explicit verification state'; end if;
  if not exists (
    select 1 from pg_indexes
    where schemaname='public'
      and indexname='organization_emblems_one_primary_per_org_uidx'
  ) then raise exception 'Unique primary emblem invariant index is missing'; end if;
  select count(*) into n from public.master_data_sources;
  if n < 21 then raise exception 'Expected official and emblem provenance sources, got %', n; end if;
  if exists (select 1 from public.report_counts) then
    raise exception 'Workbook facts are not part of seed.sql; report data is loaded through validated import batches';
  end if;
  if not (
    select c.relrowsecurity from pg_class c
    join pg_namespace s on s.oid=c.relnamespace
    where s.nspname='public' and c.relname='organizations'
  ) then raise exception 'RLS must be enabled on organizations'; end if;

  -- Laka Lalin reusable reference masters are canonical and operational facts stay out of seed.sql.
  if (select count(*) from public.laka_lalin_accident_types) <> 3 then
    raise exception 'Expected 3 Laka Lalin accident-type master rows';
  end if;
  if exists (
    with expected(code,name,ord) as (values
      ('GANDA','GANDA',1),('TUNGGAL','TUNGGAL',2),('TABRAK_LARI','TABRAK LARI',3)
    )
    select 1 from expected e
    left join public.laka_lalin_accident_types m on m.code=e.code
    where m.id is null or m.name<>e.name or m.display_order<>e.ord or not m.is_active
  ) then raise exception 'Laka Lalin accident-type master mismatch'; end if;

  if exists (
    with expected(code,name,ord) as (values
      ('MD','MD',1),('LB','LB',2),('LR','LR',3)
    )
    select 1 from expected e
    left join public.laka_lalin_loss_severities m on m.code=e.code
    where m.id is null or m.name<>e.name or m.display_order<>e.ord or not m.is_active
  ) then raise exception 'Laka Lalin loss-severity master mismatch'; end if;

  if exists (
    with expected(code,name,ord) as (values
      ('RANDIS','RANDIS',1),('RAN_UMUM','RAN UMUM',2)
    )
    select 1 from expected e
    left join public.laka_lalin_vehicle_types m on m.code=e.code
    where m.id is null or m.name<>e.name or m.display_order<>e.ord or not m.is_active
  ) then raise exception 'Laka Lalin vehicle-type master mismatch'; end if;

  if exists (
    with expected(code,name,ord) as (values
      ('RB','RB',1),('RR','RR',2)
    )
    select 1 from expected e
    left join public.laka_lalin_damage_levels m on m.code=e.code
    where m.id is null or m.name<>e.name or m.display_order<>e.ord or not m.is_active
  ) then raise exception 'Laka Lalin damage-level master mismatch'; end if;

  if exists (
    select 1 from (values
      ('laka_lalin_accident_types'),
      ('laka_lalin_loss_severities'),
      ('laka_lalin_vehicle_types'),
      ('laka_lalin_damage_levels'),
      ('laka_lalin_reports'),
      ('laka_lalin_report_counts')
    ) t(table_name)
    where not exists (
      select 1 from pg_class c
      join pg_namespace nsp on nsp.oid=c.relnamespace
      where nsp.nspname='public' and c.relname=t.table_name and c.relrowsecurity
    )
  ) then raise exception 'RLS must be enabled on all Laka Lalin tables'; end if;

  if exists (select 1 from public.laka_lalin_reports)
     or exists (select 1 from public.laka_lalin_report_counts) then
    raise exception 'Laka Lalin workbook facts are operational import data and must not be preloaded by seed.sql';
  end if;

end $$;
rollback;
