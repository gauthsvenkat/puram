{
  description = "NixOS and home-manager flakes for my machines";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dewclaw = {
      url = "github:MakiseKurisu/dewclaw";
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

    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
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
      evalNixos = import ./lib/patcher.nix {
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

      inherit (nixpkgs) lib;

      # readDir :: Path -> { String -> String }
      # :: { String -> String }, hostname -> file type, always "directory"
      nixosTargetDirs = lib.readDir ./targets/nixos;
      openwrtTargetDirs = lib.readDir ./targets/openwrt;

      # mapAttrs :: (String -> String -> hostCfg) -> { String -> String } -> { String -> hostCfg }
      # :: { String -> hostCfg }, keyed by hostname
      allHostCfgs =
        lib.mapAttrs (name: _: import ./targets/nixos/${name}/hostCfg.nix) nixosTargetDirs
        // lib.mapAttrs (name: _: import ./targets/openwrt/${name}/hostCfg.nix) openwrtTargetDirs
        // {
          infra = import ./targets/terranix/infra/hostCfg.nix;
        };

      mkNixos = import ./lib/mk-nixos.nix { inherit allHostCfgs inputs evalNixos; };
      mkOpenwrt = import ./lib/mk-openwrt.nix { inherit allHostCfgs inputs; };
      mkTerranix = import ./lib/mk-terranix.nix { inherit allHostCfgs inputs; };
      infraConfig = mkTerranix "infra";
    in
    {
      # mapAttrs :: (String -> String -> nixosSystem) -> { String -> String } -> { String -> nixosSystem }
      #   where nixosSystem = result of lib.nixosSystem
      # :: { String -> nixosSystem }, keyed by hostname
      nixosConfigurations = lib.mapAttrs (name: _: mkNixos name) nixosTargetDirs;

      # concatMapAttrs :: (String -> String -> { String -> Derivation }) -> { String -> String } -> { String -> Derivation }
      # :: { String -> Derivation }, keyed "${hostname}-image" and "${hostname}-deploy", plus "infra-config"
      packages."x86_64-linux" =
        lib.concatMapAttrs (
          name: _:
          let
            router = mkOpenwrt name;
          in
          {
            "${name}-image" = router.image;
            "${name}-deploy" = router.deploy;
          }
        ) openwrtTargetDirs
        // {
          infra-config = infraConfig;
        };

      devShells."x86_64-linux".default =
        let
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          # map :: (provider -> String) -> [ provider ] -> [ String ]
          #   where provider = { source :: String; version :: String }
          # :: [ String ], nixpkgs attribute name of each required provider, "owner_name"
          providerNames = map (provider: lib.replaceStrings [ "/" ] [ "_" ] provider.source) (
            lib.attrValues infraConfig.config.terraform.required_providers
          );
          tofu = pkgs.opentofu.withPlugins (lib.attrVals providerNames);
        in
        pkgs.mkShell {
          packages = [
            tofu
            pkgs.sops
          ];
        };
    };
}
