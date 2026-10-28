{ inputs, ... }: {
  perSystem =
    { pkgs, config, ... }:
    let
      niriBar = inputs.wrapper-modules.wrappers.quickshell.wrap {
        inherit pkgs;
        configDir = ./quickshell;

        # SysInfo reads /proc directly for everything except free disk space,
        # which has no /proc equivalent, so it shells out to df.
        runtimePkgs = [ pkgs.coreutils ];
      };
    in
    {
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
          config.packages.swayidle
          {
            data = niriBar;
            prefix = true;
          }
        ];
      };
      packages.default = config.packages.niri;
    };
}
