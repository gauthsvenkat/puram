{
  allTargetCfgs,
  flakeCfg,
  inputs,
  nixosTargets,
}:
let
  inherit (inputs.nixpkgs) lib;

  nixosCfg = {
    stateVersion = "26.05";
  };

  mkNixos =
    name:
    let
      targetCfg = allTargetCfgs.${name};
    in
    lib.nixosSystem {
      inherit (targetCfg) system;
      specialArgs = {
        inherit
          allTargetCfgs
          flakeCfg
          nixosCfg
          targetCfg
          inputs
          ;
      };
      modules = [
        ../targets/nixos/${name}
        {
          # HACK: Distrust the roots of the compromised eMudhra intermediates
          # (https://emudhra.we-have-a-problem.com/). Remove once `pkgs.cacert`
          # is NSS 3.131.1 or later.
          security.pki.caCertificateBlacklist = [
            "Comodo AAA Services root"
            "emSign ECC Root CA - G3"
          ];
        }
      ];
    };
in
{
  # genAttrs :: [ hostname::String ] -> (hostname::String -> nixosSystem) -> { hostname::String -> nixosSystem }
  nixosConfigurations = lib.genAttrs nixosTargets mkNixos;
}
