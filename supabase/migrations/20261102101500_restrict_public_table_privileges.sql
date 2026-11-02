revoke all privileges on all tables in schema public from anon;
revoke all privileges on all tables in schema public from authenticated;
grant select on all tables in schema public to authenticated;
grant all privileges on all tables in schema public to service_role;
alter default privileges for role postgres in schema public
  revoke all privileges on tables from anon, authenticated;
alter default privileges for role postgres in schema public
  grant select on tables to authenticated;
alter default privileges for role postgres in schema public
  grant all privileges on tables to service_role;
