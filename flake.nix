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
      username ? "ando",
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit username hostname inputs;
          homeDirectory = "/home/${username}";
        };
        modules = [./hosts/${hostname}];
      };
  in {
    nixosConfigurations = {
      # work
      xps = mkNixosSystem {
        hostname = "xps";
        username = "gautham";
      };
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
