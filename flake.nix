{
  description = "Work NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my-neovim = {
      url = "github:lbarraga/neovim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
  let
    import-tree = import ./import-tree.nix;
  in
  {
    nixosConfigurations.work = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        (import-tree ./modules)
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.lukasbt = import-tree ./home;
        }
      ];
    };
  };
}
