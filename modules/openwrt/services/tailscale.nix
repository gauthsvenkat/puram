{
  packages = [ "tailscale" ];

  uci.settings = {
    tailscale.settings.settings = {
      fw_mode = "nftables";
      log_stderr = true;
      log_stdout = true;
      port = 41641;
      state_file = "/etc/tailscale/tailscaled.state";
    };

    firewall = {
      zone = [
        {
          name = "tailscale";
          device = [ "tailscale0" ];
          input = "REJECT";
          output = "ACCEPT";
          forward = "REJECT";
        }
      ];

      rule = [
        {
          name = "Allow-Tailscale-DNS";
          src = "tailscale";
          proto = "tcpudp";
          dest_port = 53;
          target = "ACCEPT";
        }
      ];
    };
  };
}
