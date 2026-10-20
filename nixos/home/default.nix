{ ... }:
{
  imports = [
    ./packages.nix
    ./dotfiles.nix
  ];

  home.username = "momo";
  home.homeDirectory = "/home/momo";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "helium";
  };
}
