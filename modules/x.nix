{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.x.enable = lib.mkEnableOption "x11 configuration";
  };

  config = lib.mkIf config.my.x.enable {
    home.packages = with pkgs; [
      awesome
      scrot
      xclip
    ];

    home.file = {
      ".xsession".source = ../files/.xsession;
      ".xinitrc".source = ../files/.xinitrc;
      ".config/awesome".source = config.lib.file.mkOutOfStoreSymlink (
        config.home.homeDirectory + "/.config/home-manager/files/.config/awesome"
      );
    };
  };
}
