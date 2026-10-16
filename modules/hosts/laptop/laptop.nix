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

      ({lib, ...}: {
        virtualisation.vmVariant = {
          disko.enableConfig = lib.mkForce false;

          # Nothing to manage: no battery, no thermal envelope.
          services.tlp.enable = lib.mkForce false;
          services.thermald.enable = lib.mkForce false;

          virtualisation = {
            memorySize = 8192;
            cores = 4;
            diskSize = 32768;

            # `-vga none` is the load-bearing line. Without it qemu keeps its
            # default std VGA as well, so the guest boots with two DRM cards:
            # virtio-gpu, and bochs-drm at PCI 00:02.0. bochs-drm is the boot
            # VGA and so the primary device, niri picks it, and having no
            # render node it hangs with the window already up -- which looks
            # exactly like a frozen VM.
            #
            # The GPU itself is needed because qemu-vm.nix attaches one on
            # aarch64 only, and the x86 default has no 3D at all.
            qemu.options = [
              "-vga none"
              "-device virtio-gpu-gl-pci,xres=1920,yres=1080"
              "-display gtk,gl=on"
            ];
          };
        };
      })
    ];
  };

  perSystem = _: {
    packages.laptop-vm = config.flake.nixosConfigurations.laptop.config.system.build.vm;
  };
}
