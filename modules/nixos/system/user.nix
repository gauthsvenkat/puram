{ targetCfg, config, ... }:
let
  inherit (targetCfg) username;
  inherit (config.sops) secrets;
in
{
  sops.secrets."hashedPassword" = {
    neededForUsers = true;
    sopsFile = ../../../secrets/system.yaml;
  };

  users.users.${username} = {
    isNormalUser = true;
    hashedPasswordFile = secrets."hashedPassword".path;
    extraGroups = [ "wheel" ];
  };
}
