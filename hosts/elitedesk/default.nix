{ username, ... }:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix
    ../../common/boot.nix
    ../../common/nix-settings.nix
    ../../common/system.nix
    ../../common/users.nix
    ../../common/home-manager
    ../../common/ssh.nix
  ];

  services.openssh.enable = true;

  users.users =
    let
      # TODO: Keep these updated
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7C+VPx3ZLurAON5pknD1AlkvdsmB+0J63Yo8y7MVMJ ando@thinkpad"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBjZq6GCEU+TpzLRthwvjzN6pPO+gJt2ngakYpxycf+y ando@thunderdome"
      ];
    in
    {
      ${username}.openssh.authorizedKeys.keys = keys;
      root.openssh.authorizedKeys.keys = keys;
    };

  home-manager.users.${username}.programs.git = {
    userEmail = "gauthsvenkat@gmail.com";
  };
}
