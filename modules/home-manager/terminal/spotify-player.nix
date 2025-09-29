{ hostCfg, ... }:
let
  inherit (hostCfg) hostname;
in
{
  programs.spotify-player = {
    enable = true;
    settings.device = {
      name = "${hostname}-tui";
      device_type = "computer";
      volume = 90;
      audio_cache = true;
      autoplay = true;
    };
  };
}
