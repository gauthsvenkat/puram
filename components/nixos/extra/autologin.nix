{ config, ... }:
let
  inherit (config.hostCfg) username;
in
{
  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };
}
