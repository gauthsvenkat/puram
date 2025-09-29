{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.programs.plasma.kwin.nightLight = {
    enable = true;
    mode = "location";
    location = {
      latitude = "52.0116";
      longitude = "4.3571";
    };
  };
}
