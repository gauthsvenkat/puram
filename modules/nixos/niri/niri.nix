{
  inputs,
  targetCfg,
  pkgs,
  ...
}:
let
  inherit (targetCfg) username;
in
{
  imports = [ inputs.niri.nixosModules.niri ];

  niri-flake.cache.enable = false;

  # HACK: niri-flake enables gnome-keyring, whose `gcr-ssh-agent` conflicts with `programs.ssh.startAgent`
  services.gnome.gcr-ssh-agent.enable = false;

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  environment.systemPackages = [ pkgs.xwayland-satellite ];

  xdg.portal = {
    config.niri = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Access" = [ "gtk" ];
      "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  home-manager.users.${username} = {
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    programs.niri.settings = {
      animations.slowdown = 0.7;

      environment = {
        NIXOS_OZONE_WL = "1";
        # Load the KDE platform theme so qt apps pick up
        # the `kdeglobals` color scheme outside plasma
        QT_QPA_PLATFORMTHEME = "kde";
      };

      gestures.hot-corners.enable = false;

      hotkey-overlay.skip-at-startup = true;

      input = {
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "25%";
        };
        mod-key = "Alt";
        warp-mouse-to-focus.enable = true;
      };

      layout = {
        default-column-width.proportion = 0.5;
        gaps = 8;
        focus-ring = {
          width = 2;
          active.gradient = {
            from = "#ff0000";
            to = "#ff0000";
            angle = 45;
            in' = "oklch longer hue";
          };
          inactive.color = "#505050";
        };
        preset-column-widths = [
          { proportion = 1.0 / 3.0; }
          { proportion = 0.5; }
          { proportion = 2.0 / 3.0; }
          { proportion = 1.0; }
        ];
        preset-window-heights = [
          { proportion = 0.5; }
          { proportion = 2.0 / 3.0; }
          { proportion = 1.0; }
        ];
      };
    };
  };
}
