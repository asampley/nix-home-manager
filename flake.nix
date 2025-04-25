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
  };

  outputs = { nixpkgs, systems, home-manager, ... }: {
    # Using packages.${system}.homeConfigurations allows us to build for many targets
    packages = let
      # Specify your home configuration modules here, for example, the path to your home.nix.
      modules = [ ./home.nix ];

      # Optionally use extraSpecialArgs to pass through arguments to home.nix
      extraSpecialArgs = {
        gui = false;
        x = false;
        wine = false;
      };
    in nixpkgs.lib.genAttrs (import systems) (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in rec {
      # Fallback system that assumes no features available
      homeConfigurations."asampley" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs modules extraSpecialArgs;
      };

      # Home computer with additional features
      homeConfigurations."asampley@amanda" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs modules;

        extraSpecialArgs = extraSpecialArgs // {
          gui = true;
          x = true;
          wine = true;
        };
      };
    });
  };
}
