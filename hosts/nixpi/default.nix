{
  username,
  inputs,
  ...
}:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ../../common/nix-settings.nix
    ../../common/system.nix
    ../../common/users.nix
    ../../common/home-manager
    ../../common/ssh.nix
    ./wg-easy.nix
    ./adguardhome.nix
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
