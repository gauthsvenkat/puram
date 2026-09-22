# OpenWrt router: archer-c7

The router is a TP-Link Archer C7 v5 running OpenWrt, managed from this repo in
two stages.

## The two stages

| Stage | Tool | Owns |
|---|---|---|
| 1. Image | [nix-openwrt-imagebuilder](https://github.com/astro/nix-openwrt-imagebuilder) | the firmware: OpenWrt version, packages, and a first-boot bootstrap |
| 2. Deploy | [dewclaw](https://github.com/MakiseKurisu/dewclaw) | the configuration: network, wifi, dhcp, firewall, system |

**Stage 1** gets a wiped router back to *reachable and online*, nothing more. The
image ships a `uci-defaults` script that runs once at first boot and sets the
hostname, key-only ssh, the KPN WAN, and a temporary `archer-c7-setup` wifi so
you can reach the router without a cable. It skips itself on a router that is
already configured.

**Stage 2** replaces that with the real configuration from
`hosts/archer-c7/default.nix`: the home wifi, the guest network, dhcp and the
firewall. This is also how every later change is applied - stage 1 is only for a
fresh or upgraded router.

## Build and flash

Flashing is only needed for an OpenWrt release upgrade or to start clean.

```sh
just build-router-image
scp -O <store-path>/openwrt-*-sysupgrade.bin root@192.168.1.1:/tmp/
ssh root@192.168.1.1 'sysupgrade -n -v /tmp/openwrt-*-sysupgrade.bin'
```

`-n` wipes the existing configuration, which is what makes the bootstrap run.
Leave it out to keep the configuration across a release upgrade.

After about two minutes the `archer-c7-setup` network appears. Join it, then run
stage 2.

## Deploy

```sh
just deploy-router            # reboots the router
just deploy-router --reload   # no reboot; only for changes that cannot drop the link
```

The router reverts to its previous configuration if the deploy is not confirmed
within two minutes, so a bad change repairs itself.

## Notes

- **The router needs internet to deploy.** Every deploy refreshes the package
  lists first, so keep the ONT connected.
- **`scp -O`** is required; the router has no sftp server.
- **A failing build with a hash mismatch** means the OpenWrt download servers
  moved: `just update openwrt-imagebuilder`.
- **Secrets** (wifi, guest wifi, root password) come from `secrets/router.yaml`,
  decrypted on your machine at deploy time. See
  [setup-secrets.md](setup-secrets.md).
- **Recovery**, if the router is ever unreachable: power cycle first. Failing
  that, TFTP recovery needs a cable, see the
  [device page](https://openwrt.org/toh/tp-link/archer_c7_v5).
