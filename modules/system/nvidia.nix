{
  flake.modules.nixos.nvidia = { config, ... }: {
    hardware.graphics.enable = true;

    # Still the way to get the driver loaded, even on a pure Wayland session.
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # sets nvidia-drm.modeset=1, which Wayland compositors require
      modesetting.enable = true;
      nvidiaSettings = true;

      # the open kernel module needs Turing or newer
      open = false;

      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };
}
