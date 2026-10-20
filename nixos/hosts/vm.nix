{ lib, pkgs, ... }:
{
  imports = [
    ../modules/common.nix
    ../modules/desktop.nix
  ] ++ lib.optional (builtins.pathExists ./vm-hardware.nix) ./vm-hardware.nix;

  networking.hostName = "nixos-vm";

  # Minimal disk layout for `build-vm`; the qemu-vm module supplies the actual
  # image and overrides the boot loader device.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # The dotfiles module links to ~/Projects/My-config. In the VM that repo is
  # not present, so copy the flake source there on first boot.
  system.activationScripts.copyRepo = {
    deps = [ "users" ];
    text = ''
      if [ ! -e /home/momo/Projects/My-config ]; then
        mkdir -p /home/momo/Projects
        cp -a ${../..} /home/momo/Projects/My-config
        chmod -R u+w /home/momo/Projects/My-config
        chown -R momo:users /home/momo/Projects/My-config
      fi
    '';
  };

  environment.systemPackages = [ pkgs.firefox ];
}
