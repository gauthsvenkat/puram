{
  homeDirectory,
  username,
  ...
}: {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = username;
    dataDir = homeDirectory;
  };
}
