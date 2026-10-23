{
  description = "momo's NixOS + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      mkHost = modules: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = modules ++ [
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              users.momo = ./home;
            };
          }
        ];
      };
    in {
      nixosConfigurations.x280 = mkHost [
        ./modules/common.nix
        ./modules/desktop.nix
        ./modules/thinkpad.nix
        ./hardware-configuration.nix
      ];
    };
  }
