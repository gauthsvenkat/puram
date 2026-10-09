# OpenWrt router: flint-2

The router is a GL.iNet Flint 2 (GL-MT6000) running OpenWrt, managed from this
repo in two stages.

## The two stages

| Stage | Tool | Owns |
|---|---|---|
| 1. Image | [nix-openwrt-imagebuilder](https://github.com/astro/nix-openwrt-imagebuilder) | the firmware: OpenWrt version, packages, and a first-boot bootstrap |
| 2. Deploy | [dewclaw](https://github.com/MakiseKurisu/dewclaw) | the configuration: network, wifi, dhcp, firewall, system |

**Stage 1** gets a wiped router back to *reachable and online*, nothing more. The
image ships a `uci-defaults` script that runs once at first boot and sets the
hostname, key-only ssh, the KPN WAN, and a temporary `flint-2-setup` wifi so
you can reach the router without a cable. It skips itself on a router that is
already configured.

**Stage 2** replaces that with the real configuration from
`hosts/openwrt/flint-2/default.nix`: the home wifi, the guest network, dhcp and the
firewall. This is also how every later change is applied - stage 1 is only for a
fresh or upgraded router.

## Build and flash

Flashing is only needed for an OpenWrt release upgrade or to start clean.

Before flashing new hardware, the GL.iNet stock firmware is itself OpenWrt and
accepts `ssh root@192.168.8.1` with the admin password set in its wizard.
`cat /etc/board.json` and `ls /sys/class/leds` there confirm the port and LED
names used in `hostCfg.nix`. It cannot confirm wifi paths; stock runs the closed
MediaTek driver.

```sh
just build-router-image
scp -O <store-path>/openwrt-*-sysupgrade.bin root@192.168.1.1:/tmp/
ssh root@192.168.1.1 'sysupgrade -n -v /tmp/openwrt-*-sysupgrade.bin'
```

`-n` wipes the existing configuration, which is what makes the bootstrap run.
Leave it out to keep the configuration across a release upgrade.

Coming from the GL.iNet stock firmware instead: open its web UI at
`192.168.8.1`, go to Upgrade, upload the same `*-sysupgrade.bin`, and untick
"keep settings". Only ever flash the sysupgrade image; the factory image can
brick the device.

After about two minutes the `flint-2-setup` network appears. Join it, then run
stage 2. New hardware has a new ssh host key, so first:

```sh
ssh-keygen -R 192.168.1.1
```

## Deploy

```sh
just deploy-router            # reboots the router
just deploy-router --reload   # no reboot; only for changes that cannot drop the link
```

The router reverts to its previous configuration if the deploy is not confirmed
within two minutes, so a bad change repairs itself.

## Hardware

- `lan1` and WAN are the 2.5 GbE ports; `lan2`-`lan5` are 1 GbE.
- Label MACs: WAN `94:83:c4:e3:c9:0a`, LAN `94:83:c4:e3:c9:0c`.
- 8 GB eMMC, single kernel and rootfs partition. Not dual-boot.

## Notes

- **The router needs internet to deploy.** Every deploy refreshes the package
  lists first, so keep the ONT connected.
- **`scp -O`** is required; the router has no sftp server.
- **A failing build with a hash mismatch** means the OpenWrt download servers
  moved: `just update openwrt-imagebuilder`.
- **Secrets** (wifi, guest wifi, root password) come from `secrets/router.yaml`,
  decrypted on your machine at deploy time. See
  [setup-secrets.md](setup-secrets.md).
- **TLS errors from the package step** right after a fresh flash are most likely the
  clock: the router has no battery clock and NTP may not have synced yet. The
  deploy still completes because the image already carries every package, and
  the next deploy runs clean.
- **Hardware flow offloading** is on. `nft list flowtables` on the router
  should show `flags offload`; if the firewall fell back to software offload,
  `logread | grep offload` says so.
- **Recovery**, if the router is ever unreachable: power cycle first. Failing
  that, use the U-Boot web recovery: give your machine `192.168.1.2/24`, cable
  it into `lan2`-`lan5` (U-Boot does not drive the 2.5G ports), hold reset
  while powering on until the LED goes solid white, then upload the sysupgrade
  image at `http://192.168.1.1`. See the
  [device page](https://openwrt.org/toh/gl.inet/gl-mt6000).
