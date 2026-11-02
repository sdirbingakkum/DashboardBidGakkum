-- Run with psql against a local Supabase database after migrations + seed.
begin;
do $$
declare n integer;
begin
  select count(*) into n from public.organization_types;
  if n <> 4 then raise exception 'Expected 4 organization types, got %', n; end if;
  select count(*) into n from public.organizations o
    join public.organization_types t on t.id=o.organization_type_id
    where t.code='KODAM';
  if n <> 27 then raise exception 'Expected 27 provisional KODAM candidate rows, got %', n; end if;
  if exists (
    select 1 from public.organizations o
    join public.organization_types t on t.id=o.organization_type_id
    where t.code='KODAM' and o.status <> 'needs_verification'
  ) then raise exception 'KODAM candidate rows must remain needs_verification'; end if;
  select count(*) into n from public.organizations o
    join public.organization_types t on t.id=o.organization_type_id
    where t.code='POMDAM';
  if n <> 0 then raise exception 'POMDAM child rows must not be auto-created'; end if;
  select count(*) into n from public.personnel_categories;
  if n <> 4 then raise exception 'Expected PA/BA/TA/PNS, got % rows', n; end if;
  select count(*) into n from public.violation_categories;
  if n <> 17 then raise exception 'Expected B1-B11 and C1-C6, got % rows', n; end if;
  select count(*) into n from public.reporting_periods where report_year=2026;
  if n <> 19 then raise exception 'Expected 19 periods for 2026, got %', n; end if;
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
