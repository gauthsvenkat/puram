{
  hostname = "flint-2";

  image = {
    profile = "glinet_gl-mt6000";
    target = "mediatek";
    variant = "filogic";
  };

  lan = {
    ip = "192.168.1.1";
    ports = [
      "lan3"
      "lan4"
      "lan5"
    ];
  };

  wan.device = "eth1";

  guest.ip = "192.168.30.1";

  homelab = {
    ip = "192.168.20.1";
    # The gs1900-8hp switch; everything behind it is a server.
    ports = [ "lan2" ];
  };

  wunlock = {
    ip = "192.168.40.1";
    ssid = "wunlock";
    psk = "wunlock-password";
  };

  ports.adguard = {
    dns_port = 5353;
    web_port = 3000;
  };
}
