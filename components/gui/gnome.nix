{
  pkgs,
  username,
  ...
}: {
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # NOTE: Following is required, because without it, we get a white square
  # box as the cursor :-(.
  home-manager.users.${username}.gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
    };
  };
}
