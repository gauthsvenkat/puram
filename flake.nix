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
              gitEmail = "user@work.example";
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
              domain = "example.com";
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
                # Cosmetic — Caddy hardcodes its admin API on 127.0.0.1:2019.
                # Tracked here for documentation.
                caddy.admin_port = 2019;
                homepage.port = 7575;
                immich.port = 2283;
                # Cosmetic — services.jellyfin hardcodes 8096/8920 TCP and 1900/7359 UDP via
                # openFirewall. Tracked here for documentation.
                jellyfin = {
                  port = 8096;
                  https_port = 8920;
                };
                paperless = {
                  port = 8000;
                  gotenberg_port = 3030;
                  tika_port = 9998;
                };
                stirlingPdf.port = 8081;
              };
            };
          };
          modules = [ ./hosts/elitedesk ];
        };
      };

    };
}
