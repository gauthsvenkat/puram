{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  programs.hyprland.enable = true;

  home-manager.users.${username} = {
    services.hyprpolkitagent.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;

      # NOTE: Following is set in the NixOS module.
      package = null;
      portalPackage = null;
    };
  };
}
