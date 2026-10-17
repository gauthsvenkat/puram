{
  terraform = {
    required_version = ">= 1.7";

    backend.local.path = "../secrets/terraform.tfstate";

    required_providers = {
      cloudflare = {
        source = "cloudflare/cloudflare";
        version = "~> 5.0";
      };
      scaleway = {
        source = "scaleway/scaleway";
        version = "~> 2.0";
      };
      tailscale = {
        source = "tailscale/tailscale";
        version = "~> 0.29";
      };
    };

    encryption = {
      key_provider.pbkdf2.passphrase = { };
      method.aes_gcm.main.keys = "key_provider.pbkdf2.passphrase";
      state = {
        method = "method.aes_gcm.main";
        enforced = true;
      };
      plan = {
        method = "method.aes_gcm.main";
        enforced = true;
      };
    };
  };
}
