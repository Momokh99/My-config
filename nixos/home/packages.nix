{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alacritty
    fastfetch
    tmux
    lazygit
    btop
    imagemagick

    ripgrep
    fd
    fzf
    bat
    eza
    zoxide
    jq
    yq-go
    tree

    libsForQt5.qt5ct
    qt6Packages.qt6ct

    libinput
  ];
}
