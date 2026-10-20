{ ... }:
{
  imports = [
    ../../modules/common.nix
    ../../modules/desktop.nix
    ../../modules/browser.nix
    ../../modules/thinkpad.nix
    ./hardware.nix
    ./storage.nix
  ];

  networking.hostName = "x280";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [ "quiet" "udev.log_level=3" ];

  users.users.momo.extraGroups = [ "docker" "libvirtd" "kvm" "video" ];
  users.groups.kvm = { };
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
}
