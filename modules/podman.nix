{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.my.podman = {
    enable = lib.mkEnableOption "podman support";
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
    lib.mkIf cfg.enable {
      home.packages = with pkgs; lib.optionals cfg.compose [ podman-compose ]
        ++ lib.optionals cfg.dockerCompat [
          (pkgs.writeShellScriptBin "docker" "exec -a $0 ${pkgs.podman}/bin/podman \"$@\"")
        ];

      services.podman = {
        enable = true;
      };

      home.sessionVariables = lib.mkIf cfg.compose {
        PODMAN_COMPOSE_PROVIDER = "podman-compose";
      };
    };
}
