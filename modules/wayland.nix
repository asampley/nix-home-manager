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
      ".config/waybar/default.jsonc".source = ../files/.config/waybar/default.jsonc;
      ".config/waybar/tablet.jsonc".source = ../files/.config/waybar/tablet.jsonc;
      # Managed by stylix
      #".config/waybar/style.css".source = ../files/.config/waybar/style.css;
    };

    home.packages = with pkgs; [
      (writeShellScriptBin "fuzzel-power-menu" (builtins.readFile ../scripts/wayland/fuzzel-power-menu))
      font-awesome
      wl-clipboard
      xwayland-satellite
    ];

    # Niri default terminal
    programs.alacritty.enable = true;

    # App launcher
    programs.fuzzel.enable = true;

    # Lock
    programs.swaylock.enable = true;

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
      };
    };

    # Notifications
    services.mako.enable = true;

    # Idle timeout
    services.swayidle = let 
      lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
      lockSecs = 900;
    in {
      enable = true;
      timeouts = [
        #{
        #  timeout = lockSecs - 60;
        #  command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
        #}
        #{
        #  timeout = lockSecs;
        #  command = lock;
        #}
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

    systemd.user.services.waybar-profile = {
      Unit = {
        Description = "profile that can be easily toggled by waybar when reloaded";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionalEnvironment = "WAYLAND_DISPLAY";
      };

      Install = {
        WantedBy = [ "graphical-session.target" "waybar.service" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = with pkgs; "${writeShellScript "waybar-profile" ''
          set -eux
          ${coreutils}/bin/ln -sf "${config.home.homeDirectory}/.config/waybar/default.jsonc" "${config.home.homeDirectory}/.config/waybar/config.jsonc"
        ''}";
      };
    };
  };
}
