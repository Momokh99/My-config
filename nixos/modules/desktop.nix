{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;

  # Session-critical binaries live in the system profile so they are always on
  # PATH for greetd/UWSM and for Hyprland's exec_cmd calls.
  environment.systemPackages = with pkgs; [
    waybar
    wofi
    mako
    awww
    hypridle
    hyprlock
    kitty
    yazi
    neovim
    opencode
    matugen
    impala
    bluetui
    wifitui
    (callPackage ../packages/nmtui-go.nix { })
    hyprpolkitagent
    librewolf
  ];

  # GUI polkit prompts (NetworkManager, package tools, etc.).
  systemd.user.services.hyprpolkitagent = {
    description = "Hyprland polkit agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start hyprland-uwsm.desktop'";
      user = "greeter";
    };
  };
}
