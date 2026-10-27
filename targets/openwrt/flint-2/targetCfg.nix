{
  hostname = "flint-2";

  image = {
    profile = "glinet_gl-mt6000";
    release = "25.12.5";
    target = "mediatek";
    variant = "filogic";
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

  wan.device = "eth1";

  guest.ip = "192.168.30.1";
}
