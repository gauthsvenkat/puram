{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./home-manager.nix
    ./gui.nix
  ];

  home-manager = {
    users.${username} = {
      home.packages = with pkgs; [
        # needed for non-wezterm terminals
        meslo-lgs-nf
        # needed for neovim (and friends) among other things
        unzip
        gcc
        cmake
        gnumake
        python3
        nodejs
        ripgrep
        # TODO: Figure out how to install rust toolchain without rustup
        rustup
        wl-clipboard-rs
        nixfmt-rfc-style
        # other useful tools
        uv
        pre-commit
        cargo-generate
        # TODO: Figure out how to fetch wezterm confirm from github
        # TODO: also for neovim
        wezterm
        vscode
        kdePackages.yakuake
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

      xdg.autostart.entries = [
        "${pkgs.kdePackages.yakuake}/share/applications/org.kde.yakuake.desktop"
      ];
    };
  };
}
