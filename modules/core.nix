{ ... }: {
  # Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";

  # Networking
  networking.networkmanager.enable = true;
  services.resolved.enable = true;

  # Locale
  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";

  # nix-ld lets you run unpatched binaries (useful on a work machine)
  programs.nix-ld.enable = true;

  # nh: nicer nixos-rebuild wrapper
  programs.nh = {
    enable = true;
    flake = "/home/lukasbt/nix-config";
  };
}
