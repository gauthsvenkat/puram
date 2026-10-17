{
  targetCfg,
  ...
}:
let
  inherit (targetCfg) zpool;
in
{
  imports = [
    ../../../modules/nixos/services/sanoid.nix
  ];

  services.sanoid.datasets = {
    "${zpool}" = {
      recursive = true;
      process_children_only = true;
      use_template = [ "default" ];
    };
    "${zpool}/cache".autosnap = false;
    "${zpool}/services/config".autosnap = false;
    "${zpool}/services/databases".autosnap = false;
  };
}
