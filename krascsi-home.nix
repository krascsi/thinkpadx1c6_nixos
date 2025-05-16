# /etc/nixos/krascsi-home.nix
{ pkgs, config, lib, inputs, ... }:

let
  # For convenience if you want to use unstable packages from the flake input
  # for some home-manager packages, while your pkgs might be from a stable channel
  # if you were to change nixpkgs input for home-manager specifically.
  # In your current setup, pkgs from the function arguments and inputs.nixpkgs.legacyPackages."x86_64-linux"
  # should be the same (nixos-unstable).
  unstablePkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
in
{
  home.username = "krascsi";
  home.homeDirectory = "/home/krascsi";
  home.stateVersion = "24.11"; # Or your current system.stateVersion

  # Enable Starship prompt
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    # settings = { ... }; # Your custom starship.toml settings can go here
  };

  # Nushell configuration
  programs.nushell = {
    enable = true;
    # ...
  };

  # Direnv for automatic environment switching
  programs.direnv = {
    enable = true;
    enableNushellIntegration = true; # Essential for Nushell
    nix-direnv.enable = true;      # Enables `use_flake` and other nix integration in .envrc files
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "krascsi";
    userEmail = "krascsenits.bence@gmail.com";
    # ...
  };

  # Your user-specific packages
  home.packages = with pkgs; [
    nix-tree
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    noto-fonts
    # Add i3status here if you prefer, but programs.i3status.enable = true will also install it.
  ];

  # --- i3status Configuration ---
  # In /etc/nixos/krascsi-home.nix
  programs.i3status = {
    enable = true;
    enableDefault = true; 
  };
  # --- Sway Configuration ---
  wayland.windowManager.sway = {
    enable = true;
    # package = null; # If programs.sway.enable = true is in configuration.nix

    config = {
      # modifier = "Mod4";
      # terminal = "${pkgs.alacritty}/bin/alacritty";

      bars = [{
        # id = "bar-0";
        # mode = "dock";
        # position = "bottom";

        # --- CORRECTED STATUSCOMMAND BELOW ---
        statusCommand = "${pkgs.i3status}/bin/i3status"; # Reverted to string path
        fonts = [ "pango:JetBrainsMono Nerd Font 10" ];   # This should still be correct

        # colors = {
        #   background = "#2E3440"; 
        #   statusline = "#D8DEE9"; 
        #   # ... etc ...
        # };
      }];
      # ... other Sway config options ...
    };
    # extraConfig = ''
    # '';
  };    
  # Set Helix as the default editor via environment variables
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "yellowed";
      editor = {
        lsp.display-messages = true;
      };
    };
    # languages = { ... }; // For language server configurations
  };

  # Allow Home Manager to manage itself and other user services
  systemd.user.services.hm-reload = {
    Unit = {
      Description = "Reload Home Manager configuration";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.home-manager}/bin/home-manager switch --flake /etc/nixos#krascsi"; # Adjust path if your flake is elsewhere
    };
    Install = {
      WantedBy = [ "graphical-session.target" ]; # Or multi-user.target if preferred
    };
  };
}
