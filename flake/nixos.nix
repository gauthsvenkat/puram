{
  inputs,
  flakeCfg,
  targetCfgs,
}:
let
  inherit (inputs.nixpkgs) lib;

  nixosCfg = {
    stateVersion = "26.05";
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
  # mapAttrs :: (hostname::String -> targetCfg -> nixosSystem) -> { hostname::String -> targetCfg } -> { hostname::String -> nixosSystem }
  nixosConfigurations = lib.mapAttrs (name: _: mkNixos name) targetCfgs.nixos;
}
