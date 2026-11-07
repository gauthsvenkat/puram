{
  targetCfg,

  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) username;
in
{
  imports = [
    ../../modules/nixos/hardware/bluetooth.nix
    ../../modules/nixos/hardware/vial.nix

    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/localsend.nix
    ../../modules/nixos/services/pipewire.nix

    ../../modules/nixos/ssh/aliases.nix
    ../../modules/nixos/ssh/client.nix
    ../../modules/nixos/ssh/github.nix
    ../../modules/nixos/ssh/known-hosts.nix

    ../../modules/nixos/sops.nix

    ./system.nix
  ];

  home-manager.users.${username} = {
    imports = [
      ../../modules/home-manager/atuin.nix
      ../../modules/home-manager/bat.nix
      ../../modules/home-manager/btop.nix
      ../../modules/home-manager/claude-code.nix
      ../../modules/home-manager/direnv.nix
      ../../modules/home-manager/eza.nix
      ../../modules/home-manager/fastfetch.nix
      ../../modules/home-manager/firefox.nix
      ../../modules/home-manager/fonts.nix
      ../../modules/home-manager/git.nix
      ../../modules/home-manager/just.nix
      ../../modules/home-manager/lazygit.nix
      ../../modules/home-manager/lua.nix
      ../../modules/home-manager/neovim.nix
      ../../modules/home-manager/nh.nix
      ../../modules/home-manager/nix.nix
      ../../modules/home-manager/pre-commit.nix
      ../../modules/home-manager/python.nix
      ../../modules/home-manager/rust.nix
      ../../modules/home-manager/starship.nix
      ../../modules/home-manager/utils.nix
      ../../modules/home-manager/wallpaper.nix
      ../../modules/home-manager/wezterm.nix
      ../../modules/home-manager/workstation-apps.nix
      ../../modules/home-manager/yazi.nix
      ../../modules/home-manager/zoxide.nix
      ../../modules/home-manager/zsh.nix
    ];

    programs = {
      starship.presets = [
        "bracketed-segments"
        "nerd-font-symbols"
      ];

      zsh.shellAliases =
        let
          xdg-open = lib.getExe' pkgs.xdg-utils "xdg-open";
        in
        {
          "o" = xdg-open;
          "open" = xdg-open;
        };
    };

    xdg.autostart.enable = true;
  };
}
