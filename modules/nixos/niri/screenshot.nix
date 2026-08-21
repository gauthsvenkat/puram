{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
  grim = lib.getExe pkgs.grim;
  slurp = lib.getExe pkgs.slurp;
in
{
  home-manager.users.${username} =
    { config, ... }:
    let
      satty = lib.getExe config.programs.satty.package;
    in
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
        binds."Print".action.spawn-sh = "sel=$(${slurp}) && ${grim} -g \"$sel\" - | ${satty} --filename -";

        window-rules = [
          {
            matches = [ { app-id = "^com\\.gabm\\.satty$"; } ];
            open-floating = true;
          }
        ];
      };
    };
}
