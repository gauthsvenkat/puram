{
  config,
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username homeDirectory;
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
    home = {
      packages = with pkgs; [ sops ];
      sessionVariables.SOPS_AGE_KEY_FILE = config.sops.age.keyFile;
    };

    programs.git.settings.diff.sopsdiffer.textconv = "sops decrypt";
  };
}
