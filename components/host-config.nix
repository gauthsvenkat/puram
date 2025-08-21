{
  config,
  lib,
  ...
}:
let
  inherit (config) hostCfg;
  inherit (lib)
    mkOption
    types
    ;
in
{
  options.hostCfg = {
    hostname = mkOption {
      type = types.str;
      description = "System's hostname";
    };

    username = mkOption {
      type = types.str;
      default = "ando";
      description = "Primary user of the system";
    };

    homeDirectory = mkOption {
      type = types.str;
      default = "/home/${hostCfg.username}";
      description = "Home directory of the primary user";
    };

    gitEmail = mkOption {
      type = types.str;
      default = "gauthsvenkat@gmail.com";
      description = "Git user email";
    };

    isLaptop = mkOption {
      type = types.bool;
      default = false;
      description = "Whether the host is a laptop";
    };

    wallpaper = mkOption {
      type = types.str;
      default = "${hostCfg.homeDirectory}/Pictures/wallpapers/astronaut.jpg";
      description = "Full path to the wallpaper file";
    };
  };
}
