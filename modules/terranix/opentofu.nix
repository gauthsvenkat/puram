{ lib, ... }:
{
  variable."opentofu_encryption_passphrase".sensitive = true;

  terraform = {
    required_version = ">= 1.8";

    backend.local.path = "../secrets/terraform.tfstate";

    required_providers = {
      cloudflare = {
        source = "cloudflare/cloudflare";
        version = "~> 5.0";
      };
      oci = {
        source = "oracle/oci";
        version = "~> 9.0";
      };
      # TODO: switch to `pocket-id/pocketid` once nixpkgs packages it.
      pocketid = {
        source = "trozz/pocketid";
        version = "~> 2.4";
      };
      scaleway = {
        source = "scaleway/scaleway";
        version = "~> 2.0";
      };
      tls = {
        source = "hashicorp/tls";
        version = "~> 4.0";
      };
    };

    encryption = {
      key_provider.pbkdf2."passphrase".passphrase = lib.tf.ref "var.opentofu_encryption_passphrase";
      method.aes_gcm."main".keys = "key_provider.pbkdf2.passphrase";
      plan = {
        method = "method.aes_gcm.main";
        enforced = true;
      };
      state = {
        method = "method.aes_gcm.main";
        enforced = true;
      };
    };
  };
}
