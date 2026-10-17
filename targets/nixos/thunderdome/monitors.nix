{ targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  home-manager.users.${username}.services.shikane = {
    enable = true;
    settings.profile = [
      {
        name = "home";
        output = [
          {
            enable = true;
            mode = "best";
            position = "0,0";
            scale = 1.0;
            search = "s=HNTT303506";
          }
          {
            enable = true;
            mode = "best";
            position = "2560,300";
            scale = 1.0;
            search = "s=UPB4DK9P";
          }
        ];
      }
    ];
  };
}
