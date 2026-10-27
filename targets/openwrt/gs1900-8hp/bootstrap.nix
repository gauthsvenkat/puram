{
  flakeCfg,
  openwrtCfg,
  targetCfg,

  pkgs,
}:
let
  inherit (flakeCfg) workstationKeys;
  inherit (openwrtCfg) gateway timezone zonename;
  inherit (targetCfg) hostname lan;
  inherit (pkgs) lib;

  bootstrap = pkgs.writeText "${hostname}-bootstrap" ''
    #!/bin/sh
    # Runs after every flash. Stops if the switch is already configured.
    [ "$(uci -q get system.@system[0].hostname)" = ${hostname} ] && exit 0

    uci -q batch <<EOF
    set system.@system[0].hostname='${hostname}'
    set system.@system[0].zonename='${zonename}'
    set system.@system[0].timezone='${timezone}'

    set dropbear.@dropbear[0].PasswordAuth='off'
    set dropbear.@dropbear[0].RootPasswordAuth='off'

    set network.lan.ipaddr='${lan.ip}/24'
    set network.lan.gateway='${gateway}'
    set network.lan.dns='${gateway}'
    delete network.lan.ip6assign

    commit
    EOF
  '';
in
pkgs.runCommand "${hostname}-image-files" { } ''
  mkdir -p $out/etc/dropbear $out/etc/uci-defaults
  cp ${pkgs.writeText "authorized_keys" (lib.concatLines workstationKeys)} $out/etc/dropbear/authorized_keys
  cp ${bootstrap} $out/etc/uci-defaults/99-bootstrap
''
