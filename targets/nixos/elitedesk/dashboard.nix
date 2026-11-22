{
  flakeCfg,
  targetCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) domains;
  inherit (targetCfg) hostname ports zpool;
  # BEGIN-PRIVATE
  inherit (targetCfg) vpn;
  # END-PRIVATE
  inherit (config.sops) placeholder templates;
in
{
  sops = {
    secrets = {
      "immich_api_key" = { };
      "jellyfin_api_key" = { };
      "paperless_api_key" = { };
      "vikunja_api_key" = { };
      # BEGIN-PRIVATE
      "bazarr_api_key" = { };
      "prowlarr_api_key" = { };
      "qbittorrent_password" = { };
      "qbittorrent_username" = { };
      "sabnzbd_api_key" = { };
      "seerr_api_key" = { };
      # END-PRIVATE
    };

    templates."homepage_env" = {
      content = ''
        HOMEPAGE_VAR_IMMICH_KEY=${placeholder."immich_api_key"}
        HOMEPAGE_VAR_JELLYFIN_KEY=${placeholder."jellyfin_api_key"}
        HOMEPAGE_VAR_PAPERLESS_KEY=${placeholder."paperless_api_key"}
        HOMEPAGE_VAR_VIKUNJA_KEY=${placeholder."vikunja_api_key"}
        # BEGIN-PRIVATE
        HOMEPAGE_VAR_BAZARR_KEY=${placeholder."bazarr_api_key"}
        HOMEPAGE_VAR_PROWLARR_KEY=${placeholder."prowlarr_api_key"}
        HOMEPAGE_VAR_QBIT_PASS=${placeholder."qbittorrent_password"}
        HOMEPAGE_VAR_QBIT_USER=${placeholder."qbittorrent_username"}
        HOMEPAGE_VAR_RADARR_KEY=${placeholder."radarr_api_key"}
        HOMEPAGE_VAR_SABNZBD_KEY=${placeholder."sabnzbd_api_key"}
        HOMEPAGE_VAR_SEERR_KEY=${placeholder."seerr_api_key"}
        HOMEPAGE_VAR_SONARR_KEY=${placeholder."sonarr_api_key"}
        # END-PRIVATE
      '';
      restartUnits = [ "homepage-dashboard.service" ];
    };
  };

  services.homepage-dashboard = {
    environmentFiles = [ templates."homepage_env".path ];

    services =
      let
        envVar = name: "{{HOMEPAGE_VAR_${name}}}";
        href = sub: "https://${sub}.${domains.apex}";
        icon = name: "${name}.svg";
        loopback = p: "http://127.0.0.1:${toString p}";
        # BEGIN-PRIVATE
        vpnLoopback = p: "http://${vpn.namespaceAddress}:${toString p}";
        # END-PRIVATE
      in
      [
        {
          "Media" = [
            {
              "Jellyfin" = {
                href = href "jellyfin";
                icon = icon "jellyfin";
                widget = {
                  type = "jellyfin";
                  enableBlocks = true;
                  enableMediaControl = false;
                  key = envVar "JELLYFIN_KEY";
                  url = loopback ports.jellyfin;
                  version = 2;
                };
              };
            }
            # BEGIN-PRIVATE
            {
              "Seerr" = {
                href = href "seerr";
                icon = icon "seerr";
                widget = {
                  type = "seerr";
                  key = envVar "SEERR_KEY";
                  url = loopback ports.seerr;
                };
              };
            }
            # END-PRIVATE
            {
              "Immich" = {
                href = href "immich";
                icon = icon "immich";
                widget = {
                  type = "immich";
                  key = envVar "IMMICH_KEY";
                  url = loopback ports.immich;
                  version = 2;
                };
              };
            }
            {
              "Paperless" = {
                href = href "paperless";
                icon = icon "paperless";
                widget = {
                  type = "paperlessngx";
                  key = envVar "PAPERLESS_KEY";
                  url = loopback ports.paperless;
                };
              };
            }
          ];
        }
        {
          "Utilities" = [
            {
              "AdGuard Home" = {
                href = href "adguard";
                icon = icon "adguard-home";
              };
            }
            {
              "Speedtest" = {
                href = href "speedtest";
                # `sh-` prefix pulls the icon from selfh.st;
                # dashboard-icons has no speedtest-tracker.
                icon = icon "sh-speedtest-tracker";
                widget = {
                  type = "speedtest";
                  url = href "speedtest";
                };
              };
            }
            {
              "Vikunja" = {
                href = href "vikunja";
                icon = icon "vikunja";
                widget = {
                  type = "vikunja";
                  key = envVar "VIKUNJA_KEY";
                  url = loopback ports.vikunja;
                  version = 2;
                };
              };
            }
          ];
        }
        # BEGIN-PRIVATE
        {
          "Arrs" = [
            {
              "SABnzbd" = {
                href = href "sabnzbd";
                icon = icon "sabnzbd";
                widget = {
                  type = "sabnzbd";
                  key = envVar "SABNZBD_KEY";
                  url = vpnLoopback ports.sabnzbd;
                };
              };
            }
            {
              "Radarr" = {
                href = href "radarr";
                icon = icon "radarr";
                widget = {
                  type = "radarr";
                  key = envVar "RADARR_KEY";
                  url = loopback ports.radarr;
                };
              };
            }
            {
              "Prowlarr" = {
                href = href "prowlarr";
                icon = icon "prowlarr";
                widget = {
                  type = "prowlarr";
                  key = envVar "PROWLARR_KEY";
                  url = vpnLoopback ports.prowlarr;
                };
              };
            }
            {
              "qBittorrent" = {
                href = href "qbittorrent";
                icon = icon "qbittorrent";
                widget = {
                  type = "qbittorrent";
                  password = envVar "QBIT_PASS";
                  url = vpnLoopback ports.qbittorrent;
                  username = envVar "QBIT_USER";
                };
              };
            }
            {
              "Sonarr" = {
                href = href "sonarr";
                icon = icon "sonarr";
                widget = {
                  type = "sonarr";
                  key = envVar "SONARR_KEY";
                  url = loopback ports.sonarr;
                };
              };
            }
            {
              "Bazarr" = {
                href = href "bazarr";
                icon = icon "bazarr";
                widget = {
                  type = "bazarr";
                  key = envVar "BAZARR_KEY";
                  url = loopback ports.bazarr;
                };
              };
            }
            {
              "Bitmagnet" = {
                href = href "bitmagnet";
                icon = icon "bitmagnet";
              };
            }
          ];
        }
        # END-PRIVATE
        {
          "Infra" = [
            {
              "Caddy" = {
                icon = icon "caddy";
                widget = {
                  type = "caddy";
                  url = loopback ports.caddy-admin;
                };
              };
            }
          ];
        }
      ];

    settings = {
      title = hostname;
      color = "slate";
      headerStyle = "clean";
      theme = "dark";
      layout = [
        {
          "Media" = {
            style = "row";
            columns = 4;
            useEqualHeights = true;
          };
        }
        {
          "Utilities" = {
            style = "row";
            columns = 3;
            useEqualHeights = true;
          };
        }
        # BEGIN-PRIVATE
        {
          "Arrs" = {
            style = "row";
            columns = 3;
            useEqualHeights = true;
          };
        }
        # END-PRIVATE
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
          text = hostname;
          text_size = "xl";
        };
      }
      {
        resources = {
          cpu = true;
          disk = [
            "/"
            "/${zpool}"
          ];
          memory = true;
        };
      }
      {
        datetime = {
          format = {
            dateStyle = "long";
            timeStyle = "short";
          };
          text_size = "xl";
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
          cache = 5;
          # Delft, The Netherlands
          latitude = "52.0116";
          longitude = "4.3571";
          units = "metric";
        };
      }
    ];
  };
}
