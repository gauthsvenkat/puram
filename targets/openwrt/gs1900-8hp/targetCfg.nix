{
  hostname = "gs1900-8hp";

  image = {
    profile = "zyxel_gs1900-8hp-b1";
    target = "realtek";
    variant = "rtl838x";
    # The image ships `firewall4`; a switch inside the lan has nothing to filter.
    disabledServices = [ "firewall" ];
  };

  lan = {
    ip = "192.168.1.2";
    ports = [
      "lan1"
      "lan2"
      "lan3"
      "lan4"
      "lan5"
      "lan6"
      "lan7"
      "lan8"
    ];
  };
}
