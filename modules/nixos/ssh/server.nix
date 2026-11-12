{
  flakeCfg,
  targetCfg,
  ...
}:
let
  inherit (flakeCfg) workstationKeys;
  inherit (targetCfg) username;
in
{
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
    };
  };

  users.users = {
    ${username}.openssh.authorizedKeys.keys = workstationKeys;
    root.openssh.authorizedKeys.keys = workstationKeys;
  };
}
