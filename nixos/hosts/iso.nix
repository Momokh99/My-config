{ modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

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
