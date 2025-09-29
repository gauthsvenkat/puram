{
  description = "NixOS, nix-darwin and home-manager flakes for my machines";

  inputs = {
    # NixOS flake inputs
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

    # nix-darwin flake inputs
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
      mkHostCfg =
        {
          hostname,
          system ? "x86_64-linux",
          username ? "ando",
          isLaptop ? false,
          homeDirectory ? "/home/${username}",
          gitEmail ? "gauthsvenkat@gmail.com",
          wallpaper ? "${homeDirectory}/Pictures/wallpapers/astronaut.jpg",
        }:
        {
          inherit
            hostname
            system
            username
            isLaptop
            homeDirectory
            gitEmail
            wallpaper
            ;
        };

      hostConfigs = [
        (mkHostCfg { hostname = "elitedesk"; })
        (mkHostCfg {
          hostname = "nixpi400";
          system = "aarch64-linux";
        })
        (mkHostCfg { hostname = "toshiba"; })
        (mkHostCfg {
          hostname = "thinkpad";
          isLaptop = true;
        })
        (mkHostCfg { hostname = "thunderdome"; })
      ];
    in
    {
      nixosConfigurations = builtins.listToAttrs (
        builtins.map (hostCfg: {
          name = hostCfg.hostname;
          value = nixpkgs-nixos.lib.nixosSystem {
            inherit (hostCfg) system;
            specialArgs = {
              inherit inputs;
              inherit hostCfg;
            };
            modules = [ ./hosts/${hostCfg.hostname} ];
          };
        }) hostConfigs
      );

      darwinConfigurations.macbook-m1-pro =
        let
          hostCfg = mkHostCfg rec {
            hostname = "macbook-m1-pro";
            system = "aarch64-darwin";
            username = "gautham";
            isLaptop = true;
            homeDirectory = "/Users/${username}";
            gitEmail = "gautham@dexterenergy.ai";
          };
        in
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
            inherit hostCfg;
          };
          modules = [
            { nixpkgs.hostPlatform = hostCfg.system; }
            ./hosts/macbook-m1-pro
          ];
        };
    };
}
