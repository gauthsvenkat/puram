# How to infra

External infra is managed in Nix: [terranix](https://terranix.org) renders the modules in [`modules/terranix/`](../modules/terranix/) into `config.tf.json`, and [OpenTofu](https://opentofu.org) plans and applies it with `just tf <command>`. Provider credentials, the state passphrase and the encrypted state live in [`secrets/`](../secrets/).

## Bootstrapping the first time

Create tofu's own credentials by hand and put them in [`secrets/tofu.yaml`](../secrets/tofu.yaml):

- Cloudflare: an **account-owned** token with `Zone Read` + `DNS Write` on the zone and `Account API Tokens Write`.
- Scaleway: an API key for an [IAM application](https://www.scaleway.com/en/docs/iam/concepts/) with `ObjectStorageBucketPolicyFullAccess`, `ObjectStorageBucketsRead`, `ObjectStorageBucketsWrite` and `ObjectStorageObjectsRead` on the Project, and `BillingManager` and `IAMManager` on the Organization. Set the Organization's maximum API key duration to none (Security > Credential limitations), or tofu replaces its keys on every apply.
- OCI: none. Log in with a session token instead: `nix-shell -p oci-cli --run 'oci session authenticate'`, and for the first apply set `auth = "SecurityToken"` and `config_file_profile = "DEFAULT"` on `provider.oci`. The token lasts an hour; `oci session refresh` extends it.

tofu can't create a Cloudflare token that manages tokens, so import the hand-made one: `just tf import cloudflare_account_token.opentofu '<account_id>/<token_id>'`.

Then `just tf apply`. tofu creates its own Scaleway and OCI credentials; copy those into [`secrets/tofu.yaml`](../secrets/tofu.yaml) (see the outputs under "Rotating keys"). For OCI, remove the session token settings (`auth` and `config_file_profile`) afterwards.

## Rotating keys

Every key tofu creates has a sensitive output. A new key needs one too.

1. `just tf apply -replace=<address>`. The old key stops working here, unless the resource has `create_before_destroy`.
2. `just tf output -raw <key>_<file>`, then put the new value under `<key>` with `just secrets edit <file>`.
3. Deploy the host that reads the key: `just nixos deploy <host>`, for example sentinel or elitedesk for Caddy, elitedesk for restic. For opentofu's own keys, update [`secrets/tofu.yaml`](../secrets/tofu.yaml) right away; a wrong value locks tofu out.

tofu's own Cloudflare token is the exception: roll it in the dashboard (Manage Account > API Tokens > Roll), then update `CLOUDFLARE_API_TOKEN`. Rolling keeps the token id, so the state stays valid.
