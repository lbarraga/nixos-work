{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: let
    niriBar = inputs.wrapper-modules.wrappers.quickshell.wrap {
      inherit pkgs;
      configDir = ./quickshell;
    };
  in {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      "config.kdl".content = builtins.readFile ./config.kdl;
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
