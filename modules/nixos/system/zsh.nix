{
  targetCfg,
  pkgs,
  ...
}:
let
  inherit (targetCfg) username;
in
{
  programs.zsh.enable = true;
  users.users.${username}.shell = pkgs.zsh;
}
