{
  targetCfg,
  pkgs,
  workstationKeys,
}:
let
  inherit (targetCfg) hostname setup wan;
  inherit (pkgs) lib;

  bootstrap = pkgs.writeText "${hostname}-bootstrap" ''
    #!/bin/sh
    # Runs after every flash. Stops if the router is already configured (only then is `wan` set to `"pppoe"`).
    [ "$(uci -q get network.wan.proto)" = pppoe ] && exit 0

    uci -q batch <<EOF
    set system.@system[0].hostname='${hostname}'
    set system.@system[0].zonename='Europe/Amsterdam'
    set system.@system[0].timezone='CET-1CEST,M3.5.0,M10.5.0/3'

    set dropbear.@dropbear[0].PasswordAuth='off'
    set dropbear.@dropbear[0].RootPasswordAuth='off'

    delete network.wan6

    set network.wan.device='${wan.device}'
    set network.wan.proto='pppoe'
    set network.wan.username='internet'
    set network.wan.password='internet'
    set network.wan.ipv6='auto'

    set wireless.default_${setup.radio}.disabled='0'
    set wireless.default_${setup.radio}.ssid='${setup.ssid}'
    set wireless.default_${setup.radio}.encryption='psk2'
    set wireless.default_${setup.radio}.key='${setup.psk}'

    commit
    EOF
  '';
in
pkgs.runCommand "${hostname}-image-files" { } ''
  mkdir -p $out/etc/dropbear $out/etc/uci-defaults
  cp ${pkgs.writeText "authorized_keys" (lib.concatLines workstationKeys)} $out/etc/dropbear/authorized_keys
  cp ${bootstrap} $out/etc/uci-defaults/99-bootstrap
''
