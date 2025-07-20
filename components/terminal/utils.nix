{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  home-manager.users.${username}.home.packages = with pkgs; [
    curl
    fd
    gnumake
    jq
    just
    ripgrep
    unzip
    wget
    zip
  ];
}
