# Nix configurations

This repository holds the configurations of all my machines running [NixOS](https://nixos.org/) and [home-manager](https://github.com/nix-community/home-manager).

## Organization

The organization philosophy of this repository is inspired by the [polylith](https://polylith.gitbook.io/polylith) software architecture, with a focus on composability.

### [modules](./modules/)

These are the building blocks of my machines. Each component tries to handle one related set of configurations.

### [bases](./bases/)

These contain abstract hosts declarations, which put together multiple `modules/` to build a specialized machine. For e.g. a [KDE workstation](./bases/desktop-environment/kde.nix) or a [server](./bases/flavor/server.nix).

### [hosts](./hosts/)

These contain fully realized NixOS configurations, corresponding to my machines. It also contain host specific options / packages.

### [assets](./assets/)

Just a bunch of stuff that aren't nix files. Things like binaries (wallpaper images), configuration files.

### [lib](./lib/)

Pure helper functions used by `flake.nix`.

### [docs](./docs/)

- [setup-nixos](./docs/setup-nixos.md)
- [setup-secrets](./docs/setup-secrets.md)
- [server-zfs-pool](./docs/server-zfs-pool.md)
- [server-homepage](./docs/server-homepage.md)
- [repo-patches](./docs/repo-patches.md)
