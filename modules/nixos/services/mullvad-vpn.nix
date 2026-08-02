{
  hostCfg,
  config,
  ...
}:
let
  inherit (hostCfg) username;
  cfg = config.services.mullvad-vpn;
in
{
  services.mullvad-vpn = {
    enable = true;
    gui.enable = true;
  };

  home-manager.users.${username}.xdg.autostart.entries = [
    "${cfg.gui.package}/share/applications/mullvad-vpn.desktop"
  ];
}
