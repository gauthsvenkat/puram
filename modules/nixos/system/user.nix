{ targetCfg, config, ... }:
let
  inherit (targetCfg) username;
  inherit (config.sops) secrets;
in
{
  sops.secrets."user_hashed_password" = {
    neededForUsers = true;
    sopsFile = ../../../secrets/user.yaml;
  };

  users.users.${username} = {
    isNormalUser = true;
    hashedPasswordFile = secrets."user_hashed_password".path;
    extraGroups = [ "wheel" ];
  };
}
