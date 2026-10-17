{ targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  home-manager.users.${username} = {
    services.shikane = {
      enable = true;
      settings.profile = [
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
        {
          name = "home";
          output = [
            {
              enable = true;
              mode = "best";
              position = "0,0";
              scale = 1.0;
              search = "s=H000000000";
            }
            {
              enable = true;
              mode = "best";
              position = "2560,300";
              scale = 1.0;
              search = "s=UPB4DK9P";
            }
            {
              enable = false;
              search = "n=eDP-1";
            }
          ];
        }
        {
          name = "office";
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
      ];
    };
  };
}
