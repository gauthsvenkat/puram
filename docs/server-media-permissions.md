# Media library permissions: shared `media` group

How cross-service read/write works on `/dontdie/data/entertainment`. Covers
the Nix wiring, the one-shot disk setup, and the rationale behind the
chosen pattern.

## The setup

| Layer | Mechanism |
|---|---|
| Per-service users | `bazarr`, `jellyfin`, `sonarr`, `radarr` (later: `qbittorrent`, `sabnzbd`) - one uid each, allocated by their nixpkgs modules |
| Shared group | `media`, **gid 169** (matches nixarr's convention for ecosystem interop) |
| Group assignment | Each service's *primary* group set to `media` via `services.<name>.group = "media"` - files the service writes land as `<svc>:media` directly |
| Mode bits | `UMask=0002` per unit → new files `0664`, new dirs `0775` (group-writable) |
| Tree mode | `2775` on every directory under `entertainment/`, `0664` on every regular file. The leading `2` is SGID - non-stack processes that drop a file in the tree still see it land in `media` |

All three layers live in `hosts/elitedesk/media-permissions.nix`. The
upstream `services.{sonarr,radarr}` and `services.jellyfin` modules
hardcode their own `UMask` (`0022` for the servarr family, `0077` for
jellyfin) as defensive hardening, so the override uses `lib.mkForce`.

## Fresh-install / disaster-recovery recipe

The Nix module sets up the group and per-service umasks, but the
existing tree on disk needs one-shot re-ownership:

```sh
sudo chgrp -R media /dontdie/data/entertainment
sudo chmod 2775 /dontdie/data/entertainment
sudo fd -HI -t d . /dontdie/data/entertainment -X chmod 2775
sudo fd -HI -t f . /dontdie/data/entertainment -X chmod 0664
sudo systemctl restart bazarr sonarr radarr jellyfin
```

Notes:
- `chmod 2775` on the top dir explicitly - `fd` excludes the search-root
  from results by default, so the recursive pass would miss it.
- `-HI` includes hidden entries (catches `.stfolder` and friends) and
  bypasses any stray `.gitignore`.
- Restart is required because supplementary group membership and the
  unit's `UMask` are applied at process spawn time; running services
  hold their group set / umask from when they last started.

## Adding a new service to the stack

Two edits:

1. Append the service name to `members` in
   `hosts/elitedesk/media-permissions.nix`.
2. If the service has its own state dir under `/var/lib/`, re-chown that
   one-shot too: `sudo chgrp -R media /var/lib/<svc>` (mode 0700 ignores
   the group anyway, but keeps `stat` output tidy).

That's it for any future *arr-shaped service. No tree-rewalk needed.

## Why this pattern

Three options were on the table:

1. **Per-service user + shared group** (chosen). Servarr wiki TL;DR;
   nixarr does this line-for-line.
2. **Single shared user** (TRaSH alternative). Simpler module (~5 lines),
   but loses per-service isolation - a sonarr compromise can read/write
   radarr's config. Diverges from upstream nixpkgs hardening assumptions
   (`PrivateUsers=true`, syscall filters per-user).
3. **`extraGroups` (supplementary)** - leave each service's primary
   group as `<svc>` and add `media` as supplementary. Works, but means
   files land as `<svc>:<svc>` by default and we'd need SGID to coerce
   the group on creation. Two layers of indirection where one is enough.

(1) wins on three axes: matches the canonical reference, preserves
isolation, and the file-creation group is "right" without SGID magic
(SGID is then just defensive against non-stack writers).

## Trade-off accepted by mkForcing jellyfin's UMask

Upstream's `services.jellyfin` ships `UMask=0077` (owner-only) as
defensive hardening - assuming jellyfin shouldn't be group-readable to
anyone. Overriding to `0002` weakens that for files jellyfin writes.

By default jellyfin doesn't write to the media tree at all (NFO saving,
trickplay-to-media-folder, and subtitle-extraction-to-media-folder are
all opt-in). The override only matters if those settings get turned on,
in which case uniform group-write is what we want anyway.

The threat model anchor (jellyfin reachable only via Caddy on the
tailnet, no public exposure) makes the hardening loss negligible.

## See also

- [nixarr - canonical NixOS *arr stack module](https://github.com/nix-media-server/nixarr)
- [nixarr `util/globals/default.nix`](https://github.com/nix-media-server/nixarr/blob/main/util/globals/default.nix) - where the `gid 169` for `media` comes from
- [Servarr Docker Guide - permissions section](https://wiki.servarr.com/docker-guide)
- [TRaSH Guides - Hardlink Tutorial](https://trash-guides.info/Hardlinks/)
- `server-zfs-pool.md` - why `entertainment/` is one dataset (hardlinks require it)
