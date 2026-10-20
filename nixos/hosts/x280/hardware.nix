# Hardware for the ThinkPad X280 (20KES4BT1K).
# Kept minimal on purpose: storage/LUKS lives in ./storage.nix, so there is no
# generated hardware-configuration.nix to keep in sync after reinstalls.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "iwlwifi" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
