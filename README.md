# Nix configurations
This repository holds the configurations of all my machines running [NixOS](https://nixos.org/), [nix-darwin](https://github.com/nix-darwin/nix-darwin) or [home-manager](https://github.com/nix-community/home-manager).

## Organization
The organization philosophy of this repository is inspired by the [polylith](https://polylith.gitbook.io/polylith) software architecture, with a focus on composability.

### [Components](./components/)
These are the building blocks of my machines. Each component tries to handle one related set of configurations.

### [Bases](./bases/)
These contain abstract hosts declarations, which put together multiple `components/` to build a specialized machine. For e.g. a [Mac workstation](./bases/darwin/workstation.nix), a [NixOS KDE workstation](./bases/nixos/desktop-environment/k) or a [NixOS server](./bases/nixos/flavor/server.nix).

### [Hosts](./hosts/)
These contain fully realized NixOS, nix-darwin or home-manager configurations, corresponding to my machines. It also contain host specific options / packages.

### [notnix](./notnix/)
Just a bunch of stuff that aren't nix files. Things like binaries (wallpaper images), configuration files.

## Setting up
This configuration does a lot of the heavy lifting for me but some steps need to be run manually, which I'm documenting. You can probably write some advanced nix code that'll eliminate some of these steps, but practicality beats purity.

- [NixOS setup](./bases/nixos/README.md)
- [nix-darwin setup](./bases/darwin/README.md)

## Notes
- On NixOS don't mix multiple desktop environments. For e.g. trying both KDE and hyprland leads to funky issues. The cause seems to be conflicting `xdg-desktop-portal`s.
- nix-darwin configuration relies on the homebrew module to install gui apps. The reason is there are lots of issues with spotlight indexing gui apps installed through nixpkgs. See
  - [mac-app-util](https://github.com/hraban/mac-app-util).
  - [this PR](https://github.com/nix-darwin/nix-darwin/pull/1396#issuecomment-3150075769) for a potential solution.

## Todo
- [feature] nixify kde plasma using [plasma-manager](https://github.com/nix-community/plasma-manager).
- [feature] setup formatters in pre-commit.
- [hyprland] setup screenshotting.
- [hyprland] clipboard manager.
- [hyprland] blue light filter. It works but is quite jarring.
- [hyprland] figure out brightnessctl for idling.
- [hyprland] checkout [pyprland](https://github.com/hyprland-community/pyprland)
