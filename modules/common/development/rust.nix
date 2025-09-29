{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.home.packages = with pkgs; [
    cargo-generate
    cargo
    clippy
    rust-analyzer
    rustc
    rustfmt
  ];
}
