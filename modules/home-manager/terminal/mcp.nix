{ lib, pkgs, ... }:
{
  programs.mcp = {
    enable = true;

    servers =
      let
        uvx = lib.getExe' pkgs.uv "uvx";
      in
      {
        context7.url = "https://mcp.context7.com/mcp";
        gitmcp.url = "https://gitmcp.io/docs";
        ref.url = "https://api.ref.tools/mcp";

        fetch = {
          command = uvx;
          args = [ "mcp-server-fetch" ];
        };

        time = {
          command = uvx;
          args = [ "mcp-server-time" ];
        };
      };
  };
}
