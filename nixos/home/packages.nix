{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alacritty
    fastfetch
    tmux
    lazygit
    btop
    imagemagick
    nodejs
    ripgrep
    fd
    fzf
    bat
    eza
    zoxide
    jq
    yq-go
    tree

    osu-lazer-bin
    libsForQt5.qt5ct
    qt6Packages.qt6ct

    libinput
  ];
}
