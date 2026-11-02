-- Cover the organization foreign key and common POMDAM-first filtering.
CREATE INDEX sim_report_counts_organization_period_idx
  ON public.sim_report_counts (organization_id, report_period_id);
