{config, ...}: let
  inherit (config.hostCfg) username;
in {
  homebrew.casks = ["wezterm"];

  home-manager.users.${username}.home.file.".config/wezterm/wezterm.lua".source = ../../../notnix/configs/wezterm.lua;
}
