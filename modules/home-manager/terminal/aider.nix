{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe;
  pkg = pkgs.aider-chat-with-playwright;
in
{
  home = {
    packages = [ pkg ];
    sessionVariables.AIDER_VIM = "true";
  };

  programs = {
    zsh.shellAliases."ai" = getExe pkg;
    git.ignores = [ ".aider*" ];
  };
}
