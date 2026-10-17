{ targetCfg, ... }:
{
  # HACK: `configDir` is intentionally left at the upstream default. Custom
  # `configDir` values currently break the unit (nixpkgs#457739); we
  # persist state by bind-mounting `/var/lib/private/seerr` appropriately.
  services.seerr = {
    enable = true;
    inherit (targetCfg.ports.seerr) port;
  };
}
