{
  allHostCfgs,
  hostCfg,
  lib,
  ...
}:
let
  inherit (hostCfg) username;
  # :: [ sshUserKey ]
  workstationKeys = lib.catAttrs "sshUserKey" (lib.attrValues allHostCfgs);
in
{
  imports = [ ./system.nix ];

  home-manager.users.${username} = {
    imports = [
      ../../modules/home-manager/atuin.nix
      ../../modules/home-manager/bat.nix
      ../../modules/home-manager/btop.nix
      ../../modules/home-manager/eza.nix
      ../../modules/home-manager/fastfetch.nix
      ../../modules/home-manager/git.nix
      ../../modules/home-manager/just.nix
      ../../modules/home-manager/nh.nix
      ../../modules/home-manager/starship.nix
      ../../modules/home-manager/utils.nix
      ../../modules/home-manager/zoxide.nix
      ../../modules/home-manager/zsh.nix
    ];

    programs.starship.presets = [ "pure-preset" ];
  };

  services.openssh.enable = true;

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.users = {
    root.openssh.authorizedKeys.keys = workstationKeys;
    ${username}.openssh.authorizedKeys.keys = workstationKeys;
  };
}
