{
  services.litestream = {
    enable = true;
    # TODO: validate the replicas periodically; replication can stop silently while the app keeps running.
    # https://litestream.io/reference/config/#validation
    settings.snapshot.retention = "168h";
  };
}
