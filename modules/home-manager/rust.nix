{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cargo
    cargo-generate
    clippy
    rust-analyzer
    rustc
    rustfmt
  ];
}
