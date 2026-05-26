local wezterm = require("wezterm")
local act = wezterm.action

wezterm.on("update-right-status", function(window)
  local name = window:active_key_table()
  if name then
    name = "TABLE: " .. name
  end
  window:set_right_status(name or "")
end)

return {
  audible_bell = "Disabled",
  warn_about_missing_glyphs = false,

  font_size = (wezterm.target_triple == "aarch64-apple-darwin") and 16 or 12,

  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  tab_and_split_indices_are_zero_based = true,

  window_background_opacity = 0.9,

  keys = {
    -- Spawning new tabs
    {
      key = "t",
      mods = "CTRL|ALT",
      action = act.SpawnTab("DefaultDomain"),
    },
    -- Split panes
    {
      key = "s",
      mods = "CTRL|ALT",
      action = act.SplitPane({ direction = "Down", size = { Percent = 25 } }),
    },
    {
      key = "v",
      mods = "CTRL|ALT",
      action = act.SplitPane({ direction = "Right" }),
    },
    -- Navigating tabs
    {
      key = "n",
      mods = "CTRL|ALT",
      action = act.ActivateTabRelative(1),
    },
    {
      key = "b",
      mods = "CTRL|ALT",
      action = act.ActivateTabRelative(-1),
    },
    -- Navigating panes
    {
      key = "h",
      mods = "CTRL|ALT",
      action = act.ActivatePaneDirection("Left"),
    },
    {
      key = "j",
      mods = "CTRL|ALT",
      action = act.ActivatePaneDirection("Down"),
    },
    {
      key = "k",
      mods = "CTRL|ALT",
      action = act.ActivatePaneDirection("Up"),
    },
    {
      key = "l",
      mods = "CTRL|ALT",
      action = act.ActivatePaneDirection("Right"),
    },
    {
      key = "f",
      mods = "CTRL|ALT",
      action = act.PaneSelect({ mode = "Activate" }),
    },
    -- Closing panes
    {
      key = "d",
      mods = "CTRL|ALT",
      action = act.CloseCurrentPane({ confirm = true }),
    },
    -- Moving panes
    {
      key = "m",
      mods = "CTRL|ALT",
      action = act.ActivateKeyTable({
        name = "rotate_pane",
        one_shot = false,
      }),
    },
    -- Misc
    {
      key = "Enter",
      mods = "CTRL|ALT",
      action = act.ActivateCommandPalette,
    },
  },
  mouse_bindings = {
    {
      event = { Up = { streak = 1, button = "Right" } },
      mods = "NONE",
      action = act.PasteFrom("Clipboard"),
    },
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = act.OpenLinkAtMouseCursor,
    },
  },
}
