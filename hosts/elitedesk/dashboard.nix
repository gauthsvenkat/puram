{
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

  loopback = p: "http://127.0.0.1:${toString p}";
in
{
  services.homepage-dashboard = {
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
      {
        "Media" = [
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
