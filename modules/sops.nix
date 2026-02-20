{
  flake.homeModules.sops =
    { config, pkgs, ... }:
    {
      config = {
        home.packages = with pkgs; [
          age
          sops
        ];

        sops = {
          defaultSopsFile = "${config.home.homeDirectory}/.secrets/secrets.yaml";
          age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
          # runtime evaluation of files, without storing in the store
          validateSopsFiles = false;
        };
      };
    };
}
