{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  services.mullvad-vpn = {
    enable = true;
    # NOTE: pkgs.mullvad only contains the cli while
    # pkgs.mullvad-vpn comes with the gui as well.
    package = pkgs.mullvad-vpn;
  };

  home-manager.users.${username}.xdg.autostart.entries = [
    "${pkgs.mullvad-vpn}/share/applications/mullvad-vpn.desktop"
  ];
}
