{
  description = "One flake to rule them all";

  inputs = {
    # NixOS
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # OpenWrt
    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dewclaw = {
      url = "github:MakiseKurisu/dewclaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # terranix
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      # readDir :: Path -> { hostname::String -> fileType::String }, always "directory"
      # mapAttrs :: (hostname::String -> fileType::String -> targetCfg) -> { hostname::String -> fileType::String } -> { hostname::String -> targetCfg }
      targetCfgs = {
        nixos = lib.mapAttrs (name: _: import ./targets/nixos/${name}/targetCfg.nix) (
          lib.readDir ./targets/nixos
        );
        openwrt = lib.mapAttrs (name: _: import ./targets/openwrt/${name}/targetCfg.nix) (
          lib.readDir ./targets/openwrt
        );
        terranix = lib.mapAttrs (name: _: import ./targets/terranix/${name}/targetCfg.nix) (
          lib.readDir ./targets/terranix
        );
      };

      flakeCfg = rec {
        router = "flint-2";
        homeserver = "elitedesk";

        dns = {
          lanIp = targetCfgs.nixos.${homeserver}.staticLease.ip;
          inherit (targetCfgs.nixos.${homeserver}) tailnetIp;
        };

        domain = "example.com";

        lanDomain = "lan";
        tailnetDomain = "tailnet.ts.net";

        timezone = "Europe/Amsterdam";

        # catAttrs :: attrName::String -> [ targetCfg ] -> [ sshUserKey::String ]
        # :: [ sshUserKey::String ], one per host that has one
        workstationKeys = lib.catAttrs "sshUserKey" (lib.attrValues targetCfgs.nixos);
      };

      # recursiveUpdate :: outputs -> outputs -> outputs
      #   where outputs = { nixosConfigurations, packages, devShells :: { String -> Derivation } }
      # :: outputs, the three parts merged; parts must not share leaf names
      parts = [
        (import ./flake/nixos.nix {
          inherit
            inputs
            flakeCfg
            targetCfgs
            ;
        })
        (import ./flake/openwrt.nix {
          inherit
            inputs
            flakeCfg
            targetCfgs
            ;
        })
        (import ./flake/terranix.nix {
          inherit
            inputs
            flakeCfg
            targetCfgs
            ;
        })
      ];
    in
    lib.foldl' lib.recursiveUpdate { } parts;
}
