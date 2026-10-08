{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username} = {
    services.shikane = {
      enable = true;
      settings.profile = [
        {
          name = "lg-ultrawide";
          output = [
            {
              enable = true;
              mode = "best";
              position = "0,0";
              scale = 1.0;
              search = "m=LG HDR WQHD";
            }
            {
              enable = true;
              position = "952,1440";
              scale = 1.25;
              search = "n=eDP-1";
            }
          ];
        }
        {
          name = "samsung";
          output = [
            {
              enable = true;
              mode = "best";
              position = "1536,1033";
              scale = 1.0;
              search = "s=H000000000";
            }
            {
              enable = true;
              position = "0,1513";
              scale = 1.25;
              search = "n=eDP-1";
            }
          ];
        }
        {
          name = "undocked";
          output = [
            {
              enable = true;
              position = "0,0";
              scale = 1.25;
              search = "n=eDP-1";
            }
          ];
        }
      ];
    };
  };
}
