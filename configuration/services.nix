{ pkgs, ... }:
{
  services = {
    fprintd.enable = true;
    xserver.enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    openssh.enable = true;
    syncthing = {
      enable = true;
      user = "ando";
      dataDir = "/home/ando";
    };
    mullvad-vpn = {
      enable = true;
      # pkgs.mullvad only contains the cli
      # while pkgs.mullvad-vpn comes with the gui as well
      package = pkgs.mullvad-vpn;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    kanata = {
      enable = true;
      keyboards.laptop = {
        devices = [
          "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
        ];
        config = ''
          (defsrc
            caps a s d f j k l ;
          )

          (defvar
            tap-time 300
            hold-time 300
          )

          (defalias
            escaps (tap-hold $tap-time $hold-time esc caps)
            a (tap-hold $tap-time $hold-time a lmet)
            s (tap-hold $tap-time $hold-time s lalt)
            d (tap-hold $tap-time $hold-time d lctl)
            f (tap-hold $tap-time $hold-time f lsft)
            j (tap-hold $tap-time $hold-time j lsft)
            k (tap-hold $tap-time $hold-time k lctl)
            l (tap-hold $tap-time $hold-time l lalt)
            ; (tap-hold $tap-time $hold-time ; lmet)
          )

          (deflayer base
            @escaps @a @s @d @f @j @k @l @;
          )
        '';
      };
    };
  };
}
