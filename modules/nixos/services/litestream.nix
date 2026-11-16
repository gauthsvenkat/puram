{
  services.litestream = {
    enable = true;
    settings.snapshot.retention = "168h";
  };
}
