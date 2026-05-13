{ hostCfg, config, ... }:
let
  inherit (hostCfg.ports) radarr sonarr;
  inherit (config.sops) secrets;
in
{
  sops.secrets.radarr_api_key = { };
  sops.secrets.sonarr_api_key = { };

  services.recyclarr = {
    enable = true;
    configuration = {
      radarr.movies = {
        base_url = "http://127.0.0.1:${toString radarr.port}";
        api_key._secret = secrets.radarr_api_key.path;
        delete_old_custom_formats = true;
        quality_definition.type = "movie";
        quality_profiles = [
          {
            trash_id = "d1d67249d3890e49bc12e275d989a7e9";
            reset_unmatched_scores.enabled = true;
          }
        ];
      };
      sonarr.tv = {
        base_url = "http://127.0.0.1:${toString sonarr.port}";
        api_key._secret = secrets.sonarr_api_key.path;
        delete_old_custom_formats = true;
        quality_definition.type = "series";
        quality_profiles = [
          {
            trash_id = "9d142234e45d6143785ac55f5a9e8dc9";
            reset_unmatched_scores.enabled = true;
          }
        ];
      };
    };
  };
}
