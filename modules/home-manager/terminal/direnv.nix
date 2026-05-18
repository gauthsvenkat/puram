{
  lib,
  pkgs,
  ...
}:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zsh.shellAliases."da." = "${lib.getExe pkgs.direnv} allow .";

    git.ignores = [ ".direnv" ];
  };
}
