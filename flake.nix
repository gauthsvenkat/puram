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
      # attrNames :: { hostname::String -> fileType::String } -> [ hostname::String ]
      nixosTargets = lib.attrNames (lib.readDir ./targets/nixos);
      openwrtTargets = lib.attrNames (lib.readDir ./targets/openwrt);

      # genAttrs :: [ hostname::String ] -> (hostname::String -> targetCfg) -> { hostname::String -> targetCfg }
      allTargetCfgs =
        lib.genAttrs nixosTargets (name: import ./targets/nixos/${name}/targetCfg.nix)
        // lib.genAttrs openwrtTargets (name: import ./targets/openwrt/${name}/targetCfg.nix)
        // {
          infra = import ./targets/terranix/infra/targetCfg.nix;
        };

      flakeCfg = rec {
        router = "flint-2";
        homeserver = "elitedesk";

        dns = {
          lanIp = allTargetCfgs.${homeserver}.staticLease.ip;
          inherit (allTargetCfgs.${homeserver}) tailnetIp;
        };

        domain = "example.com";

        lanDomain = "lan";
        tailnetDomain = "tailnet.ts.net";

        timezone = "Europe/Amsterdam";

        # catAttrs :: attrName::String -> [ targetCfg ] -> [ sshUserKey::String ]
        # :: [ sshUserKey::String ], one per host that has one
        workstationKeys = lib.catAttrs "sshUserKey" (lib.attrValues allTargetCfgs);
      };

      # recursiveUpdate :: outputs -> outputs -> outputs
      #   where outputs = { nixosConfigurations, packages, devShells :: { String -> Derivation } }
      # :: outputs, the three parts merged; parts must not share leaf names
      parts = [
        (import ./flake/nixos.nix {
          inherit
            allTargetCfgs
            flakeCfg
            inputs
            nixosTargets
            ;
        })
        (import ./flake/openwrt.nix {
          inherit
            allTargetCfgs
            flakeCfg
            inputs
            openwrtTargets
            ;
        })
        (import ./flake/terranix.nix { inherit allTargetCfgs flakeCfg inputs; })
      ];
    in
    lib.foldl' lib.recursiveUpdate { } parts;
}
