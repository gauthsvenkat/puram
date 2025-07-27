{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  home-manager.users.${username} = {
    home.packages = [pkgs.just];
    programs.zsh.shellAliases."ju" = "${pkgs.just}/bin/just";
  };
}
