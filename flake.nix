{
  description = "momo's NixOS + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      mkHost = modules: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              users.momo = import ./nixos/home;
            };
          }
        ] ++ modules;
      };
    in
    {
      nixosConfigurations = {
        vm = mkHost [ ./nixos/hosts/vm.nix ];

        x280 = mkHost [
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x280
          ./nixos/hosts/x280
        ];

        # Live/installer image: nix build .#nixosConfigurations.iso.config.system.build.isoImage
        iso = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./nixos/hosts/iso.nix ];
        };
      };
    };
}
