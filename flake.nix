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

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Prepare to merge with nix-os-config
    asampley = {
      url = "github:asampley/nix-os-config";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.import-tree.follows = "import-tree";
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
                      notifications
                      podman
                      stylix
                      wayland
                      wine
                      {
                        config.my.notifications = {
                          enable = true;
                          libnotify.enable = true;
                        };
                      }
                    ];
                  };
                  "asampley@miranda" = {
                    inherit pkgs;
                    modules =
                      with inputs.asampley.homeModules;
                      with self.homeModules;
                      [
                        inputs.sops-nix.homeModules.sops
                        inputs.stylix.homeModules.stylix
                        default
                        games
                        gui
                        nextcloud
                        nextcloud-sops
                        notifications
                        ntfy-client-sops
                        podman
                        sops
                        stylix
                        tablet
                        wayland
                        wine
                        {
                          config.my.tablet.niri = true;
                          config.my.notifications = {
                            enable = true;
                            libnotify.enable = true;
                            ntfy = {
                              enable = true;
                              address = "https://ntfy.asampley.ca";
                              sops.enable = true;
                            };
                          };
                        }
                      ];
                  };
                };
          };
        };
    });
}
