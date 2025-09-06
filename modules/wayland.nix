{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    my.wayland.enable = lib.mkEnableOption "wayland configuration";
  };

  config = lib.mkIf config.my.wayland.enable {
    home.file = {
      ".config/niri".source = ../files/.config/niri;
    };

    home.packages = with pkgs; [
      wl-clipboard
      xwayland-satellite
    ];

    # Niri default terminal
    programs.alacritty.enable = true;

    # App launcher
    programs.fuzzel.enable = true;

    # Lock
    programs.swaylock.enable = true;

    # Notifications
    services.mako.enable = true;

    # Idle timeout
    services.swayidle = let 
      lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
      lockSecs = 900;
    in {
      enable = true;
      timeouts = [
        {
          timeout = lockSecs - 60;
          command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
        }
        {
          timeout = lockSecs;
          command = lock;
        }
      ];
      events = [
        {
          event = "before-sleep";
          command = lock;
        }
        {
          event = "lock";
          command = lock;
        }
      ];
    };

    services.polkit-gnome.enable = true;
  };
}
