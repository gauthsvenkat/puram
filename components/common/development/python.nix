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
    basedpyright
    mypy
    python3
    ruff
    uv
  ];
}
