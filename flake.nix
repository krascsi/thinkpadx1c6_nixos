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
          ./hardware-configuration.nix

          # Import your main configuration file
          ./configuration.nix

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
        ];
      };
    };

    # --- Default Development Shell ---
    # This provides a development environment when you run `nix develop`
    # in the directory containing this flake.nix.
    # You can add tools here that are useful for working on your NixOS config
    # or general development tasks.
    devShells."x86_64-linux".default = nixpkgs.legacyPackages."x86_64-linux".mkShell {
      # pkgs are the packages from the nixpkgs input corresponding to the system architecture
      # In this case, it's nixpkgs.legacyPackages."x86_64-linux"
      # You can also directly use `nixpkgs.legacyPackages.${system}` if you iterate over systems.
      # For a single system flake like this, direct reference is fine.

      name = "nixos-config-devshell";

      # Packages available in this dev shell
      packages = with nixpkgs.legacyPackages."x86_64-linux"; [
        git # Already in systemPackages, but good to have in a devShell too
        helix # Your preferred editor
        nixpkgs-fmt # For formatting .nix files
        
        # Add other general development tools here if you like
        # e.g., ripgrep, fd, etc.
      ];

      # Environment variables or shell hooks can be set here
      # shellHook = ''
      #   echo "Entered NixOS configuration dev shell."
      #   export MY_VARIABLE="hello from devshell"
      # '';
    };
  };
}
