{
  username,
  inputs,
  ...
}:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

    ../../common/system.nix
    ../../common/users.nix
    ../../common/nix-settings.nix

    ../../common/home-manager.nix

    ../../common/services/ssh.nix
    ../../common/services/adguardhome.nix

    ./wg-easy.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  home-manager.users.${username}.programs.git = {
    userEmail = "gauthsvenkat@gmail.com";
  };
}
