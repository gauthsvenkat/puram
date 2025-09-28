# Common workstation imports that I want on both nixos and darwin systems.
# This includes development tools and terminal utilities used across platforms.
{
  imports = [
    ../../modules/common/development/lua.nix
    ../../modules/common/development/misc.nix
    ../../modules/common/development/nix.nix
    ../../modules/common/development/python.nix
    ../../modules/common/development/rust.nix

    ../../modules/common/terminal/aider.nix
    ../../modules/common/terminal/bat.nix
    ../../modules/common/terminal/btop.nix
    ../../modules/common/terminal/claude-code.nix
    ../../modules/common/terminal/direnv.nix
    ../../modules/common/terminal/eza.nix
    ../../modules/common/terminal/fastfetch.nix
    ../../modules/common/terminal/fzf.nix
    ../../modules/common/terminal/gemini-cli.nix
    ../../modules/common/terminal/git.nix
    ../../modules/common/terminal/just.nix
    ../../modules/common/terminal/lazygit.nix
    ../../modules/common/terminal/mcfly.nix
    ../../modules/common/terminal/neovim.nix
    ../../modules/common/terminal/nh.nix
    ../../modules/common/terminal/pre-commit.nix
    ../../modules/common/terminal/spotify-player.nix
    ../../modules/common/terminal/utils.nix
    ../../modules/common/terminal/zoxide.nix
    ../../modules/common/terminal/zsh.nix

    ./system.nix
  ];
}
