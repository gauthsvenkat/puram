{ pkgs, ... }:
{
  programs.zsh.enable = true;
  users.users.ando = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$lsTOqWz/dB9pqO0pQXjKC/$si1Ef61Hnr0KsePreWy3gHqhX2dIQnDlKMyTxAeoe60";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
}
