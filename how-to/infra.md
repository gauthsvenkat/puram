# How to infra

External infra is managed in Nix: [terranix](https://terranix.org) renders the modules in [`modules/terranix/`](../modules/terranix/) into `config.tf.json`, and [OpenTofu](https://opentofu.org) plans and applies it with `just tf <command>`. Provider credentials, the state passphrase and the encrypted state live in [`secrets/`](../secrets/).

## Bootstrapping the first time

Create tofu's own credentials by hand and put them in [`secrets/infra.yaml`](../secrets/infra.yaml):

- Cloudflare: an **account-owned** token with `Zone Read` + `DNS Write` on the zone and `Account API Tokens Write`.
- Scaleway: an API key for an [IAM application](https://www.scaleway.com/en/docs/iam/concepts/) with `ObjectStorageBucketsRead`, `ObjectStorageBucketsWrite` and `ObjectStorageObjectsRead` on the Project, and `IAMManager` on the Organization.
- Tailscale: an OAuth client tagged `tag:infra`, with `dns`, `policy_file`, `devices:core` and `oauth_keys` write. `tag:infra` owns every device tag, so the client can apply them. On a new tailnet, add `"tag:infra": ["autogroup:owner"]` to `tagOwners` in the console first; a client can only be created with a tag that exists. Scopes are fixed at creation; changing them needs a new OAuth client.

Then `just tf apply`. tofu creates its own credentials; copy those into [`secrets/infra.yaml`](../secrets/infra.yaml) (see the outputs under "Rotating keys").

## Rotating keys

Every key tofu creates has a sensitive output named after its sops key, in lowercase (`CLOUDFLARE_API_TOKEN` is `cloudflare_api_token`). A new key needs one too.

1. `just tf apply -replace=<address>`. The old key stops working here, unless the resource has `create_before_destroy`.
2. `just tf output -raw <output>`, then put the new value in sops with `just secrets edit`.
3. `just nixos deploy elitedesk` for keys that Caddy or restic use. For opentofu's own keys, update [`secrets/infra.yaml`](../secrets/infra.yaml) right away; a wrong value locks tofu out.
