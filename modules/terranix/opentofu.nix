{
  terraform = {
    required_version = ">= 1.7";

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
      key_provider.pbkdf2."passphrase" = { };
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
