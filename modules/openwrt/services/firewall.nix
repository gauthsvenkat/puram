{
  uci.settings.firewall.defaults = [
    {
      flow_offloading = true;
      flow_offloading_hw = true;
      input = "REJECT";
      output = "ACCEPT";
      forward = "REJECT";
      synflood_protect = true;
    }
  ];
}
