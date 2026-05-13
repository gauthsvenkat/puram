{
  config,
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
    qbittorrent
    radarr
    sabnzbd
    seerr
    sonarr
    # END-PRIVATE
    ;
  # BEGIN-PRIVATE
  inherit (hostCfg.vpn) namespaceAddress;
  # END-PRIVATE
  inherit (config.sops) placeholder;
in
{
  sops.secrets = {
    adguard_password = { };
    adguard_username = { };
    # BEGIN-PRIVATE
    bazarr_api_key = { };
    # END-PRIVATE
    immich_api_key = { };
    jellyfin_api_key = { };
    paperless_api_key = { };
    # BEGIN-PRIVATE
    prowlarr_api_key = { };
    qbittorrent_password = { };
    qbittorrent_username = { };
    sabnzbd_api_key = { };
    seerr_api_key = { };
    # END-PRIVATE
  };

  sops.templates.homepage_env.content = ''
    HOMEPAGE_VAR_ADGUARD_PASS=${placeholder.adguard_password}
    HOMEPAGE_VAR_ADGUARD_USER=${placeholder.adguard_username}
    # BEGIN-PRIVATE
    HOMEPAGE_VAR_BAZARR_KEY=${placeholder.bazarr_api_key}
    # END-PRIVATE
    HOMEPAGE_VAR_IMMICH_KEY=${placeholder.immich_api_key}
    HOMEPAGE_VAR_JELLYFIN_KEY=${placeholder.jellyfin_api_key}
    HOMEPAGE_VAR_PAPERLESS_KEY=${placeholder.paperless_api_key}
    # BEGIN-PRIVATE
    HOMEPAGE_VAR_PROWLARR_KEY=${placeholder.prowlarr_api_key}
    HOMEPAGE_VAR_QBIT_PASS=${placeholder.qbittorrent_password}
    HOMEPAGE_VAR_QBIT_USER=${placeholder.qbittorrent_username}
    HOMEPAGE_VAR_RADARR_KEY=${placeholder.radarr_api_key}
    HOMEPAGE_VAR_SABNZBD_KEY=${placeholder.sabnzbd_api_key}
    HOMEPAGE_VAR_SEERR_KEY=${placeholder.seerr_api_key}
    HOMEPAGE_VAR_SONARR_KEY=${placeholder.sonarr_api_key}
    # END-PRIVATE
  '';

  services.homepage-dashboard = {
    environmentFiles = [ config.sops.templates.homepage_env.path ];

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
                widget = {
                  type = "qbittorrent";
                  url = vpnLoopback qbittorrent.port;
                  username = envVar "QBIT_USER";
                  password = envVar "QBIT_PASS";
                };
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
