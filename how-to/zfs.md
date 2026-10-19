# How to ZFS

[elitedesk](../targets/nixos/elitedesk/) keeps its bulk data and nightly backups on the ZFS pool `dontdie`. The pool and datasets are created by hand with the commands below; Nix only imports them ([`default.nix`](../targets/nixos/elitedesk/default.nix)), unlocks the encrypted datasets with a key from sops ([`zfs-encryption.nix`](../targets/nixos/elitedesk/zfs-encryption.nix)) and snapshots them with sanoid ([`zfs-snapshots.nix`](../targets/nixos/elitedesk/zfs-snapshots.nix)).

## Pool

A 2-disk mirror:

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

## Datasets

```
ENC="-o encryption=on -o keyformat=hex -o keylocation=file:///run/secrets/zfs_dontdie_key"

# Organizational parents (not mounted)
zfs create -o mountpoint=none dontdie/services
zfs create -o mountpoint=none dontdie/data

zfs create -o mountpoint=/dontdie/services/backups    $ENC dontdie/services/backups
zfs create -o mountpoint=/dontdie/data/immich         $ENC dontdie/data/immich
zfs create -o mountpoint=/dontdie/data/paperless-ngx  $ENC dontdie/data/paperless-ngx
```
