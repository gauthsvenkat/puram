{
  pkgs,
  username,
  ...
}:
{
  imports = [ ./default.nix ];

  home-manager = {
    users.${username} = {
      programs = {
        ripgrep.enable = true;
      };
      home.packages = with pkgs; [
        # needed for non-wezterm terminals
        meslo-lgs-nf
        # needed for neovim (and friends) among other things
        gcc
        cmake
        gnumake
        python3
        nodejs
        rustup
        wl-clipboard-rs
        # other useful tools
        vscode
        uv
        kdePackages.yakuake
        cargo-generate
        spotify
        neovide
      ];
    };
  };
}
