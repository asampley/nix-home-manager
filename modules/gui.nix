{
  flake.homeModules.gui =
    {
      lib,
      pkgs,
      ...
    }:
    {
      config = {
        home.packages = with pkgs; [
          bitwarden-desktop
          chromium
          dconf
          dex
          discord
          firefox
          gnome-network-displays
          inkscape
          kdePackages.kdenlive
          libreoffice
          mpv
          qbittorrent
          thunar
          xournalpp
        ];

        programs.alacritty = {
          enable = true;
        };

        programs.obs-studio = {
          enable = true;
          plugins = [
            pkgs.obs-studio-plugins.obs-pipewire-audio-capture
          ];
        };

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = lib.mkForce "prefer-dark";
          };
        };

        fonts.fontconfig.enable = true;
      };
    };

  # Requires systemd-templates, so separated out
  flake.homeModules.gui-notify =
    { pkgs, ... }:
    {
      my.systemd-templates = {
        on-failure.script = ''
          unit=$1
          ${pkgs.libnotify}/bin/notify-send "$unit service failed." --urgency critical;
        '';
        on-success.script = ''
          unit=$1
          ${pkgs.libnotify}/bin/notify-send "$unit service succeeded.";
        '';
      };
    };
}
