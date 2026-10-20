{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko = {
    devices = {
      disk."main" = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            "ESP" = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            "nix" = {
              size = "100%";
              content = {
                type = "luks";
                # decrypted device is mapped at `/dev/mapper/<name>`
                # https://man7.org/linux/man-pages/man8/cryptsetup-open.8.html
                name = "decrypted";
                passwordFile = "/tmp/secret.key";
                settings.allowDiscards = true;
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };

      # from disko's tmpfs root example
      # https://github.com/nix-community/disko/blob/725ea35/example/hybrid-tmpfs-on-root.nix#L35-L41
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [ "mode=755" ];
      };
    };

    # disko's test framework formats the disk with the dummy passphrase `"secretsecret"`
    # https://github.com/nix-community/disko/blob/725ea35/lib/tests.nix#L364
    tests.bootCommands = ''
      machine.wait_for_console_text("passphrase for disk")
      machine.send_console("secretsecret\n")
    '';
  };
}
