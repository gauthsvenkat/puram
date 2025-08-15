# NixOS setup

- Installing NixOS.
  - Manual installation with the graphical ISO installer.
    - Download the ISO, follow the steps. Don't forget to encrypt disk if laptop.
    - Reboot and head to `/etc/nixos/configuration.nix` to change the hostname to your preference.
    - (Optional) enable ssh to continue the rest from a different machine.
    - Re (boot or login).
  - Automated installation with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere).
    - Make a partition scheme with [disko](https://github.com/nix-community/disko).
    - Check the [justfile](../../justfile) and the nixos-anywhere docs for which commands to run.
    - Along the way, a new `hardware-configuration.nix` will be generated. Make sure to add it to the `hosts/`.

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
  - Install the rust toolchain by running `rustup default stable`.
  - Clone neovim configuration: `git clone git@github.com:gauthsvenkat/nvim.git ~/.config/nvim/`.
