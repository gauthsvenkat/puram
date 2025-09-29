{
  config,
  ...
}:
let
  inherit (config.hostCfg) username;
  inherit (config.hyprVars) wezterm;
in
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings =
    let
      dropDownTermCls = "dropdown-terminal";
    in
    {
      bind = [ ", F12, togglespecialworkspace, ${dropDownTermCls}" ];

      windowrule = [
        "float, class:^(${dropDownTermCls})$"
        "size 75% 45%, class:^(${dropDownTermCls})$"
        "move 12.5% 2%, class:^(${dropDownTermCls})$"
        "workspace special:${dropDownTermCls}, class:^(${dropDownTermCls})$"
      ];

      workspace = [
        "special:${dropDownTermCls}, gapsout:20, gapsin:10, on-created-empty:${wezterm} start --class ${dropDownTermCls}"
      ];
    };
}
