{
  flake.homeModules.games =
    { pkgs, ... }:
    {
      config = {
        home.packages = with pkgs; [
          prismlauncher
        ];
      };
    };
}
