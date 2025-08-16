{ config, pkgs, ... }:
let
  inherit (config.hostCfg) username homeDirectory;
in
{
  sops = {
    defaultSopsFile = ../../secrets.yaml;

    age = {
      sshKeyPaths = [ "${homeDirectory}/.ssh/id_ed25519" ];
      keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [ sops ];

    programs.git.extraConfig.diff.sopsdiffer.textconv = "sops decrypt";
  };
}
