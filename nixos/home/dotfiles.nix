{ config, pkgs, ... }:
let
  repo = "${config.home.homeDirectory}/Projects/My-config";

  # Live symlink into the repo: edits stay editable and matugen can keep
  # writing generated colours into these directories.
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";

  # Repo scripts use `#!/usr/bin/env bash`, which does not exist on NixOS.
  # Wrap them instead of linking so the shebang is always valid.
  script = name: file: pkgs.writeShellScript name ''
    exec ${pkgs.bash}/bin/bash ${repo}/${file} "$@"
  '';
in
{
  # Whole directories: Hyprland's Lua config requires modules/ and colors.lua.
  xdg.configFile."hypr".source = link "hypr";
  xdg.configFile."waybar".source = link "waybar";
  xdg.configFile."wofi".source = link "wofi";
  xdg.configFile."wofi-power".source = link "wofi-power";
  xdg.configFile."wofi-screenshot".source = link "wofi-screenshot";
  xdg.configFile."wofi-wallpaper".source = link "wofi-wallpaper";
  xdg.configFile."mako".source = link "mako";
  xdg.configFile."kitty".source = link "kitty";
  xdg.configFile."alacritty".source = link "alacritty";
  xdg.configFile."yazi".source = link "yazi";
  xdg.configFile."nvim".source = link "nvim";
  xdg.configFile."matugen".source = link "matugen";
  xdg.configFile."gtk-3.0".source = link "gtk-3.0";
  xdg.configFile."gtk-4.0".source = link "gtk-4.0";
  xdg.configFile."qt5ct".source = link "qt5ct";
  xdg.configFile."qt6ct".source = link "qt6ct";
  xdg.configFile."kdeglobals".source = link "kdeglobals";
  xdg.configFile."fastfetch".source = link "fastfetch";

  home.file.".zshrc".source = link ".zshrc";
  home.file.".tmux.conf".source = link "tmux/.tmux.conf";

  home.file.".local/bin/wofi-power".source = script "wofi-power" "wofi-power.sh";
  home.file.".local/bin/wofi-screenshot".source = script "wofi-screenshot" "wofi-screenshot.sh";
  home.file.".local/bin/wofi-wallpaper".source = script "wofi-wallpaper" "wofi-wallpaper.sh";
  home.file.".local/bin/set-theme".source = script "set-theme" "set-theme.sh";
}
