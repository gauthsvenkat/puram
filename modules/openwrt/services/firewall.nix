{
  uci.settings.firewall.defaults = [
    {
      input = "REJECT";
      output = "ACCEPT";
      forward = "REJECT";
      synflood_protect = true;
      flow_offloading = true;
      flow_offloading_hw = true;
    }
  ];
}
