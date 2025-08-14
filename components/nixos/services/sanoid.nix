{
  services.sanoid = {
    enable = true;
    templates."default" = {
      autosnap = true;
      autoprune = true;
      hourly = 4;
      daily = 7;
      monthly = 1;
      yearly = 0;
    };
  };
}
