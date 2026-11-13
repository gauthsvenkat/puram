{
  hostname = "flint-2";

  image = {
    target = "mediatek";
    variant = "filogic";
    profile = "glinet_gl-mt6000";
  };

  lan = {
    ip = "192.168.1.1";
    ports = [
      "lan1"
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

  iot.ip = "192.168.50.1";

  wunlock = {
    ip = "192.168.40.1";
    ssid = "wunlock";
    psk = "wunlock-password";
  };

  ports = {
    doh = 5053;
    tang = 9090;
  };
}
