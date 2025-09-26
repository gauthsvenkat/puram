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
    python3
    ruff
    ty
    uv
  ];
}
