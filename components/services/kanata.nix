{
  services.kanata = {
    enable = true;
    keyboards.laptop = {
      # NOTE: Make sure that the devices are present in the host
      devices = [
        "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
      ];
      extraDefCfg = ''
        process-unmapped-keys yes
      '';
      # Config stolen from https://github.com/jtroo/kanata/discussions/1455
      config = builtins.readFile ../../notnix/configs/kanata.kbd;
    };
  };
}
