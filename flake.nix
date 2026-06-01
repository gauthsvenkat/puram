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
    { nixpkgs, ... }@inputs:
    let
      mkNixos = import ./lib/patcher.nix {
        inherit nixpkgs;
        patches = [
          {
            name = "jellyfin-hevc10bit-520045";
            url = "https://github.com/NixOS/nixpkgs/pull/520045.patch?full_index=1";
            hash = "sha256-fmAG7AcagzUEfBEzkJ8cSG5prX/TgAth3s1JhHEzTzU=";
          }
        ];
      };

      mkHost =
        name: system:
        let
          builder =
            if nixpkgs.lib.hasSuffix "darwin" system then inputs.nix-darwin.lib.darwinSystem else mkNixos;
        in
        builder {
          inherit system;
          specialArgs = {
            inherit inputs;
            hostCfg = import ./hosts/${name}/hostCfg.nix;
          };
          modules = [ ./hosts/${name} ];
        };
    in
    {
      darwinConfigurations = {
        "macbook-m1-pro" = mkHost "macbook-m1-pro" "aarch64-darwin";
      };

      nixosConfigurations = {
        "toshiba" = mkHost "toshiba" "x86_64-linux";
        "thinkpad" = mkHost "thinkpad" "x86_64-linux";
        "thunderdome" = mkHost "thunderdome" "x86_64-linux";
        "nixpi400" = mkHost "nixpi400" "aarch64-linux";
        "elitedesk" = mkHost "elitedesk" "x86_64-linux";
      };
    };
}
