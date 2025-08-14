{config, ...}: let
  inherit (config.hostCfg) username;
in {
  homebrew = {
    brews = ["kanata"];
    casks = ["karabiner-elements"];
  };

  home-manager.users.${username}.home.file.".config/kanata/kanata.kbd".text = builtins.readFile ../../../notnix/configs/kanata/kanata.darwin.kbd;

  launchd.daemons.kanata.serviceConfig = {
    Label = "com.homebrew.kanata";
    ProgramArguments = [
      "/opt/homebrew/bin/kanata"
      "--cfg"
      "/Users/${username}/.config/kanata/kanata.kbd"
    ];
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = "/var/log/kanata.log";
    StandardOutPath = "/var/log/kanata.log";
  };
}
