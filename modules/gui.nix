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
      dconf
      dex
      discord
      firefox
      kdePackages.kdenlive
      kitty
      libreoffice
      vlc
    ];

    gtk = {
      enable = true;
      theme = {
        package = pkgs.rose-pine-gtk-theme;
        name = "rose-pine";
      };
      iconTheme = {
        package = pkgs.rose-pine-icon-theme;
        name = "rose-pine";
      };
    };

    programs.obs-studio = {
      enable = true;
      plugins = [
        pkgs.obs-studio-plugins.obs-pipewire-audio-capture
      ];
    };
  };
}
