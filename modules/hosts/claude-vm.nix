{ config, inputs, ... }: {
  flake.nixosConfigurations.claude-vm = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      base
      locale
      network
      user
      claude-code
      cli-tools
      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "claude-vm";
        system.stateVersion = "26.05";

        services.openssh = {
          enable = true;
          settings.PasswordAuthentication = true;
        };

        virtualisation.vmVariant.virtualisation = {
          memorySize = 4096;
          diskSize = 8192;
          cores = 4;
          forwardPorts = [
            { from = "host"; host.port = 2222; guest.port = 22; }
          ];
        };
      }
    ];
  };

  perSystem = _: {
    packages.claude-vm = config.flake.nixosConfigurations.claude-vm.config.system.build.vm;
  };
}
