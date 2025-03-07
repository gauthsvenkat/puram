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
        # meslo-lgs-nf
        # needed for neovim (and friends) among other things
        gcc
        cmake
        gnumake
        python3
        nodejs
        rustup
        wl-clipboard-rs
        # other useful tools
        cargo-generate
        # wezterm mentioned as a package and not enabled in programs
        # because it'll try to create a config in ~/.config/wezterm
        wezterm
        spotify
        neovide
      ];
    };
  };
}
