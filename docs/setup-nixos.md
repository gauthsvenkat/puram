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

## Automated installation ([nixos-anywhere](https://github.com/nix-community/nixos-anywhere))

Make a partition scheme with [disko](https://github.com/nix-community/disko) in
`hosts/<hostname>/disko-config.nix`, then boot the target from a live ISO with
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

Add the printed age key to [`.sops.yaml`](../.sops.yaml), then `just secrets-rekey`.
Without this, first boot has no secrets and therefore no user password.

### 3. Test the disk layout (optional)

```sh
nix run github:nix-community/nixos-anywhere -- --flake .#$hostname --vm-test
```

### 4. Install

```sh
read -rs passphrase # only for encrypted disks

nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./hosts/$hostname/hardware-configuration.nix \
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
