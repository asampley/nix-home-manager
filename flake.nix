{
  description = "Home Manager configuration of asampley";

  inputs = {
    # All settings have been merged into a different repository
    asampley = {
      url = "github:asampley/nix-config";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    inputs:
    inputs.asampley.inputs.flake-parts.lib.mkFlake { inherit inputs; } (top: {
      flake = {
        legacyPackages = inputs.asampley.legacyPackages;
      };
      systems = import inputs.asampley.inputs.systems;
    });
}
