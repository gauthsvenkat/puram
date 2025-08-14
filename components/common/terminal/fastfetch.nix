{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username isLaptop;
  mkSeparator = {
    type = "separator";
    string = "─────────────────────────";
  };
in {
  home-manager.users.${username}.programs = {
    fastfetch = {
      enable = true;

      settings = {
        logo = {
          source = "nixos";
          padding.right = 1;
        };

        display = {
          separator = " ";

          color = {
            keys = "blue";
            title = "bright_blue";
          };

          percent = {
            type = 3;
            color = {
              green = "bright_green";
              yellow = "bright_yellow";
              red = "bright_red";
            };
          };
        };

        modules = [
          {
            type = "title";
            color = {
              user = "bright_cyan";
              at = "white";
              host = "bright_magenta";
            };
          }

          mkSeparator

          # System Information
          {
            type = "os";
            key = " OS";
            keyColor = "bright_blue";
          }
          {
            type = "kernel";
            key = " Kernel";
            keyColor = "bright_blue";
          }
          {
            type = "uptime";
            key = " Uptime";
            keyColor = "bright_blue";
          }

          mkSeparator

          # Hardware Information
          {
            type = "host";
            key = " Host";
            keyColor = "bright_green";
          }
          {
            type = "cpu";
            key = " CPU";
            keyColor = "bright_green";
            temp = true;
          }

          mkSeparator

          # Hardware usage
          {
            type = "cpuusage";
            key = " CPU Usage";
            keyColor = "bright_red";
            percent.type = 3;
          }
          {
            type = "memory";
            key = " Memory";
            keyColor = "bright_red";
            percent.type = 3;
          }
          {
            type = "disk";
            key = " Disk";
            keyColor = "bright_red";
            percent.type = 3;
          }

          mkSeparator

          # Network Information
          {
            type = "localip";
            key = " Local IP";
            keyColor = "bright_cyan";
          }
          {
            type = "publicip";
            key = " Public IP";
            keyColor = "bright_cyan";
          }
          {
            type = "dns";
            key = " DNS";
            keyColor = "bright_cyan";
          }

          (
            if isLaptop
            then {
              type = "wifi";
              key = " WiFi";
              keyColor = "bright_cyan";
            }
            else {
              type = "netio";
              key = " NetIO";
              keyColor = "bright_cyan";
            }
          )
        ];
      };
    };

    zsh.shellAliases."ff" = "${pkgs.fastfetch}/bin/fastfetch";
  };
}
