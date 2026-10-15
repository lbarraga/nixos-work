{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: let
    # The wallpaper sits in ./quickshell beside the QML that loads it, so the
    # directory goes to the wrapper as-is. Committed rather than fetched: 500K,
    # and it means the desktop builds offline.
    niriBar = inputs.wrapper-modules.wrappers.quickshell.wrap {
      inherit pkgs;
      configDir = ./quickshell;
    };
  in {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      "config.kdl".path = ./config.kdl;
      runtimePkgs = [
        config.packages.foot
        config.packages.fuzzel
        pkgs.xwayland-satellite
        pkgs.playerctl
        pkgs.brightnessctl
        pkgs.procps
        config.packages.hyprlock
        {
          data = niriBar;
          prefix = true;
        }
      ];
    };
    packages.default = config.packages.niri;
  };
}
