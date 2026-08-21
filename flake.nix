{
  description = "NixOS and home-manager flakes for my machines";

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

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      mkNixos = import ./lib/patcher.nix {
        inherit nixpkgs;
        patches = [
          /*
            # e.g. patch
            {
              name = "jellyfin-hevc10bit-520045";
              url = "https://github.com/NixOS/nixpkgs/pull/520045.patch?full_index=1";
              hash = "sha256-fmAG7AcagzUEfBEzkJ8cSG5prX/TgAth3s1JhHEzTzU=";
            }
          */
        ];
      };

      mkHost = import ./lib/mk-host.nix { inherit inputs mkNixos; };
    in
    {
      nixosConfigurations = {
        "thinkpad-t14s" = mkHost "thinkpad-t14s" "x86_64-linux";
        "thinkpad-x1-carbon" = mkHost "thinkpad-x1-carbon" "x86_64-linux";
        "thunderdome" = mkHost "thunderdome" "x86_64-linux";
        "elitedesk" = mkHost "elitedesk" "x86_64-linux";
      };
    };
}
