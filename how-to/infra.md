# How to infra

External infra is managed in Nix: [terranix](https://terranix.org) renders the modules in [`modules/terranix/`](../modules/terranix/) into `config.tf.json`, and [OpenTofu](https://opentofu.org) plans and applies it with `just tf <command>`. Provider credentials, the state passphrase and the encrypted state live in [`secrets/`](../secrets/).

## Bootstrapping the first time

Create tofu's own credentials by hand and put them in [`secrets/tofu.yaml`](../secrets/tofu.yaml):

- Cloudflare: an **account-owned** token with `Zone Read` + `DNS Write` on the zone and `Account API Tokens Write`.
- Scaleway: an API key for an [IAM application](https://www.scaleway.com/en/docs/iam/concepts/) with `ObjectStorageBucketPolicyFullAccess`, `ObjectStorageBucketsRead`, `ObjectStorageBucketsWrite` and `ObjectStorageObjectsRead` on the Project, and `BillingManager` and `IAMManager` on the Organization. Set the Organization's maximum API key duration to none (Security > Credential limitations), or tofu replaces its keys on every apply.
- OCI: the first time, log in with a session token instead: `nix-shell -p oci-cli --run 'oci session authenticate'`. The token lasts an hour; `oci session refresh` extends it. For the first apply, switch [`modules/terranix/oci.nix`](../modules/terranix/oci.nix) to the session token:

  ```nix
  # variable = {
  #   "oci_fingerprint".sensitive = true;
  #   "oci_private_key".sensitive = true;
  #   "oci_user_ocid".sensitive = true;
  # };

  provider.oci = {
    inherit (targetCfg.oci) region;
    tenancy_ocid = tenancyOcid;
    auth = "SecurityToken";
    config_file_profile = "DEFAULT";
    # fingerprint = lib.tf.ref "var.oci_fingerprint";
    # private_key = lib.tf.ref "var.oci_private_key";
    # user_ocid = lib.tf.ref "var.oci_user_ocid";
  };
  ```

tofu can't create a Cloudflare token that manages tokens, so import the hand-made one: `just tf import cloudflare_account_token.opentofu '<account_id>/<token_id>'`.

Then `just tf apply`. tofu creates its own Scaleway and OCI credentials; copy those into [`secrets/tofu.yaml`](../secrets/tofu.yaml) (see the outputs under "Rotating keys"). For OCI, undo the session token switch afterwards.

## Rotating keys

Every key tofu creates has a sensitive output. A new key needs one too.

1. `just secrets rotate <address> <file>` replaces the key, then copies the output's keys into `secrets/<file>.yaml`. The old key stops working here; hosts that use it fail until the next step.
2. Deploy the host that reads the key: `just nixos deploy <host>`.

> [!NOTE]
> A new OCI key seems to work only after about 5 minutes; until then, `just tf` fails with `401-NotAuthenticated`.

tofu's own Cloudflare token is the exception: roll it in the dashboard (Manage Account > API Tokens > Roll), then update `TF_VAR_cloudflare_api_token`. Rolling keeps the token id, so the state stays valid.
