alter table public.organizations
  add constraint organizations_code_valid_from_key unique nulls not distinct (code, valid_from);
