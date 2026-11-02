-- Cover the damage_level_id foreign key for efficient FK checks and joins.
CREATE INDEX laka_lalin_counts_damage_level_idx
  ON public.laka_lalin_report_counts(damage_level_id);
