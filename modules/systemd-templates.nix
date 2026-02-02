{ lib, ... }:
let
  shared-options =
    with lib;
    with types;
    {
      my.systemd-templates = {
        on-failure = mkOption {
          type = submodule {
            options = {
              enable = mkEnableOption "add on-failure systemd service" // {
                default = true;
              };
              script = mkOption {
                type = lines;
                description = "script to run on tasks with this failure task assigned";
                example = "\${pkgs.libnotify}/bin/notify-send \"$1 failed\"";
                default = "";
              };
            };
          };
          default = { };
        };
        on-success = mkOption {
          type = submodule {
            options = {
              enable = mkEnableOption "add on-failure systemd service" // {
                default = true;
              };
              script = mkOption {
                type = lines;
                description = "script to run on tasks with this failure task assigned";
                example = "\${pkgs.libnotify}/bin/notify-send \"$1 succeeded\"";
                default = "";
              };
            };
          };
          default = { };
        };
      };
    };
  shared-services = { config, pkgs }:
    let
      cfg = config.my.systemd-templates;
    in
      lib.mkMerge [
        (lib.mkIf cfg.on-failure.enable {
          "on-failure@" = {
            Unit = {
              Description = "runs a script indicating %i has failed";
            };

            Service = {
              ExecStart = "${pkgs.writeShellScript "on-failure" cfg.on-failure.script} %i";
            };
          };
        })
        (lib.mkIf cfg.on-success.enable {
          "on-success@" = {
            Unit = {
              Description = "runs a script indicating %i has succeeded";
            };

            Service = {
              ExecStart = "${pkgs.writeShellScript "on-success" cfg.on-success.script} %i";
            };
          };
        })
      ];
in
{
  flake.nixosModules.systemd-templates =
    { config, pkgs, ... }:
    {
      options = shared-options;
      config.systemd.services = shared-services { inherit config pkgs; };
    };

  flake.homeModules.systemd-templates =
    { config, pkgs, ... }:
    {
      options = shared-options;
      config = {
          systemd.user.services = shared-services { inherit config pkgs; };
      };
    };
}
