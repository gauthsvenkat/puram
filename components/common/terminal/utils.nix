{
  config,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username}.home.packages = with pkgs; [
    curl
    fd
    gnumake
    imagemagick
    jq
    ripgrep
    unzip
    wget
    zip
  ];
}
