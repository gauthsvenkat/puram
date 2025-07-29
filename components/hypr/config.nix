{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.hyprCfg = {
    launcher = mkOption {
      type = types.str;
      default = "${pkgs.tofi}/bin/tofi-drun --drun-launch=true";
      description = "application launcher";
    };
  };
}
