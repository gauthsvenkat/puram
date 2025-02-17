{ pkgs, ... }:
with pkgs;
[
  meslo-lgs-nf
  # needed for neovim (and friends) among other things
  gcc
  cmake
  gnumake
  python3
  nodejs
  rustup
  #
  cargo-generate
  nixfmt-rfc-style
  pre-commit
  just
  ttyper
  # wezterm mentioned as a package and not enabled in programs
  # because it'll try to create a config in ~/.config/wezterm
  wezterm
  spotify
  jellyfin-media-player
  neovide
  mpv
  rustdesk
  kdePackages.krdc
  localsend
]
