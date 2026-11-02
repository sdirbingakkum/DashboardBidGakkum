-- Add covering indexes for foreign-key lookups and joins identified by
-- Supabase's performance advisor after the initial schema deployment.
create index if not exists organization_change_log_org_idx
  on public.organization_change_log(organization_id);
create index if not exists organization_change_log_recorded_by_idx
  on public.organization_change_log(recorded_by);
create index if not exists organization_change_log_source_idx
  on public.organization_change_log(source_id);
create index if not exists position_assignments_personnel_category_idx
  on public.position_assignments(incumbent_personnel_category_id);
create index if not exists position_assignments_position_idx
  on public.position_assignments(position_id);
create index if not exists positions_org_type_idx
  on public.positions(organization_type_id);
create index if not exists report_counts_personnel_category_idx
  on public.report_counts(personnel_category_id);
create index if not exists report_imports_imported_by_idx
  on public.report_imports(imported_by);
create index if not exists report_imports_source_organization_idx
  on public.report_imports(source_organization_id);
create index if not exists violation_categories_group_idx
  on public.violation_categories(group_id);
