{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cargo-generate
    cargo
    clippy
    rust-analyzer
    rustc
    rustfmt
  ];
}
