# Personal nixos configurations

This repository contains the personal configurations of my various nix machines. Checkouts the [hosts](./hosts) folder for all the different configurations.

## First steps after installation
While this configuration gets me most of the way, there are still some steps that need to be run manually.

- (as user) `ssh-keygen`
- Install rust toolchain (do this before starting neovim the first time): `rustup default stable`
- Clone wezterm configuration: `git clone git@github.com:gauthsvenkat/wezterm.git ~/.config/wezterm/`
- Clone neovim configuration: `git clone git@github.com:gauthsvenkat/nvim.git ~/.config/nvim/`
