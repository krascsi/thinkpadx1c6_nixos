# /etc/nixos/flake.nix
{
  description = "NixOS configuration for krascsi's ThinkPad X1 Carbon Gen 6";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensures Home Manager uses the same nixpkgs
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: { # Added home-manager here for clarity
    nixosConfigurations = {
      "thinkpadx1c6" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; }; # Allows your modules to access flake inputs
        modules = [
          # Import the hardware configuration
          ./hardware-configuration.nix # Added comma

          # Import your main configuration file
          ./configuration.nix          # Added comma

          # --- Home Manager Integration ---
          # Part 1: The main Home Manager NixOS module
          inputs.home-manager.nixosModules.home-manager 
          
          # Part 2: An anonymous inline NixOS module to configure Home Manager for your user(s)
          { 
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.krascsi = import ./krascsi-home.nix; # Points to your HM config for krascsi
            home-manager.extraSpecialArgs = { inherit inputs; };   # Passes flake inputs to krascsi-home.nix
            home-manager.backupFileExtension = "hm-bak";
          }
          # No comma after this brace if it's the LAST item in the modules list
        ];
      };
    };
  };
}
