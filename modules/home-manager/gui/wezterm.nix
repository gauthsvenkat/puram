{ lib, pkgs, ... }:
{
  programs.wezterm = {
    enable = true;

    settings =
      let
        inherit (lib.generators) mkLuaInline;
      in
      {
        audible_bell = "Disabled";
        warn_about_missing_glyphs = false;

        font_size = if pkgs.stdenv.isDarwin then 16 else 12;

        hide_tab_bar_if_only_one_tab = true;
        tab_and_split_indices_are_zero_based = true;
        use_fancy_tab_bar = false;

        window_background_opacity = 0.9;

        keys = [
          # tabs
          {
            key = "t";
            mods = "CTRL|ALT";
            action = mkLuaInline ''wezterm.action.SpawnTab("DefaultDomain")'';
          }
          {
            key = "n";
            mods = "CTRL|ALT";
            action = mkLuaInline "wezterm.action.ActivateTabRelative(1)";
          }
          {
            key = "b";
            mods = "CTRL|ALT";
            action = mkLuaInline "wezterm.action.ActivateTabRelative(-1)";
          }
          {
            key = "n";
            mods = "CTRL|ALT|SHIFT";
            action = mkLuaInline "wezterm.action.MoveTabRelative(1)";
          }
          {
            key = "b";
            mods = "CTRL|ALT|SHIFT";
            action = mkLuaInline "wezterm.action.MoveTabRelative(-1)";
          }

          # panes
          {
            key = "s";
            mods = "CTRL|ALT";
            action = mkLuaInline ''wezterm.action.SplitPane({ direction = "Down", size = { Percent = 40 } })'';
          }
          {
            key = "v";
            mods = "CTRL|ALT";
            action = mkLuaInline ''wezterm.action.SplitPane({ direction = "Right" })'';
          }
          {
            key = "h";
            mods = "CTRL|ALT";
            action = mkLuaInline ''wezterm.action.ActivatePaneDirection("Left")'';
          }
          {
            key = "j";
            mods = "CTRL|ALT";
            action = mkLuaInline ''wezterm.action.ActivatePaneDirection("Down")'';
          }
          {
            key = "k";
            mods = "CTRL|ALT";
            action = mkLuaInline ''wezterm.action.ActivatePaneDirection("Up")'';
          }
          {
            key = "l";
            mods = "CTRL|ALT";
            action = mkLuaInline ''wezterm.action.ActivatePaneDirection("Right")'';
          }
          {
            key = "f";
            mods = "CTRL|ALT";
            action = mkLuaInline ''wezterm.action.PaneSelect({ mode = "Activate" })'';
          }
          {
            key = "d";
            mods = "CTRL|ALT";
            action = mkLuaInline "wezterm.action.CloseCurrentPane({ confirm = true })";
          }
          {
            key = "f";
            mods = "CTRL|ALT|SHIFT";
            action = mkLuaInline ''wezterm.action.PaneSelect({ mode = "SwapWithActive" })'';
          }

          # misc
          {
            key = "Enter";
            mods = "CTRL|ALT";
            action = mkLuaInline "wezterm.action.ActivateCommandPalette";
          }
        ];

        mouse_bindings = [
          {
            event.Up = {
              streak = 1;
              button = "Right";
            };
            mods = "NONE";
            action = mkLuaInline ''wezterm.action.PasteFrom("Clipboard")'';
          }
          {
            event.Up = {
              streak = 1;
              button = "Left";
            };
            mods = "CTRL|ALT";
            action = mkLuaInline "wezterm.action.OpenLinkAtMouseCursor";
          }
        ];
      };
  };
}
