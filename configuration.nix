# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable experimental Nix features for flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix = {
    settings = {
      # Add to the list of substituters (binary caches)
      # It's good to keep the default cache.nixos.org
      substituters = [
        "https://cache.nixos.org/"
        "https://cache.garnix.io/"
        # If you have other substituters already listed, include them here too
      ];

      # Add the corresponding public keys for trusted caches
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "garnix.cache.nixos.org-1:LGgY2n6vlK237n532k33SGCnL9WJ6hkG3Jvh2gGFs7w="
        # If you have other trusted keys already listed, include them here too
      ];

      # Ensure experimental features for flakes are enabled
      # (nix-command is often needed with flakes)
      # Or, if you want to set it definitively and your NixOS version supports it directly:
      # experimental-features = [ "nix-command" "flakes" ];
      # The mkForce line above merges with existing ones, which can be safer if other modules set some.
      # If experimental-features isn't already a list in your NixOS version's nix.settings,
      # you might need to use nix.extraOptions like:
      # extraOptions = ''
      #   experimental-features = nix-command flakes
      # '';
      # But the nix.settings.experimental-features list is the modern way.
    };
  };
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thinkpadx1c6"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Budapest";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "hu_HU.UTF-8";
    LC_IDENTIFICATION = "hu_HU.UTF-8";
    LC_MEASUREMENT = "hu_HU.UTF-8";
    LC_MONETARY = "hu_HU.UTF-8";
    LC_NAME = "hu_HU.UTF-8";
    LC_NUMERIC = "hu_HU.UTF-8";
    LC_PAPER = "hu_HU.UTF-8";
    LC_TELEPHONE = "hu_HU.UTF-8";
    LC_TIME = "hu_HU.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.xserver.enable = true;
  programs.xwayland.enable = true;
  console.keyMap = "us";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.krascsi = {
    isNormalUser = true;
    description = "krascsi";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.nushell;
    packages = with pkgs; [];
  };

  # programs.niri.enable = true;
  programs.sway.enable = true;
  # Enable automatic login for the user.
  # services.getty.autologinUser = "krascsi";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    nushell
    git
    helix
    greetd.tuigreet  # For the text-based login screen
    alacritty
    brave
    nil
  ];


  # languages = { ... }; // For language server configurations
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.greetd = {
    enable = true;
    # vt = 1; # You can specify a Virtual Terminal, but default is usually fine.
    settings = {
      default_session = {
        # This command launches tuigreet (a TTY-based greeter).
        # After you log in, tuigreet will start the 'niri' session.
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd sway";
      };
    };
  };
  services.tlp.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
