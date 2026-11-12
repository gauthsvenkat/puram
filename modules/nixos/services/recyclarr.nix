{ targetCfg, config, ... }:
let
  inherit (targetCfg.ports) radarr sonarr;
  inherit (config.sops) secrets;
in
{
  sops.secrets = {
    "radarr_api_key".restartUnits = [ "recyclarr.service" ];
    "sonarr_api_key".restartUnits = [ "recyclarr.service" ];
  };

  services.recyclarr = {
    enable = true;
    # TRaSH penalises x265 (HD) at -10000 and stacks WEB-source bonuses, so any
    # WEB release outscores an existing x265 BluRay rip and trips an upgrade.
    # `upgrade.allowed = false` freezes existing files; the `custom_formats` overrides
    # neutralise the x265 penalty so x265 stays eligible for fresh grabs.
    configuration = {
      radarr.movies = {
        api_key._secret = secrets."radarr_api_key".path;
        base_url = "http://127.0.0.1:${toString radarr.port}";
        quality_profiles = [
          {
            trash_id = "d1d67249d3890e49bc12e275d989a7e9";
            reset_unmatched_scores.enabled = true;
            upgrade.allowed = false;
          }
        ];
        custom_formats = [
          {
            trash_ids = [
              "dc98083864ea246d05a42df0d05f81cc"
              "839bea857ed2c0a8e084f3cbdbd65ecb"
            ];
            assign_scores_to = [
              {
                trash_id = "d1d67249d3890e49bc12e275d989a7e9";
                score = 0;
              }
            ];
          }
        ];
        delete_old_custom_formats = true;
        quality_definition.type = "movie";
      };
      sonarr.tv = {
        api_key._secret = secrets."sonarr_api_key".path;
        base_url = "http://127.0.0.1:${toString sonarr.port}";
        quality_profiles = [
          {
            trash_id = "9d142234e45d6143785ac55f5a9e8dc9";
            reset_unmatched_scores.enabled = true;
            upgrade.allowed = false;
          }
        ];
        custom_formats = [
          {
            trash_ids = [ "47435ece6b99a0b477caf360e79ba0bb" ];
            assign_scores_to = [
              {
                trash_id = "9d142234e45d6143785ac55f5a9e8dc9";
                score = 0;
              }
            ];
          }
        ];
        delete_old_custom_formats = true;
        quality_definition.type = "series";
      };
    };
  };
}
