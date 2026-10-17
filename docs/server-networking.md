# Networking: Caddy + Tailscale + Cloudflare

Out-of-repo dependencies and recovery recipe for `*.gauthsvenkat.dev` access on/off LAN.

## Request flow

```
[client device]                  Tailscale-connected (laptop, phone, thunderdome, ...)
   ↓ DNS query *.gauthsvenkat.dev
[Cloudflare DNS]                 authoritative for the domain (registrar + DNS in one)
   → returns 100.103.236.120     (elitedesk's tailnet IP)
   ↓ TCP/443
[Tailscale tailnet]              encrypted overlay; WAN never sees these packets
[Caddy on elitedesk]             TLS termination (LE certs via DNS-01) + reverse proxy
   ↓ loopback or LAN
[backend service]                jellyfin, immich, paperless, ...
```

The router has no inbound ports forwarded; all entry happens via Tailscale.

## External accounts

| Service | Account | Holds |
|---|---|---|
| Cloudflare (registrar + DNS) | `gauthsvenkat99@gmail.com` | `gauthsvenkat.dev` domain, wildcard A record, ACME API token |
| Tailscale | `gauthsvenkat@gmail.com` (Google login) | tailnet, device list |
| Let's Encrypt | `gauthsvenkat@gmail.com` | ACME account, auto-registered by Caddy on first cert request |
| Mullvad | - | wg-quick configs |

## Cloudflare

The domain was purchased through Cloudflare, so Cloudflare is both registrar and authoritative DNS host. No nameserver delegation step.

### DNS records

| Name | Type | Value | Proxy |
|---|---|---|---|
| `*` | A | `100.103.236.120` | DNS only (gray cloud) |

A single wildcard A record covers every subdomain (`jellyfin`, `immich`, `paperless`, …). Adding a new vhost in Caddy needs no DNS change.

The record is managed by opentofu (`modules/terranix/cloudflare.nix`, see `repo-infra.md`). The zone also holds an unmanaged ad-hoc record (`*.myrthe.gauthsvenkat.dev`).

Do **not** turn on Cloudflare's HTTP proxy (orange cloud): the tailnet IP is unroutable from the public internet, and proxying breaks the off-LAN path.

If elitedesk's tailnet IP ever shifts (rare; only on tailnet recreate or device deletion), edit `tailnetIp` in `targets/nixos/elitedesk/hostCfg.nix` and `just tf apply` - it updates this record and the tailnet nameserver together.

### ACME API token

Caddy needs a token to perform Let's Encrypt DNS-01 challenges. Stored in sops as `cloudflare_dns_token` in env-file shape so it can be passed directly via `EnvironmentFile`:

```yaml
cloudflare_dns_token: CLOUDFLARE_API_TOKEN=<token>
```

The token itself (`caddy-acme-elitedesk`, account-owned) is managed by opentofu as `cloudflare_account_token.caddy_dns` in `modules/terranix/cloudflare.nix`: `Zone Read` + `DNS Write`, scoped to the `gauthsvenkat.dev` zone only.

Rotation: opentofu replaces the token and sops gets the new value by hand - runbook in `repo-infra.md`.

## Tailscale

Tailnet IP for elitedesk: **`100.103.236.120`**. Verify after re-enrolment with `tailscale ip -4`.

### Per-host enrollment

Hosts that import `modules/nixos/services/tailscale.nix` get the daemon enabled but do not auto-authenticate. One-shot per device:

```sh
sudo tailscale up
```

Opens a browser auth URL; sign in via Google. Device shows up in the tailnet admin within seconds.

No auth-key file is wired in - Tailscale auth keys expire after 90 days, and the rebuild cadence doesn't justify rotating them.

elitedesk carries `tag:server` (applied via `modules/terranix/tailscale.nix`), which disables its node-key expiry - the server never silently drops off the tailnet.

### Hosts in the tailnet

| Host | Role | Tailscale needed |
|---|---|---|
| `elitedesk` | server (Caddy + services) | yes |
| `thunderdome` | desktop | yes |
| Laptops (`thinkpad-x1-carbon`, etc.) | inherit via `bases/nixos/laptop.nix` | yes |
| `raspi400`, `raspi5` | bare servers, roles TBD | yes |
| Phones, tablets | added manually from device | yes if you want named/HTTPS access |

LAN-only or IoT devices (smart TVs, etc.) keep using direct LAN IPs - they don't get the named-HTTPS path.

### Admin console DNS

The tailnet DNS panel (https://login.tailscale.com/admin/dns) routes every tailnet device's DNS through AdGuard on elitedesk, so blocklists apply on and off LAN.

| Setting | Value | Purpose |
|---|---|---|
| MagicDNS | on (`taile02742.ts.net`) | resolves tailnet hostnames via `100.100.100.100` |
| Global nameserver 1 | `100.103.236.120` | elitedesk AdGuard - primary |
| Global nameserver 2 | Cloudflare Public DNS (`1.1.1.1`, `1.0.0.1`, …) | fallback if elitedesk is offline |
| Global nameserver 3 | Quad9 Public DNS (`9.9.9.9`, `149.112.112.112`, …) | second fallback |
| Override DNS servers | **on** | forces all tailnet devices to use the above regardless of local DHCP / manual DNS |

The fallbacks matter: with override on, if elitedesk goes down every tailnet device loses DNS unless there's a backup. Cloudflare and Quad9 keep resolution working in that window.

Caveat: Tailscale does not guarantee nameserver order (https://tailscale.com/docs/reference/dns-in-tailscale) - clients may race all three, so the public resolvers can win over AdGuard and bypass blocklists intermittently. Strict blocklist coverage would require AdGuard as the only global nameserver, at the cost of tailnet-wide DNS outage when elitedesk is down.

AdGuard binds `0.0.0.0:53` (`modules/nixos/services/adguard-home.nix`), so the tailnet interface is covered without extra config. Allowed-clients defaults to permissive - any tailnet peer can query - so no allowlist tweak is needed.

This config is encoded in `modules/terranix/tailscale.nix` (along with the ACL policy) and applied with `just tf apply` - a fresh tailnet gets it back from the repo, not by hand. See `repo-infra.md`.

## Router / WAN posture

- **All inbound ports closed.** No port forwards. Caddy is unreachable from the public internet by design.
- **UPnP disabled** on the router. Same posture is encoded in `modules/nixos/services/syncthing.nix` (LAN-only sync).
- **Static DHCP** on the router pins elitedesk to a fixed LAN IP. No nix-side reference to that IP - it's only relevant when reaching elitedesk by LAN IP for service-side configuration (e.g. the qBittorrent / sabnzbd UIs below).
- **DNS** is configured to be elitedesk's LAN IP, so all devices on LAN use adguard as the resolver.

## Egress: VPN-confined services

Some services run inside a dedicated network namespace (`wg`) whose only
egress is a WireGuard tunnel to Mullvad. If the tunnel drops, the
namespace has no fallback route - confined services stall (kernel-
enforced kill switch). Wired via the `vpn-confinement` flake input;
the host-side entrypoint is `targets/nixos/elitedesk/vpn.nix`, and the
`confined` list there is the source of truth for what's behind VPN.

```
service in wg ns ── wg0 ── Mullvad endpoint ── clearnet
       ▲
       │  veth-wg (192.168.15.1)  ↔  wg-br (192.168.15.5)
       │
    host default ns: Caddy, sonarr, radarr, ...
```

### Non-obvious mechanics

- `portMappings` is the only mechanism to poke holes in the namespace's
  default-DROP INPUT firewall. The DNAT side (`from` → host port) is
  inert in our setup since the host firewall closes those ports
  anyway; we use `portMappings` purely for its INPUT-allow side
  effect on the `to` port.
- `networking.firewall.trustedInterfaces = [ "wg-br" ]` enables the
  reverse direction - confined services reaching back to host services
  (e.g. Prowlarr's Application sync pushing indexers to Sonarr/Radarr).
- `accessibleFrom` adds return-path routes inside the namespace for
  source IPs **outside** the bridge subnet. Caddy on the host connects
  via the bridge subnet itself, so empty/omitted is correct.
- DNS resolution inside the namespace goes via Mullvad's tunnel DNS
  (whatever the wg-quick config sets, typically `10.64.0.1`), not via
  AdGuard. The vpn-confinement module hard-drops outbound UDP/53 to
  any other resolver.

### URL conventions

Service UIs that talk to a peer on the other side of the bridge need
explicit IPs (loopback won't traverse the namespace boundary):

| Direction | Use |
|---|---|
| Host → confined service (Caddy, other host services) | `192.168.15.1:<port>` |
| Confined service → host service | `192.168.15.5:<port>` |

### Mullvad caveats

- The wg-quick config pins one server. No automatic rotation; regenerate
  the conf at Mullvad's portal to switch locations.
- Port forwarding has been disabled at Mullvad since 2023, so qBit's
  incoming peer connections won't reach us. Outbound (DHT, PEX,
  connecting to peers with open ports) still works.

### Mullvad wg-quick secret

`secrets/homeserver.yaml` holds `mullvad_wg_private_key` and `mullvad_wg_address`;
the full wg-quick config is assembled from them by
`sops.templates.mullvad_wg_config` in `targets/nixos/elitedesk/vpn.nix` (peer
endpoint and keys live there in plain nix). Generate new values at
https://mullvad.net/en/account → WireGuard configuration.

## Per-service runtime config (out of nix)

Two services enforce host-header / origin checks via their own UI configs, not env vars - has to be done once per service after first deploy:

### qBittorrent

Tools (gear) → Options → Web UI → **Server domains**: `qbittorrent.gauthsvenkat.dev`

### sabnzbd

Config → General → Tuning → **Host whitelist**: `sabnzbd.gauthsvenkat.dev`

Config → Servers → **Port**: `443` (SSL; not the NNTPS default `563`). ISP providers *may* throttle usenet traffic on `563`.

Paperless is configured fully through nix (`PAPERLESS_URL`); the rest of the stack accepts whatever Caddy proxies through.

## Caddy state and certs

ACME state - account, registered keys, per-vhost certs - lives at `/var/lib/caddy/` on the host rootfs. Not on the `dontdie` pool. Implication: a full reinstall wipes it, but Caddy re-issues every cert via DNS-01 within ~60s on first start, so no backup is needed. Just don't delete this between deploys.

## Disaster recovery: fresh elitedesk install

1. NixOS install + import `dontdie` (see `server-zfs-pool.md`).
2. Restore `~/.ssh/id_ed25519` so sops can decrypt.
3. Confirm `cloudflare_dns_token`, `mullvad_wg_private_key`, and `mullvad_wg_address` are in `secrets/homeserver.yaml` (regenerate at https://mullvad.net/en/account if not).
4. `just apply`.
5. `sudo tailscale up` → authorize device in browser.
6. Wait ~60s - Caddy issues certs for every declared vhost via DNS-01.
7. Verify: `curl https://homarr.gauthsvenkat.dev` from any tailnet device.
8. If `tailscale ip -4` on elitedesk returns something other than `100.103.236.120`, edit `tailnetIp` in `targets/nixos/elitedesk/hostCfg.nix` and `just tf apply` - it updates the Cloudflare record and the tailnet nameserver together (the nameserver change needs the `ignore_changes` line lifted for that one apply, see `repo-infra.md`).
9. Redo the per-service runtime config above (qBittorrent server domains, sabnzbd host whitelist) - the configs live in service state, not in nix.

## See also

- `repo-infra.md` - opentofu management of Cloudflare/Tailscale/Scaleway.
- `server-zfs-pool.md` - storage layout for the homeserver datasets.
- Caddy DNS-01 / Cloudflare plugin: https://github.com/caddy-dns/cloudflare
- Tailscale admin: https://login.tailscale.com/admin
