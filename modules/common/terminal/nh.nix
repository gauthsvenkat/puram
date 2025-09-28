{ config, ... }:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username}.programs.nh = {
    enable = true;
    clean.enable = true;
  };
}
