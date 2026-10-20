# How to NixOS

## Installing NixOS with [`nixos-anywhere`](https://github.com/nix-community/nixos-anywhere)

Make a partition scheme with [disko](https://github.com/nix-community/disko) in `targets/nixos/<hostname>/disko-config.nix` (e.g. [elitedesk's](../targets/nixos/elitedesk/disko-config.nix)).

### On NixOS live boot

Boot the target from the NixOS live ISO with root ssh enabled and note its IP.

### On Arch live boot

The NixOS ISO doesn't boot from ventoy (neither normal nor grub2 mode). An Arch ISO in grub2 mode works, but needs two fixes before installing:

```sh
# nixos-anywhere aborts without it
pacman -Sy --noconfirm cpio
# the kexec tarball doesn't fit in the default overlay
mount -o remount,size=8G /run/archiso/cowspace
```

### On other Linux live boot

The live system needs `tar`, `cpio`, `setsid` (with `--wait`) and `curl` or `wget`. So make sure these are installed and available in `$PATH`.

### Installing

```sh
hostname=<hostname>
username=<username>  # workstations only
ip=<target-ip>
```

#### 1. Pre-generate the sops key

Stage the key in a directory mirroring the target's filesystem root, so nixos-anywhere can copy it over during installation:

```sh
root=/tmp/extra-files/$hostname

# workstation
mkdir -p $root/home/$username/.ssh
ssh-keygen -t ed25519 -N "" -f $root/home/$username/.ssh/id_ed25519

# server
mkdir -p $root/etc/ssh
ssh-keygen -t ed25519 -N "" -f $root/etc/ssh/ssh_host_ed25519_key
```

#### 2. Register the key

[Enroll](./secrets.md#enrolling-a-host) the generated `.pub` key. Without this, first boot has no secrets and therefore no user password.

#### 3. (Optional) Test the disk layout

```sh
nix run github:nix-community/nixos-anywhere -- --flake .#$hostname --vm-test
```

#### 4. Install

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

- `--chown`: workstations only. Everything under `--extra-files` lands owned by root; 1000:100 is the first user's uid and the default `users` gid ([ids.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/misc/ids.nix)).
- `--disk-encryption-keys`: encrypted disks only. The passphrase file only exists during installation, for disko to format the disk; its path must match `passwordFile` in the disko config.

Commit the generated `hardware-configuration.nix`.

#### 5. Fix home ownership

`--chown` doesn't always stick, which breaks home-manager activation. Before logging in as the user, log in as root and check `ls -ld /home/<username>`. If it shows `root`:

```sh
chown -R <username>:users /home/<username>
systemctl restart home-manager-<username>.service
```

## Installing NixOS with graphical ISO installer

[Download the ISO](https://nixos.org/download/) and follow the installer; encrypt the disk on laptops. The installer partitions the disk itself, so this host has no disko config. After the reboot, set the hostname in `/etc/nixos/configuration.nix` and switch, optionally enabling ssh to continue from another machine. Before replacing `/etc/nixos` in [Post Install](#post-install), copy its `hardware-configuration.nix` to `targets/nixos/<hostname>/`, and [enroll](./secrets.md#enrolling-a-host) the host's SSH key from a workstation. The first switch to this flake may need `--option experimental-features "nix-command flakes"`.

## Installing NixOS on Raspberry Pi

Building the aarch64 image needs binfmt emulation (`boot.binfmt.emulatedSystems = [ "aarch64-linux" ]`) in the corresponding workstation.

```sh
hostname=<hostname>
```

### 1. Pre-generate and register the host key

```sh
mkdir -p /tmp/extra-files/$hostname/etc/ssh
ssh-keygen -t ed25519 -N "" -f /tmp/extra-files/$hostname/etc/ssh/ssh_host_ed25519_key
```

[Enroll](./secrets.md#enrolling-a-host) the `.pub` key for [`secrets/system.yaml`](../secrets/system.yaml) and [`secrets/wifi.yaml`](../secrets/wifi.yaml). Without this, first boot has no wifi and no user password.

### 2. Build and flash the image on a flash drive.

```sh
nix build .#nixosConfigurations.$hostname.config.system.build.sdImage
zstd -d --stdout result/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
```

### 3. Stage the host key

Mount the card's root partition (labelled `NIXOS_SD`) and copy the SSH keypair in:

```sh
mount=$(nix-shell -p udisks --run "udisksctl mount -b /dev/disk/by-label/NIXOS_SD" | grep -o '/run/media/.*')
sudo install -d -m 755 $mount/etc/ssh
sudo install -m 600 /tmp/extra-files/$hostname/etc/ssh/ssh_host_ed25519_key $mount/etc/ssh/
sudo install -m 644 /tmp/extra-files/$hostname/etc/ssh/ssh_host_ed25519_key.pub $mount/etc/ssh/
nix-shell -p udisks --run "udisksctl unmount -b /dev/disk/by-label/NIXOS_SD"
```

### 4. First boot

Headless: the pi joins the home wifi via the `home-wifi` NetworkManager profile (credentials in [`secrets/wifi.yaml`](../secrets/wifi.yaml)) and starts sshd. Find its IP on the router, log in as the user, then `sudo tailscale up`.

Known issue: `expand-root-partition.service` [fails on first boot](https://github.com/NixOS/nixpkgs/issues/554294), leaving the root filesystem at the built image size (~5G). It only runs on first boot, so fix it by hand:

```sh
sudo sh -c 'echo ",+," | sfdisk -N2 --no-reread /dev/mmcblk0 && partprobe && resize2fs /dev/mmcblk0p2'
```

## Post Install

- Adding the public key to [GitHub](https://github.com/settings/keys) and [Codeberg](https://codeberg.org/user/settings/keys).
  - (If it doesn't exist) generate an SSH key with `ssh-keygen`. Use defaults.
  - Print the SSH key with `cat ~/.ssh/id_ed25519.pub`.
  - Add that bad boy to GitHub and Codeberg.
  - (Optional) Remove old keys if they exist.
- Using the configuration
  - (If it exists) move or delete `/etc/nixos/`.
  - Clone this repository by running `sudo nix-shell -p git --run "git clone git@github.com:gauthsvenkat/puram.git /etc/nixos"`.
  - Own the directory by `sudo chown -R <user> /etc/nixos`.
  - (If not installed through nixos-anywhere) Switch to the new configuration `sudo nixos-rebuild switch`.
