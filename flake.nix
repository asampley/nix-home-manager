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

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    # Unified style settings for many programs
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (top: {
      flake = {
        homeModules = {
          games = import modules/games.nix;
          gui = import modules/gui.nix;
          nextcloud = import modules/nextcloud.nix;
          podman = import modules/podman.nix;
          wayland = import modules/wayland.nix;
          wine = import modules/wine.nix;
          x = import modules/x.nix;
        };
      };
      systems = builtins.import ./systems.nix;
      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt;
          legacyPackages = {
            homeConfigurations =
              let
                modules = [
                  ./home.nix
                  inputs.stylix.homeModules.stylix
                ]
                ++ builtins.attrValues inputs.self.homeModules;
              in
              builtins.mapAttrs (_: value: inputs.home-manager.lib.homeManagerConfiguration value) {
                "asampley" = {
                  inherit pkgs;
                  modules = modules ++ [ hosts/default.nix ];
                };
                "asampley@amanda" = {
                  inherit pkgs;
                  modules = modules ++ [ hosts/amanda.nix ];
                };
                "asampley@miranda" = {
                  inherit pkgs;
                  modules = modules ++ [ hosts/miranda.nix ];
                };
              };
          };
        };
    });
}
