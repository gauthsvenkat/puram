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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # BEGIN-PRIVATE
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
    # END-PRIVATE

    # OpenWrt
    dewclaw = {
      url = "github:MakiseKurisu/dewclaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
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
        servers = {
          control = "sentinel";
          dns = "sentinel";
          home = "elitedesk";
        };

        backups = rec {
          region = "nl-ams";
          endpoint = "https://s3.${region}.scw.cloud";
          buckets = {
            headscale = "gauthsvenkat-headscale";
            homeserver = "elitedesk-backup";
            pocket-id = "gauthsvenkat-pocket-id";
          };
        };

        domains = rec {
          apex = "gauthsvenkat.dev";
          headnet = "headnet.${apex}";
          lan = "lan";
          oci = "oci.${apex}";
        };

        fqdns = {
          auth = "auth.${domains.apex}";

          adguard = "adguard.${domains.apex}";
          dns = "dns.${domains.apex}";

          headplane = "headplane.${domains.apex}";
          headscale = "headscale.${domains.apex}";

          ntfy = "ntfy.${domains.apex}";

          pocket-id = "id.${domains.apex}";
        };

        pocketId = {
          adminGroup = "admins";
          clientIds = {
            headplane = "headplane";
            headscale = "headscale";
            oauth2-proxy = "oauth2-proxy";
          };
        };

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
