{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.my.games = {
    enable = lib.mkEnableOption "Games";
  };

  config = lib.mkIf config.my.games.enable {
    home.packages = with pkgs; [
      prismlauncher
    ];
  };
}
