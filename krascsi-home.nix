# /etc/nixos/krascsi-home.nix
{ pkgs, config, lib, inputs, ... }:
{
  home.username = "krascsi";
  home.homeDirectory = "/home/krascsi";
  home.stateVersion = "24.11"; # Or your current system.stateVersion

  # Enable Starship prompt
  programs.starship = {
    enable = true;
    # This is crucial for Nushell:
    enableNushellIntegration = true; 
    # You can add custom Starship settings later by creating a starship.toml
    # and pointing to it, or using 'settings = { ... }'.
    # For now, default Starship will be used.
  };

  # Nushell configuration (Home Manager will ensure Starship is initialized)
  programs.nushell = {
    enable = true;
    # Any other Nushell specific settings via Home Manager can go here later
  };

  # Re-add your Git configuration via Home Manager if you like
  programs.git = {
    enable = true;
    userName = "krascsi"; # Or your preferred Git username
    userEmail = "krascsenits.bence@gmail.com"; # Your Git email
  };

  # Add starship to your user's packages
  home.packages = with pkgs; [
    starship
  ];
}
