{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) fqdns;
  inherit (targetCfg) ports;
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
      ${fqdns.headplane}.extraConfig = ''
        @headnet remote_ip 100.64.0.0/10
        handle @headnet {
          redir / /admin/
          reverse_proxy 127.0.0.1:${toString ports.headplane}
        }
        respond 404
      '';
      ${fqdns.headscale}.extraConfig = ''
        @headscale path /key /ts2021 /machine/ping-response /register/*
        handle @headscale {
          reverse_proxy 127.0.0.1:${toString ports.headscale}
        }
        respond 404
      '';
    };

    tailscale.extraSetFlags = [ "--accept-dns=false" ];
  };

  sops.defaultSopsFile = ../../../secrets/headscale.yaml;
}
