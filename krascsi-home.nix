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
    # To ensure direnv hook is sourced by Nushell:
    # The programs.direnv.enableNushellIntegration = true; should handle this,
    # but if not, you might need to manually add to extraConfig:
    # extraConfig = ''
    #   source ${pkgs.direnv}/share/direnv/direnv.nu
    # '';
    # However, the Home Manager option is preferred.
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
    # Consider adding other git settings here, e.g., default branch name, editor, etc.
    # extraConfig = {
    #   init.defaultBranch = "main";
    #   core.editor = "hx"; # If you want to set Helix as git's editor
    # };
  };

  # Your user-specific packages
  home.packages = with pkgs; [
    # starship was here, but programs.starship.enable = true already installs it.
    
    # Developer utility tools
    nix-tree # Utility to visualize Nix derivation trees
    # ripgrep # Fast grep alternative
    # fd # Simple and fast alternative to find

    # Fonts - very important for a good terminal and UI experience
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    noto-fonts # Comprehensive font family for general UI and web content
    # liberation_ttf # Another good set of common fonts
    # dejavu_fonts

    # For your interest in functional programming languages:
    # These are better managed per-project via devShells in those projects' flakes.
    # However, if you want global access to compilers/interpreters for quick experiments:
    # ghcMinimal # Minimal Haskell compiler
    # cabal-install # Haskell build tool
    # ocaml # OCaml compiler
    # opam # OCaml package manager
    # lean4 # Lean 4 theorem prover (might be available as lean or lean-bin; check nix search)
    # rustup # For managing Rust toolchains (though Rust is also excellent with project-local flakes)
  ];

  # Example: Configuring SSH client
  # programs.ssh = {
  #   enable = true;
  #   # addKeysToAgent = "yes";
  #   # knownHosts = { ... };
  #   # matchBlocks = {
  #   #   "my-server" = {
  #   #     hostname = "192.168.1.100";
  #   #     user = "myuser";
  #   #     # SOCKS proxy for this host via another host
  #   #     # dynamicForward = "1080";
  #   #   };
  #   # };
  # };

  # If you use GnuPG
  # programs.gpg.enable = true;
  # services.gpg-agent = {
  #   enable = true;
  #   enableSshSupport = true; # If you want gpg-agent to also act as an ssh-agent
  #   # defaultCacheTtl = 1800;
  #   # maxCacheTtl = 7200;
  # };

  # Set Helix as the default editor via environment variables
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  # You can also manage Helix configuration declaratively if you wish:
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
