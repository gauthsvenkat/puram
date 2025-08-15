{ config, ... }:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username}.programs.mcfly = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    keyScheme = "vim";
  };
}
