{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  programs.zsh.enable = true;
  users.users.${username}.shell = pkgs.zsh;
}
