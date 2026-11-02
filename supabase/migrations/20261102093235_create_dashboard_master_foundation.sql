create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
create table public.organization_types (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  created_at timestamptz not null default now()
);
create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  organization_type_id uuid not null references public.organization_types(id),
  code text not null,
  short_name text not null,
  official_name text not null,
  parent_organization_id uuid references public.organizations(id),
  status text not null default 'needs_verification'
    check (status in ('active','inactive','planned','needs_verification','historical')),
  display_order integer,
  valid_from date,
  valid_until date,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint organizations_code_validity_unique unique (code, valid_from),
  constraint organizations_validity_check check (valid_until is null or valid_from is null or valid_until >= valid_from),
  constraint organizations_not_own_parent check (parent_organization_id is null or parent_organization_id <> id)
);
create index organizations_parent_idx on public.organizations(parent_organization_id);
create index organizations_type_status_idx on public.organizations(organization_type_id, status);
create table public.organization_aliases (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  alias text not null,
  alias_type text not null default 'legacy_code'
    check (alias_type in ('legacy_code','historical_name','spelling_variant','source_label','other')),
  source_reference text,
  valid_from date,
  valid_until date,
  notes text,
  created_at timestamptz not null default now(),
  unique (organization_id, alias, alias_type, valid_from)
);
create index organization_aliases_alias_idx on public.organization_aliases(lower(alias));
create table public.organization_emblems (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  asset_url text,
  source_url text not null,
  file_format text,
  verification_status text not null default 'unverified'
    check (verification_status in ('unverified','verified','rejected','superseded')),
  verified_at timestamptz,
  license_notes text,
  is_primary boolean not null default true,
  valid_from date,
  valid_until date,
  created_at timestamptz not null default now(),
  check (valid_until is null or valid_from is null or valid_until >= valid_from)
);
create index organization_emblems_org_idx on public.organization_emblems(organization_id, is_primary);
create table public.personnel_categories (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  category_type text not null default 'personnel_group'
    check (category_type in ('personnel_group','civil_service_group','other')),
  display_order integer,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
create table public.positions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  short_name text not null,
  official_name text not null,
  organization_type_id uuid references public.organization_types(id),
  description text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
create table public.position_assignments (
  id uuid primary key default gen_random_uuid(),
  position_id uuid not null references public.positions(id),
  organization_id uuid not null references public.organizations(id),
  incumbent_name text,
  incumbent_personnel_category_id uuid references public.personnel_categories(id),
  rank_title text,
  valid_from date,
  valid_until date,
  source_reference text,
  notes text,
  created_at timestamptz not null default now(),
  check (valid_until is null or valid_from is null or valid_until >= valid_from)
);
create index position_assignments_org_validity_idx on public.position_assignments(organization_id, valid_from, valid_until);
create table public.terminology (
  id uuid primary key default gen_random_uuid(),
  term text not null unique,
  expansion text not null,
  domain text not null,
  notes text,
  source_reference text,
  verification_status text not null default 'verified'
    check (verification_status in ('verified','needs_verification','historical','disputed')),
  created_at timestamptz not null default now()
);
create table public.master_data_sources (
  id uuid primary key default gen_random_uuid(),
  source_name text not null,
  source_url text,
  source_type text not null,
  publisher text,
  published_at date,
  accessed_at timestamptz not null default now(),
  reliability text not null default 'pending'
    check (reliability in ('primary_official','official_secondary','secondary','pending')),
  notes text,
  created_at timestamptz not null default now()
);
create table public.organization_change_log (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  change_type text not null,
  old_values jsonb,
  new_values jsonb,
  effective_at date,
  source_id uuid references public.master_data_sources(id),
  recorded_at timestamptz not null default now(),
  recorded_by uuid references auth.users(id)
);
create table public.violation_groups (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  display_order integer,
  created_at timestamptz not null default now()
);
create table public.violation_categories (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.violation_groups(id),
  code text not null unique,
  name text not null,
  description text,
  legal_basis text,
  source_label text,
  display_order integer,
  is_active boolean not null default true,
  verification_status text not null default 'needs_verification'
    check (verification_status in ('verified','needs_verification','disputed','historical')),
  created_at timestamptz not null default now()
);
create table public.reporting_periods (
  id uuid primary key default gen_random_uuid(),
  report_year smallint not null,
  period_type text not null check (period_type in ('month','quarter','semester','year')),
  period_number smallint not null,
  period_label text not null,
  starts_on date not null,
  ends_on date not null,
  created_at timestamptz not null default now(),
  unique (report_year, period_type, period_number),
  check (ends_on >= starts_on),
  check (
    (period_type='month' and period_number between 1 and 12) or
    (period_type='quarter' and period_number between 1 and 4) or
    (period_type='semester' and period_number between 1 and 2) or
    (period_type='year' and period_number=1)
  )
);
create table public.report_imports (
  id uuid primary key default gen_random_uuid(),
  file_name text not null,
  file_sha256 text,
  report_year smallint,
  source_period_label text,
  source_organization_id uuid references public.organizations(id),
  imported_by uuid references auth.users(id),
  import_status text not null default 'pending'
    check (import_status in ('pending','validated','accepted','rejected','superseded')),
  validation_summary jsonb not null default '{}'::jsonb,
  imported_at timestamptz not null default now(),
  accepted_at timestamptz,
  notes text
);
create table public.report_counts (
  id uuid primary key default gen_random_uuid(),
  report_period_id uuid not null references public.reporting_periods(id),
  organization_id uuid not null references public.organizations(id),
  violation_category_id uuid not null references public.violation_categories(id),
  personnel_category_id uuid not null references public.personnel_categories(id),
  reported_count integer not null check (reported_count >= 0),
  measure_code text not null default 'jumlah_tercatat'
    check (measure_code in ('jumlah_tercatat','incident_count','personnel_count','other')),
  source_import_id uuid references public.report_imports(id),
  source_sheet text,
  source_cell text,
  verification_status text not null default 'unverified'
    check (verification_status in ('unverified','verified','disputed','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (report_period_id, organization_id, violation_category_id, personnel_category_id, measure_code)
);
create index report_counts_period_org_idx on public.report_counts(report_period_id, organization_id);
create index report_counts_category_idx on public.report_counts(violation_category_id, report_period_id);
create index report_counts_import_idx on public.report_counts(source_import_id);
alter table public.organization_types enable row level security;
alter table public.organizations enable row level security;
alter table public.organization_aliases enable row level security;
alter table public.organization_emblems enable row level security;
alter table public.personnel_categories enable row level security;
alter table public.positions enable row level security;
alter table public.position_assignments enable row level security;
alter table public.terminology enable row level security;
alter table public.master_data_sources enable row level security;
alter table public.organization_change_log enable row level security;
alter table public.violation_groups enable row level security;
alter table public.violation_categories enable row level security;
alter table public.reporting_periods enable row level security;
alter table public.report_imports enable row level security;
alter table public.report_counts enable row level security;
grant select on public.organization_types, public.organizations, public.organization_aliases,
 public.organization_emblems, public.personnel_categories, public.positions,
 public.position_assignments, public.terminology, public.master_data_sources,
 public.organization_change_log, public.violation_groups, public.violation_categories,
 public.reporting_periods, public.report_imports, public.report_counts to authenticated;
grant all on public.organization_types, public.organizations, public.organization_aliases,
 public.organization_emblems, public.personnel_categories, public.positions,
 public.position_assignments, public.terminology, public.master_data_sources,
 public.organization_change_log, public.violation_groups, public.violation_categories,
 public.reporting_periods, public.report_imports, public.report_counts to service_role;
create policy "authenticated read organization_types" on public.organization_types for select to authenticated using (true);
create policy "authenticated read organizations" on public.organizations for select to authenticated using (true);
create policy "authenticated read organization_aliases" on public.organization_aliases for select to authenticated using (true);
create policy "authenticated read organization_emblems" on public.organization_emblems for select to authenticated using (true);
create policy "authenticated read personnel_categories" on public.personnel_categories for select to authenticated using (true);
create policy "authenticated read positions" on public.positions for select to authenticated using (true);
create policy "authenticated read position_assignments" on public.position_assignments for select to authenticated using (true);
create policy "authenticated read terminology" on public.terminology for select to authenticated using (true);
create policy "authenticated read master_data_sources" on public.master_data_sources for select to authenticated using (true);
create policy "authenticated read organization_change_log" on public.organization_change_log for select to authenticated using (true);
create policy "authenticated read violation_groups" on public.violation_groups for select to authenticated using (true);
create policy "authenticated read violation_categories" on public.violation_categories for select to authenticated using (true);
create policy "authenticated read reporting_periods" on public.reporting_periods for select to authenticated using (true);
create policy "authenticated read report_imports" on public.report_imports for select to authenticated using (true);
create policy "authenticated read report_counts" on public.report_counts for select to authenticated using (true);
comment on table public.organizations is 'Master hierarki organisasi dengan penamaan singkatan sebagai label utama; simpan sejarah melalui valid_from/valid_until.';
comment on table public.organization_emblems is 'Lambang melekat pada organisasi induk Kodam; Pomdam mengambil lambang melalui parent Kodam, bukan emblem Pomdam mandiri.';
comment on table public.organization_aliases is 'Alias/kode historis dari sumber laporan; tidak mengubah identitas organisasi kanonik.';
comment on table public.report_counts is 'Nilai dasar laporan. Jumlah disimpan netral sebagai jumlah_tercatat sampai definisi insiden vs personel terverifikasi.';