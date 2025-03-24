{ username, ... }:
{
  home-manager.users.${username}.services.espanso = {
    enable = true;
    matches.base.matches = [
      {
        trigger = ":eur";
        replace = "€";
      }
      {
        trigger = ":s-yday";
        replace = "{{start_yesterday}}";
        vars = [
          {
            name = "start_yesterday";
            type = "shell";
            params.cmd = "date -d \"$(date -d 'yesterday 00:00:00' +'%Y-%m-%dT%H:%M:%S%:z')\" --utc --iso-8601=seconds";
          }
        ];
      }
      {
        trigger = ":s-today";
        replace = "{{start_today}}";
        vars = [
          {
            name = "start_today";
            type = "shell";
            params.cmd = "date -d \"$(date -d '00:00:00' +'%Y-%m-%dT%H:%M:%S%:z')\" --utc --iso-8601=seconds";
          }
        ];
      }
      {
        trigger = ":s-tomo";
        replace = "{{start_tomorrow}}";
        vars = [
          {
            name = "start_tomorrow";
            type = "shell";
            params.cmd = "date -d \"$(date -d 'tomorrow 00:00:00' +'%Y-%m-%dT%H:%M:%S%:z')\" --utc --iso-8601=seconds";
          }
        ];
      }
    ];
  };
}
