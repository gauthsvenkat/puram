{ config, ... }:
let
  inherit (config) sops;
in
{
  sops = {
    secrets =
      let
        sopsFile = ../../../secrets/wifi.yaml;
      in
      {
        "wifi/home_wifi_psk" = {
          inherit sopsFile;
          key = "home_wifi_psk";
        };
        "wifi/home_wifi_ssid" = {
          inherit sopsFile;
          key = "home_wifi_ssid";
        };
      };
    templates."wifi_env" = {
      content = ''
        WIFI_SSID=${sops.placeholder."wifi/home_wifi_ssid"}
        WIFI_PASSWORD=${sops.placeholder."wifi/home_wifi_psk"}
      '';
      restartUnits = [ "NetworkManager-ensure-profiles.service" ];
    };
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ sops.templates."wifi_env".path ];
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
