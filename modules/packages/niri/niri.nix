{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: let
    # The wallpaper lives in ./quickshell next to the QML that loads it, so the
    # whole directory can be handed to the wrapper as-is. It is committed
    # rather than fetched: at 500K it is small enough not to bloat the repo,
    # and a local file means the desktop builds without network access.
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
