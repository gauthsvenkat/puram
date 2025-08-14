{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  home-manager.users.${username}.programs = {
    bat.enable = true;
    zsh.shellAliases."b" = "${pkgs.bat}/bin/bat";
  };
}
