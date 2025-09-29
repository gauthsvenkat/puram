{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ../../../notnix/configs/wezterm.lua;
  };
}
