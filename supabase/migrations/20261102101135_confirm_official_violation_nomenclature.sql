-- The project owner confirmed B1-B11 and C1-C6 are the official violation nomenclature.
-- Keep all codes and labels unchanged; this migration changes verification state only.
do $$
declare
  expected_count integer;
  updated_count integer;
begin
  select count(*) into expected_count
  from public.violation_categories
  where code = any (array[
    'B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11',
    'C1','C2','C3','C4','C5','C6'
  ]);

  if expected_count <> 17 then
    raise exception 'Expected 17 official violation categories, found %', expected_count;
  end if;

  update public.violation_categories
  set verification_status = 'verified'
  where code = any (array[
    'B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11',
    'C1','C2','C3','C4','C5','C6'
  ]);

  get diagnostics updated_count = row_count;
  if updated_count <> 17 then
    raise exception 'Expected to verify 17 violation categories, updated %', updated_count;
  end if;
end $$;
