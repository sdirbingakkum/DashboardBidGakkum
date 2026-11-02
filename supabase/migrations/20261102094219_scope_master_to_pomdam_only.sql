do $$
declare
  pomdam_type_id uuid;
  kodam_type_id uuid;
  unsafe_assignments integer;
begin
  select id into pomdam_type_id from public.organization_types where code='POMDAM';
  select id into kodam_type_id from public.organization_types where code='KODAM';

  if pomdam_type_id is null then
    raise exception 'POMDAM organization type is missing';
  end if;

  select count(*) into unsafe_assignments
  from public.position_assignments pa
  join public.positions p on p.id=pa.position_id
  where p.code <> 'DANPOMDAM';

  if unsafe_assignments > 0 then
    raise exception 'Cannot prune non-POMDAM positions: % position assignments still reference them', unsafe_assignments;
  end if;

  delete from public.positions where code <> 'DANPOMDAM';
  update public.positions
    set short_name='DANPOMDAM',
        official_name='Komandan POMDAM',
        organization_type_id=pomdam_type_id,
        description='Jabatan komandan pada satuan POMDAM.'
    where code='DANPOMDAM';

  if kodam_type_id is not null then
    update public.organizations
    set organization_type_id=pomdam_type_id,
        code='POMDAM-' || code,
        short_name='POMDAM ' || regexp_replace(short_name, '^KODAM ', ''),
        official_name='Polisi Militer Kodam ' || regexp_replace(official_name, '^Komando Daerah Militer ', ''),
        parent_organization_id=null,
        status='active',
        metadata = coalesce(metadata,'{}'::jsonb) ||
          jsonb_build_object(
            'application_scope','POMDAM_ONLY',
            'unit_exists','confirmed_by_user',
            'emblem_rule','same_emblem_as_corresponding_territorial_command',
            'legacy_source_code',code
          ),
        updated_at=now()
    where organization_type_id=kodam_type_id;
  end if;

  delete from public.organizations where code='POMAD';
  delete from public.organization_types where code <> 'POMDAM';

  delete from public.terminology where term not in ('POMDAM','DANPOMDAM');
  update public.terminology
    set expansion='Polisi Militer Kodam',
        domain='satuan',
        verification_status='verified',
        notes='Satu-satunya jenis organisasi yang dikelola dalam Dashboard Sdirbingakkum.'
    where term='POMDAM';
  update public.terminology
    set expansion='Komandan POMDAM',
        domain='jabatan',
        verification_status='verified',
        notes='Jabatan komandan satuan POMDAM.'
    where term='DANPOMDAM';

  with ranked as (
    select id,
      row_number() over (
        partition by organization_id, alias, alias_type, valid_from
        order by created_at, id
      ) as rn
    from public.organization_aliases
  )
  delete from public.organization_aliases a
  using ranked r
  where a.id=r.id and r.rn > 1;
end $$;

alter table public.organization_aliases
  add constraint organization_aliases_unique_nulls_not_distinct
  unique nulls not distinct (organization_id, alias, alias_type, valid_from);

drop index if exists public.organizations_parent_idx;
alter table public.organizations drop column if exists parent_organization_id;

comment on table public.organizations is
  'Master organisasi POMDAM saja. Nama singkatan POMDAM menjadi label utama; riwayat disimpan melalui valid_from/valid_until.';
comment on table public.organization_emblems is
  'Aset lambang melekat langsung pada masing-masing POMDAM. Lambang harus sama dengan lambang satuan teritorial yang menjadi padanannya; tidak ada entitas organisasi KODAM di aplikasi.';
comment on table public.organization_aliases is
  'Alias/kode historis dari sumber laporan POMDAM; tidak mengubah identitas organisasi kanonik.';
