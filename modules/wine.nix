{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.wine.enable = lib.mkEnableOption "wine configuration";
  };

  config = lib.mkIf config.my.wine.enable {
    home.packages = with pkgs; [
      (wineWowPackages.full.override {
        wineRelease = "staging";
        mingwSupport = true;
      })
      winetricks
    ];
  };
}
