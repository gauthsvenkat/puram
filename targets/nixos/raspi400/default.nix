{
  flakeCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) domain;
  cfg_headplane = config.services.headplane;
  cfg_headscale = config.services.headscale;
in
{
  imports = [
    ../../../bases/nixos/raspi.nix

    ../../../modules/nixos/services/caddy.nix
    ../../../modules/nixos/services/headplane.nix
    ../../../modules/nixos/services/headscale.nix
  ];

  services = {
    caddy.virtualHosts = {
      "headplane.${domain}".extraConfig = ''
        @headnet remote_ip 100.64.0.0/10
        handle @headnet {
          redir / /admin/
          reverse_proxy 127.0.0.1:${toString cfg_headplane.settings.server.port}
        }
        respond 404
      '';
      "headscale.${domain}".extraConfig = ''
        @headscale path /key /ts2021 /machine/ping-response /register/*
        handle @headscale {
          reverse_proxy 127.0.0.1:${toString cfg_headscale.port}
        }
        respond 404
      '';
    };

    tailscale.extraSetFlags = [ "--accept-dns=false" ];
  };

  sops.defaultSopsFile = ../../../secrets/headscale.yaml;
}
