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

      platforms = [
        "nixos"
        "openwrt"
        "terranix"
      ];

      # genAttrs :: [ platform::String ] -> (platform::String -> { hostname::String -> targetCfg }) -> { platform::String -> { hostname::String -> targetCfg } }
      # readDir :: Path -> { hostname::String -> fileType::String }, always "directory"
      # mapAttrs :: (hostname::String -> fileType::String -> targetCfg) -> { hostname::String -> fileType::String } -> { hostname::String -> targetCfg }
      targetCfgs = lib.genAttrs platforms (
        platform:
        lib.mapAttrs (name: _: import ./targets/${platform}/${name}/targetCfg.nix) (
          lib.readDir ./targets/${platform}
        )
      );

      flakeCfg = rec {
        router = "flint-2";
        controlServer = "raspi400";
        homeserver = "elitedesk";

        ddnsName = "apartment";
        domain = "example.com";

        headnetDomain = "headnet.${domain}";
        lanDomain = "lan";

        timezone = "Europe/Amsterdam";

        # catAttrs :: attrName::String -> [ targetCfg ] -> [ sshUserKey::String ]
        # :: [ sshUserKey::String ], one per host that has one
        workstationKeys = lib.catAttrs "sshUserKey" (lib.attrValues targetCfgs.nixos);
      };

      # map :: (platform::String -> outputs) -> [ platform::String ] -> [ outputs ]
      # recursiveUpdate :: outputs -> outputs -> outputs
      #   where outputs = { nixosConfigurations, packages, devShells :: { String -> Derivation } }
      # :: outputs, one part per platform merged; parts must not share leaf names
      parts = map (
        platform:
        import ./flake/${platform}.nix {
          inherit
            inputs
            flakeCfg
            targetCfgs
            ;
        }
      ) platforms;
    in
    lib.foldl' lib.recursiveUpdate { } parts;
}
