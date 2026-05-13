{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) domain hostname zpool;
  inherit (hostCfg.ports)
    adguard
    # BEGIN-PRIVATE
    bazarr
    # END-PRIVATE
    caddy
    immich
    jellyfin
    paperless
    # BEGIN-PRIVATE
    prowlarr
    radarr
    sabnzbd
    seerr
    sonarr
    # END-PRIVATE
    ;
  # BEGIN-PRIVATE
  inherit (hostCfg.vpn) namespaceAddress;
  # END-PRIVATE

  loopback = p: "http://127.0.0.1:${toString p}";
  # BEGIN-PRIVATE
  vpnLoopback = p: "http://${namespaceAddress}:${toString p}";
  # END-PRIVATE
in
{
  services.homepage-dashboard = {
    settings = {
      title = hostname;
      headerStyle = "clean";
      theme = "dark";
      color = "slate";
      layout = [
        # BEGIN-PRIVATE
        {
          "Downloads" = {
            style = "row";
            columns = 2;
            useEqualHeights = true;
          };
        }
        # END-PRIVATE
        {
          "Media" = {
            style = "row";
            columns = 4;
            useEqualHeights = true;
          };
        }
        # BEGIN-PRIVATE
        {
          "Arrs" = {
            style = "row";
            columns = 4;
            useEqualHeights = true;
          };
        }
        # END-PRIVATE
        {
          "Utilities" = {
            style = "row";
            columns = 3;
            useEqualHeights = true;
          };
        }
        {
          "Infra" = {
            style = "row";
            columns = 2;
            useEqualHeights = true;
          };
        }
      ];
    };

    widgets = [
      {
        greeting = {
          text_size = "xl";
          text = hostname;
        };
      }
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/${zpool}";
        };
      }
      {
        datetime = {
          text_size = "xl";
          format = {
            timeStyle = "short";
            dateStyle = "long";
          };
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
      {
        openmeteo = {
          # Delft, The Netherlands
          latitude = "52.0116";
          longitude = "4.3571";
          units = "metric";
          cache = 5;
        };
      }
    ];

    services = [
      # BEGIN-PRIVATE
      {
        "Downloads" = [
          {
            "qBittorrent" = {
              icon = "qbittorrent.svg";
              href = "https://qbittorrent.${domain}";
              # TODO: re-enable once qBit 5.x CSRF / Host-header validation is sorted.
              # widget = {
              #   type = "qbittorrent";
              #   url = loopback qbittorrent.port;
              #   username = "{{HOMEPAGE_VAR_QBIT_USER}}";
              #   password = "{{HOMEPAGE_VAR_QBIT_PASS}}";
              # };
            };
          }
          {
            "SABnzbd" = {
              icon = "sabnzbd.svg";
              href = "https://sabnzbd.${domain}";
              widget = {
                type = "sabnzbd";
                url = vpnLoopback sabnzbd.port;
                key = "{{HOMEPAGE_VAR_SABNZBD_KEY}}";
              };
            };
          }
        ];
      }
      # END-PRIVATE
      {
        "Media" = [
          # BEGIN-PRIVATE
          {
            "Seerr" = {
              icon = "seerr.svg";
              href = "https://seerr.${domain}";
              widget = {
                type = "seerr";
                url = loopback seerr.port;
                key = "{{HOMEPAGE_VAR_SEERR_KEY}}";
              };
            };
          }
          # END-PRIVATE
          {
            "Jellyfin" = {
              icon = "jellyfin.svg";
              href = "https://jellyfin.${domain}";
              widget = {
                type = "jellyfin";
                url = loopback jellyfin.port;
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                enableBlocks = true;
                enableMediaControl = false;
                version = 2;
              };
            };
          }
          {
            "Immich" = {
              icon = "immich.svg";
              href = "https://immich.${domain}";
              widget = {
                type = "immich";
                url = loopback immich.port;
                key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                version = 2;
              };
            };
          }
          {
            "Paperless" = {
              icon = "paperless.svg";
              href = "https://paperless.${domain}";
              widget = {
                type = "paperlessngx";
                url = loopback paperless.port;
                key = "{{HOMEPAGE_VAR_PAPERLESS_KEY}}";
              };
            };
          }
        ];
      }
      # BEGIN-PRIVATE
      {
        "Arrs" = [
          {
            "Sonarr" = {
              icon = "sonarr.svg";
              href = "https://sonarr.${domain}";
              widget = {
                type = "sonarr";
                url = loopback sonarr.port;
                key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
              };
            };
          }
          {
            "Radarr" = {
              icon = "radarr.svg";
              href = "https://radarr.${domain}";
              widget = {
                type = "radarr";
                url = loopback radarr.port;
                key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
              };
            };
          }
          {
            "Prowlarr" = {
              icon = "prowlarr.svg";
              href = "https://prowlarr.${domain}";
              widget = {
                type = "prowlarr";
                url = vpnLoopback prowlarr.port;
                key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
              };
            };
          }
          {
            "Bazarr" = {
              icon = "bazarr.svg";
              href = "https://bazarr.${domain}";
              widget = {
                type = "bazarr";
                url = loopback bazarr.port;
                key = "{{HOMEPAGE_VAR_BAZARR_KEY}}";
              };
            };
          }
        ];
      }
      # END-PRIVATE
      {
        "Utilities" = [
          {
            "AdGuard Home" = {
              icon = "adguard-home.svg";
              href = "https://adguard.${domain}";
              widget = {
                type = "adguard";
                url = loopback adguard.web_port;
                username = "{{HOMEPAGE_VAR_ADGUARD_USER}}";
                password = "{{HOMEPAGE_VAR_ADGUARD_PASS}}";
              };
            };
          }
          {
            "Stirling PDF" = {
              icon = "stirling-pdf.svg";
              href = "https://stirling.${domain}";
            };
          }
          {
            "Speedtest" = {
              icon = "sh-speedtest-tracker.svg";
              href = "https://speedtest.${domain}";
              widget = {
                type = "speedtest";
                url = "https://speedtest.${domain}";
              };
            };
          }
        ];
      }
      {
        "Infra" = [
          {
            "Caddy" = {
              icon = "caddy.svg";
              widget = {
                type = "caddy";
                url = loopback caddy.admin_port;
              };
            };
          }
          {
            "Tailscale" = {
              icon = "tailscale.svg";
              href = "https://login.tailscale.com/admin/machines";
            };
          }
        ];
      }
    ];
  };
}
