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
        ref.url = "https://api.ref.tools/mcp";

        markitdown = {
          command = uvx;
          args = [ "markitdown-mcp" ];
        };
      };
  };
}
