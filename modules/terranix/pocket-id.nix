{
  flakeCfg,
  targetCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (flakeCfg) controlServer fqdns pocketId;
  inherit (targetCfg.pocketId) email firstName lastName;
  inherit (targetCfgs.nixos.${controlServer}) username;
in
{
  variable."pocket_id_static_api_key".sensitive = true;

  provider.pocketid = {
    base_url = "https://${fqdns.pocket-id}";
    api_token = lib.tf.ref "var.pocket_id_static_api_key";
  };

  resource = {
    pocketid_group."admins" = {
      name = pocketId.adminGroup;
      friendly_name = "Admins";
    };

    pocketid_user.${username} = {
      inherit email username;
      first_name = firstName;
      last_name = lastName;
      email_verified = true;
      is_admin = true;
      groups = [ (lib.tf.ref "pocketid_group.admins.id") ];
    };

    pocketid_client."oauth2-proxy" = {
      name = "oauth2-proxy";
      client_id = pocketId.clientIds.oauth2-proxy;
      callback_urls = [ "https://${fqdns.auth}/oauth2/callback" ];
      pkce_enabled = true;
      allowed_user_groups = [ (lib.tf.ref "pocketid_group.admins.id") ];
    };

    # The first sign-in, to add a passkey.
    pocketid_one_time_access_token.${username} = {
      user_id = lib.tf.ref "pocketid_user.${username}.id";
      ttl = "1h";
    };
  };

  output."pocket-id" = {
    value."pocket_id_oauth2_proxy_client_secret" =
      lib.tf.ref "pocketid_client.oauth2-proxy.client_secret";
    sensitive = true;
  };

  output."pocket_id_login_url" = {
    value = "https://${fqdns.pocket-id}/lc/${lib.tf.ref "pocketid_one_time_access_token.${username}.token"}";
    sensitive = true;
  };
}
