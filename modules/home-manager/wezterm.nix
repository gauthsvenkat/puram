{ lib, ... }:
{
  programs.wezterm = {
    enable = true;

    # HACK: the default `hyperlink_rules` keep a trailing `)` on links in nested parentheses
    # (https://github.com/wezterm/wezterm/issues/3803). The `open-uri` handler strips
    # trailing punctuation and opens the cleaned link; when nothing is stripped, it
    # returns nothing and WezTerm opens the link as usual.
    #
    # https://wezterm.org/config/lua/window-events/open-uri.html
    # https://www.lua.org/manual/5.4/manual.html#6.4
    extraConfig = ''
      wezterm.on("open-uri", function(_, _, uri)
        local trailing = uri:find("(", 1, true) and "[.,;:]+$" or "[).,;:]+$"
        local cleaned = uri:gsub(trailing, "")
        if cleaned ~= uri then
          wezterm.open_with(cleaned)
          return false
        end
      end)
    '';

    settings =
      let
        inherit (lib.generators) mkLuaInline;
      in
      {
        audible_bell = "Disabled";
        warn_about_missing_glyphs = false;

        font_size = 12;

        hide_tab_bar_if_only_one_tab = true;
        tab_and_split_indices_are_zero_based = true;
        use_fancy_tab_bar = false;

        keys =
          let
            mkKey = mods: key: action: {
              inherit key mods;
              action = mkLuaInline "wezterm.action.${action}";
            };
          in
          [
            # tabs
            (mkKey "CTRL|ALT" "t" ''SpawnTab("DefaultDomain")'')
            (mkKey "CTRL|ALT" "n" "ActivateTabRelative(1)")
            (mkKey "CTRL|ALT" "b" "ActivateTabRelative(-1)")
            (mkKey "CTRL|ALT|SHIFT" "n" "MoveTabRelative(1)")
            (mkKey "CTRL|ALT|SHIFT" "b" "MoveTabRelative(-1)")

            # panes
            (mkKey "CTRL|ALT" "s" ''SplitPane({ direction = "Down", size = { Percent = 40 } })'')
            (mkKey "CTRL|ALT" "v" ''SplitPane({ direction = "Right" })'')
            (mkKey "CTRL|ALT" "h" ''ActivatePaneDirection("Left")'')
            (mkKey "CTRL|ALT" "j" ''ActivatePaneDirection("Down")'')
            (mkKey "CTRL|ALT" "k" ''ActivatePaneDirection("Up")'')
            (mkKey "CTRL|ALT" "l" ''ActivatePaneDirection("Right")'')
            (mkKey "CTRL|ALT" "f" ''PaneSelect({ mode = "Activate" })'')
            (mkKey "CTRL|ALT" "d" "CloseCurrentPane({ confirm = true })")
            (mkKey "CTRL|ALT|SHIFT" "f" ''PaneSelect({ mode = "SwapWithActive" })'')

            # misc
            (mkKey "CTRL|ALT" "Enter" "ActivateCommandPalette")
          ];

        mouse_bindings = [
          {
            event.Up = {
              button = "Right";
              streak = 1;
            };
            mods = "NONE";
            action = mkLuaInline ''wezterm.action.PasteFrom("Clipboard")'';
          }
          {
            event.Up = {
              button = "Left";
              streak = 1;
            };
            mods = "CTRL|ALT";
            action = mkLuaInline "wezterm.action.OpenLinkAtMouseCursor";
          }
        ];

        window_background_opacity = 0.9;
      };
  };
}
