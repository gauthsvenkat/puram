{
  pkgs,
  username,
  ...
}:
{
  imports = [ ./default.nix ];

  home-manager = {
    users.${username} = {
      programs = {
        ripgrep.enable = true;
      };
      home.packages = with pkgs; [
        # needed for non-wezterm terminals
        meslo-lgs-nf
        # needed for neovim (and friends) among other things
        gcc
        cmake
        gnumake
        python3
        nodejs
        rustup
        wl-clipboard-rs
        # other useful tools
        wezterm
        vscode
        uv
        kdePackages.yakuake
        cargo-generate
        spotify
        neovide
      ];

      home.file."/home/${username}/.config/yakuakerc".text = ''
        [Desktop Entry]
        DefaultProfile=default.profile

        [Dialogs]
        FirstRun=false

        [Shortcuts]
        new-session=Alt+T
        next-session=Alt+N
        next-terminal=Alt+L
        previous-session=Alt+B
        previous-terminal=Alt+H
        split-left-right=Alt+P

        [Window]
        KeepOpen=false
      '';

      xdg.autostart = {
        enable = true;
        entries = [
          "${pkgs.kdePackages.yakuake}/share/applications/org.kde.yakuake.desktop"
        ];
      };
    };
  };
}
