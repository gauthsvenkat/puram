{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;
  inherit (lib) getExe;
in
{
  home-manager.users.${username}.programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    zsh.shellAliases."da." = "${getExe pkgs.direnv} allow .";
  };
}
