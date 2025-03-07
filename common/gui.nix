{
  services = {
    # Uncomment following to enable Xorg (beside wayland)
    # xserver.enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # Allows pipewire to acquire realtime priority
  security.rtkit.enable = true;

  programs = {
    firefox.enable = true;
    kdeconnect.enable = true;
  };
}
