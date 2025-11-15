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

  config = lib.mkIf config.my.wayland.enable (
    let
      monitors-power = (
        pkgs.writeShellScript "monitors-power" (builtins.readFile ../scripts/wayland/monitors-power)
      );
    in
    {
      xdg.configFile = {
        "niri".source = ../files/.config/niri;

        # Generated from stylix
        "waybar/stylix.css".text = ''
          * {
              font-family: "${config.stylix.fonts.monospace.name}";
              font-size: ${toString config.stylix.fonts.sizes.desktop}pt;
          }

        ''
        + lib.strings.concatMapStrings (
          key: "@define-color base0${key} #${config.lib.stylix.colors."base0${key}"};\n"
        ) (builtins.genList (i: lib.toHexString i) 16);
      }
      // (
        let
          entries = builtins.readDir ../files/.config/waybar;
          names = builtins.attrNames entries;
        in
        builtins.listToAttrs (
          map (name: {
            name = "waybar/${name}";
            value = {
              source = ../files/.config/waybar/${name};
            };
          }) names
        )
      );

      home.packages = with pkgs; [
        (writeShellScriptBin "fuzzel-power-menu" (builtins.readFile ../scripts/wayland/fuzzel-power-menu))
        (writeShellScriptBin "niri-fuzzel-monitor-orientation" (
          builtins.readFile ../scripts/wayland/niri-fuzzel-monitor-orientation
        ))
        brightnessctl
        nerd-fonts.symbols-only
        swaybg
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
      services.swayidle =
        let
          lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
          lockSecs = 900;
          lockNotifySecs = 30;
        in
        {
          enable = true;
          extraArgs = [
            "-d"
          ];
          timeouts = [
            {
              timeout = lockSecs - lockNotifySecs;
              command = "${pkgs.libnotify}/bin/notify-send 'Locking in ${toString lockNotifySecs} seconds' -t ${toString lockNotifySecs}000";
            }
            {
              timeout = lockSecs;
              command = lock;
            }
            {
              timeout = lockSecs + 5;
              command = "${monitors-power} off";
              resumeCommand = "${monitors-power} on";
            }
          ];
          events = [
            {
              event = "before-sleep";
              command = "${monitors-power} off; ${lock}";
            }
            {
              event = "lock";
              command = "${monitors-power} off; ${lock}";
            }
            {
              event = "after-resume";
              command = "${monitors-power} on";
            }
            {
              event = "unlock";
              command = "${monitors-power} on";
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
            WantedBy = [
              "graphical-session.target"
              "waybar.service"
            ];
          };

          Service = {
            Type = "oneshot";
            ExecStart =
              with pkgs;
              "${writeShellScript "waybar-wm" ''
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

        swaybg = {
          Unit = {
            Description = "set background";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
            ConditionEnvironment = "WAYLAND_DISPLAY";
          };

          Install = {
            WantedBy = [ "graphical-session.target" ];
          };

          Service = {
            ExecStart = with pkgs; "${swaybg}/bin/swaybg -i ${config.stylix.image}";
          };
        };
      };
    }
  );
}
