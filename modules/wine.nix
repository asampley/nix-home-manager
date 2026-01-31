{
  flake.homeModules.wine =
    { pkgs, ... }:
    {
      config = {
        home.packages = with pkgs; [
          (wineWowPackages.full.override {
            wineRelease = "staging";
            mingwSupport = true;
          })
          winetricks
        ];
      };
    };
}
