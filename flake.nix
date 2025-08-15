{
  description = "Personal nix flake for my various machines";

  inputs = {
    nixpkgs-nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager-nixos = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager-darwin = {
      url = "github:nix-community/home-manager";
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
          modules = [ ./hosts/${hostname} ];
        };
    in
    {
      nixosConfigurations = {
        # work
        xps = mkNixosSystem { hostname = "xps"; };
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

      darwinConfigurations.macbook-m1-pro = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          ./hosts/macbook-m1-pro
        ];
      };
    };
}
