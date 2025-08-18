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
  };

  outputs =
    {
      nixpkgs-nixos,
      nix-darwin,
      ...
    }@inputs:
    let
      mkNixosSystem =
        {
          hostname,
          system ? "x86_64-linux",
        }:
        nixpkgs-nixos.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            { hostCfg = { inherit hostname; }; }
            ./hosts/${hostname}
          ];
        };
    in
    {
      nixosConfigurations = {
        # personal
        thinkpad = mkNixosSystem { hostname = "thinkpad"; };
        thunderdome = mkNixosSystem { hostname = "thunderdome"; };
        # homeserver
        elitedesk = mkNixosSystem { hostname = "elitedesk"; };
        # server
        toshiba = mkNixosSystem { hostname = "toshiba"; };
        nixpi400 = mkNixosSystem {
          hostname = "nixpi400";
          system = "aarch64-linux";
        };
      };

      # work
      darwinConfigurations.macbook-m1-pro = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          { hostCfg.hostname = "macbook-m1-pro"; }
          ./hosts/macbook-m1-pro
        ];
      };
    };
}
