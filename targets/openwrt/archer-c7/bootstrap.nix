{
  targetCfg,
  pkgs,
  workstationKeys,
}:
let
  inherit (targetCfg)
    hostname
    setup
    switch
    wan
    ;
  inherit (pkgs) lib;

  # concatImapStrings :: (Int -> vlan -> String) -> [ vlan ] -> String
  #   where vlan = { vid :: Int; ports :: String }
  # :: String, uci batch lines adding one switch_vlan section per vlan
  switchVlans = lib.concatImapStrings (
    i:
    { vid, ports }:
    ''
      add network switch_vlan
      set network.@switch_vlan[-1].device='${switch.name}'
      set network.@switch_vlan[-1].vlan='${toString i}'
      set network.@switch_vlan[-1].vid='${toString vid}'
      set network.@switch_vlan[-1].ports='${ports}'
    ''
  ) switch.vlans;

  bootstrap = pkgs.writeText "${hostname}-bootstrap" ''
    #!/bin/sh
    # Runs after every flash. We assume that only a configured
    # router has 'pppoe' (default is 'dhcp'), and stop script
    # execution if that is the case.
    [ "$(uci -q get network.wan.proto)" = pppoe ] && exit 0

    while uci -q delete network.@switch_vlan[0]; do :; done

    uci -q batch <<EOF
    set system.@system[0].hostname='${hostname}'
    set system.@system[0].zonename='Europe/Amsterdam'
    set system.@system[0].timezone='CET-1CEST,M3.5.0,M10.5.0/3'

    set dropbear.@dropbear[0].PasswordAuth='off'
    set dropbear.@dropbear[0].RootPasswordAuth='off'

    ${switchVlans}

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
