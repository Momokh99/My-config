{ ... }:
{
  imports = [
    ./packages.nix
    ./dotfiles.nix
    ./git.nix

  ];

  home.username = "momo";
  home.homeDirectory = "/home/momo";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.sessionPath = [ "$HOME/.local/bin" ];
}
