{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  home-manager.users.${username}.home = {
    sessionPath = ["$HOME/.local/bin"];

    packages = with pkgs; [
      rustup
      cargo-generate
      uv
      pre-commit
      libqalculate
    ];
  };
}
