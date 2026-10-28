# How to [OpenWrt](https://openwrt.org)

Each device under [`targets/openwrt/`](../targets/openwrt/) is built into an image with [nix-openwrt-imagebuilder](https://github.com/astro/nix-openwrt-imagebuilder) and configured with [dewclaw](https://github.com/MakiseKurisu/dewclaw). Flashing is only for a release upgrade or a clean start; every other change is a deploy.

## Build and flash

```sh
device=<device>
ip=<device-ip>

just openwrt build $device
scp -O <store-path>/openwrt-*-sysupgrade.bin root@$ip:/tmp/
ssh root@$ip 'sysupgrade -n -v /tmp/openwrt-*-sysupgrade.bin'
```

- `scp -O`: OpenWrt's dropbear has no sftp server, so scp needs the legacy protocol.
- `sysupgrade -n`: wipes the configuration, so the device's bootstrap runs on first boot. Leave it out to keep the configuration across a release upgrade. After a wipe the device has a new ssh host key: `ssh-keygen -R $ip`.

## Deploy

```sh
just openwrt deploy $device
```

The device reboots. If a deploy breaks it, it [rolls back](https://github.com/MakiseKurisu/dewclaw/blob/main/openwrt/default.nix) to the previous configuration within two minutes.

## Notes

- **Joining the tailnet** is a one-time manual step after the first deploy: `ssh root@$ip 'tailscale up --accept-dns=false --advertise-tags=tag:router'`, then open the login URL it prints. `tag:router` must already be in the policy. Joining tagged disables key expiry; tagging later does not. `--accept-dns=false` because the router is the tailnet's nameserver; it must not send its own queries to itself through Tailscale.
- **Deploys need internet.** Every deploy refreshes the package lists first.
- **A build failing with a hash mismatch** means OpenWrt republished its package index: `just update openwrt-imagebuilder`. Upstream's hashes can lag by up to a day, so it may still fail right after the update.
- **TLS errors from the package step** right after a flash are most likely the clock: NTP may not have synced yet. The deploy still completes, and the next one runs clean.
