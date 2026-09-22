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

      # :: { hostname -> filetype }
      hostDirs = nixpkgs.lib.readDir ./hosts;

      # :: { hostname -> hostCfg }
      allHostCfgs = nixpkgs.lib.mapAttrs (name: _: import ./hosts/${name}/hostCfg.nix) hostDirs;

      mkNixos = import ./lib/mk-nixos.nix { inherit allHostCfgs inputs evalNixos; };
      mkOpenwrt = import ./lib/mk-openwrt.nix { inherit allHostCfgs inputs; };
    in
    {
      nixosConfigurations = {
        "thinkpad-t14s" = mkNixos "thinkpad-t14s" "x86_64-linux";
        "thinkpad-x1-carbon" = mkNixos "thinkpad-x1-carbon" "x86_64-linux";
        "thunderdome" = mkNixos "thunderdome" "x86_64-linux";
        "elitedesk" = mkNixos "elitedesk" "x86_64-linux";
        "raspi400" = mkNixos "raspi400" "aarch64-linux";
        "raspi5" = mkNixos "raspi5" "aarch64-linux";
      };

      packages."x86_64-linux" = {
        "archer-c7-image" = (mkOpenwrt "archer-c7").image;
        "archer-c7-deploy" = (mkOpenwrt "archer-c7").deploy;
      };

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
