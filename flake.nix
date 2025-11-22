{
  description = "NixOS, nix-darwin and home-manager flakes for my machines";

  inputs = {
    # ==================== NixOS flake inputs ====================
    nixpkgs-nixos.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager-nixos = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };

    sops-nix-nixos = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
      inputs.home-manager.follows = "home-manager-nixos";
    };

    # ==================== nix-darwin flake inputs ====================
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager-darwin = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    sops-nix-darwin = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
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
      nixpkgs-nixos,
      nix-darwin,
      ...
    }@inputs:
    let
      # Helper function to create a a host configuration, with sensible defaults
      # that can be overridden.
      mkHostCfg =
        {
          hostname,
          username ? "ando",
          isLaptop ? false,
          homeDirectory ? "/home/${username}",
          gitEmail ? "gauthsvenkat@gmail.com",
          wallpaper ? "${homeDirectory}/Pictures/wallpapers/astronaut.jpg",
        }:
        {
          inherit
            hostname
            username
            isLaptop
            homeDirectory
            gitEmail
            wallpaper
            ;
        };
    in
    {
      # ==================== NixOS configurations ====================
      nixosConfigurations = {
        "elitedesk" = nixpkgs-nixos.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            hostCfg = mkHostCfg { hostname = "elitedesk"; };
          };
          modules = [ ./hosts/elitedesk ];
        };

        "toshiba" = nixpkgs-nixos.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            hostCfg = mkHostCfg { hostname = "toshiba"; };
          };
          modules = [ ./hosts/toshiba ];
        };

        "thinkpad" = nixpkgs-nixos.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            hostCfg = mkHostCfg {
              hostname = "thinkpad";
              isLaptop = true;
            };
          };
          modules = [ ./hosts/thinkpad ];
        };

        "thunderdome" = nixpkgs-nixos.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            hostCfg = mkHostCfg { hostname = "thunderdome"; };
          };
          modules = [ ./hosts/thunderdome ];
        };

        "nixpi400" = nixpkgs-nixos.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
            hostCfg = mkHostCfg { hostname = "nixpi400"; };
          };
          modules = [ ./hosts/nixpi400 ];
        };
      };

      # ==================== nix-darwin configurations ====================
      darwinConfigurations = {
        "macbook-m1-pro" = nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
            hostCfg = mkHostCfg rec {
              hostname = "macbook-m1-pro";
              username = "gautham";
              isLaptop = true;
              homeDirectory = "/Users/${username}";
              gitEmail = "gautham@dexterenergy.ai";
            };
          };
          modules = [
            { nixpkgs.hostPlatform = "aarch64-darwin"; }
            ./hosts/macbook-m1-pro
          ];
        };
      };
    };
}
