-- Preserve the historical source label found in Rekap Pelanggaran.xlsx.
-- Canonical identity remains POMDAM XIX/TUTAM; XIX/TT is an import alias only.
insert into public.organization_aliases(
  organization_id,alias,alias_type,source_reference,notes
)
select o.id,'XIX/TT','source_label','Rekap Pelanggaran.xlsx (2026)',
  'Label sumber pada workbook lama untuk POMDAM XIX/TUTAM; dipertahankan sebagai alias agar impor historis tidak mengubah label sumber.'
from public.organizations o
where o.code='POMDAM-XIX'
and not exists (
  select 1 from public.organization_aliases a
  where a.organization_id=o.id
    and a.alias='XIX/TT'
    and a.alias_type='source_label'
);

do $$
begin
  if not exists (
    select 1
    from public.organization_aliases a
    join public.organizations o on o.id=a.organization_id
    where o.code='POMDAM-XIX' and a.alias='XIX/TT'
  ) then
    raise exception 'Required workbook alias XIX/TT -> POMDAM XIX/TUTAM was not registered';
  end if;
end $$;
