{ config, ... }:
let
  inherit (config.sops) placeholder;
in
{
  sops = {
    secrets = {
      "wifi_psk".sopsFile = ../../../secrets/wifi.yaml;
      "wifi_ssid".sopsFile = ../../../secrets/wifi.yaml;
    };
    templates."wifi".content = ''
      WIFI_SSID=${placeholder."wifi_ssid"}
      WIFI_PASSWORD=${placeholder."wifi_psk"}
    '';
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.templates."wifi".path ];
    profiles."home-wifi" = {
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
}
