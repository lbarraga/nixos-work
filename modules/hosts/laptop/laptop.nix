{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      base
      locale
      network
      user
      audio
      power
      niri
      work-apps
      common-apps
      shell
      fonts
      claude-code
      cli-tools
      notifications
      bluetooth
      printing
      removable-media
      yubikey
      docker

      inputs.disko.nixosModules.disko
      ./_disko.nix
      ./_hardware-configuration.nix
      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "laptop";
        system.stateVersion = "26.05";

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
      }
    ];
  };
}
