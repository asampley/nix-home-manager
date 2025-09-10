{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.gui.enable = lib.mkEnableOption "gui configuration";
  };

  config = lib.mkIf config.my.gui.enable {
    home.packages = with pkgs; [
      bitwarden
      chromium
      dconf
      dex
      discord
      firefox
      inkscape
      kdePackages.kdenlive
      libreoffice
      qbittorrent
      vlc
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
}
