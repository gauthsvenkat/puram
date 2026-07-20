{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  imports = [
    ../../../modules/common/home-manager.nix
    ../../../modules/common/zsh.nix

    ../system.nix
  ];

  home-manager.users.${username} = {
    imports = [
      ../../../modules/home-manager/cli/atuin.nix
      ../../../modules/home-manager/cli/bat.nix
      ../../../modules/home-manager/cli/btop.nix
      ../../../modules/home-manager/cli/eza.nix
      ../../../modules/home-manager/cli/fastfetch.nix
      ../../../modules/home-manager/cli/git.nix
      ../../../modules/home-manager/cli/just.nix
      ../../../modules/home-manager/cli/nh.nix
      ../../../modules/home-manager/cli/starship.nix
      ../../../modules/home-manager/cli/utils.nix
      ../../../modules/home-manager/cli/zoxide.nix
      ../../../modules/home-manager/cli/zsh.nix
    ];

    programs.starship.presets = [ "pure-preset" ];
  };

  services.openssh.enable = true;

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
