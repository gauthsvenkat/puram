# External infra: OpenTofu

What the terranix config in `targets/terranix/infra/` manages, how to operate it, and how to bootstrap it from nothing.

## Scope

| Provider | Managed | Deliberately not managed |
|---|---|---|
| Tailscale | admin DNS panel, ACL policy, `tag:server` on elitedesk (`modules/terranix/tailscale.nix`) | device enrollment (manual SSO), auth keys, OAuth clients |
| Cloudflare | zone `gauthsvenkat.dev`, wildcard A record, Caddy's ACME token, opentofu's own token policy (`modules/terranix/cloudflare.nix`) | zone settings, registrar, `*.myrthe.gauthsvenkat.dev` (ad-hoc) |
| Scaleway | `elitedesk-backup` bucket + multipart-abort lifecycle rule, IAM trios (application/policy/api key) for restic and opentofu itself (`modules/terranix/scaleway.nix`) | default org policies (Administrators, Editors, ...) |

`tailnetIp` in `targets/nixos/elitedesk/targetCfg.nix` is the single source for elitedesk's tailnet IP - it feeds both the Cloudflare wildcard record and the tailnet's primary nameserver. If the IP ever changes, edit that one line and apply.

## Operating

```sh
just tf plan
just tf apply
```

The recipe builds `.#infra-config` (terranix renders the Nix modules to `config.tf.json`) into the gitignored `.tofu/`, runs `tofu init` there, then the given command - all under `sops exec-env secrets/infra.yaml`, so provider credentials and the state passphrase exist only in that process's environment. `tofu` itself comes from the flake devshell (direnv) with providers from nixpkgs, the list derived from `required_providers`; `init` never touches a registry.

- After every `apply`, commit `secrets/terraform.tfstate`.
- A flake update can bump a provider; `init -upgrade` accepts it, and `plan` shows what the new version changes (typically new attributes). The provider lock file lives in `.tofu/` and is never committed.
- Fresh checkout: nothing to set up, `just tf plan` works.

## State

Local state at `secrets/terraform.tfstate`, committed to git, encrypted client-side by tofu (AES-GCM, key derived via PBKDF2), not by sops. `enforced = true` in `modules/terranix/opentofu.nix` makes tofu refuse to read or write plaintext state. The passphrase lives in `secrets/infra.yaml`:

```yaml
TF_ENCRYPTION: '{"key_provider":{"pbkdf2":{"passphrase":{"passphrase":"<random, 16+ chars>"}}}}'
```

Losing both the passphrase and the console access means re-importing everything; losing just the passphrase is recoverable by re-importing state from the live resources.

## Credentials

All in `secrets/infra.yaml` (decryptable by workstations only, see `setup-secrets.md`), named exactly as the env vars the providers read.

| Key(s) | Where to create | Scope |
|---|---|---|
| `TAILSCALE_OAUTH_CLIENT_ID` / `_SECRET` | admin console → Settings → OAuth clients | `dns` write, `policy_file` write, `devices:core` write, tagged `tag:server` |
| `CLOUDFLARE_API_TOKEN` | account dashboard → API Tokens (account-owned token) | `Zone Read` + `DNS Write` on `gauthsvenkat.dev`, `Account API Tokens Write`; separate from Caddy's token |
| `SCW_ACCESS_KEY` / `SCW_SECRET_KEY` | console → IAM → application `opentofu-infra` → API keys | `ObjectStorageBucketsRead`/`Write` on project `Backup`, `IAMManager` (org) |

Tailscale OAuth client scopes are fixed at creation - a scope change means a new client (create new, swap sops values, revoke old). The Cloudflare token value is shown once; ditto the Scaleway secret key.

## File layout

Same shape as the other platforms: `targets/terranix/infra/default.nix` imports `bases/terranix/opentofu.nix` (the `terraform` block: providers, encryption, state path) and one module per provider from `modules/terranix/`. `targets/terranix/infra/targetCfg.nix` holds the account and org IDs. Values shared with a NixOS host (`domain`, `tailnetIp`) live in that host's `targetCfg` and the modules read them through `allTargetCfgs`.

Inside a module, resources are grouped by type and sorted lexicographically like any other Nix file. Cross-resource references are `lib.tf.ref "<address>"` strings. The provider's nested blocks (`rule`, `nameservers`, `lifecycle_rule`) are lists of attrsets. There are no `import` blocks; everything is in state.

## Quirks

- **Tailscale nameserver order**: the API returns the list unordered, so `ignore_changes = [nameservers]` suppresses phantom reorder diffs. To change the list deliberately, comment out the `lifecycle.ignore_changes` line for one apply.
- **ACL is whole-policy**: applying replaces the entire console policy with the attrset in `tailscale.nix`. Console-side ACL edits get clobbered on the next apply.
- **Backup bucket**: never add object expiration to the lifecycle rules - restic owns all deletion, age-based expiry corrupts the repository. `force_destroy = false` makes tofu refuse to destroy the bucket while it holds objects.
- **elitedesk re-enrollment**: a wiped/re-enrolled device gets a new node ID; the `tailscale_device` data source re-resolves by hostname, so the next apply re-tags it. Tagging disables key expiry automatically.
- **Cloudflare token families**: tokens are either user-owned (`/user/tokens`, My Profile) or account-owned (`/accounts/{id}/tokens`). Everything here is account-owned; the provider's `cloudflare_api_token` resource is for user tokens and does not apply.

## Rotating the Caddy token

1. Add (once) a sensitive output in `cloudflare.nix`: `output.caddy_dns_token = { value = lib.tf.ref "cloudflare_account_token.caddy_dns.value"; sensitive = true; };`.
2. `just tf apply -replace=cloudflare_account_token.caddy_dns` - the old token dies here.
3. `just tf output -raw caddy_dns_token`, then `just secrets edit`: `cloudflare_dns_token: CLOUDFLARE_API_TOKEN=<new value>`.
4. `just nixos deploy elitedesk` - re-renders Caddy's env file and restarts it.

Between steps 2 and 4 Caddy holds a dead token; only cert issuance in that window would notice.

## Rotating Scaleway keys

Both API keys expire: restic on **2027-07-30**, opentofu on **2027-08-25**. Rotate before then - an expired restic key silently kills offsite backups.

- restic: add (once) a sensitive output for `scaleway_iam_api_key.restic.secret_key` (same shape as the Caddy one), then `just tf apply -replace=scaleway_iam_api_key.restic`, read access + secret via `just tf output`, update `scaleway_backups_access_key` / `scaleway_backups_secret_key` in sops (both change), `just nixos deploy elitedesk`, verify the next backup run.
- opentofu's own key: same replace flow (`create_before_destroy` mints the successor before revoking the old key), then update `SCW_ACCESS_KEY` / `SCW_SECRET_KEY` in sops immediately - a wrong paste here locks opentofu out until fixed from state or the console.

## Disaster recovery

- Fresh tailnet: enroll devices manually, recreate the OAuth client, then `just tf apply` recreates the DNS panel, ACL, and elitedesk's tag.
- Anything drifted by hand in a console shows up in the next `plan`; apply reverts it.
