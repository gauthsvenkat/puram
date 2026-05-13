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

    services =
      let
        loopback = p: "http://127.0.0.1:${toString p}";
        # BEGIN-PRIVATE
        vpnLoopback = p: "http://${namespaceAddress}:${toString p}";
        # END-PRIVATE
        href = sub: "https://${sub}.${domain}";
        icon = name: "${name}.svg";
        envVar = name: "{{HOMEPAGE_VAR_${name}}}";
      in
      [
        # BEGIN-PRIVATE
        {
          "Downloads" = [
            {
              "qBittorrent" = {
                icon = icon "qbittorrent";
                href = href "qbittorrent";
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
                icon = icon "sabnzbd";
                href = href "sabnzbd";
                widget = {
                  type = "sabnzbd";
                  url = vpnLoopback sabnzbd.port;
                  key = envVar "SABNZBD_KEY";
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
                icon = icon "seerr";
                href = href "seerr";
                widget = {
                  type = "seerr";
                  url = loopback seerr.port;
                  key = envVar "SEERR_KEY";
                };
              };
            }
            # END-PRIVATE
            {
              "Jellyfin" = {
                icon = icon "jellyfin";
                href = href "jellyfin";
                widget = {
                  type = "jellyfin";
                  url = loopback jellyfin.port;
                  key = envVar "JELLYFIN_KEY";
                  enableBlocks = true;
                  enableMediaControl = false;
                  version = 2;
                };
              };
            }
            {
              "Immich" = {
                icon = icon "immich";
                href = href "immich";
                widget = {
                  type = "immich";
                  url = loopback immich.port;
                  key = envVar "IMMICH_KEY";
                  version = 2;
                };
              };
            }
            {
              "Paperless" = {
                icon = icon "paperless";
                href = href "paperless";
                widget = {
                  type = "paperlessngx";
                  url = loopback paperless.port;
                  key = envVar "PAPERLESS_KEY";
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
                icon = icon "sonarr";
                href = href "sonarr";
                widget = {
                  type = "sonarr";
                  url = loopback sonarr.port;
                  key = envVar "SONARR_KEY";
                };
              };
            }
            {
              "Radarr" = {
                icon = icon "radarr";
                href = href "radarr";
                widget = {
                  type = "radarr";
                  url = loopback radarr.port;
                  key = envVar "RADARR_KEY";
                };
              };
            }
            {
              "Prowlarr" = {
                icon = icon "prowlarr";
                href = href "prowlarr";
                widget = {
                  type = "prowlarr";
                  url = vpnLoopback prowlarr.port;
                  key = envVar "PROWLARR_KEY";
                };
              };
            }
            {
              "Bazarr" = {
                icon = icon "bazarr";
                href = href "bazarr";
                widget = {
                  type = "bazarr";
                  url = loopback bazarr.port;
                  key = envVar "BAZARR_KEY";
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
                icon = icon "adguard-home";
                href = href "adguard";
                widget = {
                  type = "adguard";
                  url = loopback adguard.web_port;
                  username = envVar "ADGUARD_USER";
                  password = envVar "ADGUARD_PASS";
                };
              };
            }
            {
              "Stirling PDF" = {
                icon = icon "stirling-pdf";
                href = href "stirling";
              };
            }
            {
              "Speedtest" = {
                icon = icon "sh-speedtest-tracker";
                href = href "speedtest";
                widget = {
                  type = "speedtest";
                  url = href "speedtest";
                };
              };
            }
          ];
        }
        {
          "Infra" = [
            {
              "Caddy" = {
                icon = icon "caddy";
                widget = {
                  type = "caddy";
                  url = loopback caddy.admin_port;
                };
              };
            }
            {
              "Tailscale" = {
                icon = icon "tailscale";
                href = "https://login.tailscale.com/admin/machines";
              };
            }
          ];
        }
      ];
  };
}
