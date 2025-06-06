{
  pkgs,
  username,
  ...
}: {
  # to add `~/.local/bin` to PATH
  environment.localBinInPath = true;

  home-manager.users.${username}.home = {
    #NOTE: By default only NIX_SSL_CERT_FILE is set. Better to set
    # the following to make non-nix programs work as well. For e.g.
    # compiling with rust.
    sessionVariables.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      gnumake
      ripgrep
      fd
      rustup
      cargo-generate
      uv
      pre-commit
      libqalculate
    ];
  };
}
