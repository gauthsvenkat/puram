{
  inputs,

  targetCfg,

  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) username;
  persistDir = "/nix/persist";
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence

    ../../../bases/nixos/server.nix

    ../../../modules/nixos/services/kanata.nix
    ../../../modules/nixos/system/wifi.nix

    ./disko-config.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot.configurationLimit = 2;
  };

  environment = {
    persistence.${persistDir} = {
      directories = [
        "/var/lib/nixos"
        "/var/log"
        {
          directory = "/etc/nixos";
          group = "users";
          user = username;
        }
      ];
      files = [ "/etc/machine-id" ];
      hideMounts = true;
      users.${username}.directories = [ ".ssh" ];
    };

    systemPackages = with pkgs; [
      e2fsprogs
      fio
      gsmartcontrol
      lshw
      memtester
      smartmontools
      stress-ng
      tmux
      usbutils
    ];
  };

  hardware.enableAllHardware = true;

  services = {
    kanata.keyboards."laptop".devices = lib.mkForce [ ];

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
}
