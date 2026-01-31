{ moduleWithSystem, ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      packages.docker = (pkgs.writeShellScriptBin "docker" "exec -a $0 ${pkgs.podman}/bin/podman \"$@\"");
    };

  flake.homeModules.podman = moduleWithSystem (
    { self', ... }:
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.my.podman = {
        compose = lib.mkEnableOption "podman compose support" // {
          default = true;
        };
        dockerCompat = lib.mkEnableOption "docker executable linked to podman" // {
          default = true;
        };
      };

      config =
        let
          cfg = config.my.podman;
        in
        {
          home.packages =
            with pkgs;
            lib.optionals cfg.compose [ podman-compose ]
            ++ lib.optionals cfg.dockerCompat [ self'.packages.docker ];

          services.podman = {
            enable = true;
          };

          home.sessionVariables = lib.mkIf cfg.compose {
            PODMAN_COMPOSE_PROVIDER = "podman-compose";
          };
        };
    }
  );
}
