{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  imports = [
    ../../../modules/nixos/services/mullvad-vpn.nix
    ../../../modules/nixos/services/syncthing.nix

    ../workstation.nix
  ];

  home-manager.users.${username}.imports = [
    ../../../modules/home-manager/extra/personal.nix
  ];
}
