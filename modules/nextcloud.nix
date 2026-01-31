{
  flake.homeModules.nextcloud =
    { config, ... }:
    {
      config = {
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
                pass = "${config.home.homeDirectory}/secrets/nextcloud";
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
}
