{
  targetCfg,

  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) username homeDirectory;
  sshKey = "${homeDirectory}/.ssh/id_ed25519";
in
{
  home-manager.users.${username}.home = {
    packages = [ pkgs.sops ];
    sessionVariables.SOPS_AGE_KEY_CMD = "${lib.getExe pkgs.ssh-to-age} -private-key -i ${sshKey}";
  };

  sops.age.sshKeyPaths = [ sshKey ];
}
