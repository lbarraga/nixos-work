{ config, inputs, ... }: {
  flake.nixosConfigurations.vic = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      base
      locale
      user
      ssh
      mdns-publish
      zsh
      cli-tools
      netbird
      home-assistant

      inputs.disko.nixosModules.disko
      ./_disko.nix
      ./_hardware-configuration.nix
      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "vic";
        system.stateVersion = "26.05";

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        networking.firewall.enable = true;
      }
    ];
  };
}
