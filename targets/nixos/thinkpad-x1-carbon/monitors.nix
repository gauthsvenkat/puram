{ targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  home-manager.users.${username}.services.shikane = {
    enable = true;
    settings.profile = [
      {
        name = "undocked";
        output = [
          {
            enable = true;
            search = "n=eDP-1";
            position = "0,0";
            scale = 2.5;
          }
        ];
      }
      {
        name = "home";
        output = [
          {
            enable = true;
            search = "s=H000000000";
            mode = "best";
            position = "0,0";
            scale = 1.0;
          }
          {
            enable = true;
            search = "s=UPB4DK9P";
            mode = "best";
            position = "2560,300";
            scale = 1.0;
          }
          {
            enable = false;
            search = "n=eDP-1";
          }
        ];
      }
    ];
  };
}
