# ZFS Pool: `dontdie`

Canonical reference for the homeserver data pool. Layout, property choices, and the fresh-pool setup recipe.

## Layout

```
dontdie/
├── services/                 mountpoint=none (organizational)
│   └── backups*              nightly Postgres dumps + service-state mirror (targets/nixos/elitedesk/backups.nix)
└── data/                     mountpoint=none (organizational)
    ├── immich*               photos
    ├── paperless-ngx*        documents
    └── entertainment         media library + downloaders (shared root for *arr hardlinks)

* = encrypted, see `targets/nixos/elitedesk/zfs-encryption.nix`
```

Hot service state (sqlite app dirs, the shared Postgres cluster, Jellyfin's dataDir) lives on the internal SSD under `/var/lib` since 2026-07 -- see [Why service state moved off the pool](#why-service-state-moved-off-the-pool-2026-07). The pool keeps bulk data and receives nightly backups of that state, so it remains the complete, host-portable copy.

## Property choices

| Dataset | compression | recordsize | sync |
|---|---|---|---|
| `services/backups` | `zstd` | (default 128k) | `standard` |
| `data/immich` | `zstd` | (default) | `standard` |
| `data/paperless-ngx` | `zstd` | (default) | `standard` |
| `data/entertainment` | `zstd` | (default) | `standard` |

Pool-wide defaults (set on the root filesystem, inherited):
- `xattr=sa` -- store extended attributes in inodes (faster than separate files).
- `ashift=12` -- 4K sector alignment, matches modern HDDs/SSDs.
- `atime=on`, `relatime=on` -- access-time tracking with the relatime optimization.

### Why these choices

**`compression=zstd` everywhere.** Since OpenZFS 2.2 (PR #13244), `zstd` ships always-on early-abort: an LZ4 pre-pass and a zstd-1 pre-pass run before the full level, plus a 12.5% sector-rounding threshold below which the block is stored raw. Incompressible blocks (jpeg/heic, h264/h265) therefore land raw and read back with zero decompress cost; the only write-side cost is the two pre-passes, which at zstd-3 is negligible. Any setting other than `off` also keeps ZFS's zero-block hole-punching active -- compression=off disables it, which would silently inflate sparse files (sqlite WALs, transcode scratch). Net: default-on is the simpler, safer choice; `=off` is only justified by a measured CPU bottleneck we don't have.

Properties only affect *new* writes. Existing data keeps whatever policy it was originally written with; rewriting to flip retroactively is intentional only when worth the cost (e.g. a `zfs send | recv` migration).

## Fresh-pool setup recipe

The canonical command sequence to build `dontdie` from nothing on a new machine. *Not* the in-place restructure -- this is for disaster recovery / new hardware.

Verify flag syntax against current OpenZFS docs before running, since flags evolve:
- OpenZFS docs index: https://openzfs.github.io/openzfs-docs/
- `man zpool-create`, `man zfs-create`, `man zfsprops`

### Pool

Production topology is a **2-disk mirror** for redundancy. Identify devices via `/dev/disk/by-id/` (stable across reboots, unlike `/dev/sdX`):

```
zpool create \
  -o ashift=12 \
  -O xattr=sa \
  -O compression=zstd \
  -O mountpoint=/dontdie \
  dontdie mirror \
  /dev/disk/by-id/<dev1> \
  /dev/disk/by-id/<dev2>
```

`-O compression=zstd` makes zstd the pool-wide default; child datasets inherit it without restating.

### Datasets

```
ENC="-o encryption=on -o keyformat=hex -o keylocation=file:///run/secrets/zfs_dontdie_key"

# Organizational parents (not mounted)
zfs create -o mountpoint=none dontdie/services
zfs create -o mountpoint=none dontdie/data

zfs create -o mountpoint=/dontdie/services/backups    $ENC dontdie/services/backups
zfs create -o mountpoint=/dontdie/data/immich         $ENC dontdie/data/immich
zfs create -o mountpoint=/dontdie/data/paperless-ngx  $ENC dontdie/data/paperless-ngx

zfs create -o mountpoint=/dontdie/data/entertainment dontdie/data/entertainment
```

Children of `dontdie/services` and `dontdie/data` need explicit mountpoints because they can't inherit through a `mountpoint=none` parent.

### NixOS config

Two edits land the pool in NixOS:

1. `boot.zfs.extraPools = [ "dontdie" ];` -- import on boot.
2. `services.sanoid.datasets` -- snapshot retention.

Apply with `just a`. First boot will mount all datasets and arm the sanoid timer.

#### Services with a custom dataDir

Any NixOS service whose unit has sandboxing (`BindPaths=`, `ReadWritePaths=`, ...) referencing a custom `dataDir` refuses to start if that directory is missing -- the mount namespace fails before `preStart` runs. Declare the dir via `systemd-tmpfiles` so it's created at boot before the unit starts:

```nix
systemd.tmpfiles.rules = [
  "d ${paths.postgres} 0700 postgres postgres - -"
];
```

Postgres (`/var/lib/postgresql`, a non-default dataDir on the SSD) is the canonical example.

## Bootstrapping on a fresh host

NixOS won't activate if `boot.zfs.extraPools` names a pool that doesn't exist, and any service consuming a pool path fails the same way. To break the chicken-and-egg on a new machine:

1. Comment out `boot.zfs.extraPools` and every service that touches a pool path (caddy virtualHosts, sanoid datasets, immich, paperless, the backup jobs, ...). Keep `modules/nixos/services/zfs.nix` -- it adds the kernel module + userspace tools without trying to import.
2. Deploy with `nixos-rebuild boot` and reboot so the ZFS-aware kernel is the one running.
3. Create the pool + datasets per the [Fresh-pool setup recipe](#fresh-pool-setup-recipe).
4. Uncomment everything, redeploy.

## Design notes

### Why `data/entertainment` is one dataset

Sonarr/Radarr/qBittorrent/SABnzbd hardlink across `media/` (final library) and `torrents/` / `usenet/` (download dirs). Hardlinks require source and target to live on the same filesystem -- so both must be under one ZFS dataset. The TRaSH Guides recommend exactly this layout.

### Why service state moved off the pool (2026-07)

The pool's disks are 2.5" USB SMR drives on the legacy `usb-storage` protocol (queue depth 1). Random sync writes -- sqlite fsyncs from the *arr apps and seerr, Postgres page writes and checkpoints -- are their pathological workload: once the drives' internal CMR cache overflows, per-op latency hits hundreds of ms and every fsync on the pool queues behind it. Symptoms observed before the migration: sonarr `database is locked` storms, seerr taking tens of seconds to open, Jellyfin playback stutter, Postgres start/stop checkpoint timeouts, IO PSI pinned at 80-90%.

The fix: all hot state (sqlite app dirs, the shared Postgres cluster at `/var/lib/postgresql`, Jellyfin's dataDir and cache) lives on the internal SSD; the pool serves the workload SMR handles fine -- sequential media reads/writes -- plus one nightly backup burst. `targets/nixos/elitedesk/backups.nix` writes `pg_dumpall` output and an rsync mirror of the state dirs to `services/backups`, so the pool remains the complete copy to carry to a new host (dumps restore across Postgres versions; the SSD is just the hot working set).

Retired datasets from the pre-migration layout -- `services/config`, `services/databases`, `cache` (and the `/dontdie/data/vikunja` dir) -- are kept through a rollback window, then destroyed.
