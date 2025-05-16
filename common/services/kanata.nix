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

        (deftemplate charmod (char mod)
          (switch
            ((key-timing 3 less-than 250)) $char break
            () (tap-hold-release-timeout 200 500 $char $mod $char) break
          )
        )

        (deflayermap (main)
          caps esc
          esc caps
          lsft (tap-hold-press 200 200 (caps-word-toggle 1000) lsft)
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
