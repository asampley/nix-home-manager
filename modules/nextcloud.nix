{ lib, ... }:
{
  flake.homeModules.nextcloud =
    { config, ... }:
    {
      options.my.nextcloud = with lib; {
        passFile = mkOption {
          type = types.str;
          default = "${config.home.homeDirectory}/secrets/nextcloud";
        };
      };
      config = 
        let
          cfg = config.my.nextcloud;
        in
          {
            # rclone creates cached fuse mounts for webdav
            programs.rclone = {
              enable = true;
              remotes = {
                nextcloud = {
                  config = {
                    type = "webdav";
                    url = "https://cloud.asampley.ca/remote.php/dav/files/asampley";
                    vendor = "nextcloud";
                    user = "asampley";
                  };
                  secrets = {
                    pass = cfg.passFile;
                  };
                  mounts = {
                    "/" = {
                      enable = true;
                      mountPoint = "${config.home.homeDirectory}/nextcloud";
                      options = {
                        dir-cache-time = "10m";
                        poll-interval = "10s";
                      };
                    };
                  };
                };
              };
            };
          };
    };

  flake.homeModules.nextcloud-sops =
    { config, ... }:
    {
      sops.secrets.nextcloud = { };
      my.nextcloud.passFile = config.sops.secrets.nextcloud.path;
    };
}
