{ config, pkgs, nvim-config, awesome-config, gui, x, wine, ... }:

rec {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "asampley";
  home.homeDirectory = "/home/asampley";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.bash-prompt-prefix = "nix-env:";

  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 30d";
    persistent = true;
    randomizedDelaySec = "45min";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # terminal packages
    git
    glibcLocales
    keychain
    neovim
    (openssh.override { withKerberos = true; })
    ripgrep
    unzip
  ] ++ pkgs.lib.optionals x [
    awesome
    scrot
    xclip
  ] ++ pkgs.lib.optionals gui [
    # x packages
    bitwarden
    dconf
    dex
    discord
    firefox
    kdePackages.kdenlive
    kitty
    libreoffice
    vlc
  ] ++ pkgs.lib.optionals wine [
    (wineWowPackages.full.override {
      wineRelease = "staging";
      mingwSupport = true;
    })
    winetricks
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "discord"
    ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".profile".text = (builtins.readFile files/.profile) + ''
      . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
    '';
    ".bashrc".source = files/.bashrc;
    ".bash_profile".source = files/.bash_profile;
    ".bash_logout".source = files/.bash_logout;
    ".editorconfig".source = files/.editorconfig;

    ".xsession" = {
      enable = x;
      source = files/.xsession;
    };
    ".xinitrc" = {
      enable = x;
      source = files/.xinitrc;
    };

    # Link to repository in home-manager for easy changes and testing as it's already stored in its own repo
    # Though this does disable rollbacks, they can be done with git easily enough
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink (home.homeDirectory + "/.config/home-manager/files/.config/nvim");
    ".config/awesome" = {
      enable = x;
      source = config.lib.file.mkOutOfStoreSymlink (home.homeDirectory + "/.config/home-manager/files/.config/awesome");
    };
  };

  gtk = {
    enable = gui;
    theme = {
      package = pkgs.rose-pine-gtk-theme;
      name = "rose-pine";
    };
    iconTheme = {
      package = pkgs.rose-pine-icon-theme;
      name = "rose-pine";
    };
  };

  programs.obs-studio = {
    enable = gui;
    plugins = [
      pkgs.obs-studio-plugins.obs-pipewire-audio-capture
    ];
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/asampley/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
