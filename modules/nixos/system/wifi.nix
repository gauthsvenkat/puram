{ config, ... }:
let
  inherit (config.sops) secrets;
in
{
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ secrets.wifi.path ];
    profiles.home-wifi = {
      connection = {
        id = "home";
        type = "wifi";
      };
      wifi.ssid = "$WIFI_SSID";
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$WIFI_PASSWORD";
      };
    };
  };

  sops.secrets.wifi.sopsFile = ../../../secrets/system.yaml;
}
