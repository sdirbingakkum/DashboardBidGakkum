-- Complete the POMDAM-only emblem/avatar master.
-- 15 legacy-unit files come from the official Dinas Sejarah AD Kotama directory.
-- 12 newer-unit files are candidate Commons references and stay unverified.
do $$
declare
  r record;
  v_org_id uuid;
  v_emblem_id uuid;
begin
  for r in
    select * from (values
      ('POMDAM-IM','https://disjarah.tni-ad.mil.id/asset/lambang/dam%20im.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-I','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Bukit_Barisan.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-II','https://disjarah.tni-ad.mil.id/asset/lambang/dam%20swj.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official directory image; source label spelling variant II/SJW.'),
      ('POMDAM-III','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Siliwangi.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-IV','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Diponegoro.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-V','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Brawijaya.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-VI','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Mulawarman.svg.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-IX','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Udayana.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-XII','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Tanjungpura.svg.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-XIII','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Merdeka.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-XIV','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Hasanuddin.svg.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official directory image; source label spelling variant XIV/HSD.'),
      ('POMDAM-XV','https://disjarah.tni-ad.mil.id/asset/lambang/dam%20ptm.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Pattimura emblem; legacy page lists XVI/PTM; current canonical POMDAM label remains XV/PTM.'),
      ('POMDAM-XVII','https://disjarah.tni-ad.mil.id/asset/lambang/dam%20cen.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-XVIII','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Kasuari.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-JAYA','https://disjarah.tni-ad.mil.id/asset/lambang/Lambang_Kodam_Jaya.png','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','verified','PNG','Official Dinas Sejarah AD directory asset.'),
      ('POMDAM-XIX','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Kodam_Tuanku_Tambusai.png','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Tuanku_Tambusai.png','unverified','PNG','Commons candidate; attributed to Rajawali45/vectorized from photo. Verify against official unit file.'),
      ('POMDAM-XX','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Kodam_Tuanku_Imam_Bonjol.png','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Tuanku_Imam_Bonjol.png','unverified','PNG','Commons candidate by contributor; verify against official unit file.'),
      ('POMDAM-XXI','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Komando_Daerah_Militer_Radin_Inten.png','https://commons.wikimedia.org/wiki/File:Lambang_Komando_Daerah_Militer_Radin_Inten.png','unverified','PNG','Commons metadata attributes source/author to Kodam XXI; direct unit confirmation still needed.'),
      ('POMDAM-XXII','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Kodam_XXII_Tambun_Bungai_%282025%29.png','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_XXII_Tambun_Bungai_(2025).png','unverified','PNG','Commons metadata attributes source photo to Kodam XXII; visual confirmation still needed.'),
      ('POMDAM-XXIII','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Kodam_Palaka_Wira.png','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Palaka_Wira.png','unverified','PNG','Commons candidate by contributor; verify against official unit file.'),
      ('POMDAM-XXIV','https://commons.wikimedia.org/wiki/Special:FilePath/Lambang_Kodam_XXIII_Mandala_Trikora.png','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_XXIII_Mandala_Trikora.png','unverified','PNG','Commons caption says Kodam XXIV but filename uses XXIII; source says Scribd; review before verification.'),
      ('POMDAM-XXV','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXV_SMR.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXV_SMR.png','unverified','PNG','Recreated by Kur3115; Commons file page lists CC BY-SA 4.0. Preserve attribution if used.'),
      ('POMDAM-XXVI','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXVI_MATARAM.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVI_MATARAM.png','unverified','PNG','Recreated by Kur3115; confirm against official unit file.'),
      ('POMDAM-XXVII','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXVII_SOBE_SONBAI.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVII_SOBE_SONBAI.png','unverified','PNG','Commons candidate by Kur3115 under CC0; confirm against official unit file.'),
      ('POMDAM-XXVIII','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXVII_MOLOKU_KIE_RAHA.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVII_MOLOKU_KIE_RAHA.png','unverified','PNG','Commons caption says XXVIII but filename contains XXVII; review visual identity.'),
      ('POMDAM-XXIX','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXIX_MAMBRUK.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXIX_MAMBRUK.png','unverified','PNG','Recreated by Kur3115; confirm against official unit file.'),
      ('POMDAM-XXX','https://commons.wikimedia.org/wiki/Special:FilePath/LOGO_KODAM_XXX_RINAMBORA.png','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXX_RINAMBORA.png','unverified','PNG','Commons caption says Tinambora while official unit name is Rinambora; review before verification.')
    ) as v(org_code,asset_url,source_url,verification_status,file_format,license_notes)
  loop
    select id into v_org_id
    from public.organizations
    where code=r.org_code
    order by valid_from desc nulls first
    limit 1;
    if v_org_id is null then
      raise exception 'Missing POMDAM organization master row for %', r.org_code;
    end if;

    select id into v_emblem_id
    from public.organization_emblems
    where organization_id=v_org_id and is_primary=true
    order by created_at
    limit 1;

    if v_emblem_id is null then
      insert into public.organization_emblems(
        organization_id,asset_url,source_url,file_format,
        verification_status,license_notes,is_primary
      ) values (
        v_org_id,r.asset_url,r.source_url,r.file_format,
        r.verification_status,r.license_notes,true
      );
    else
      update public.organization_emblems
      set asset_url=r.asset_url,source_url=r.source_url,
          file_format=r.file_format,verification_status=r.verification_status,
          license_notes=r.license_notes,is_primary=true
      where id=v_emblem_id;
    end if;
  end loop;
end $$;

insert into public.master_data_sources(source_name,source_url,source_type,publisher,reliability,notes)
values
 ('Direktori lambang Kotama TNI AD','https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama','pomdam_emblem_catalog','Dinas Sejarah Angkatan Darat','primary_official','Memuat gambar lambang dan tautan satuan untuk 15 unit lama. Aset dilekatkan ke record POMDAM sesuai scope aplikasi.'),
 ('Daftar Kodam TNI AD 2026 — Potret TMMD ke-127','https://tniad.mil.id/konten/unggahan/2026/04/POTRET-TMMD-KE-127.pdf','pomdam_nomenclature','TNI Angkatan Darat','primary_official','Rujukan nomenklatur satuan 2026, termasuk XV/Pattimura dan enam satuan XIX–XXIV.'),
 ('Peresmian enam Kodam baru 2025','https://tniad.mil.id/presiden-resmikan-6-kodam-baru-dan-satuan-teritorial-pembangunan-perkuat-pertahanan-dukung-kesejahteraan-rakyat/','pomdam_nomenclature','TNI Angkatan Darat','primary_official','Rujukan pembentukan enam satuan XIX–XXIV pada 10 Agustus 2025.'),
 ('Peresmian enam Kodam baru 2026','https://tniad.mil.id/hut-ke-81-tni-kasad-saksikan-peresmian-enam-kodam-baru/','pomdam_nomenclature','TNI Angkatan Darat','primary_official','Rujukan pembentukan enam satuan XXV–XXX pada 5 Oktober 2026.'),
 ('Konfirmasi nama dan lambang Kodam XIX/Tuanku Tambusai','https://mediacenter.riau.go.id/arsip/93266','pomdam_emblem_context','Media Center Riau','official_secondary','Rujukan konteks nama dan desain lambang XIX/Tuanku Tambusai.'),
 ('Logo POMDAM XIX — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Tuanku_Tambusai.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat; atribusi dan sumber file tercatat pada halaman Commons.'),
 ('Logo POMDAM XX — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Tuanku_Imam_Bonjol.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat; belum diverifikasi langsung.'),
 ('Logo POMDAM XXI — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Komando_Daerah_Militer_Radin_Inten.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Metadata menyebut Kodam XXI/Radin Inten sebagai sumber/pembuat; tetap menunggu validasi.'),
 ('Logo POMDAM XXII — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_XXII_Tambun_Bungai_(2025).png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Metadata mengatribusikan foto kepada Kodam XXII; tetap menunggu validasi.'),
 ('Logo POMDAM XXIII — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_Palaka_Wira.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat oleh kontributor Commons; belum diverifikasi.'),
 ('Logo POMDAM XXIV — Commons','https://commons.wikimedia.org/wiki/File:Lambang_Kodam_XXIII_Mandala_Trikora.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Caption dan filename memiliki nomor yang berbeda; perlu ditinjau.'),
 ('Logo POMDAM XXV — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXV_SMR.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Rekreasi desain CC BY-SA 4.0; atribusi wajib dipertahankan.'),
 ('Logo POMDAM XXVI — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVI_MATARAM.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat rekreasi desain; belum diverifikasi.'),
 ('Logo POMDAM XXVII — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVII_SOBE_SONBAI.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat CC0; belum diverifikasi.'),
 ('Logo POMDAM XXVIII — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXVII_MOLOKU_KIE_RAHA.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Caption menyebut XXVIII, filename XXVII; perlu diperiksa.'),
 ('Logo POMDAM XXIX — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXIX_MAMBRUK.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Kandidat rekreasi desain; belum diverifikasi.'),
 ('Logo POMDAM XXX — Commons','https://commons.wikimedia.org/wiki/File:LOGO_KODAM_XXX_RINAMBORA.png','pomdam_emblem_candidate','Wikimedia Commons','secondary','Caption menulis Tinambora; nomenklatur resmi Rinambora; perlu diperiksa.')
on conflict (source_url) where source_url is not null do update
set source_name=excluded.source_name,source_type=excluded.source_type,
    publisher=excluded.publisher,reliability=excluded.reliability,notes=excluded.notes;

insert into public.organization_aliases(organization_id,alias,alias_type,source_reference,notes)
select o.id,v.alias,v.alias_type,
  'https://disjarah.tni-ad.mil.id/page/detail/bintal-jarah-kotama',v.notes
from (values
  ('POMDAM-XV','XVI/PTM','historical_name','Legacy directory label; canonical application label stays XV/PTM.'),
  ('POMDAM-II','II/SJW','source_label','Disjarah AD spelling variant; canonical label stays II/SWJ.'),
  ('POMDAM-XIV','XIV/HSD','source_label','Disjarah AD spelling variant; canonical label stays XIV/HSN.')
) as v(org_code,alias,alias_type,notes)
join public.organizations o on o.code=v.org_code
where not exists(
  select 1 from public.organization_aliases a
  where a.organization_id=o.id and a.alias=v.alias and a.alias_type=v.alias_type
);

create unique index if not exists organization_emblems_one_primary_per_org_uidx
  on public.organization_emblems(organization_id)
  where is_primary=true;
