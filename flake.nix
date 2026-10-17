{
  description = "One flake to rule them all";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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

    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dewclaw = {
      url = "github:MakiseKurisu/dewclaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      # readDir :: Path -> { String -> String }, directory name -> file type, always "directory"
      # attrNames :: { String -> String } -> [ String ]
      # :: [ String ], hostnames, one per directory
      nixosTargets = lib.attrNames (lib.readDir ./targets/nixos);
      openwrtTargets = lib.attrNames (lib.readDir ./targets/openwrt);

      # genAttrs :: [ String ] -> (String -> targetCfg) -> { String -> targetCfg }
      # :: { String -> targetCfg }, keyed by hostname
      allTargetCfgs =
        lib.genAttrs nixosTargets (name: import ./targets/nixos/${name}/targetCfg.nix)
        // lib.genAttrs openwrtTargets (name: import ./targets/openwrt/${name}/targetCfg.nix)
        // {
          infra = import ./targets/terranix/infra/targetCfg.nix;
        };

      # recursiveUpdate :: outputs -> outputs -> outputs
      #   where outputs = { nixosConfigurations, packages, devShells :: { String -> Derivation } }
      # :: outputs, the three parts merged; parts must not share leaf names
      parts = [
        (import ./flake/nixos.nix { inherit allTargetCfgs inputs nixosTargets; })
        (import ./flake/openwrt.nix { inherit allTargetCfgs inputs openwrtTargets; })
        (import ./flake/terranix.nix { inherit allTargetCfgs inputs; })
      ];
    in
    lib.foldl' lib.recursiveUpdate { } parts;
}
