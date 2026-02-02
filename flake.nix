{
  description = "Home Manager configuration of asampley";

  inputs = {
    systems = {
      url = ./systems.nix;
      flake = false;
    };

    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Unified style settings for many programs
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
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
            # Home configurations defined as legacy packages to allow having a default for all systems.
            #
            # Currently it seemse like legacyPackages is checked first for a valid configuration, so all must be here.
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
                      inputs.stylix.homeModules.stylix
                      default
                      games
                      gui
                      gui-notify
                      podman
                      stylix
                      systemd-templates
                      wayland
                      wine
                    ];
                  };
                  "asampley@miranda" = {
                    inherit pkgs;
                    modules = with self.homeModules; [
                      inputs.stylix.homeModules.stylix
                      default
                      games
                      gui
                      gui-notify
                      nextcloud
                      podman
                      stylix
                      systemd-templates
                      wayland
                      wine
                    ];
                  };
                };
          };
        };
    });
}
