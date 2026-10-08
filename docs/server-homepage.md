# Homepage Dashboard

Out-of-repo bits for the elitedesk homepage at `https://homepage.gauthsvenkat.dev`. Everything else (services, layout, widgets, theming) is fully declared in `hosts/nixos/elitedesk/default.nix`.

## What's in nix vs. out

| In nix | Out of nix |
|---|---|
| Service tiles, widgets, layout, bookmarks, theme | API keys / passwords for the services homepage queries |
| Caddy reverse proxy, allowedHosts | Per-service web-UI flags that gate API access (qBit, sabnzbd) |

Manual state lives in **one** sops secret (`homepage_env`) and a couple of per-service web-UI toggles.

## The `homepage_env` secret

`services.homepage-dashboard` reads `homepage_env` as a systemd `EnvironmentFile`. The host config references each value with `{{HOMEPAGE_VAR_*}}` placeholders, which homepage substitutes at request time so secrets never land in the world-readable `/etc/homepage-dashboard/services.yaml`.

Shape:

```yaml
homepage_env: |
  HOMEPAGE_VAR_JELLYFIN_KEY=...
  HOMEPAGE_VAR_IMMICH_KEY=...
  HOMEPAGE_VAR_PAPERLESS_KEY=...
  HOMEPAGE_VAR_SONARR_KEY=...
  HOMEPAGE_VAR_RADARR_KEY=...
  HOMEPAGE_VAR_PROWLARR_KEY=...
  HOMEPAGE_VAR_BAZARR_KEY=...
  HOMEPAGE_VAR_SABNZBD_KEY=...
  HOMEPAGE_VAR_SEERR_KEY=...
  HOMEPAGE_VAR_QBIT_USER=...
  HOMEPAGE_VAR_QBIT_PASS=...
  HOMEPAGE_VAR_ADGUARD_USER=...
  HOMEPAGE_VAR_ADGUARD_PASS=...
```

The dashboard renders fine if a value is missing - the affected tile just shows an "API Error". Populate incrementally.

### Where each value comes from

| Variable | Source |
|---|---|
| `JELLYFIN_KEY` | `https://jellyfin.gauthsvenkat.dev` → Dashboard → API Keys |
| `IMMICH_KEY` | `https://immich.gauthsvenkat.dev` → Account Settings → API Keys |
| `PAPERLESS_KEY` | `https://paperless.gauthsvenkat.dev` → user menu (top right) → My Profile → API Auth Token |
| `SONARR_KEY` | `https://sonarr.gauthsvenkat.dev` → Settings → General → API Key |
| `RADARR_KEY` | same path on `radarr.gauthsvenkat.dev` |
| `PROWLARR_KEY` | same path on `prowlarr.gauthsvenkat.dev` |
| `BAZARR_KEY` | `https://bazarr.gauthsvenkat.dev` → Settings → General → API Key |
| `SABNZBD_KEY` | `https://sabnzbd.gauthsvenkat.dev` → Config → General → API Key (full, not NZB) |
| `SEERR_KEY` | `https://seerr.gauthsvenkat.dev` → Settings → General → API Key |
| `QBIT_USER` / `QBIT_PASS` | The Web UI login credentials for `https://qbittorrent.gauthsvenkat.dev` (Tools → Options → Web UI → Authentication) |
| `ADGUARD_USER` / `ADGUARD_PASS` | The login credentials for `https://adguard.gauthsvenkat.dev` |

To add or remove vars, edit the placeholder in `hosts/nixos/elitedesk/default.nix`, then add/remove the matching `HOMEPAGE_VAR_*` line via `just secrets-edit`.

## Icons

Default icon source is the dashboard-icons CDN - referenced by bare filename like `jellyfin.svg`. For services missing from dashboard-icons, prefix with `sh-` to pull from selfh.st instead. Currently used for Speedtest (`sh-speedtest-tracker.svg`), since dashboard-icons doesn't carry it.

To check whether an icon exists: try `https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/<name>.svg` (200 = use bare name) and `https://cdn.jsdelivr.net/gh/selfhst/icons/svg/<name>.svg` (200 = use `sh-<name>.svg`).

## Disaster recovery

After a fresh elitedesk install, homepage comes up empty (every widget shows "API Error") until `homepage_env` is populated. Walk the table above against each service's web UI and paste keys back in via `just secrets-edit`. No homepage-side state to restore.

## See also

- `server-networking.md` - Caddy / Tailscale / Cloudflare setup that fronts the dashboard.
- Homepage docs: https://gethomepage.dev
- selfh.st icons: https://selfh.st/icons
