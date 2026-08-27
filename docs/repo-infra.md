# External infra: OpenTofu

What `infra/` manages, how to operate it, and how to bootstrap it from nothing.

## Scope

| Provider | Managed | Deliberately not managed |
|---|---|---|
| Tailscale | admin DNS panel (`infra/tailscale.tf`), ACL policy file (`infra/tailnet-acl.hujson`), `tag:server` on elitedesk | device enrollment (manual SSO), auth keys, OAuth clients |
| Cloudflare | zone `gauthsvenkat.dev`, wildcard A record, Caddy's ACME token, opentofu's own token policy (`infra/cloudflare.tf`) | zone settings, registrar, `*.myrthe.gauthsvenkat.dev` (ad-hoc) |
| Scaleway | `elitedesk-backup` bucket + multipart-abort lifecycle rule, IAM trios (application/policy/api key) for restic and opentofu itself (`infra/scaleway.tf`) | default org policies (Administrators, Editors, ...) |

`local.tailnet_ip` in `infra/tailscale.tf` is the single source for elitedesk's tailnet IP - it feeds both the Cloudflare wildcard record and the tailnet's primary nameserver. If the IP ever changes, edit that one line and apply.

## Operating

```sh
just tf plan
just tf apply
```

The recipe wraps `sops exec-env secrets.yaml 'tofu -chdir=infra ...'` - provider credentials and the state passphrase exist only in that process's environment. `tofu` itself comes from the flake devshell (direnv) with providers pinned from nixpkgs; `init` never touches a registry.

- After every `apply`, commit `infra/terraform.tfstate`.
- After a flake update bumps a provider, `plan` fails on a lock mismatch; run `just tf init -upgrade` and commit `.terraform.lock.hcl`.
- Fresh checkout: `just tf init` once (offline), then plan.

## State

Local state, committed to git, encrypted client-side (AES-GCM, key derived via PBKDF2). `enforced = true` in `infra/providers.tf` makes tofu refuse to read or write plaintext state. The passphrase lives in `secrets.yaml`:

```yaml
TF_ENCRYPTION: '{"key_provider":{"pbkdf2":{"passphrase":{"passphrase":"<random, 16+ chars>"}}}}'
```

Losing both the passphrase and the console access means re-importing everything; losing just the passphrase is recoverable by re-importing state from the live resources.

## Credentials

All in `secrets.yaml`, named exactly as the env vars the providers read.

| Key(s) | Where to create | Scope |
|---|---|---|
| `TAILSCALE_OAUTH_CLIENT_ID` / `_SECRET` | admin console → Settings → OAuth clients | `dns` write, `policy_file` write, `devices:core` write, tagged `tag:server` |
| `CLOUDFLARE_API_TOKEN` | account dashboard → API Tokens (account-owned token) | `Zone Read` + `DNS Write` on `gauthsvenkat.dev`, `Account API Tokens Write`; separate from Caddy's token |
| `SCW_ACCESS_KEY` / `SCW_SECRET_KEY` | console → IAM → application `opentofu-infra` → API keys | `ObjectStorageBucketsRead`/`Write` on project `Backup`, `IAMManager` (org) |

Tailscale OAuth client scopes are fixed at creation - a scope change means a new client (create new, swap sops values, revoke old). The Cloudflare token value is shown once; ditto the Scaleway secret key.

## File layout

One file per provider, sections in order: `provider` block (if the provider needs config), `locals`, resources from big scope to small (infrastructure first, then credential trios application → policy → key, with opentofu's own credentials last), `output`s, and `import` blocks at the end grouped by date, mirroring resource order. `data` blocks are not a section - each sits directly above its first consumer.

## Quirks

- **Tailscale nameserver order**: the API returns the list unordered, so `ignore_changes = [nameservers]` suppresses phantom reorder diffs. To change the list deliberately, comment out the `lifecycle` block for one apply.
- **ACL is whole-file**: applying replaces the entire console policy with `tailnet-acl.hujson`. Console-side ACL edits get clobbered on the next apply.
- **Backup bucket**: never add object expiration to the lifecycle rules - restic owns all deletion, age-based expiry corrupts the repository. `force_destroy = false` makes tofu refuse to destroy the bucket while it holds objects.
- **elitedesk re-enrollment**: a wiped/re-enrolled device gets a new node ID; the `tailscale_device` data source re-resolves by hostname, so the next apply re-tags it. Tagging disables key expiry automatically.
- **Cloudflare token families**: tokens are either user-owned (`/user/tokens`, My Profile) or account-owned (`/accounts/{id}/tokens`). Everything here is account-owned; the provider's `cloudflare_api_token` resource is for user tokens and does not apply.

## Rotating the Caddy token

1. Add (once) a sensitive output for `cloudflare_account_token.caddy_dns.value`.
2. `just tf apply -replace=cloudflare_account_token.caddy_dns` - the old token dies here.
3. `just tf output -raw caddy_dns_token`, then `just secrets-edit`: `cloudflare_dns_token: CLOUDFLARE_API_TOKEN=<new value>`.
4. `just deploy elitedesk` - re-renders Caddy's env file and restarts it.

Between steps 2 and 4 Caddy holds a dead token; only cert issuance in that window would notice.

## Rotating Scaleway keys

Both API keys expire: restic on **2027-07-30**, opentofu on **2027-08-25**. Rotate before then - an expired restic key silently kills offsite backups.

- restic: add (once) a sensitive output for `scaleway_iam_api_key.restic.secret_key`, then `just tf apply -replace=scaleway_iam_api_key.restic`, read access + secret via `just tf output`, update `scaleway_backups_access_key` / `scaleway_backups_secret_key` in sops (both change), `just deploy elitedesk`, verify the next backup run.
- opentofu's own key: same replace flow (`create_before_destroy` mints the successor before revoking the old key), then update `SCW_ACCESS_KEY` / `SCW_SECRET_KEY` in sops immediately - a wrong paste here locks opentofu out until fixed from state or the console.

## Disaster recovery

- Fresh tailnet: enroll devices manually, recreate the OAuth client, then `just tf apply` recreates the DNS panel, ACL, and elitedesk's tag.
- Anything drifted by hand in a console shows up in the next `plan`; apply reverts it.
