# Common imports that I want on both nixos and darwin systems.
{
  imports = [
    ../../modules/common/extra/nix-settings.nix
    ../../modules/common/home-manager.nix
    ../../modules/common/sops.nix
  ];
}
