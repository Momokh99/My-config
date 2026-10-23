{ pkgs, ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "momo" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
  time.timeZone = "Africa/Casablanca";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  networking.hostName = "x280";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  programs.zsh.enable = true;
  programs.dconf.enable = true;

  # Backlight writes need the brightnessctl udev rule plus the video group.
  services.udev.packages = [ pkgs.brightnessctl ];
  services.fstrim.enable = true;

  users.users.momo = {
    isNormalUser = true;
    description = "momo";
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "nixos"; # change with `passwd` after first login
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = true;
  security.polkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.pulseaudio.enable = false;

  services.upower.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };
  hardware.enableRedistributableFirmware = true;
  zramSwap.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
  ];

  # Set here (not in Home Manager) so graphical sessions launched by greetd
  # get them too, not just login shells.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "librewolf";
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    htop
    tree
    pciutils
    usbutils
    wl-clipboard
    grim
    slurp
    libnotify
    brightnessctl
    playerctl
    zsh
    bibata-cursors
    glib # provides gsettings, used by matugen's post-hook
  ];
}
