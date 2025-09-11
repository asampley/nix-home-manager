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

      # Managed by stylix
      #".config/waybar/style.css".source = ../files/.config/waybar/style.css;
    } // (let
      entries = builtins.readDir ../files/.config/waybar;
      names = builtins.attrNames entries;
    in
        builtins.listToAttrs (
        map (name: {
          name = ".config/waybar/${name}";
          value = { source = ../files/.config/waybar/${name}; };
        })
        names
      )
    );

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

    systemd.user.services = {
      waybar-profile = {
        Unit = {
          Description = "set up window manager config for waybar";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Install = {
          WantedBy = [ "graphical-session.target" "waybar.service" ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = with pkgs; "${writeShellScript "waybar-wm" ''
            set -eux
            cd "${config.home.homeDirectory}/.config/waybar/"

            wm_file="wm/$XDG_SESSION_DESKTOP.jsonc"
            wm_target="wm.jsonc"

            if [ -e "$wm_file" ]; then
              ${coreutils}/bin/ln -sf "$wm_file" "$wm_target"
            elif [ -e "$wm_target" ]; then
              rm "$wm_target"
            fi
          ''}";
        };
      };
    };
  };
}
