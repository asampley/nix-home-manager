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
			# TODO: This will simplify in 2.27
			url = "file:./files/.config/nvim";
			type = "git";
			flake = false;
		};
		awesome-config = {
			# TODO: This will simplify in 2.27
			url = "file:./files/.config/awesome?ref=main?submodules=1";
			type = "git";
			flake = false;
		};
	};

	outputs = { nixpkgs, home-manager, nvim-config, awesome-config, ... }:
		let
			system = "x86_64-linux";
			pkgs = nixpkgs.legacyPackages.${system};
		in {
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
				};
			};
		};
}
