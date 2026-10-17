{
  allTargetCfgs,
  inputs,
  nixosTargets,
}:
let
  inherit (inputs.nixpkgs) lib;

  mkNixos =
    name:
    let
      targetCfg = allTargetCfgs.${name};
    in
    lib.nixosSystem {
      inherit (targetCfg) system;
      specialArgs = {
        inherit allTargetCfgs targetCfg inputs;
      };
      modules = [ ../targets/nixos/${name} ];
    };
in
{
  # genAttrs :: [ hostname::String ] -> (hostname::String -> nixosSystem) -> { hostname::String -> nixosSystem }
  nixosConfigurations = lib.genAttrs nixosTargets mkNixos;
}
