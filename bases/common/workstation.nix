# Common workstation imports that I want on both nixos and darwin systems.
# This includes development tools and terminal utilities used across platforms.
{
  imports = [
    ../../components/common/development/lua.nix
    ../../components/common/development/misc.nix
    ../../components/common/development/nix.nix
    ../../components/common/development/python.nix
    ../../components/common/development/rust.nix

    ../../components/common/terminal/aider.nix
    ../../components/common/terminal/bat.nix
    ../../components/common/terminal/btop.nix
    ../../components/common/terminal/claude-code.nix
    ../../components/common/terminal/direnv.nix
    ../../components/common/terminal/eza.nix
    ../../components/common/terminal/fastfetch.nix
    ../../components/common/terminal/fzf.nix
    ../../components/common/terminal/gemini-cli.nix
    ../../components/common/terminal/git.nix
    ../../components/common/terminal/just.nix
    ../../components/common/terminal/lazygit.nix
    ../../components/common/terminal/mcfly.nix
    ../../components/common/terminal/neovim.nix
    ../../components/common/terminal/nh.nix
    ../../components/common/terminal/pre-commit.nix
    ../../components/common/terminal/spotify-player.nix
    ../../components/common/terminal/utils.nix
    ../../components/common/terminal/zoxide.nix
    ../../components/common/terminal/zsh.nix

    ./system.nix
  ];
}
