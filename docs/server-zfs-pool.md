# ZFS Pool: `dontdie`

Canonical reference for the homeserver data pool. Layout, property choices, and the fresh-pool setup recipe.

## Layout

```
dontdie/
├── services/                 mountpoint=none (organizational)
│   ├── config                app configs (one subdir per service)
│   └── databases             DB-backed state -- shared Postgres cluster, Jellyfin's sqlite-driven dataDir
├── data/                     mountpoint=none (organizational)
│   ├── immich                photos
│   ├── paperless-ngx         documents
│   └── entertainment         media library + downloaders (shared root for *arr hardlinks)
└── cache                     regenerable scratch
```

`services/databases` and `data/<service>` keep stateful DB data and bulk user data separate from configs so each can have appropriate ZFS properties and backup cadence.

## Property choices

| Dataset | compression | recordsize | sync |
|---|---|---|---|
| `services/config` | `zstd` | (default 128k) | `standard` |
| `services/databases` | `zstd` | `16k` | `standard` |
| `data/immich` | `zstd` | (default) | `standard` |
| `data/paperless-ngx` | `zstd` | (default) | `standard` |
| `data/entertainment` | `zstd` | (default) | `standard` |
| `cache` | `zstd` | (default) | `disabled` |

Pool-wide defaults (set on the root filesystem, inherited):
- `xattr=sa` -- store extended attributes in inodes (faster than separate files).
- `ashift=12` -- 4K sector alignment, matches modern HDDs/SSDs.
- `atime=on`, `relatime=on` -- access-time tracking with the relatime optimization.

### Why these choices

**`compression=zstd` everywhere.** Since OpenZFS 2.2 (PR #13244), `zstd` ships always-on early-abort: an LZ4 pre-pass and a zstd-1 pre-pass run before the full level, plus a 12.5% sector-rounding threshold below which the block is stored raw. Incompressible blocks (jpeg/heic, h264/h265) therefore land raw and read back with zero decompress cost; the only write-side cost is the two pre-passes, which at zstd-3 is negligible. Any setting other than `off` also keeps ZFS's zero-block hole-punching active -- compression=off disables it, which would silently inflate sparse files (sqlite WALs, transcode scratch). Net: default-on is the simpler, safer choice; `=off` is only justified by a measured CPU bottleneck we don't have.

**`recordsize=16k` on `services/databases`** is driven by the shared Postgres cluster (immich + paperless-ngx): 16k = Postgres's 8KiB page size doubled, standard guidance to avoid write amplification on Postgres-on-ZFS. The default 128k recordsize would force ZFS to read-modify-write a 128k block on every 8k Postgres page write. Jellyfin's sqlite dataDir co-tenants this dataset; sqlite's 4KiB pages fit four-per-record cleanly, so the same setting works without further tuning.

**`sync=disabled` on `cache`** -- by default ZFS honors `fsync()` by waiting for the write to hit stable storage via the ZIL (so a crash loses no acknowledged write). `disabled` ignores sync requests; writes still land on disk via the regular ~5s txg flush, but `fsync()` returns immediately. A crash can lose up to ~5s of "acknowledged" writes -- acceptable here because cache contents are regenerable by definition. The win is fsync latency reclaimed from fsync-heavy consumers (Jellyfin transcoding, sqlite WALs).

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
# Organizational parents (not mounted)
zfs create -o mountpoint=none dontdie/services
zfs create -o mountpoint=none dontdie/data

zfs create -o mountpoint=/dontdie/services/config     dontdie/services/config
zfs create -o mountpoint=/dontdie/services/databases \
           -o recordsize=16k                          dontdie/services/databases

zfs create -o mountpoint=/dontdie/data/immich         dontdie/data/immich
zfs create -o mountpoint=/dontdie/data/paperless-ngx  dontdie/data/paperless-ngx
zfs create -o mountpoint=/dontdie/data/entertainment  dontdie/data/entertainment

zfs create -o mountpoint=/dontdie/cache \
           -o sync=disabled                           dontdie/cache
```

Children of `dontdie/services` and `dontdie/data` need explicit mountpoints because they can't inherit through a `mountpoint=none` parent.

### NixOS config

Two edits land the pool in NixOS:

1. `boot.zfs.extraPools = [ "dontdie" ];` -- import on boot.
2. `services.sanoid.datasets` -- snapshot retention.

Apply with `just apply`. First boot will mount all datasets and arm the sanoid timer.

#### Services with a custom dataDir on the pool

Any NixOS service whose unit has sandboxing (`BindPaths=`, `ReadWritePaths=`, ...) referencing a custom `dataDir` refuses to start if that directory is missing -- the mount namespace fails before `preStart` runs. Declare the dir via `systemd-tmpfiles` so it's created at boot before the unit starts:

```nix
systemd.tmpfiles.rules = [
  "d ${paths.postgres} 0700 postgres postgres - -"
];
```

Postgres on the shared cluster (`services/databases/postgres`) is the canonical example.

## Bootstrapping on a fresh host

NixOS won't activate if `boot.zfs.extraPools` names a pool that doesn't exist, and any service consuming a pool path fails the same way. To break the chicken-and-egg on a new machine:

1. Comment out `boot.zfs.extraPools` and every service that touches a pool path (caddy virtualHosts, postgres `dataDir`, sanoid datasets, bind-mounts, immich, ...). Keep `modules/nixos/services/zfs.nix` -- it adds the kernel module + userspace tools without trying to import.
2. Deploy with `nixos-rebuild boot` and reboot so the ZFS-aware kernel is the one running.
3. Create the pool + datasets per the [Fresh-pool setup recipe](#fresh-pool-setup-recipe).
4. Uncomment everything, redeploy.

## Design notes

### Why `data/entertainment` is one dataset

Sonarr/Radarr/qBittorrent/SABnzbd hardlink across `media/` (final library) and `torrents/` / `usenet/` (download dirs). Hardlinks require source and target to live on the same filesystem -- so both must be under one ZFS dataset. The TRaSH Guides recommend exactly this layout.

### Why DB-backed state is extracted out of `services/config`

In the previous Docker Compose setup, each service's Postgres data lived as a subdir of its config dir (`<service>/postgres/`). Splitting stateful DB data out into `services/databases/` lets:

1. The dataset get `recordsize=16k` matching Postgres's page size, without touching the much larger config dataset.
2. A single backup/snapshot strategy target `services/databases` for everything DB-backed at once.
3. Per-service DB metrics and properties stay separable from app config.

`services/databases` ended up wider than just Postgres -- Jellyfin's `dataDir` (sqlite library DB + metadata) also lives here. The naming reflects intent: "stateful DB-shaped data," not "Postgres only."

### Why a single `cache` dataset rather than per-service ones

Most upstream service docs (Immich, Paperless, *arr) don't cleanly distinguish cache from state. Pre-emptively carving cache subdirectories per service adds friction for little benefit at our pool size. `dontdie/cache` is reserved for services with well-documented cache subpaths (e.g. Jellyfin's `/config/cache` and `/config/transcodes`). Add child cache datasets reactively if a specific service's regenerable data starts dominating snapshot growth.
