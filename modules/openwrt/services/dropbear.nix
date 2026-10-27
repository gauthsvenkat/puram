{ flakeCfg, lib, ... }:
let
  inherit (flakeCfg) workstationKeys;
in
{
  etc."dropbear/authorized_keys".text = lib.concatLines workstationKeys;

  uci.settings.dropbear.dropbear."main" = {
    PasswordAuth = false;
    RootPasswordAuth = false;
  };
}
