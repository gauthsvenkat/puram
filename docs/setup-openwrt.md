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
`targets/openwrt/flint-2/default.nix`: the home wifi, the guest network, dhcp and the
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
just build-openwrt-image
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
just deploy-openwrt            # reboots the router
just deploy-openwrt --reload   # no reboot; only for changes that cannot drop the link
```

The router reverts to its previous configuration if the deploy is not confirmed
within two minutes, so a bad change repairs itself.

## Switch: gs1900-8hp

The Zyxel GS1900-8HP (rev. B1) runs the same two stages, plus one before them,
with `just device=gs1900-8hp ...`. It is a plain switch at `192.168.1.2`: all
ports in one bridge, PoE on every port, no dhcp, no firewall.

The stock UI only accepts Zyxel-format images, so a first install goes through
OpenWrt's initramfs image, which runs from RAM and writes nothing. The
imagebuilder cannot produce one, so it comes from upstream. It boots at
`192.168.1.1`, the router's address, so this stage runs on a direct cable in a
network namespace: a separate routing table where `192.168.1.1` can only mean
the switch. It is gone after a reboot, or with `ip netns del lab`. Nothing
inside the namespace has internet, so fetch tools into the store first.

1. Download the initramfs, check it against
   [sha256sums](https://downloads.openwrt.org/releases/25.12.5/targets/realtek/rtl838x/sha256sums),
   and give it a short name; the stock UI rejects filenames over 64 characters:

   ```sh
   curl -o initramfs.bin https://downloads.openwrt.org/releases/25.12.5/targets/realtek/rtl838x/openwrt-25.12.5-realtek-rtl838x-zyxel_gs1900-8hp-b1-initramfs-kernel.bin
   ```

2. Cable the switch to a spare port and move that port into a namespace:

   ```sh
   sudo ip netns add lab
   sudo ip link set <port> netns lab
   sudo ip -n lab addr add 192.168.1.10/24 dev <port>
   sudo ip -n lab link set <port> up
   sudo ip -n lab link set lo up
   ```

3. Stock waits for dhcp and does not fall back to `192.168.1.1`, so lend it a
   lease. This stays in the foreground and prints the address it hands out:

   ```sh
   sudo ip netns exec lab "$(nix build --no-link --print-out-paths nixpkgs#dnsmasq)/bin/dnsmasq" -d -i <port> --port=0 --no-resolv --no-hosts --dhcp-range=192.168.1.50,192.168.1.60,1h
   ```

4. Open that address in a browser that lives in the namespace; `--no-remote`
   stops it from handing the url to the one already running outside:

   ```sh
   mkdir -p /tmp/lab
   sudo ip netns exec lab sudo -u "$USER" env HOME="$HOME" DISPLAY="$DISPLAY" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" firefox --no-remote --profile /tmp/lab
   ```

   Log in (admin / 1234). Under Maintenance, Firmware, Management note which
   image is active; it must be partition 0. Under Firmware, Upload, upload the
   initramfs as the active image. Back on Management, partition 0 now shows the
   initramfs size. Reboot. Anything on a PoE port loses power.
5. It boots OpenWrt at `192.168.1.1` with an empty root password. Flash for
   real. `sudo` runs ssh as root, hence the explicit key:

   ```sh
   just device=gs1900-8hp build-openwrt-image
   sudo ip netns exec lab scp -O -i ~/.ssh/id_ed25519 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no <store-path>/openwrt-*-sysupgrade.bin root@192.168.1.1:/tmp/sysupgrade.bin
   sudo ip netns exec lab ssh -i ~/.ssh/id_ed25519 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.1.1 'sysupgrade -n -v /tmp/sysupgrade.bin'
   ```

   The command ends with a failed ubus call; that is sysupgrade closing its
   own session. This overwrites both of Zyxel's firmware slots. From here on,
   recovery is failsafe mode or a serial console (header reachable through the
   vent slits on B1).
6. The LED blinks for a minute or two while the overlay is created, then goes
   solid. It comes back at `192.168.1.2` with the bootstrap applied. Delete the
   namespace; the port only returns once every process in it is gone, and the
   lab browser leaves dbus and portal helpers behind, so kill those or reboot.
   Plug the switch into the lan and run
   `just device=gs1900-8hp deploy-openwrt`. Every deploy restarts the PoE
   daemon, which briefly cuts power to PoE devices.

**Failsafe**, if the switch boots but is unreachable: power cycle, ignore the
rapid blink, and hold the reset pin from the moment the LED goes dark until it
blinks rapidly again. It is then at `192.168.1.1` on `lan1` only, with no
password. `sysupgrade` does not work there; fix the config instead:

```sh
ssh root@192.168.1.1 "mount_root; uci set network.lan.ipaddr='192.168.1.2/24'; uci commit network; reboot -f"
```

If it keeps booting the initramfs after sysupgrade, the active slot was 1:
`fw_setsys bootpartition 0` and reboot. Details on the
[device page](https://openwrt.org/toh/zyxel/gs1900-8hp_v1) and the
[partition change](https://github.com/openwrt/openwrt/pull/16442).

## Backup router

The Archer C7 config is kept under `targets/openwrt/archer-c7/` as a cold spare.
It is not deployed to; to bring it back, flash it and run the recipes with
`just device=archer-c7 ...`. Keep its WAN unplugged otherwise, as both routers
claim 192.168.1.1.

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
- **Secrets** (wifi, guest wifi, root password) come from `secrets/wifi.yaml` (the root password is `hashedPassword` in
  `secrets/system.yaml`), merged and decrypted on your machine at deploy time. See
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
