{ config, hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  sops.secrets.hashedPassword.neededForUsers = true;

  users.users.${username} = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.hashedPassword.path;
    extraGroups = [ "wheel" ];
  };
}
