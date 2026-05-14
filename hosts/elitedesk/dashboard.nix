{
  config,
  hostCfg,
  ...
}:
let
  inherit (hostCfg) domain hostname zpool;
  inherit (hostCfg.ports)
    adguard
    caddy
    immich
    jellyfin
    paperless
    ;
  inherit (config.sops) placeholder;
in
{
  sops.secrets = {
    adguard_password = { };
    adguard_username = { };
    immich_api_key = { };
    jellyfin_api_key = { };
    paperless_api_key = { };
  };

  sops.templates.homepage_env.content = ''
    HOMEPAGE_VAR_ADGUARD_PASS=${placeholder.adguard_password}
    HOMEPAGE_VAR_ADGUARD_USER=${placeholder.adguard_username}
    HOMEPAGE_VAR_IMMICH_KEY=${placeholder.immich_api_key}
    HOMEPAGE_VAR_JELLYFIN_KEY=${placeholder.jellyfin_api_key}
    HOMEPAGE_VAR_PAPERLESS_KEY=${placeholder.paperless_api_key}
  '';

  services.homepage-dashboard = {
    environmentFiles = [ config.sops.templates.homepage_env.path ];

    settings = {
      title = hostname;
      headerStyle = "clean";
      theme = "dark";
      color = "slate";
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
            columns = 2;
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
        href = sub: "https://${sub}.${domain}";
        icon = name: "${name}.svg";
        envVar = name: "{{HOMEPAGE_VAR_${name}}}";
      in
      [
        {
          "Media" = [
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
