{ pkgs, ... }:
{
  home.packages = with pkgs; [
    basedpyright
    mypy
    pyrefly
    python3
    ruff
    ty
    uv
  ];
}
