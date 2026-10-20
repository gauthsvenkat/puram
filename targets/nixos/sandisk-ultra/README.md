# sandisk-ultra

A portable NixOS on a USB stick. `/` is a tmpfs; [impermanence](https://github.com/nix-community/impermanence) keeps what [`default.nix`](./default.nix) lists under `/nix/persist`, on LUKS.

## Installing

### 1. Pre-generate the sops key

```sh
root=/tmp/extra-files/sandisk-ultra
mkdir -p $root/nix/persist/etc/ssh
ssh-keygen -t ed25519 -N "" -C root@sandisk-ultra -f $root/nix/persist/etc/ssh/ssh_host_ed25519_key
sudo chown -R root:root $root
```

`disko-install` keeps file owners, so without the `chown` the key lands owned by your user.

### 2. Register the key

[Enroll](../../../how-to/secrets.md#enrolling-a-host) the `.pub` key and set it as `sshHostKey` in [`targetCfg.nix`](./targetCfg.nix).

### 3. Install

```sh
read -rs passphrase
echo -n "$passphrase" | sudo tee /tmp/secret.key >/dev/null

sudo nix run github:nix-community/disko/725ea35#disko-install -- \
  --flake /etc/nixos#sandisk-ultra \
  --disk main /dev/sda \
  --extra-files /tmp/extra-files/sandisk-ultra/nix/persist/etc/ssh /nix/persist/etc/ssh

# NOTE: disko-install seems to leave the LUKS mapping open; close it before unplugging.
sudo nix run nixpkgs#cryptsetup -- close decrypted
sudo rm /tmp/secret.key
```

The stick is slow at small writes, so copying the store takes a while.

## TODO

- Try f2fs instead of ext4 for `/nix`; benchmark both with fio first.
