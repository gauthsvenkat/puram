{ config, hostCfg, ... }:
let
  inherit (hostCfg) username;
  inherit (config.sops) secrets;
in
{
  sops.secrets.hashedPassword = {
    neededForUsers = true;
    sopsFile = ../../../secrets/system-hashed-password.yaml;
  };

  users.users.${username} = {
    isNormalUser = true;
    hashedPasswordFile = secrets.hashedPassword.path;
    extraGroups = [ "wheel" ];
  };
}
