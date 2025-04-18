{ config, pkgs, nvim-config, awesome-config, ... }:

{
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

		# x packages
		awesome
		bitwarden
		dconf
		dex
		discord
		firefox
		kdePackages.kdenlive
		kitty
		vlc
		(wineWowPackages.full.override {
			wineRelease = "staging";
			mingwSupport = true;
		})
		winetricks

		# terminal packages
		git
		glibcLocales
		keychain
		neovim
		openssh
		ripgrep
		unzip
	];

	nixpkgs.config.allowUnfreePredicate = pkg:
		builtins.elem (pkgs.lib.getName pkg) [
			"discord"
		];

	# Home Manager is pretty good at managing dotfiles. The primary way to manage
	# plain files is through 'home.file'.
	home.file = {
		# # Building this configuration will create a copy of 'dotfiles/screenrc' in
		# # the Nix store. Activating the configuration will then make '~/.screenrc' a
		# # symlink to the Nix store copy.
		# ".screenrc".source = dotfiles/screenrc;

		# # You can also set the file content immediately.
		# ".gradle/gradle.properties".text = ''
		#   org.gradle.console=verbose
		#   org.gradle.daemon.idletimeout=3600000
		# '';

		".profile".text = (builtins.readFile files/.profile) + ''
			. $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
		'';
		".bashrc".source = files/.bashrc;
		".bash_profile".source = files/.bash_profile;
		".bash_logout".source = files/.bash_logout;
		".xsession".source = files/.xsession;
		".xinitrc".source = files/.xinitrc;
		".editorconfig".source = files/.editorconfig;
		".config/awesome" = {
			source = awesome-config;
			recursive = true;
		};
		".config/nvim" = {
			source = nvim-config;
			recursive = true;
		};
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

	gtk = {
		enable = true;
		theme = {
			package = pkgs.rose-pine-gtk-theme;
			name = "rose-pine";
		};
		iconTheme = {
			package = pkgs.rose-pine-icon-theme;
			name = "rose-pine";
		};
	};

	# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;

	programs.obs-studio = {
		enable = true;
		plugins = [
			pkgs.obs-studio-plugins.obs-pipewire-audio-capture
		];
	};
}
