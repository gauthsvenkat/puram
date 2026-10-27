{
  uci.settings.firewall = {
    zone = [
      {
        name = "lan";
        network = [ "lan" ];
        input = "ACCEPT";
        output = "ACCEPT";
        forward = "ACCEPT";
      }
    ];

    forwarding = [
      {
        src = "lan";
        dest = "wan";
      }
    ];
  };
}
