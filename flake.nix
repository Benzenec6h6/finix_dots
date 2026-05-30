{
  description = "TetoOS - finix + Home Manager";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    finix.url = "github:finix-community/finix";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    nix-cachyos-kernel,
    finix,
    disko,
    home-manager,
    sops-nix,
    nix-index-database,
    ...
  } @ inputs: let
    vars = import ./vars.nix;
    system = vars.system;

    finalPkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        nix-cachyos-kernel.overlays.default
        (final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        })
      ];
    };

    mkFinixConfig = host:
      inputs.finix.lib.finixSystem {
        lib = nixpkgs.lib;
        specialArgs = {
          inherit inputs vars;
        };
        modules = [
          # 2. Finix独自の nixpkgs モジュールに対して、上で作った完成版pkgsを直接注入する
          {
            nixpkgs.pkgs = finalPkgs;
          }
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          nix-index-database.nixosModules.default
          ./hosts/${host}
        ];
      };
  in {
    nixosConfigurations = {
      laptop = mkFinixConfig "laptop";
      vm = mkFinixConfig "vm";
    };
  };
}
