{ inputs, ... }:
{
  imports = [ inputs.helium.nixosModules.default ];

  programs.helium = {
    enable = true;
    flags = [ "--ozone-platform-hint=auto" ];
  };
}
