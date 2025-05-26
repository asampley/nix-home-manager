{
  description = "Home Manager configuration of asampley";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    systems = {
      url = ./systems.nix;
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Unified style settings for many programs
    stylix.url = "github:danth/stylix";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      home-manager,
      stylix,
      ...
    }:
    {
      homeModules = {
        # Fallback system that assumes no features available
        "asampley" = { };

        # Home computer with additional features
        "asampley@amanda" = {
          config.my.gui.enable = true;
          config.my.x.enable = true;
          config.my.wine.enable = true;
        };
      };

      formatter = nixpkgs.lib.genAttrs (import systems) (
        system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );

      # Using packages.${system}.homeConfigurations allows us to build for many targets
      packages = nixpkgs.lib.genAttrs (import systems) (system: {
        homeConfigurations = builtins.mapAttrs (
          name: value:
          home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${system};

            modules = [
              ./home.nix
              stylix.homeModules.stylix
              value
            ];
          }
        ) self.homeModules;
      });
    };
}
