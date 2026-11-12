{
  targetCfg,

  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) username;
in
{
  home-manager.users.${username} =
    { config, ... }:
    let
      cfg = config.programs.satty;
    in
    {
      # satty doesn't create the output directory itself
      systemd.user.tmpfiles.rules = [ "d %h/Pictures/Screenshots 0755 - - -" ];

      programs = {
        satty = {
          enable = true;
          settings.general = {
            copy-command = lib.getExe' pkgs.wl-clipboard "wl-copy";
            early-exit = [ "all" ];
            initial-tool = "brush";
            output-filename = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";
          };
        };

        niri.settings = {
          binds."Print".action.spawn-sh =
            let
              grim = lib.getExe pkgs.grim;
              pgrep = lib.getExe' pkgs.procps "pgrep";
              satty = lib.getExe cfg.package;
              slurp = lib.getExe pkgs.slurp;
            in
            "${pgrep} -x 'slurp|satty' >/dev/null && exit 0; sel=$(${slurp}) && ${grim} -g \"$sel\" - | ${satty} --filename -";

          window-rules = [
            {
              matches = [ { app-id = "^com\\.gabm\\.satty$"; } ];
              open-floating = true;
            }
          ];
        };
      };
    };
}
