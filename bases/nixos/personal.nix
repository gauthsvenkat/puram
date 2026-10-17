{ targetCfg, lib, ... }:
let
  inherit (targetCfg) username;
in
{
  imports = [
    ../../modules/nixos/services/mullvad-vpn.nix
    ../../modules/nixos/services/syncthing.nix

    ./workstation.nix
  ];

  home-manager.users.${username} = {
    imports = [ ../../modules/home-manager/personal-apps.nix ];

    programs.firefox.policies = {
      Bookmarks = lib.mkBefore [
        {
          Title = "WhatsApp";
          URL = "https://web.whatsapp.com/";
          Placement = "toolbar";
        }
      ];

      ExtensionSettings =
        let
          amo = slug: {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
            installation_mode = "force_installed";
          };
        in
        {
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = amo "bitwarden-password-manager";
          "admin@2fas.com" = amo "2fas-two-factor-authentication";
        };
    };
  };
}
