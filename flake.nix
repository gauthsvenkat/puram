{
  description = "Personal nix flake for my various machines";

  inputs = {
    nixpkgs-nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };

    home-manager-nixos = {
      url = "github:nix-community/home-manager";
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
  };

  outputs = {
    nixpkgs-nixos,
    nix-darwin,
    ...
  } @ inputs: let
    mkNixosSystem = {
      hostname,
      system ? "x86_64-linux",
    }:
      nixpkgs-nixos.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          inputs.home-manager-nixos.nixosModules.home-manager
          ./hosts/${hostname}
        ];
      };
  in {
    nixosConfigurations = {
      # work
      xps = mkNixosSystem {hostname = "xps";};
      # personal
      thinkpad = mkNixosSystem {hostname = "thinkpad";};
      thunderdome = mkNixosSystem {hostname = "thunderdome";};
      # homeserver
      elitedesk = mkNixosSystem {hostname = "elitedesk";};
      # server
      toshiba = mkNixosSystem {hostname = "toshiba";};
    };

    darwinConfigurations.macbook-m1-pro = nix-darwin.lib.darwinSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {nixpkgs.hostPlatform = "aarch64-darwin";}
        inputs.home-manager-darwin.darwinModules.home-manager
        ./hosts/macbook-m1-pro
      ];
    };
  };
}
