{
  flakeCfg,
  openwrtCfg,
  targetCfg,

  pkgs,
}:
let
  inherit (flakeCfg) workstationKeys;
  inherit (openwrtCfg) pppoe timezone zonename;
  inherit (targetCfg) hostname wan;
  inherit (pkgs) lib;
  setupSsid = "${hostname}-setup";

  bootstrap = pkgs.writeText "${hostname}-bootstrap" ''
    #!/bin/sh
    # Runs after every flash. Stops if the router is already configured (only then is `wan` set to `"pppoe"`).
    [ "$(uci -q get network.wan.proto)" = pppoe ] && exit 0

    uci -q batch <<EOF
    set system.@system[0].hostname='${hostname}'
    set system.@system[0].zonename='${zonename}'
    set system.@system[0].timezone='${timezone}'

    set dropbear.@dropbear[0].PasswordAuth='off'
    set dropbear.@dropbear[0].RootPasswordAuth='off'

    delete network.wan6

    set network.wan.device='${wan.device}.${toString pppoe.vid}'
    set network.wan.proto='pppoe'
    set network.wan.username='${pppoe.username}'
    set network.wan.password='${pppoe.password}'
    set network.wan.ipv6='auto'

    set wireless.default_radio0.disabled='0'
    set wireless.default_radio0.ssid='${setupSsid}'
    set wireless.default_radio0.encryption='psk2'
    set wireless.default_radio0.key='${setupSsid}'

    commit
    EOF
  '';
in
pkgs.runCommand "${hostname}-image-files" { } ''
  mkdir -p $out/etc/dropbear $out/etc/uci-defaults
  cp ${pkgs.writeText "authorized_keys" (lib.concatLines workstationKeys)} $out/etc/dropbear/authorized_keys
  cp ${bootstrap} $out/etc/uci-defaults/99-bootstrap
''
