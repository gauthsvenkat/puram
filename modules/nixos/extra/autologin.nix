{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };
}
