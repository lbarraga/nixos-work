{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      workstation

      personal-apps
      cad
      brave
      netbird

      nvidia
      gaming
      mouse-config

      inputs.disko.nixosModules.disko
      ./_disko.nix
      ./_hardware-configuration.nix
      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "desktop";
        system.stateVersion = "26.05";

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
      }
    ];
  };
}
