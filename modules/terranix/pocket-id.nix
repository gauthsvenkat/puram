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
  users = {
    ${username} = {
      inherit email username;
      first_name = firstName;
      last_name = lastName;
      email_verified = true;
      is_admin = true;
      groups = [ (lib.tf.ref "pocketid_group.admins.id") ];
    };
  };
  # attrNames :: { username::String -> user } -> [ username::String ]
  #   where user = { username, email, first_name, last_name :: String; ... }
  usernames = lib.attrNames users;
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

    pocketid_user = users;

    pocketid_client =
      let
        admins = [ (lib.tf.ref "pocketid_group.admins.id") ];
        mkClient = name: callbackUrl: allowedGroups: {
          inherit name;
          client_id = pocketId.clientIds.${name};
          callback_urls = [ callbackUrl ];
          pkce_enabled = true;
          allowed_user_groups = allowedGroups;
        };
      in
      {
        "headscale" = mkClient "headscale" "https://${fqdns.headscale}/oidc/callback" null;
        "headplane" = mkClient "headplane" "https://${fqdns.headplane}/admin/oidc/callback" admins;
        "oauth2-proxy" = mkClient "oauth2-proxy" "https://${fqdns.auth}/oauth2/callback" admins;
      };

    # The first sign-in, to add a passkey.
    # genAttrs :: [ username::String ] -> (username::String -> token) -> { username::String -> token }
    #   where token = { user_id, ttl :: String }
    pocketid_one_time_access_token = lib.genAttrs usernames (name: {
      user_id = lib.tf.ref "pocketid_user.${name}.id";
      ttl = "1h";
    });
  };

  output."pocket-id" = {
    value = {
      "pocket_id_headplane_client_secret" = lib.tf.ref "pocketid_client.headplane.client_secret";
      "pocket_id_headscale_client_secret" = lib.tf.ref "pocketid_client.headscale.client_secret";
      "pocket_id_oauth2_proxy_client_secret" = lib.tf.ref "pocketid_client.oauth2-proxy.client_secret";
    };
    sensitive = true;
  };

  output."pocket_id_login_urls" = {
    # genAttrs :: [ username::String ] -> (username::String -> url::String) -> { username::String -> url::String }
    value = lib.genAttrs usernames (
      name: "https://${fqdns.pocket-id}/lc/${lib.tf.ref "pocketid_one_time_access_token.${name}.token"}"
    );
    sensitive = true;
  };
}
