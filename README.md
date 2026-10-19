# Puram

A flake monorepo for everything I run:

- my machines, with [NixOS](https://nixos.org/) and [home-manager](https://github.com/nix-community/home-manager)
- my [OpenWrt](https://openwrt.org) router and switch, with [nix-openwrt-imagebuilder](https://github.com/astro/nix-openwrt-imagebuilder) and [dewclaw](https://github.com/MakiseKurisu/dewclaw)
- external infra (Cloudflare, Scaleway, Tailscale), with [terranix](https://terranix.org) and [OpenTofu](https://opentofu.org)
- secrets for all of the above, with [sops-nix](https://github.com/Mic92/sops-nix)

> [!NOTE]
> Agam (அகம், "interior") and puram (புறம், "exterior") are the two genres of classical Tamil poetry: private life and public life. Unless you're me, you're reading *puram*, the redacted public copy.

## Organization

The organization was originally inspired by the [polylith](https://polylith.gitbook.io/polylith) software architecture, with a focus on composability. Most folders below are split by platform (`nixos`, `home-manager`, `openwrt`, `terranix`).

- [modules](./modules/): are the building blocks. Each module handles one related set of configurations and never imports another module from this repo.
  - Usually one module per program or service, e.g. [`services/caddy.nix`](./modules/nixos/services/caddy.nix) for `services.caddy`.
  - Some group by topic instead, e.g. [`system/`](./modules/nixos/system/) or the [`openwrt`](./modules/openwrt/) ones.
  - Bigger setups get a folder split by concern, so downstream can pick parts, e.g. [`niri/`](./modules/nixos/niri/).
- [bases](./bases/): glue that imports related `modules/` and adds config shared by one or more `targets/`, e.g. a [niri workstation](./bases/nixos/niri.nix) or a [server](./bases/nixos/server.nix).
- [targets](./targets/): are the deployable units, corresponding to my machines, network devices and external infrastructure. Each one imports one or more bases and declares its own options in its `targetCfg.nix`.
- [flake](./flake/): turn the targets into flake outputs, one file per platform, merged in [`flake.nix`](./flake.nix).
- [assets](./assets/): non-nix files tracked in the repo, e.g. wallpapers and config files.
- [secrets](./secrets/): contain encrypted secrets, split by who needs them; [`.sops.yaml`](./.sops.yaml) says which host can decrypt which file. Also holds the tofu-encrypted infra state.
- [how-to](./how-to/)
  - [infra](./how-to/infra.md)
  - [nixos](./how-to/nixos.md)
  - [openwrt](./how-to/openwrt.md)
  - [secrets](./how-to/secrets.md)
  - [zfs](./how-to/zfs.md)
