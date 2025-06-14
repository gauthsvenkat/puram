{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Allows pipewire to acquire realtime priority
  security.rtkit.enable = true;
}
