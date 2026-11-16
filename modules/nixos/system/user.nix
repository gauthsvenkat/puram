{ targetCfg, config, ... }:
let
  inherit (targetCfg) username;
  inherit (config.sops) secrets;
in
{
  sops.secrets."user/user_hashed_password" = {
    sopsFile = ../../../secrets/user.yaml;
    key = "user_hashed_password";
    neededForUsers = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = secrets."user/user_hashed_password".path;
  };
}
