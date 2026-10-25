{
  packages = [ "tang" ];

  uci.settings.tang.tang.config = {
    enabled = true;
    port = 9090;
  };
}
