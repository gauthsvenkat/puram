{ hostCfg, ... }:
let
  inherit (hostCfg) hostname username;
in
{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  users.users.${username}.extraGroups = [ "networkmanager" ];
}
