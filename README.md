# NixOS configurations
This repository holds the configurations of all my [machines](./hosts/) running [NixOS](https://nixos.org/).

## Organization
The organization philosophy of this repository is inspired by the [polylith](https://polylith.gitbook.io/polylith) software architecture, with a focus on composability.

In essence, I declare basic [components](./components/), that can be composed into different [bases](./bases/), which themselves can be composed (along with additional components) to build fully functioning NixOS [hosts](./hosts/).

### [Components](./components/)
These are the building blocks of my machines. I make a distinction between [core](./components/core/) and [optional](./components/optional/) components; The former contains modules that are required for some of my hosts to work, while the latter contains settings and toolings that are, while very important to me, are not required for the hosts to run (you can argue otherwise, but it is my code and it makes sense to me ¯\_(ツ)_/¯).

### [Bases](./bases/)
These contain abstract hosts declarations that can (coupled with some `hardware-configuration.nix`) be a fully functioning NixOS host. They put together several components and contains minimal configuration that are applicable for more than one of my host machines.

### [Hosts](./hosts/)
These contain entire NixOS configurations, corresponding to my machines.

## Setting up
This configuration does a lot of the heavy lifting for me but some steps need to be run manually, which I'm documenting here (lest I forget). You can probably write some advanced code that'll eliminate some of these steps, but practicality beats purity.

- Install NixOS
  - either through the normal process (just select some defaults).
  - or use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere). You probably also need [disko](https://github.com/nix-community/disko) in this case.
- Generate SSH keys (`ssh-keygen`)
  - Just choose defaults by hitting enter.
  - Add the public keys to [github](https://github.com/gauthsvenkat/).
- Move the default `/etc/nixos` directory somewhere (if it exists).
- Clone this repository (`git clone git@github.com:gauthsvenkat/nixos.git`) to `/etc/nixos`. Might need `sudo` and `git` for this.
- Own this directory (`chmod -R ando:ando /etc/nixos`).
- If workstation
  - Install the rust toolchain (`cargo` required for neovim) (`rustup default stable`).
  - Clone neovim configuration: `git clone git@github.com:gauthsvenkat/nvim.git ~/.config/nvim/`

## Maintainnance
This repository comes equipped with a very handy [justfile](./justfile) for basic tasks like switching config, upgrading the system and checking the flake.
