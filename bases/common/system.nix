# Common imports that I want on both nixos and darwin systems.
{
  imports = [
    ../../components/common/extra/nix-settings.nix
    ../../components/common/home-manager.nix
    ../../components/common/sops.nix
  ];
}
