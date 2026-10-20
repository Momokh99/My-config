{ modulesPath, pkgs, lib, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  system.stateVersion = lib.mkDefault "25.11";

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    cryptsetup
    btrfs-progs
    gptfdisk
    dosfstools
    util-linux
  ];
}
