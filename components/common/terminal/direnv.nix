{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username}.programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    zsh.shellAliases."da." = "${lib.getExe pkgs.direnv} allow .";
  };
}
