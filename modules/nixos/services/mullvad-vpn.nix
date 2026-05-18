{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
  pkg = pkgs.mullvad-vpn;
in
{
  services.mullvad-vpn = {
    enable = true;
    # pkgs.mullvad only contains the cli; pkgs.mullvad-vpn ships the gui too.
    package = pkg;
  };

  home-manager.users.${username}.xdg.autostart.entries = [
    "${pkg}/share/applications/mullvad-vpn.desktop"
  ];
}
