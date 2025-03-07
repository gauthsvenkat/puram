{
  services.kanata = {
    enable = true;
    keyboards.laptop = {
      # NOTE: Highly recommended to set the devices in the host.
      # Otherwise, all keyboards will be intercepted.
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
}
