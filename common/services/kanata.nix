{
  services.kanata = {
    enable = true;
    keyboards.laptop = {
      # NOTE: Highly recommended to set the devices in the host.
      # Otherwise, all keyboards will be intercepted.
      devices = [
        "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
      ];
      extraDefCfg = ''
        process-unmapped-keys yes
      '';
      # Config stolen from https://github.com/jtroo/kanata/discussions/1455
      config = ''
        (defsrc
        )

        (defvar
          tap-timeout 200
          hold-timeout 300
          key-recency 3
          key-recency-time 250
          caps-word-timeout 1000
        )

        (deftemplate charmod (char mod)
          (switch
            ((key-timing $key-recency lt $key-recency-time)) $char break
            () (tap-hold-release $tap-timeout $hold-timeout $char $mod) break
          )
        )

        (deflayermap (main)
          caps esc
          esc caps

          lsft (tap-hold-press $tap-timeout $hold-timeout (caps-word-toggle $caps-word-timeout) lsft)
          rsft (tap-hold-press $tap-timeout $hold-timeout f12 rsft)

          a (t! charmod a lmet)
          s (t! charmod s lalt)
          d (t! charmod d lctl)
          f (t! charmod f lsft)
          j (t! charmod j lsft)
          k (t! charmod k rctl)
          l (t! charmod l ralt)
          ; (t! charmod ; rmet)
        )
      '';
    };
  };
}
