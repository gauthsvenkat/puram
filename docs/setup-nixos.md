# NixOS setup

- Installing NixOS.
  - Manual installation with the graphical ISO installer.
    - Download the ISO, follow the steps. Don't forget to encrypt disk if laptop.
    - Reboot and head to `/etc/nixos/configuration.nix` to change the hostname to your preference.
    - (Optional) enable ssh to continue the rest from a different machine.
    - Re (boot or login).
  - Automated installation with nixos-anywhere - see [below](#automated-installation-nixos-anywhere).

- Adding public keys to [github](https://github.com/gauthsvenkat/).
  - Generate SSH keys with `ssh-keygen`. Use defaults.
  - Print the SSH keys with `cat ~/.ssh/id_ed25519.pub`.
  - Add that bad boy to github.
  - (Optional) Remove old keys associated with the current machine if it exists.

- Using the configuration
  - (If it exists) move or delete `/etc/nixos/`.
  - Clone this repository by running `sudo nix-shell -p git --run "git@github.com:gauthsvenkat/nixos.git /etc/nixos"`.You can directly use `git` if installed through nixos-anywhere.
  - Own the directory by `sudo chown -R <user> /etc/nixos`.
  - (If not installed through nixos-anywhere) Switch to the new configuration `sudo nixos-rebuild switch`.

- Post configuration steps for workstations
  - Clone neovim configuration: `git clone git@github.com:gauthsvenkat/nvim.git ~/.config/nvim/`.

## Raspberry Pi installation (SD image)

The pis boot an SD card image produced by nixpkgs' `sd-image-aarch64.nix`,
which the pi hosts import permanently - no disko, no nixos-anywhere. Building
the aarch64 image needs binfmt emulation (`boot.binfmt.emulatedSystems` on
thunderdome).

### 1. Pre-generate and register the host key

Same idea as `--extra-files` below, but the key lands on the SD card by hand:

```sh
mkdir -p /tmp/extra-files/$hostname/etc/ssh
ssh-keygen -t ed25519 -N "" -f /tmp/extra-files/$hostname/etc/ssh/ssh_host_ed25519_key
nix run nixpkgs#ssh-to-age -- -i /tmp/extra-files/$hostname/etc/ssh/ssh_host_ed25519_key.pub
```

Add the printed age key to [`.sops.yaml`](../.sops.yaml) under the
`secrets/system.yaml` and `secrets/wifi.yaml` rules, then `just secrets rekey`. Without this, first
boot has no wifi and no user password.

### 2. Build and flash

```sh
nix build .#nixosConfigurations.$hostname.config.system.build.sdImage
zstd -d --stdout result/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
```

### 3. Stage the host key

Mount the card's root partition (labelled `NIXOS_SD`) and copy the key in:

```sh
mount=$(udisksctl mount -b /dev/disk/by-label/NIXOS_SD | grep -o '/run/media/.*')
sudo install -d -m 755 $mount/etc/ssh
sudo install -m 600 /tmp/extra-files/$hostname/etc/ssh/ssh_host_ed25519_key $mount/etc/ssh/
sudo install -m 644 /tmp/extra-files/$hostname/etc/ssh/ssh_host_ed25519_key.pub $mount/etc/ssh/
udisksctl unmount -b /dev/disk/by-label/NIXOS_SD
```

### 4. First boot

Headless: the pi joins the home wifi via the `home-wifi` NetworkManager
profile (credentials in `secrets/wifi.yaml`) and starts sshd. Find its IP on
the router or AdGuard, log in as the user, then `sudo tailscale up`.

Known issue: `expand-root-partition.service` fails on first boot
(https://github.com/NixOS/nixpkgs/issues/554294), leaving the root filesystem
at the built image size (~5G). It only runs on first boot, so fix it by hand:

```sh
sudo sh -c 'echo ",+," | sfdisk -N2 --no-reread /dev/mmcblk0 && partprobe && resize2fs /dev/mmcblk0p2'
```

## Automated installation ([nixos-anywhere](https://github.com/nix-community/nixos-anywhere))

Make a partition scheme with [disko](https://github.com/nix-community/disko) in
`targets/nixos/<hostname>/disko-config.nix`, then boot the target from a live ISO with
root ssh enabled and note its IP.

The NixOS ISO doesn't boot from ventoy (neither normal nor grub2 mode). An Arch
ISO in grub2 mode works, but needs two fixes before installing:

```sh
# nixos-anywhere aborts without it
pacman -Sy --noconfirm cpio
# the kexec tarball doesn't fit in the default overlay
mount -o remount,size=8G /run/archiso/cowspace
```

### 1. Pre-generate the sops key

Workstations decrypt secrets with the user's ssh key, servers with the host key
(see `sops.age.sshKeyPaths`). Stage it in a directory mirroring the target's
filesystem root, so nixos-anywhere can copy it over during installation:

```sh
root=/tmp/extra-files/$hostname

# workstation
mkdir -p $root/home/$username/.ssh
ssh-keygen -t ed25519 -N "" -f $root/home/$username/.ssh/id_ed25519

# server
mkdir -p $root/etc/ssh
ssh-keygen -t ed25519 -N "" -f $root/etc/ssh/ssh_host_ed25519_key
```

### 2. Register the key

```sh
nix run nixpkgs#ssh-to-age -- -i <generated key>.pub
```

Add the printed age key to [`.sops.yaml`](../.sops.yaml), then `just secrets rekey`.
Without this, first boot has no secrets and therefore no user password.

### 3. Test the disk layout (optional)

```sh
nix run github:nix-community/nixos-anywhere -- --flake .#$hostname --vm-test
```

### 4. Install

```sh
read -rs passphrase # only for encrypted disks

nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./targets/nixos/$hostname/hardware-configuration.nix \
  --flake .#$hostname \
  --extra-files /tmp/extra-files/$hostname \
  --chown /home/$username 1000:100 \
  --disk-encryption-keys /tmp/secret.key <(echo -n "$passphrase") \
  --target-host root@$ip
```

- `--chown`: workstations only. Everything under `--extra-files` lands owned by
  root; 1000:100 is the first user's uid and the default `users` gid
  ([ids.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/misc/ids.nix)).
- `--disk-encryption-keys`: encrypted disks only. The target path must match
  `passwordFile` in the disko config.

Commit the generated `hardware-configuration.nix`.

### 5. Fix home ownership

`--chown` doesn't always stick, which breaks home-manager activation. Before
logging in as the user:

```sh
ls -ld /home/$username
chown -R $username:users /home/$username
systemctl restart home-manager-$username.service
```
