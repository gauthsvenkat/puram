{ username, ... }:
{
  # NOTE: Enable ssh in the individual hosts
  services.openssh = {
    hostKeys = [
      {
        type = "ed25519";
        path = "/home/${username}/.ssh/id_ed25519";
      }
    ];
  };
}
