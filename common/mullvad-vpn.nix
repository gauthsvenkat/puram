{ pkgs, ... }:
{
  services.mullvad-vpn = {
    enable = true;
    # pkgs.mullvad only contains the cli
    # while pkgs.mullvad-vpn comes with the gui as well
    package = pkgs.mullvad-vpn;
  };
}
