{
	description = "Home Manager configuration of asampley";

	inputs = {
		# Specify the source of Home Manager and Nixpkgs.
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nvim-config = {
			type = "git";
			# TODO: This will simplify in 2.27
			url = "file:./files/.config/nvim";
			flake = false;
		};
		awesome-config = {
			type = "git";
			# TODO: This will simplify in 2.27
			url = "file:./files/.config/awesome";
			submodules = true;
			flake = false;
		};
	};

	outputs = { nixpkgs, home-manager, nvim-config, awesome-config, ... }:
		let
			system = "x86_64-linux";
			pkgs = nixpkgs.legacyPackages.${system};
		in rec {
			# Fallback system that assumes no features available
			homeConfigurations."asampley" = home-manager.lib.homeManagerConfiguration {
				inherit pkgs;

				# Specify your home configuration modules here, for example,
				# the path to your home.nix.
				modules = [ ./home.nix ];

				# Optionally use extraSpecialArgs
				# to pass through arguments to home.nix
				extraSpecialArgs = {
					inherit nvim-config;
					inherit awesome-config;
					gui = false;
					x = false;
					wine = false;
				};
			};

			homeConfigurations."asampley@amanda" = home-manager.lib.homeManagerConfiguration {
				inherit pkgs;

				# Specify your home configuration modules here, for example,
				# the path to your home.nix.
				modules = [ ./home.nix ];

				# Optionally use extraSpecialArgs
				# to pass through arguments to home.nix
				extraSpecialArgs = {
					inherit nvim-config;
					inherit awesome-config;
					gui = true;
					x = true;
					wine = true;
				};
			};
		};
}
