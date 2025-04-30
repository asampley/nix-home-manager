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
      libreoffice
      vlc
    ];

    programs.kitty = {
      enable = true;
    };

    programs.obs-studio = {
      enable = true;
      plugins = [
        pkgs.obs-studio-plugins.obs-pipewire-audio-capture
      ];
    };
  };
}
