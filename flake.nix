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

    nvim-config = {
      type = "git";
      # TODO: This will simplify in 2.27
      url = "file:./files/.config/nvim";
      flake = false;
    };

    awesome-config = {
      type = "git";
      # TODO: This will simplify in 2.27
      url = "file:./files/.config/awesome";
      submodules = true;
      flake = false;
    };
  };

  outputs = { nixpkgs, systems, home-manager, nvim-config, awesome-config, ... }: {
    # Using packages.${system}.homeConfigurations allows us to build for many targets
    packages = nixpkgs.lib.genAttrs (import systems) (system: rec {
      # Fallback system that assumes no features available
      homeConfigurations."asampley" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        # Specify your home configuration modules here, for example, the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs to pass through arguments to home.nix
        extraSpecialArgs = {
          inherit nvim-config;
          inherit awesome-config;
          gui = false;
          x = false;
          wine = false;
        };
      };

      # Home computer with additional features
      homeConfigurations."asampley@amanda" = homeConfigurations."asampley" // {
        extraSpecialArgs.gui = true;
        extraSpecialArgs.x = true;
        extraSpecialArgs.wine = true;
      };
    });
  };
}
