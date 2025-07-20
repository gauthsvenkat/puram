{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  # Neovim is installed through NixOS so it is also available to root.
  # But additional dependencies are installed using home-manager since
  # they are only required for the user's nvim configuration. The actual
  # configuration lives in a separate repo.
  environment = {
    systemPackages = [pkgs.neovim];
    variables.EDITOR = "nvim";
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      nodejs
      python3
      wl-clipboard
    ];

    programs = {
      neovim.enable = true;
      zsh.shellAliases."v" = "${pkgs.neovim}/bin/nvim";
    };
  };
}
