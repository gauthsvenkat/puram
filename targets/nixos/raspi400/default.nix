{
  flakeCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) domain;
  cfg = config.services.headscale;
in
{
  imports = [
    ../../../bases/nixos/raspi.nix

    ../../../modules/nixos/services/caddy.nix
    ../../../modules/nixos/services/headscale.nix
  ];

  services.caddy.virtualHosts."headscale.${domain}".extraConfig = ''
    @headscale path /key /ts2021 /machine/ping-response /register/*
    handle @headscale {
      reverse_proxy 127.0.0.1:${toString cfg.port}
    }
    respond 404
  '';

  sops.defaultSopsFile = ../../../secrets/headscale.yaml;
}
