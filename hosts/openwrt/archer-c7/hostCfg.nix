rec {
  hostname = "archer-c7";
  profile = "tplink_archer-c7-v5";
  release = "25.12.5";
  target = "ath79";
  variant = "generic";

  setup = rec {
    radio = "radio1"; # 2.4Ghz
    ssid = "${hostname}-setup";
    psk = ssid;
  };

  lan = rec {
    ip = "192.168.1.1";
    vid = 1;
    ports = [ "eth0.${toString vid}" ];
  };

  wan = rec {
    vid = 6;
    device = "eth0.${toString vid}";
  };

  guest = {
    ip = "192.168.30.1";
    radio = "radio0"; # 5Ghz
  };

  switch = {
    name = "switch0";
    vlans = [
      {
        inherit (lan) vid;
        ports = "0t 2 3 4 5";
      }
      {
        inherit (wan) vid;
        ports = "0t 1t";
      }
    ];
  };

  radios = {
    radio0 = {
      path = "pci0000:00/0000:00:00.0";
      band = "5g";
      channel = 36;
      htmode = "VHT80";
    };
    radio1 = {
      path = "platform/ahb/18100000.wmac";
      band = "2g";
      channel = 1;
      htmode = "HT20";
    };
  };
}
