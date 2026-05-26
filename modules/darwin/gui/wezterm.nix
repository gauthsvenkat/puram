{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  homebrew.casks = [ "wezterm" ];

  home-manager.users.${username}.home.file.".config/wezterm/wezterm.lua".source =
    ../../../assets/configs/wezterm.lua;
}
