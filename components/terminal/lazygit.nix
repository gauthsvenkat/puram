{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  home-manager.users.${username}.programs = {
    lazygit = {
      enable = true;
      settings.keybinding.universal = {
        quit = "q";
        quit-alt1 = "<delete>";
      };
    };
    zsh.shellAliases."lg" = "${pkgs.lazygit}/bin/lazygit";
  };
}
