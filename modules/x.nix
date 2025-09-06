{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.x = {
    enable = lib.mkEnableOption "x11 configuration";
  };

  config = lib.mkIf config.my.x.enable {
    home.packages = with pkgs; [
      awesome
      scrot
      xclip
      xss-lock
    ];

    home.file = {
      ".xsession".source = ../files/.xsession;
      ".xinitrc".source = ../files/.xinitrc;
      ".config/awesome".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/files/.config/awesome";
    };

    systemd.user.services.xautolock-session = {
      Unit = {
        Description = "xautolock, session locker service";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.xautolock}/bin/xautolock"
          "-time 10"
          "-locker '${pkgs.systemd}/bin/loginctl lock-session \${XDG_SESSION_ID}'"
          "-detectsleep"
          "-corners -0-0"
        ];
        Restart = "always";
      };
    };
  };
}
