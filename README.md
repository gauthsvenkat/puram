# Nix configurations

This repository holds the configurations of all my machines running [NixOS](https://nixos.org/), [nix-darwin](https://github.com/nix-darwin/nix-darwin) or [home-manager](https://github.com/nix-community/home-manager).

## Organization

The organization philosophy of this repository is inspired by the [polylith](https://polylith.gitbook.io/polylith) software architecture, with a focus on composability.

### [modules](./modules/)

These are the building blocks of my machines. Each component tries to handle one related set of configurations.

### [bases](./bases/)

These contain abstract hosts declarations, which put together multiple `modules/` to build a specialized machine. For e.g. a [Mac workstation](./bases/darwin/workstation.nix), a [NixOS KDE workstation](./bases/nixos/desktop-environment/k) or a [NixOS server](./bases/nixos/flavor/server.nix).

### [hosts](./hosts/)

These contain fully realized NixOS, nix-darwin or home-manager configurations, corresponding to my machines. It also contain host specific options / packages.

### [assets](./assets/)

Just a bunch of stuff that aren't nix files. Things like binaries (wallpaper images), configuration files.

### [patches](./patches.nix)

Upstream `nixpkgs` PRs applied at evaluation time, as a holding pen until they merge.

### [docs](./docs/)

- [setup-nixos](./docs/setup-nixos.md)
- [setup-darwin](./docs/setup-darwin.md)
- [setup-secrets](./docs/setup-secrets.md)
- [server-zfs-pool](./docs/server-zfs-pool.md)
- [server-homepage](./docs/server-homepage.md)
- [repo-patches](./docs/repo-patches.md)
