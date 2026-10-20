{ inputs, targetCfg, ... }:
let
  inherit (targetCfg) username;
  persistDir = "/nix/persist";
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence

    ../../../bases/nixos/server.nix

    ./disko-config.nix
  ];

  hardware.enableAllHardware = true;

  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot.configurationLimit = 2;
  };

  services = {
    openssh.hostKeys = [
      {
        path = "${persistDir}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];

    xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
    };
  };

  environment.persistence.${persistDir} = {
    directories = [
      "/var/lib/nixos"
      "/var/log"
      {
        directory = "/etc/nixos";
        user = username;
        group = "users";
      }
    ];
    files = [ "/etc/machine-id" ];
    hideMounts = true;
    users.${username}.directories = [ ".ssh" ];
  };
}
