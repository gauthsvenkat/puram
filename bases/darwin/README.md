# nix-darwin setup

My condolences.

- Installing Nix and preparing.
  - Install `nix` using the [installer from Determinate Systems](https://github.com/DeterminateSystems/nix-installer). Make sure you use the recommended upstream Nix.
  - Install xcode with `xcode-select --install`. This is required for some homebrew steps that run when doing `darwin-rebuild switch`.

- (Optional) Preparing to use [kanata](https://github.com/jtroo/kanata)
  (This has been put together on a best-effort basis by going through [this github discussion](https://github.com/jtroo/kanata/discussions/1537))
  - Install the [Karabiner-DriverKit-VirtualHIDDevice](https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/tree/main/dist).
  - Run it manually and give it the required permissions and whatnot.
  - Re (boot or login) for good measure.

- Adding public keys to [github](https://github.com/gauthsvenkat/).
  - Generate SSH keys with `ssh-keygen`. Use defaults.
  - Print the SSH keys with `cat ~/.ssh/id_ed25519.pub`.
  - Add that bad boy to github.
  - (Optional) Remove old keys associated with the current machine if it exists.

- Using the configuration
  - Clone this repository by running `sudo nix-shell -p git --run "git@github.com:gauthsvenkat/nixos.git /etc/nix-darwin"`. You can also directly use `git` since it is installed with xcode.
  - Own the directory by `sudo chown -R <user> /etc/nix-darwin`.
  - Switch to the new configuration by `sudo nix run nix-darwin/master#darwin-rebuild -- switch`.

- Post configuration steps
  - Install the rust toolchain by running `rustup default stable`.
  - Clone neovim configuration: `git clone git@github.com:gauthsvenkat/nvim.git ~/.config/nvim/`.
  - Install [Docker](https://docs.docker.com/desktop/setup/install/mac-install/).
  - (Optional) For `kanata`, make sure the binary (`/opt/homebrew/bin/kanata`) has the input monitoring permission.
  - (Optional) Setup [iterm2](https://iterm2.com/) for that sweet drop-down terminal. Switch the font while you're at it.
