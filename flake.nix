{
  description = "Personal nix flake for my various machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    mkNixosSystem = {
      hostname,
      system ? "x86_64-linux",
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [./hosts/${hostname}];
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
