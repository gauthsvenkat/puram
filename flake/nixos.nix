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
      inherit (targetCfg) system;
    in
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit allTargetCfgs targetCfg inputs;
      };
      modules = [ ../targets/nixos/${name} ];
    };
in
{
  # genAttrs :: [ String ] -> (String -> nixosSystem) -> { String -> nixosSystem }
  #   where nixosSystem = result of lib.nixosSystem
  # :: { String -> nixosSystem }, keyed by hostname
  nixosConfigurations = lib.genAttrs nixosTargets mkNixos;
}
