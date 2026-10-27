{ inputs, ... }:
{
  imports = [
    ../../modules/nixos/system/boot.nix
    ../../modules/nixos/system/home-manager.nix
    ../../modules/nixos/system/misc.nix
    ../../modules/nixos/system/networking.nix
    ../../modules/nixos/system/nix-settings.nix
    ../../modules/nixos/system/user.nix
    ../../modules/nixos/system/zsh.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
  ];
}
