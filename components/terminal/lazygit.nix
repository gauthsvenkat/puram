{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  home-manager.users.${username}.programs = {
    lazygit.enable = true;
    zsh.shellAliases."lg" = "${pkgs.lazygit}/bin/lazygit";
  };
}
