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
    {
      programs.satty = {
        enable = true;
        settings.general = {
          copy-command = lib.getExe' pkgs.wl-clipboard "wl-copy";
          early-exit = [ "all" ];
          initial-tool = "brush";
          output-filename = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";
        };
      };

      # satty doesn't create the output directory itself
      systemd.user.tmpfiles.rules = [ "d %h/Pictures/Screenshots 0755 - - -" ];

      programs.niri.settings = {
        binds."Print".action.spawn-sh =
          let
            grim = lib.getExe pkgs.grim;
            slurp = lib.getExe pkgs.slurp;
            satty = lib.getExe config.programs.satty.package;
            pgrep = lib.getExe' pkgs.procps "pgrep";
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
}
