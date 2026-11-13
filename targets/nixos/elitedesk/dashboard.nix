{
  flakeCfg,
  targetCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) domain;
  inherit (targetCfg) hostname ports zpool;
  inherit (config.sops) placeholder templates;
in
{
  sops = {
    secrets = {
      "immich_api_key" = { };
      "jellyfin_api_key" = { };
      "paperless_api_key" = { };
      "vikunja_api_key" = { };
    };

    templates."homepage_env" = {
      content = ''
        HOMEPAGE_VAR_IMMICH_KEY=${placeholder."immich_api_key"}
        HOMEPAGE_VAR_JELLYFIN_KEY=${placeholder."jellyfin_api_key"}
        HOMEPAGE_VAR_PAPERLESS_KEY=${placeholder."paperless_api_key"}
        HOMEPAGE_VAR_VIKUNJA_KEY=${placeholder."vikunja_api_key"}
      '';
      restartUnits = [ "homepage-dashboard.service" ];
    };
  };

  services.homepage-dashboard = {
    environmentFiles = [ templates."homepage_env".path ];

    services =
      let
        envVar = name: "{{HOMEPAGE_VAR_${name}}}";
        href = sub: "https://${sub}.${domain}";
        icon = name: "${name}.svg";
        loopback = p: "http://127.0.0.1:${toString p}";
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
