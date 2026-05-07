{
  description = "NixOS, nix-darwin and home-manager flakes for my machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      ...
    }@inputs:
    {
      darwinConfigurations = {
        "macbook-m1-pro" = nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
            hostCfg = rec {
              hostname = "macbook-m1-pro";
              username = "gautham";
              isLaptop = true;
              homeDirectory = "/Users/${username}";
              gitEmail = "gautham@dexterenergy.ai";
              wallpaper = "${homeDirectory}/Pictures/wallpapers/astronaut.jpg";
            };
          };
          modules = [
            { nixpkgs.hostPlatform = "aarch64-darwin"; }
            ./hosts/macbook-m1-pro
          ];
        };
      };

      nixosConfigurations = {
        "toshiba" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            hostCfg = rec {
              hostname = "toshiba";
              username = "ando";
              isLaptop = false;
              homeDirectory = "/home/${username}";
              gitEmail = "gauthsvenkat@gmail.com";
              wallpaper = "${homeDirectory}/Pictures/wallpapers/astronaut.jpg";
            };
          };
          modules = [ ./hosts/toshiba ];
        };

        "thinkpad" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            hostCfg = rec {
              hostname = "thinkpad";
              username = "ando";
              isLaptop = true;
              homeDirectory = "/home/${username}";
              gitEmail = "gauthsvenkat@gmail.com";
              wallpaper = "${homeDirectory}/Pictures/wallpapers/astronaut.jpg";
            };
          };
          modules = [ ./hosts/thinkpad ];
        };

        "thunderdome" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            hostCfg = rec {
              hostname = "thunderdome";
              username = "ando";
              isLaptop = false;
              homeDirectory = "/home/${username}";
              gitEmail = "gauthsvenkat@gmail.com";
              wallpaper = "${homeDirectory}/Pictures/wallpapers/astronaut.jpg";

              zpool = "dontdie";
            };
          };
          modules = [ ./hosts/thunderdome ];
        };

        "nixpi400" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
            hostCfg = rec {
              hostname = "nixpi400";
              username = "ando";
              isLaptop = false;
              homeDirectory = "/home/${username}";
              gitEmail = "gauthsvenkat@gmail.com";
              wallpaper = "${homeDirectory}/Pictures/wallpapers/astronaut.jpg";
              zpool = "tank";
            };
          };
          modules = [ ./hosts/nixpi400 ];
        };

        "elitedesk" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            hostCfg = rec {
              hostname = "elitedesk";
              username = "ando";
              isLaptop = false;
              homeDirectory = "/home/${username}";
              gitEmail = "gauthsvenkat@gmail.com";

              zpool = "dontdie";
              domain = "gauthsvenkat.dev";
              paths = rec {
                config = "/${zpool}/services/config";
                databases = "/${zpool}/services/databases";
                postgres = "${databases}/postgres";
                data = "/${zpool}/data";
                cache = "/${zpool}/cache";
              };

              ports = {
                adguard = {
                  dns_port = 53;
                  web_port = 3000;
                };
                # BEGIN-PRIVATE
                bazarr.port = 6767;
                # END-PRIVATE
                homarr.port = 7575;
                immich.port = 2283;
                # Cosmetic — services.jellyfin hardcodes 8096/8920 TCP and 1900/7359 UDP via
                # openFirewall. Tracked here for documentation and future cross-references.
                jellyfin = {
                  port = 8096;
                  https_port = 8920;
                };
                paperless = {
                  port = 8000;
                  gotenberg_port = 3030;
                  tika_port = 9998;
                };
                # BEGIN-PRIVATE
                prowlarr.port = 9696;
                qbittorrent = {
                  port = 8082;
                  bt_port = 6881;
                };
                radarr.port = 7878;
                sabnzbd.port = 8083;
                sonarr.port = 8989;
                # END-PRIVATE
                stirlingPdf.port = 8081;
              };

              images = {
                # BEGIN-PRIVATE
                bazarr = "lscr.io/linuxserver/bazarr:1.5.6";
                flaresolverr = "ghcr.io/flaresolverr/flaresolverr:v3.4.6";
                gluetun = "qmcgaw/gluetun:v3.41.1";
                # END-PRIVATE
                homarr = "ghcr.io/homarr-labs/homarr:v1.59.3";
                # BEGIN-PRIVATE
                prowlarr = "lscr.io/linuxserver/prowlarr:2.3.5";
                qbittorrent = "lscr.io/linuxserver/qbittorrent:5.1.4";
                radarr = "lscr.io/linuxserver/radarr:6.1.1";
                sabnzbd = "lscr.io/linuxserver/sabnzbd:4.5.5";
                sonarr = "lscr.io/linuxserver/sonarr:4.0.17";
                # END-PRIVATE
              };

              commonEnvVars = {
                PUID = "1000";
                PGID = "1000";
                TZ = "Europe/Paris";
              };
            };
          };
          modules = [ ./hosts/elitedesk ];
        };
      };

    };
}
