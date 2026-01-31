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

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # Unified style settings for many programs
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (top: {
      imports = [
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./modules)
      ];
      systems = import ./systems.nix;
      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt;
          legacyPackages = {
            homeConfigurations =
              builtins.mapAttrs (_: value: inputs.home-manager.lib.homeManagerConfiguration value)
                {
                  "asampley" = {
                    inherit pkgs;
                    modules = with self.homeModules; [
                      default
                    ];
                  };
                  "asampley@amanda" = {
                    inherit pkgs;
                    modules = with self.homeModules; [
                      default
                      games
                      gui
                      podman
                      stylix
                      wayland
                      wine
                    ];
                  };
                  "asampley@miranda" = {
                    inherit pkgs;
                    modules = with self.homeModules; [
                      default
                      games
                      gui
                      podman
                      stylix
                      wayland
                      wine
                    ];
                  };
                };
          };
        };
    });
}
