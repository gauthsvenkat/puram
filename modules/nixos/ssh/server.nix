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
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users = {
    root.openssh.authorizedKeys.keys = workstationKeys;
    ${username}.openssh.authorizedKeys.keys = workstationKeys;
  };
}
