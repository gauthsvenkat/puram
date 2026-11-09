{
  imports = [
    ../../modules/openwrt/guest.nix
    ../../modules/openwrt/headscale.nix
    ../../modules/openwrt/homelab.nix
    ../../modules/openwrt/iot.nix
    ../../modules/openwrt/lan/dhcp.nix
    ../../modules/openwrt/lan/firewall.nix
    ../../modules/openwrt/lan/wifi.nix
    ../../modules/openwrt/services/ddns.nix
    ../../modules/openwrt/services/dnsmasq.nix
    ../../modules/openwrt/services/firewall.nix
    ../../modules/openwrt/services/odhcpd.nix
    ../../modules/openwrt/services/tang.nix
    ../../modules/openwrt/wunlock.nix
    ../../modules/openwrt/wan.nix

    ./device.nix
  ];
}
