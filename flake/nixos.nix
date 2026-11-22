{
  inputs,
  flakeCfg,
  targetCfgs,
}:
let
  inherit (inputs.nixpkgs) lib;

  nixosCfg = {
    stateVersion = "26.11";
  };

  mkNixos =
    name:
    let
      targetCfg = targetCfgs.nixos.${name};
    in
    lib.nixosSystem {
      inherit (targetCfg) system;
      specialArgs = {
        inherit
          inputs

          flakeCfg
          nixosCfg
          targetCfg

          targetCfgs
          ;
      };
      modules = [ ../targets/nixos/${name} ];
    };
in
{
  # mapAttrs :: (hostname::String -> targetCfg -> nixosSystem) -> { hostname::String -> targetCfg } -> { hostname::String -> nixosSystem }
  nixosConfigurations = lib.mapAttrs (name: _: mkNixos name) targetCfgs.nixos;
}
