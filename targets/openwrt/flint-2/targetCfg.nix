rec {
  hostname = "flint-2";
  profile = "glinet_gl-mt6000";
  release = "25.12.5";
  target = "mediatek";
  variant = "filogic";

  setup = rec {
    radio = "radio0"; # 2.4Ghz
    ssid = "${hostname}-setup";
    psk = ssid;
  };

  lan = {
    ip = "192.168.1.1";
    ports = [
      "lan1"
      "lan2"
      "lan3"
      "lan4"
      "lan5"
    ];
  };

  wan = rec {
    vid = 6;
    device = "eth1.${toString vid}";
  };

  guest = {
    ip = "192.168.30.1";
    radio = "radio1"; # 5Ghz
  };
}
