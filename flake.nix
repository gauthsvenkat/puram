{
  description = "Personal nix flake for my various machines";

  inputs = {
    nixpkgs-nixos.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };

    home-manager-nixos = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };
  };

  outputs = {nixpkgs-nixos, ...} @ inputs: let
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
  };
}
