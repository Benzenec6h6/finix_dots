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
    finix, # ★ 忘れずにここに明示（...に含まれますが、明示すると見やすいです）
    disko,
    home-manager,
    sops-nix,
    nix-index-database,
    ...
  } @ inputs: let
    vars = import ./vars.nix;
    system = vars.system;

    mkFinixConfig = host:
    # ★ 修正：nixpkgs からではなく、inputs.finix から lib.finixSystem を呼び出す
      inputs.finix.lib.finixSystem {
        lib = nixpkgs.lib; # ★ 修正：Finixの評価エンジンに実際のlibを明示的に渡す
        specialArgs = {
          inherit inputs vars;
        };
        modules = [
          {
            nixpkgs.hostPlatform = system;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              nix-cachyos-kernel.overlays.default
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  system = prev.stdenv.hostPlatform.system;
                  config.allowUnfree = true;
                };
              })
            ];
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
