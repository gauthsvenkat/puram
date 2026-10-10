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
      nixosHostDirs = lib.readDir ./hosts/nixos;
      openwrtHostDirs = lib.readDir ./hosts/openwrt;

      # mapAttrs :: (String -> String -> hostCfg) -> { String -> String } -> { String -> hostCfg }
      # :: { String -> hostCfg }, keyed by hostname
      allHostCfgs =
        lib.mapAttrs (name: _: import ./hosts/nixos/${name}/hostCfg.nix) nixosHostDirs
        // lib.mapAttrs (name: _: import ./hosts/openwrt/${name}/hostCfg.nix) openwrtHostDirs;

      mkNixos = import ./lib/mk-nixos.nix { inherit allHostCfgs inputs evalNixos; };
      mkOpenwrt = import ./lib/mk-openwrt.nix { inherit allHostCfgs inputs; };
    in
    {
      # mapAttrs :: (String -> String -> nixosSystem) -> { String -> String } -> { String -> nixosSystem }
      #   where nixosSystem = result of lib.nixosSystem
      # :: { String -> nixosSystem }, keyed by hostname
      nixosConfigurations = lib.mapAttrs (name: _: mkNixos name) nixosHostDirs;

      # concatMapAttrs :: (String -> String -> { String -> Derivation }) -> { String -> String } -> { String -> Derivation }
      # :: { String -> Derivation }, keyed "${hostname}-image" and "${hostname}-deploy"
      packages."x86_64-linux" = lib.concatMapAttrs (
        name: _:
        let
          router = mkOpenwrt name;
        in
        {
          "${name}-image" = router.image;
          "${name}-deploy" = router.deploy;
        }
      ) openwrtHostDirs;

      devShells."x86_64-linux".default =
        let
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
        in
        pkgs.mkShell {
          packages = with pkgs; [
            (opentofu.withPlugins (p: [
              p.cloudflare_cloudflare
              p.scaleway_scaleway
              p.tailscale_tailscale
            ]))
            sops
          ];
        };
    };
}
