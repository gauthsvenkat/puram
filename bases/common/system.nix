# Common imports that I want on both nixos and darwin systems.
{
  imports = [
    ../../modules/common/home-manager.nix
    ../../modules/common/nix-settings.nix
    ../../modules/common/sops.nix
  ];
}
