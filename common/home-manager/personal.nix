{
  pkgs,
  username,
  ...
}:
{
  imports = [ ./default.nix ];

  home-manager = {
    users.${username} = {
      home.packages = with pkgs; [
        jellyfin-media-player
        mpv
        rustdesk
        localsend
      ];
    };
  };
}
