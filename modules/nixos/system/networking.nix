{ targetCfg, ... }:
let
  inherit (targetCfg) hostname username;
in
{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  users.users.${username}.extraGroups = [ "networkmanager" ];
}
